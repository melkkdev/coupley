const { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } =
  require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { getAuth } = require('firebase-admin/auth');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineString } = require('firebase-functions/params');
const { randomBytes } = require('crypto');

const REGION = 'asia-northeast3';

initializeApp();

// 카카오 개발자 콘솔 > 내 애플리케이션 > 앱 ID (숫자). 배포 시 입력하거나 functions/.env 에 KAKAO_APP_ID=... 로 지정
const KAKAO_APP_ID = defineString('KAKAO_APP_ID');

// 커플 중 파트너의 FCM 토큰 조회
async function getPartnerToken(coupleId, senderUserId) {
  const db = getFirestore();

  const coupleDoc = await db.collection('couples').doc(coupleId).get();
  if (!coupleDoc.exists) return null;

  const members = coupleDoc.data().members || [];
  const partnerId = members.find((id) => id !== senderUserId);
  if (!partnerId) return null;

  const partnerDoc = await db.collection('users').doc(partnerId).get();
  return partnerDoc.data()?.fcmToken || null;
}

// userId로 userName 조회
async function getUserName(userId) {
  const db = getFirestore();
  const userDoc = await db.collection('users').doc(userId).get();
  return userDoc.data()?.userName || '파트너';
}

// FCM 전송 헬퍼
async function sendPush(token, title, body) {
  try {
    await getMessaging().send({ token, notification: { title, body } });
  } catch (e) {
    // 토큰 만료/무효화 시 조용히 무시
    console.error('FCM send error:', e.message);
  }
}

// 커플 일정 추가 → 파트너에게 알림
exports.onEventCreated = onDocumentCreated({ document: 'events/{eventId}', region: REGION }, async (event) => {
  const data = event.data.data();
  if (!data.coupleId) return; // 개인 일정은 알림 없음

  const token = await getPartnerToken(data.coupleId, data.userId);
  if (!token) return;

  const senderName = await getUserName(data.userId);
  await sendPush(token, '새 커플 일정 ❤️', `${senderName}님이 "${data.title}" 일정을 추가했어요`);
});

// 커플 일정 수정 → 파트너에게 알림
exports.onEventUpdated = onDocumentUpdated({ document: 'events/{eventId}', region: REGION }, async (event) => {
  const after = event.data.after.data();
  if (!after.coupleId) return;

  // 본인이 수정한 경우만 알림 (updatedAt 변경 확인)
  const before = event.data.before.data();
  if (before.updatedAt?.isEqual(after.updatedAt)) return;

  const token = await getPartnerToken(after.coupleId, after.userId);
  if (!token) return;

  const senderName = await getUserName(after.userId);
  await sendPush(token, '커플 일정 수정', `${senderName}님이 "${after.title}" 일정을 수정했어요`);
});

// 커플 일정 삭제 → 파트너에게 알림
exports.onEventDeleted = onDocumentDeleted({ document: 'events/{eventId}', region: REGION }, async (event) => {
  const data = event.data.data();
  if (!data.coupleId) return;

  const token = await getPartnerToken(data.coupleId, data.userId);
  if (!token) return;

  await sendPush(token, '커플 일정 삭제', `"${data.title}" 일정이 삭제됐어요`);
});

// ─────────────────────────────────────────────
// 카카오 로그인 → Firebase Custom Token 발급
// ─────────────────────────────────────────────
// 클라이언트가 보낸 카카오 액세스 토큰을 카카오 서버에 직접 검증한 뒤
// Firebase Custom Token 을 발급한다. 토큰이 우리 앱에서 발급된 것인지(app_id)도 확인.
exports.kakaoLogin = onCall({ region: REGION }, async (request) => {
  const accessToken = request.data?.accessToken;
  if (typeof accessToken !== 'string' || accessToken.length === 0) {
    throw new HttpsError('invalid-argument', 'accessToken이 필요합니다.');
  }
  const headers = { Authorization: `Bearer ${accessToken}` };

  // 1) 토큰 유효성 + 발급 앱 확인
  const infoRes = await fetch('https://kapi.kakao.com/v1/user/access_token_info', { headers });
  if (!infoRes.ok) {
    throw new HttpsError('unauthenticated', '유효하지 않은 카카오 토큰입니다.');
  }
  const info = await infoRes.json();
  if (String(info.app_id) !== KAKAO_APP_ID.value()) {
    throw new HttpsError('permission-denied', '다른 앱에서 발급된 카카오 토큰입니다.');
  }

  // 2) 사용자 정보 조회
  const meRes = await fetch('https://kapi.kakao.com/v2/user/me', { headers });
  if (!meRes.ok) {
    throw new HttpsError('unauthenticated', '카카오 사용자 정보를 가져오지 못했습니다.');
  }
  const me = await meRes.json();
  const kakaoId = String(me.id);
  const nickname = me.kakao_account?.profile?.nickname || me.properties?.nickname || null;

  const auth = getAuth();
  let uid = `kakao:${kakaoId}`;

  // 3) 기존 합성 이메일 계정(kakao_{id}@coupley.kakao)이 있으면 그 uid를 그대로 사용해
  //    커플·일정 데이터를 유지하고, 추측 가능한 비밀번호는 무작위 값으로 바꿔 무력화한다.
  try {
    const legacy = await auth.getUserByEmail(`kakao_${kakaoId}@coupley.kakao`);
    uid = legacy.uid;
    if (!legacy.customClaims?.kakaoMigrated) {
      await auth.updateUser(uid, { password: randomBytes(32).toString('hex') });
      await auth.setCustomUserClaims(uid, { ...(legacy.customClaims || {}), kakaoMigrated: true });
    }
  } catch (e) {
    if (e.code !== 'auth/user-not-found') throw e;
    // 4) 신규 사용자면 Auth 계정 생성 (닉네임은 클라이언트에서 없으면 랜덤 생성)
    try {
      await auth.getUser(uid);
    } catch (e2) {
      if (e2.code !== 'auth/user-not-found') throw e2;
      await auth.createUser({ uid, ...(nickname ? { displayName: nickname } : {}) });
    }
  }

  const token = await auth.createCustomToken(uid, { provider: 'kakao' });
  return { token };
});
