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

//login function
app.post('/login', async (req, res) => {
    const { username, password } = req.body;

    try{
        const check = await db.query("SELECT * FROM users WHERE username = $1", [
            username,
        ]);

        if(check.rows.length>0){
            const user = check.rows[0];
            const pass = check.password;

            if(password == pass){
                res.status(200).json({ message: "Login Successful" });
            }
            else{
                res.status(400).json({ message: "Incorrect Password" });
            }
        }
        else{
            res.status(404).json({ message: "User not found" });
        }

    }
    catch(err){
        res.send(err.message);
    }
})

app.listen(3000, () => {
    console.log(`Server running on http://localhost:3000/`);
})