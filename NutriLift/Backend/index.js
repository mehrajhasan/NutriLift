const express = require('express');
require('dotenv').config();
const jwt = require('jsonwebtoken');
const db = require('./db');


const app = express();
app.use(express.json());
const { v4: uuidv4 } = require('uuid'); //run npm install uuid if not building

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
/*
 bcrypt youtube link https://youtu.be/AzA_LTDoFqY?si=YW7JPCKFwlzf0pCA
 */

app.post('/login', async (req, res) => {
    const { username, password } = req.body;
    console.log("-> Login attempt:", username, password);

    try {
        // Fetch user by username
        const check = await db.query("SELECT user_id, username, pass FROM users WHERE username = $1", [username]);

        console.log("-> Database query result:", check.rows); //Debugging

        if (check.rows.length === 0) {
            console.log("User not found.");
            return res.status(404).json({ error: "User not found" });
        }

        const user = check.rows[0];
        const storedPass = user.pass;

        // Compare hashed password
        const passwordMatch = await bcrypt.compare(password, storedPass);

        if (!passwordMatch) {
            console.log("Incorrect password.");
            return res.status(400).json({ error: "Incorrect password" });
        }

        // Generate JWT token including `user_id`
        const token = jwt.sign(
            { user_id: user.user_id, username: user.username }, // Include `user_id`
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );

        console.log("Login successful. User ID:", user.user_id);

        res.status(200).json({
            message: "Login Successful",
            user_id: user.user_id, // Now returning `user_id`
            token: token
        });
    } catch (err) {
        console.error("Login error:", err);
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
/*
 
 
 
 
 
                                        SIGN UP
 
 
 
 
 
 
 */
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

        //necessary to treat the initial signup tables as one creation
        await db.query('BEGIN');

        // Save user to database
        const result = await db.query(
            'INSERT INTO users (first_name, last_name, email, username, pass) VALUES ($1, $2, $3, $4, $5) RETURNING *',
            [firstName, lastName, email, username, hashedPassword]
        );

        console.log("User created successfully:", result.rows[0]);
        const userId = result.rows[0].user_id;

        await db.query(
            'INSERT INTO userprofiles (user_id, profile_pic, points) VALUES ($1, $2, $3)',
            [userId, null, 0]
        );

        //ends
        await db.query('COMMIT');

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
/*
                                       



                                        PROFILE
 
 
 
 
 
 
 */

//EDIT PROFILE ROUTE
app.put('/user/:user_id/update', authenticateToken, async (req,res) => {
    const { user_id } = req.params;
    const { username, first_name, last_name } = req.body; //gets updated info (except pfp for now)

    try{
        //if username change, check if its taken. return 400 if yes
        const result = await db.query('SELECT * FROM users WHERE username = $1 AND user_id != $2', [username, user_id]);
        if (result.rows.length > 0) {
          return res.status(400).json({ error: 'Username already taken' });
        }

        //updating fetched info in users table, does not include pfp yet
        const update = `
            UPDATE users 
            SET username = $1, first_name = $2, last_name = $3 
            WHERE user_id = $4
            RETURNING user_id, username, first_name, last_name;
        `;

        const values = [username, first_name, last_name, user_id];

        const updatedProfile = await db.query(update, values);

        //send back the updated info
        return res.json(updatedProfile.rows[0]);
    }
    catch(err){
        console.log("An error occured.", err);
        return res.status(500).json({ error: "An error occured." })
    }



});



/*
 
                                        WORKOUT
 
 
 
 
 */
// Fetch all exercises
app.get('/api/exercises', async (req, res) => {
    try {
        const result = await db.query("SELECT * FROM exercises");
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server error while fetching exercises" });
    }
});

app.get('/api/routines', authenticateToken, async (req, res) => {
    // Use the user_id from the token instead of a URL parameter.
    const user_id = req.user.user_id;
    console.log("->Fetching routines for user_id from token:", user_id);

    try {
        const result = await db.query(
            "SELECT id, title, exercises, user_id FROM routines WHERE user_id = $1",
            [user_id]
        );

        const routines = result.rows.map(row => ({
            id: row.id,
            title: row.title,
            user_id: row.user_id,  // This is still returned for reference
            exercises: typeof row.exercises === 'string' ? JSON.parse(row.exercises) : row.exercises
        }));

        console.log("->Parsed routines:", routines);
        res.json(routines);
    } catch (err) {
        console.error("Error fetching routines:", err);
        res.status(500).json({ error: "Failed to fetch routines" });
    }
});


app.post('/api/routines', async (req, res) => {
    console.log("Incoming request:", req.body);

    try {
        const { title, exercises, user_id } = req.body; // Include user_id

        if (!title || !exercises || !user_id) {
            return res.status(400).json({ error: "Title, exercises, and user_id are required" });
        }
        
        // Map over exercises to add an id to each exercise if it doesn't already have one
        const exercisesWithIds = exercises.map(ex => ({
            id: ex.id || uuidv4(),
            name: ex.name,
            sets: ex.sets
        }));

        // Use exercisesWithIds when saving the routine
        const result = await db.query(
            "INSERT INTO routines (title, exercises, user_id) VALUES ($1, $2, $3) RETURNING *",
            [title, JSON.stringify(exercisesWithIds), user_id]
        );

        console.log("Routine saved:", JSON.stringify(result.rows[0], null, 2));
        res.json(result.rows[0]);
    } catch (err) {
        console.error("Error saving routine:", err);
        res.status(500).json({ error: "Error saving routine" });
    }
});


/*
 
                                        User Search
 
 
 
 
 */
//search for users
app.get('/search', async (req,res) => {
    const { query } = req.query;

    try{
        const result = await db.query(
            `SELECT 
                u.user_id,
                u.username,
                u.first_name,
                u.last_name,
                up.profile_pic,
                up.points
             FROM 
                Users u
             JOIN 
                UserProfiles up ON u.user_id = up.user_id
             WHERE 
                u.username ILIKE $1 OR 
                u.first_name ILIKE $1 OR 
                u.last_name ILIKE $1`,
            [`%${query}%`]
        );

        res.status(200).json(result.rows);
    }
    catch(err){
        console.error("Error searching users:", err.message);
        res.status(500).json({ error: "Interal server err"});
    }
});






const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

