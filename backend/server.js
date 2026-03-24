const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const path = require("path");

dotenv.config({ path: path.join(__dirname, ".env") });

const { makeAuthRouter } = require("./auth.routes");

const app = express();

const PORT = Number(process.env.PORT || "8080");
const CORS_ORIGIN = process.env.CORS_ORIGIN || "*";

const ALLOWED_DOMAINS = String(process.env.ALLOWED_DOMAINS || "pcu.ac.kr")
  .split(",")
  .map((s) => s.trim().toLowerCase())
  .filter(Boolean);

app.use(express.json({ limit: "1mb" }));
app.use(
  cors({
    origin: CORS_ORIGIN === "*" ? true : CORS_ORIGIN,
    credentials: true,
  })
);

app.get("/health", (req, res) => {
  res.json({ ok: true, ts: Date.now() });
});

app.use("/auth", makeAuthRouter({ allowedDomains: ALLOWED_DOMAINS }));

app.listen(PORT, "0.0.0.0", () => {
  console.log(`✅ listening on :${PORT}`);
  console.log(`✅ health: /health`);
  console.log(`✅ auth: /auth/request-otp , /auth/verify-otp`);
});