import SwiftUI
import Charts

struct SummaryView: View {
    var selectedDate: Date
    var savedMeals: [LoggedMeal]
    @State private var userMacroGoals: MacroGoals? = nil    //To store logged in users macro goals fetched from db
    
    struct MacroGoals: Codable {    //matches JSON structure from backend for macro_goals. use to decode users macro goals from backend JSON
        let proteinGoal: Double
        let carbsGoal: Double
        let fatsGoal: Double
        let caloriesGoal: Double
        
        enum CodingKeys: String, CodingKey {    //key mapping snacke_case JSON keys
            case proteinGoal = "protein_goal"
            case carbsGoal = "carbs_goal"
            case fatsGoal = "fats_goal"
            case caloriesGoal = "calories_goal"
        }
        init(from decoder: Decoder) throws {    //needed to decode since backend was sending numbers as strings
            let container = try decoder.container(keyedBy: CodingKeys.self)
            proteinGoal = Double(try container.decode(String.self, forKey: .proteinGoal)) ?? 0
            carbsGoal = Double(try container.decode(String.self, forKey: .carbsGoal)) ?? 0
            fatsGoal = Double(try container.decode(String.self, forKey: .fatsGoal)) ?? 0
            caloriesGoal = Double(try container.decode(String.self, forKey: .caloriesGoal)) ?? 0
            
        }
    }
    
    func calculateCalories(protein: Double, carbs: Double, fats: Double) -> Double {
        return (protein * 4) + (carbs * 4) + (fats * 9)
    }
    
