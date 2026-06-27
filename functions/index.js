const { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } =
  require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

const REGION = 'asia-northeast3';

initializeApp();

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
