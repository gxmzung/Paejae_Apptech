/**
 * 배재대 이메일 인증 서버 (OTP)
 * --------------------------------
 * POST /auth/send   { email }
 * POST /auth/verify { email, code }
 *
 * 실행:
 * MAIL_USER=이메일 MAIL_PASS=앱비번 node index.js
 */

import express from 'express';
import cors from 'cors';
import nodemailer from 'nodemailer';
import crypto from 'crypto';

const app = express();
app.use(cors());
app.use(express.json());

// ===============================
// 설정
// ===============================
const PORT = 8080;
const OTP_EXPIRE_MIN = 10; // 10분
const ALLOWED_DOMAIN = '@pcu.ac.kr';

// ===============================
// OTP 저장소 (MVP: 메모리)
// email -> { hash, expiresAt }
// ===============================
const otpStore = new Map();

// ===============================
// 유틸
// ===============================
function genCode() {
return Math.floor(100000 + Math.random() * 900000).toString(); // 6자리
}

function sha256(v) {
return crypto.createHash('sha256').update(v).digest('hex');
}

// ===============================
// 메일 트랜스포터
// ===============================
const transporter = nodemailer.createTransport({
service: 'gmail',
auth: {
user: process.env.MAIL_USER, // ex) your@gmail.com
pass: process.env.MAIL_PASS, // Gmail 앱 비밀번호
},
});

// ===============================
// 라우트: OTP 발송
// ===============================
app.post('/auth/send', async (req, res) => {
try {
const { email } = req.body || {};

if (!email || typeof email !== 'string') {
return res.status(400).json({ ok: false, msg: 'email required' });
}

if (!email.endsWith(ALLOWED_DOMAIN)) {
return res.status(400).json({
ok: false,
msg: 'pcu email only',
});
}

const code = genCode();
const expiresAt = Date.now() + OTP_EXPIRE_MIN * 60 * 1000;

otpStore.set(email, {
hash: sha256(code),
expiresAt,
});

await transporter.sendMail({
from: process.env.MAIL_USER,
to: email,
subject: '[배재대 앱] 이메일 인증 코드',
text: `
배재대학교 앱 이메일 인증 코드입니다.

인증 코드: ${code}
유효 시간: ${OTP_EXPIRE_MIN}분

본인이 요청하지 않았다면 이 메일을 무시하세요.
`.trim(),
});

return res.json({ ok: true });
} catch (err) {
console.error('SEND OTP ERROR:', err);
return res.status(500).json({ ok: false, msg: 'mail send failed' });
}
});

// ===============================
// 라우트: OTP 검증
// ===============================
app.post('/auth/verify', (req, res) => {
const { email, code } = req.body || {};

if (!email || !code) {
return res.status(400).json({ ok: false, msg: 'bad request' });
}

const row = otpStore.get(email);
if (!row) {
return res.status(400).json({ ok: false, msg: 'no otp' });
}

if (Date.now() > row.expiresAt) {
otpStore.delete(email);
return res.status(400).json({ ok: false, msg: 'expired' });
}

if (sha256(code) !== row.hash) {
return res.status(400).json({ ok: false, msg: 'invalid code' });
}

// 인증 성공 → OTP 제거
otpStore.delete(email);

/**
 * 여기서 실제 서비스라면:
 * - 유저 계정 생성
 * - JWT 발급
 * - Firebase Custom Token 발급
 * 같은 걸 하면 됨
 */

return res.json({ ok: true });
});

// ===============================
// 서버 시작
// ===============================
app.listen(PORT, () => {
console.log(`✅ OTP Server running on http://localhost:${PORT}`);
});