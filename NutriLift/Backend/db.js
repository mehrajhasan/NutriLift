const { Client } = require('pg');
require('dotenv').config();

const db = new Client({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
})

module.exports = db;
