// functions/index.js
/*eslint-disable*/
const admin = require('firebase-admin');
const { onSchedule } = require('firebase-functions/v2/scheduler');

// Initialize the default app
admin.initializeApp();

exports.sendChoreNotifications = onSchedule(
  {
    // Run at the top of every hour:
    // i.e. equivalent to "every 1 hours"
    schedule: '0 * * * *',
    // Make sure times match Vancouver, if you care about time zones
    timeZone: 'America/Vancouver',
  },
  async () => {
    const db = admin.firestore();
    const now = new Date();

    // Compute midnight today & tomorrow
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // Decide which window we’re in
    let windowLabel, windowStart;
    const hour = now.getHours();
    if (hour >= 18) {
      windowLabel = 'evening';
      windowStart = today;
    } else if (hour >= 6) {
      windowLabel = 'morning';
      windowStart = today;
    } else {
      windowLabel = 'night-before';
      windowStart = tomorrow;
    }
    const windowEnd = new Date(windowStart);
    windowEnd.setDate(windowStart.getDate() + 1);

    // 1) Find all chores whose nextDueAt ∈ [windowStart, windowEnd)
    const choreSnap = await db
      .collectionGroup('chores')
      .where('nextDueAt', '>=', admin.firestore.Timestamp.fromDate(windowStart))
      .where('nextDueAt', '<', admin.firestore.Timestamp.fromDate(windowEnd))
      .get();

    const sendPromises = [];

    for (const doc of choreSnap.docs) {
      const chore = doc.data();
      const lastNotified = chore.lastNotifiedAt
        ? chore.lastNotifiedAt.toDate()
        : new Date(0);

      // 2) Skip if we already notified in this window
      if (lastNotified >= windowStart) continue;
      if (!chore.assignedTo) continue;

      // 3) Load that user’s tokens
      const tokenSnap = await db
        .collection('users')
        .doc(chore.assignedTo)
        .collection('deviceTokens')
        .get();
      const tokens = tokenSnap.docs.map(d => d.id);
      if (tokens.length === 0) continue;

      // 4) Build notification text
      let title, body;
      if (windowLabel === 'night-before') {
        title = `Tomorrow: ${chore.title}`;
        body = `Don't forget to do "${chore.title}" tomorrow.`;
      } else if (windowLabel === 'morning') {
        title = `Today: ${chore.title}`;
        body = `Time to do "${chore.title}" this morning.`;
      } else {
        title = `Tonight: ${chore.title}`;
        body = `Please finish "${chore.title}" this evening.`;
      }

      const message = {
        tokens,
        notification: { title, body },
        data: { choreId: doc.id, window: windowLabel },
      };

      // 5) Send & mark lastNotifiedAt
      sendPromises.push(
        admin.messaging().sendMulticast(message)
          .then(() =>
            doc.ref.update({
              lastNotifiedAt: admin.firestore.FieldValue.serverTimestamp(),
            })
          )
      );
    }

    await Promise.all(sendPromises);
    return null;
  }
);
