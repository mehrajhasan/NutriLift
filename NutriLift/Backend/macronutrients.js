const express = require("express");
const router = express.Router();
const pool = require("./db");
const axios = require("axios");
const apiKey = process.env.USDA_API_KEY;


// Getting all meals for a user
router.get("/macros/:user_id", async (req, res) => {
    try {
        const { user_id } = req.params;
        const result = await pool.query(
            "SELECT * FROM macros WHERE user_id = $1 ORDER BY created_at DESC",
            [user_id]
        );
        // Cast strings to numbers for frontend compatibility
        const meals = result.rows.map(meal => ({
            ...meal,
            protein: parseFloat(meal.protein),
            carbs: parseFloat(meal.carbs),
            fats: parseFloat(meal.fats)
        }));

        res.json(meals);
    } catch (err) {
        console.error(err.message);
        res.status(500).send("Server Error");
    }
});

// ADD a new meal
router.post("/macros", async (req, res) => {
    try {
        const { user_id, food_name, serving_size, calories, protein, carbs, fats, meal_type, created_at } = req.body;
        const newMeal = await pool.query(
            "INSERT INTO macros (user_id, food_name, serving_size, calories, protein, carbs, fats, meal_type, created_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *",
            [user_id, food_name, serving_size, calories, protein, carbs, fats, meal_type, created_at]
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

//
router.get("/usda/search/:query", async (req, res) => {
    try {
        const { query } = req.params;

        const response = await axios.get("https://api.nal.usda.gov/fdc/v1/foods/search", {
            params: {
                api_key: apiKey,
                query,
                pageSize: 10 //changing from 5 to 10 to see if it helps with search list having better results
            }
        });

        res.json(response.data.foods);
    } catch (err) {
        console.error("USDA API Error:", err.message);
        res.status(500).send("USDA API Error");
    }
});

module.exports = router;
