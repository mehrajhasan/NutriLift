/*
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
                .padding(.bottom)
            
            // Nutritional Information
            List(meal.nutrients) { nutrient in
                HStack {
                    Text(nutrient.name)
                        .font(.headline)
                    Spacer()
                    Text("\(nutrient.amount ?? 0, specifier: "%.1f") \(nutrient.unitName ?? "")")
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
        Nutrient(id: 1, name: "Protein", amount: 10.5, unitName: "g"),
        Nutrient(id: 2, name: "Carbs", amount: 30.2, unitName: "g"),
        Nutrient(id: 3, name: "Fat", amount: 15.8, unitName: "g")
    ]))
}
*/
