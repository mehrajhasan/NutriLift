const express = require('express');
const cors = require('cors');
require('dotenv').config();

const db = require('./db');

db.connect();

const app = express();
app.get('/', (req, res) => {
    res.send('testing');
});


app.listen(3000, () => {
    console.log(`Server running on http://localhost:3000/`);
})