    func fetchMacroGoals() {    //fetch logged in users macro goals from backend
        guard let userID = UserDefaults.standard.value(forKey: "userId") as? Int else { return }    //getting user ID from the UserDefaults which is stored using @Appstorage during login)
        guard let url = URL(string: "http://localhost:3000/api/macro_goals/\(userID)") else { return }  //creating URL using userID
        URLSession.shared.dataTask(with: url) {data, _, _ in
            if let data = data {    //making GET request
                let decoder = JSONDecoder()
                //decoder.keyDecodingStrategy = .convertFromSnakeCase //converting snake_case JSON to camelCase swift
                
                if let decoded = try? decoder.decode(MacroGoals.self, from: data) {
                    DispatchQueue.main.sync {
                        print("Fetched macro goals: \(decoded)")
                        self.userMacroGoals = decoded
                    }
                } else {
                    print("failed to decode macro goals.")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("raw JSON response:\n\(responseString)")
                    }
                }
            }
        }.resume()
    }
    
    struct MacroGoalRow: View {
        let label: String   //"Protein"
        let goal: Double
        let consumed: Double
        
        var body: some View {
            HStack {
                Text(label)
                    .frame(width: 100, alignment: .leading)
                Spacer()
                
                Text("\(goal, specifier: "%.0f")g") //show the goal value
                    .frame(width: 80, alignment: .trailing)
                Text("\(max(goal - consumed, 0), specifier: "%.0f")g")
                    .frame(width: 80, alignment: .trailing)
            }
        }
    }

    //Filters meals to only show entries for the selected date
    var mealsForSelectedDate: [LoggedMeal] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selectedDateString = formatter.string(from: selectedDate)

        return savedMeals.filter { meal in
            meal.created_at.starts(with: selectedDateString)
        }
    }

    // Calculates protein, carbs, and fat totals for a specific meal type
    func totals(for mealType: String) -> (protein: Double, carbs: Double, fats: Double) {
        let meals = mealsForSelectedDate.filter { $0.meal_type == mealType }
        let protein = meals.reduce(0) { $0 + $1.protein }
        let carbs = meals.reduce(0) { $0 + $1.carbs }
        let fats = meals.reduce(0) { $0 + $1.fats }
        return (protein, carbs, fats)
    }

    // Calculates total macros for the entire day
    var dailyTotals: (protein: Double, carbs: Double, fats: Double) {
        let protein = mealsForSelectedDate.reduce(0) { $0 + $1.protein }
        let carbs = mealsForSelectedDate.reduce(0) { $0 + $1.carbs }
        let fats = mealsForSelectedDate.reduce(0) { $0 + $1.fats }
        return (protein, carbs, fats)
    }
    
    var macroPercentages: [(label: String, value: Double, color: Color)] {  //calculate percentage of each macro based on total
        let total = dailyTotals.protein + dailyTotals.carbs + dailyTotals.fats
        guard total > 0 else { return [] }

        return [
            ("Protein", (dailyTotals.protein / total) * 100, .blue),
            ("Carbs", (dailyTotals.carbs / total) * 100, .green),
            ("Fats", (dailyTotals.fats / total) * 100, .orange)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Macro Summary")
                    .font(.largeTitle)
                    .bold()

                Text("Date: \(dateFormatter.string(from: selectedDate))")
                    .foregroundColor(.gray)

                // Pie Chart for macro percentages
                Chart {
                    ForEach(macroPercentages, id: \.label) { item in
                        SectorMark(
                            angle: .value(item.label, item.value),
                            innerRadius: .ratio(0.3),
                            angularInset: 3
                        )
                        .foregroundStyle(item.color)
                        .annotation(position: .overlay) {
                            Text("\(item.label)\n\(Int(item.value))%")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .frame(height: 250)
                .padding()
                // Table of grouped totals by meal type

                VStack(alignment: .leading, spacing: 15) {
                    //Text("Meal Totals")
                        //.font(.headline)
                    HStack {
                        Text("Meal Totals")
                            .font(.headline)
                            .frame(width: 100, alignment: .leading)

                        Spacer()

                        Text("Protein")
                            .font(.subheadline)
                            .frame(width: 60, alignment: .trailing)

                        Text("Carbs")
                            .font(.subheadline)
                            .frame(width: 60, alignment: .trailing)

                        Text("Fats")
                            .font(.subheadline)
                            .frame(width: 60, alignment: .trailing)
                        
                        Text("Calories")
                            .font(.subheadline)
                            .frame(width: 60, alignment: .trailing)
                    }

                    SummaryRow(
                        label: "Breakfast",
                        totals: totals(for: "Breakfast"),
                        calories: calculateCalories(
                            protein: totals(for: "Breakfast").protein,
                            carbs: totals(for: "Breakfast").carbs,
                            fats: totals(for: "Breakfast").fats
                        )
                    )
                    SummaryRow(
                        label: "Lunch",
                        totals: totals(for: "Lunch"),
                        calories: calculateCalories(
                            protein: totals(for: "Lunch").protein,
                            carbs: totals(for: "Lunch").carbs,
                            fats: totals(for: "Lunch").fats
                        )
                    )
                    SummaryRow(
                        label: "Dinner",
                        totals: totals(for: "Dinner"),
                        calories: calculateCalories(
                            protein: totals(for: "Dinner").protein,
                            carbs: totals(for: "Dinner").carbs,
                            fats: totals(for: "Dinner").fats
                        )
                    )
                    Divider()

                    SummaryRow(
                        label: "Total",
                        totals: dailyTotals,
                        calories: calculateCalories(protein: dailyTotals.protein, carbs: dailyTotals.carbs, fats: dailyTotals.fats)
                    )
                    
                    
                    if let goals = userMacroGoals { //if macro goals exist, show users remaining vs their goal for each nutrient
                        Divider()
                        
                        SummaryRow( //Daily Goal row
                            label: "Daily Goal",
                            totals: (goals.proteinGoal, goals.carbsGoal, goals.fatsGoal),
                            calories: goals.caloriesGoal
                        )
                        
                        SummaryRow( //Remaining row
                            label: "Remaining",
                            totals: (
                                max(goals.proteinGoal - dailyTotals.protein, 0),
                                max(goals.carbsGoal - dailyTotals.carbs, 0),
                                max(goals.fatsGoal - dailyTotals.fats, 0)
                            ),
                            calories: max(goals.caloriesGoal - calculateCalories(protein: dailyTotals.protein, carbs: dailyTotals.carbs, fats: dailyTotals.fats), 0)
                        )
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    fetchMacroGoals()   //should auto load users macro goals from DB
                }
            }
        }
    }

    // Reusable row for macro breakdowns
    struct SummaryRow: View {
        let label: String
        let totals: (protein: Double, carbs: Double, fats: Double)
        let calories: Double? //for calorie column
        
        init(label: String, totals: (protein: Double, carbs: Double, fats: Double), calories: Double? = nil) {
            self.label = label
            self.totals = totals
            self.calories = calories
        }

        var body: some View {
            HStack {
                Text(label)
                    .frame(width: 100, alignment: .leading)

                Spacer()

                Text("\(totals.protein, specifier: "%.1f")g")
                    .frame(width: 60, alignment: .trailing)

                Text("\(totals.carbs, specifier: "%.1f")g")
                    .frame(width: 60, alignment: .trailing)

                Text("\(totals.fats, specifier: "%.1f")g")
                    .frame(width: 60, alignment: .trailing)
                
                if let calories = calories {
                    Text("\(calories, specifier: "%.0f")")
                        .frame(width: 60, alignment: .trailing)
                }
            }
        }
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }
}

#Preview {
    SummaryView(selectedDate: Date(), savedMeals: [
        LoggedMeal(id: 1, user_id: 1, food_name: "Eggs", serving_size: "44.0 g", calories: 136, protein: 13.6, carbs: 0.0, fats: 9.0, created_at: "2025-04-02T12:00:00.000Z", meal_type: "Breakfast"),
        LoggedMeal(id: 2, user_id: 1, food_name: "Chicken", serving_size: "85.0 g", calories: 188, protein: 24.7, carbs: 1.1, fats: 9.4, created_at: "2025-04-02T12:00:00.000Z", meal_type: "Lunch")
    ])
}

