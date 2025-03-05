const express = require('express');
const cors = require('cors');
require('dotenv').config();

const db = require('./db');

db.connect();

const app = express();
app.get('/', async (req, res) => {
    res.send('testing');
});

//checking if db connected
app.get('/users', async (req,res) => {
    try{
        const { rows } = await db.query('SELECT * FROM Users');
        res.send(rows);
    }
    catch(err){
        res.send(err.message);
    }
});


app.listen(3000, () => {
    console.log(`Server running on http://localhost:3000/`);
})