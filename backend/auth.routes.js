     const express = require("express");
     const { sendOtpMail } = require("./mailer");

     function normalizeEmail(email) {
       return String(email || "").trim().toLowerCase();
     }

     function domainOf(email) {
       const i = email.lastIndexOf("@");
       return i < 0 ? "" : email.slice(i + 1).trim().toLowerCase();
     }

     function isSixDigits(s) {
       return /^[0-9]{6}$/.test(String(s || "").trim());
     }

     function generateOtp() {
       return String(Math.floor(100000 + Math.random() * 900000));
     }

     function getPolicy() {
       const OTP_EXPIRES_MIN = Number(process.env.OTP_EXPIRES_MIN || "10") || 10;
       const OTP_RESEND_COOLDOWN_SEC =
         Number(process.env.OTP_RESEND_COOLDOWN_SEC || "45") || 45;
       const OTP_MAX_PER_HOUR = Number(process.env.OTP_MAX_PER_HOUR || "6") || 6;

       return { OTP_EXPIRES_MIN, OTP_RESEND_COOLDOWN_SEC, OTP_MAX_PER_HOUR };
     }

     const otpStore = new Map();

     function makeAuthRouter({ allowedDomains = ["pcu.ac.kr"] } = {}) {
       const router = express.Router();
       const allowed = allowedDomains
         .map((d) => String(d).trim().toLowerCase())
         .filter(Boolean);

       router.post("/request-otp", async (req, res) => {
         try {
           const { OTP_EXPIRES_MIN, OTP_RESEND_COOLDOWN_SEC, OTP_MAX_PER_HOUR } =
             getPolicy();

           const email = normalizeEmail(req.body?.email);

           if (!email || !email.includes("@")) {
             return res
               .status(400)
               .json({ ok: false, message: "이메일 형식이 올바르지 않아." });
           }

           const d = domainOf(email);
           if (!allowed.includes(d)) {
             return res.status(400).json({
               ok: false,
               message: `학교 이메일만 가능해. (@${allowed.join(", @")})`,
             });
           }

           const now = Date.now();
           const cooldownMs = OTP_RESEND_COOLDOWN_SEC * 1000;
           const hourMs = 60 * 60 * 1000;

           const existing = otpStore.get(email);

           if (existing?.lastSentAt && now - existing.lastSentAt < cooldownMs) {
             const remain = Math.ceil(
               (cooldownMs - (now - existing.lastSentAt)) / 1000
             );
             return res
               .status(429)
               .json({ ok: false, message: `너무 빨라! ${remain}초 뒤에 다시 시도해줘.` });
           }

           let windowStart = existing?.sentCountWindowStart ?? now;
           let count = existing?.sentCountInWindow ?? 0;

           if (now - windowStart > hourMs) {
             windowStart = now;
             count = 0;
           }

           if (count >= OTP_MAX_PER_HOUR) {
             return res.status(429).json({
               ok: false,
               message: "요청이 너무 많아. 1시간 뒤에 다시 시도해줘.",
             });
           }

           const code = generateOtp();
           const expiresAt = now + OTP_EXPIRES_MIN * 60 * 1000;

           await sendOtpMail({ to: email, code });

           otpStore.set(email, {
             code,
             expiresAt,
             lastSentAt: now,
             sentCountWindowStart: windowStart,
             sentCountInWindow: count + 1,
           });

           return res.json({ ok: true, message: "인증번호를 보냈어." });
         } catch (e) {
           console.error("[OTP] request-otp failed:");
           console.error(e);
           console.error(e?.stack);

           return res.status(500).json({
             ok: false,
             message: "메일 발송에 실패했어. SMTP 설정을 확인해줘.",
             detail: String(e?.message || e),
           });
         }
       });

       router.post("/verify-otp", async (req, res) => {
         const email = normalizeEmail(req.body?.email);
         const code = String(req.body?.code || "").trim();

         if (!email || !email.includes("@")) {
           return res
             .status(400)
             .json({ ok: false, message: "이메일 형식이 올바르지 않아." });
         }

         if (!isSixDigits(code)) {
           return res
             .status(400)
             .json({ ok: false, message: "인증번호는 6자리 숫자야." });
         }

         const row = otpStore.get(email);
         if (!row) {
           return res.status(400).json({
             ok: false,
             message: "인증 요청 기록이 없어. 먼저 인증번호를 받아줘.",
           });
         }

         if (Date.now() > row.expiresAt) {
           otpStore.delete(email);
           return res
             .status(400)
             .json({ ok: false, message: "인증번호가 만료됐어. 다시 받아줘." });
         }

         if (row.code !== code) {
           return res
             .status(400)
             .json({ ok: false, message: "인증번호가 틀렸어." });
         }

         otpStore.delete(email);
         return res.json({ ok: true, message: "인증 완료!" });
       });

       return router;
     }

     module.exports = { makeAuthRouter };