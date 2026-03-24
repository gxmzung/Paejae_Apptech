const path = require('path');
const Database = require('better-sqlite3');

let db;

function initDb() {
  if (db) return db;
  const file = path.join(__dirname, 'app.db');
  db = new Database(file);

  db.exec(`
    CREATE TABLE IF NOT EXISTS otp (
      email TEXT PRIMARY KEY,
      code_hash TEXT NOT NULL,
      expires_at INTEGER NOT NULL,
      last_sent_at INTEGER NOT NULL,
      sent_count_hour INTEGER NOT NULL,
      hour_bucket INTEGER NOT NULL
    );
  `);

  return db;
}

module.exports = { initDb };