const express = require("express");
const router = express.Router();
const pool = require("./db");

// Getting all meals for a user
router.get("/macros/:user_id", async (req, res) => {
    try {
        const { user_id } = req.params;
        const result = await pool.query(
            "SELECT * FROM macros WHERE user_id = $1 ORDER BY created_at DESC",
            [user_id]
        );
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// ADD a new meal
router.post("/macros", async (req, res) => {
    try {
        const { user_id, food_name, serving_size, calories, protein, carbs, fats } = req.body;
        const newMeal = await pool.query(
            "INSERT INTO macros (user_id, food_name, serving_size, calories, protein, carbs, fats) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *",
            [user_id, food_name, serving_size, calories, protein, carbs, fats]
        );
        res.json(newMeal.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// Deleting a meal entry
router.delete("/macros/:id", async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query("DELETE FROM macros WHERE id = $1", [id]);
        res.json({ message: "Meal deleted successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

module.exports = router;





