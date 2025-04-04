import SwiftUI
import Charts

struct SummaryView: View {
    var selectedDate: Date
    var savedMeals: [LoggedMeal]

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
    
    var macroPercentages: [(label: String, value: Double, color: Color)] {
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
                    }

                    SummaryRow(label: "Breakfast", totals: totals(for: "Breakfast"))
                    SummaryRow(label: "Lunch", totals: totals(for: "Lunch"))
                    SummaryRow(label: "Dinner", totals: totals(for: "Dinner"))

                    Divider()

                    SummaryRow(label: "Total", totals: dailyTotals)
                }
                .padding(.horizontal)
            }
        }
    }

    // Reusable row for macro breakdowns
    struct SummaryRow: View {
        let label: String
        let totals: (protein: Double, carbs: Double, fats: Double)

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

