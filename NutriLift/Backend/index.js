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

/*bcrypt youtube video
https://youtu.be/AzA_LTDoFqY?si=W2SVbxsXv7QGCF-P
 */
const bcrypt = require('bcryptjs');
const saltRounds = 10; // Number of hashing rounds

app.post('/signup', async (req, res) => {
    const { firstName, lastName, email, username, password, confirmPassword } = req.body;

    if (!firstName || !lastName || !email || !username || !password || !confirmPassword) {
        return res.status(400).json({ error: "All fields are required" });
    }

    // Check if passwords match
    if (password !== confirmPassword) {
        return res.status(400).json({
            error: "Passwords do not match",
            field: "password"
        });
    }

    try {
        console.log("Checking if username or email exists...");

        // Check if username already exists
        const usernameCheck = await db.query('SELECT * FROM users WHERE username = $1', [username]);
        if (usernameCheck.rows.length > 0) {
            console.log("Username already taken:", username);
            return res.status(400).json({
                error: "Username already exists",
                field: "username"
            });
        }

        // Check if email already exists
        const emailCheck = await db.query('SELECT * FROM users WHERE email = $1', [email]);
        if (emailCheck.rows.length > 0) {
            console.log("Email already in use:", email);
            return res.status(400).json({
                error: "Email already in use",
                field: "email"
            });
        }

        console.log("Username and email are unique. Proceeding with signup...");

        // Hash password before storing it
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        // Save user to database
        const result = await db.query(
            'INSERT INTO users (first_name, last_name, email, username, pass) VALUES ($1, $2, $3, $4, $5) RETURNING *',
            [firstName, lastName, email, username, hashedPassword]
        );

        console.log("User created successfully:", result.rows[0]);

        return res.status(201).json({
            message: "User created successfully",
            user: result.rows[0]
        });

    } catch (error) {
        console.error("Signup error:", error);
        return res.status(500).json({ error: "Database error" });
    }
});

// Check if username is taken
app.get("/check-username", async (req, res) => {
    try {
        const { value } = req.query;
        if (!value) {
            return res.status(400).json({ available: false, error: "Username is required" });
        }

        const result = await db.query("SELECT COUNT(*) FROM users WHERE username = $1", [value]);
        const isAvailable = result.rows[0].count == "0"; // If count is 0, username is available

        console.log(`Checking username: "${value}" - Available: ${isAvailable}`); // 🔹 Logs check

        return res.json({ available: isAvailable });
    } catch (error) {
        console.error("Username check error:", error);
        return res.status(500).json({ available: false, error: "Database error" });
    }
});

// Check if email is taken
app.get("/check-email", async (req, res) => {
    try {
        const { value } = req.query;
        if (!value) {
            return res.status(400).json({ available: false, error: "Email is required" });
        }

        const result = await db.query("SELECT COUNT(*) FROM users WHERE email = $1", [value]);
        const isAvailable = result.rows[0].count == "0"; // If count is 0, email is available

        console.log(`Checking email: "${value}" - Available: ${isAvailable}`); //Logs check

        return res.json({ available: isAvailable });
    } catch (error) {
        console.error("Email check error:", error);
        return res.status(500).json({ available: false, error: "Database error" });
    }
});


// Check if email is taken
app.get("/check-email", async (req, res) => {
    try {
        const { value } = req.query;
        if (!value) {
            return res.status(400).json({ available: false, error: "Email is required" });
        }

        const result = await db.query("SELECT COUNT(*) FROM users WHERE email = $1", [value]);
        const isAvailable = result.rows[0].count == "0"; // If count is 0, email is available

        return res.json({ available: isAvailable });
    } catch (error) {
        console.error("Email check error:", error);
        return res.status(500).json({ available: false, error: "Database error" });
    }
});


app.listen(3000, () => {
    console.log(`Server running on http://localhost:3000/`);
})
