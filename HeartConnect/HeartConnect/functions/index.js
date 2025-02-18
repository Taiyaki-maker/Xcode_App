const {onRequest} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

// Firebase Admin SDKの初期化
admin.initializeApp();

// 新しい関数の追加
exports.sendPushNotification = onRequest(async (req, res) => {
  const {token, title, body} = req.body;

  const message = {
    token: token,
    notification: {
      title: title,
      body: body,
    },
  };

  try {
    const response = await admin.messaging().send(message);
    res.status(200).send("Successfully sent message: " + response);
  } catch (error) {
    console.error("Error sending message:", error);
    res.status(500).send("Error sending message: " + error);
  }
});
