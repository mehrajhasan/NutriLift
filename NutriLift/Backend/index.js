const express = require('express');
require('dotenv').config();
const jwt = require('jsonwebtoken');
const db = require('./db');


const app = express();
app.use(express.json());

// Ensure database connection
db.connect()
    .then(() => console.log("Connected to PostgreSQL"))
    .catch(err => console.error("Database connection error:", err));

app.get('/', async (req, res) => {
    res.send('testing');
});

//macronutrient route
const macronutrientRoutes = require("./macronutrients");
app.use("/api", macronutrientRoutes);


//login function
app.post('/login', async (req, res) => {
    const { username, password } = req.body;

    try {
        const check = await db.query("SELECT * FROM users WHERE username = $1", [username]);

        if (check.rows.length > 0) {
            const user = check.rows[0];
            const storedPass = user.pass;

            // Compare hashed password
            const passwordMatch = await bcrypt.compare(password, storedPass);

            if (passwordMatch) {
                const token = jwt.sign(
                    { username: user.username },
                    process.env.JWT_SECRET,
                    { expiresIn: '24h' }
                );
                res.status(200).json({ message: "Login Successful", token: token });
            } else {
                res.status(400).json({ message: "Incorrect Password" });
            }
        } else {
            res.status(404).json({ message: "User not found" });
        }
    } catch (err) {
        res.status(500).json({ error: "Server error" });
    }
});


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


const bcrypt = require('bcryptjs');
const saltRounds = 10; // Number of hashing rounds

app.post('/signup', async (req, res) => {
    const { firstName, lastName, email, username, password } = req.body;

    if (!firstName || !lastName || !email || !username || !password) {
        return res.status(400).json({ error: "All fields are required" });
    }

    try {
        // Check if username already exists
        const usernameCheck = await db.query('SELECT * FROM users WHERE username = $1', [username]);
        if (usernameCheck.rows.length > 0) {
            return res.status(400).json({ error: "Username already exists" });
        }

        // Check if email already exists
        const emailCheck = await db.query('SELECT * FROM users WHERE email = $1', [email]);
        if (emailCheck.rows.length > 0) {
            return res.status(400).json({ error: "Email already in use" });
        }

        // Hash password before storing it
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        // Save user to database
        const result = await db.query(
            'INSERT INTO users (first_name, last_name, email, username, pass) VALUES ($1, $2, $3, $4, $5) RETURNING *',
            [firstName, lastName, email, username, hashedPassword]
        );

        res.status(201).json({ message: "User created successfully", user: result.rows[0] });
    } catch (error) {
        console.error("Signup error:", error);
        res.status(500).json({ error: "Database error" });
    }
});

app.listen(3000, () => {
    console.log(`Server running on http://localhost:3000/`);
})