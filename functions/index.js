const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.deleteExpiredSubscriptions = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
    const firestore = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    const usersSnapshot = await firestore.collection('users').get();

    const batch = firestore.batch();

    usersSnapshot.forEach((userDoc) => {
        const subscriptions = userDoc.data().subscriptions || [];
        const updatedSubscriptions = subscriptions.filter(sub => sub.expiration.toDate() > now.toDate());

        if (updatedSubscriptions.length !== subscriptions.length) {
            const userDocRef = firestore.collection('users').doc(userDoc.id);
            batch.update(userDocRef, { subscriptions: updatedSubscriptions });
        }
    });

    await batch.commit();
    console.log('Deleted expired subscriptions');
});
