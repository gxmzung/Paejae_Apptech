const nodemailer = require("nodemailer");

function must(name) {
  const v = process.env[name];
  if (!v) throw new Error(`ENV ${name} is missing`);
  return v;
}

async function sendOtpMail({ to, code }) {
  const host = must("SMTP_HOST");
  const port = Number(must("SMTP_PORT"));
  const secure =
    String(process.env.SMTP_SECURE || "false").toLowerCase() === "true";
  const user = must("SMTP_USER");
  const pass = must("SMTP_PASS");

  const fromName = process.env.MAIL_FROM_NAME || "배재Pick";
  const fromEmail = process.env.MAIL_FROM_EMAIL || user;

  const transporter = nodemailer.createTransport({
    host,
    port,
    secure,
    auth: { user, pass },
    logger: true,
    debug: true,
  });

  console.log("[SMTP] host =", host);
  console.log("[SMTP] port =", port);
  console.log("[SMTP] secure =", secure);
  console.log("[SMTP] user =", user);
  console.log("[SMTP] from =", `${fromName} <${fromEmail}>`);

  await transporter.verify();
  console.log("[SMTP] verify success");

  const subject = `[배재Pick] 이메일 인증번호: ${code}`;
  const text = `배재Pick 이메일 인증번호는 ${code} 입니다.
(유효시간: ${process.env.OTP_EXPIRES_MIN || 10}분)

본인이 요청하지 않았다면 이 메일을 무시해도 됩니다.`;

  const info = await transporter.sendMail({
    from: `${fromName} <${fromEmail}>`,
    to,
    subject,
    text,
  });

  console.log("[SMTP] send success:", info.messageId);
}

module.exports = { sendOtpMail };