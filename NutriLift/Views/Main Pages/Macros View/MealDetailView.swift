import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    
    var body: some View {
        VStack {
            Text(meal.name)
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Text("Serving Size: \(meal.servingSize)")
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("\(meal.calories) Calories")
                .font(.headline)
                .padding(.bottom)

            // Nutritional Information
            List(meal.nutrients) { nutrient in
                HStack {
                    Text(nutrient.nutrientName)
                    Spacer()
                    Text("\(nutrient.value ?? 0, specifier: "%.1f") \(nutrient.unitName ?? "")")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
}


// Preview
#Preview {
    MealDetailView(meal: Meal(id: 1, name: "Example Meal", servingSize: "1 Large", calories: 200, nutrients: [
        Nutrient(nutrientName: "Protein", value: 10.5, unitName: "g"),
        Nutrient(nutrientName: "Carbs", value: 30.2, unitName: "g"),
        Nutrient(nutrientName: "Fat", value: 15.8, unitName: "g")
    ]))
}
