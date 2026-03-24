// backend/test_mail.js
require("dotenv").config({ path: __dirname + "/.env" });
const { sendOtpMail } = require("./mailer");

(async () => {
  try {
    const to = process.argv[2];
    if (!to) throw new Error("Usage: node test_mail.js <toEmail>");
    const code = "123456";

    const info = await sendOtpMail({ to, code });
    console.log("OK mail sent. messageId=", info.messageId);
  } catch (e) {
    console.error("FAIL:", e?.message ?? e);
    process.exit(1);
  }
})();