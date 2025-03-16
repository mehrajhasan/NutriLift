const express = require('express');
require('dotenv').config();
const jwt = require('jsonwebtoken');
const db = require('./db');

db.connect();
const app = express();
app.use(express.json());

app.get('/', async (req, res) => {
    res.send('testing');
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
            const storedPass = user.pass;

            console.log(`Password from request:" ${password}`);
            console.log(`Password from database:" ${storedPass}`);


            if(password === storedPass){
                const token = jwt.sign(
                    {
                        username: user.username
                    },
                    process.env.JWT_SECRET,
                    { expiresIn: '24h' }
                );
                res.status(200).json({ message: "Login Successful", token: token });
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


/*
Authentication in SwiftUI App Using JSON Web Token (JWT) by azamsharp
https://www.youtube.com/watch?v=iXG3tVTZt6o
*/
//authenticate teh token
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];

    //"Bearer ..............""
    const token = authHeader && authHeader.split(' ')[1];
    
    //if not there
    if (!token) return res.status(401).json({ message: "Authentication required" });
    
    //if invalid
    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ message: "Invalid or expired token" });
        
        req.user = user;
        next();
    });
};

/*
Authentication in SwiftUI App Using JSON Web Token (JWT) by azamsharp
https://www.youtube.com/watch?v=iXG3tVTZt6o
*/
//for jwt
app.get('/protected', authenticateToken, async (req,res) => {
    res.json({ message: "Success", user: req.user });
})

//fetch user profile info (incomplete)
app.get('/user/:user_id', async (req, res) => {
    const { user_id } = req.params;

    try {
        //join to get first last name from user
        const result = await db.query(
            `SELECT 
                u.user_id,
                u.username,
                u.first_name,
                u.last_name,
                u.email,
                up.profile_pic,
                up.points
             FROM 
                Users u
             JOIN 
                UserProfiles up ON u.user_id = up.user_id
             WHERE 
                u.user_id = $1`,
            [user_id]
        );

        const profile = result.rows[0];
        res.status(200).json(profile);
    }
    catch(err){
        console.log("Error: ", err.message);
    }
})

app.listen(3000, () => {
    console.log(`Server running on http://localhost:3000/`);
})
