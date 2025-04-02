import SwiftUI

struct MacrosView: View {
    @AppStorage("user_id") var userID: Int = 0
    @State private var selectedDate = Date()
    @State private var savedMeals: [LoggedMeal] = []
    
    var mealsForSelectedDate: [LoggedMeal] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selectedDateString = formatter.string(from: selectedDate)
        
        return savedMeals.filter { meal in
            return meal.created_at.starts(with: selectedDateString)
        }
    }


    var body: some View {
        NavigationView {  // Wrap everything in NavigationView
            VStack {
                // Header
                HStack {
                    Spacer()
                    Text("Macronutrients")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                    Button(action: { /* Open menu */ }) {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(.black)
                            .font(.title)
                    }
                }
                .padding()
                
                // View Summary Button
                Button(action: { /* View summary action */ }) {
                    Text("View Summary")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Date Navigation
                // Date Navigation with optional calendar picker
                VStack {
                    HStack {
                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate //toggle backwards date
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        }

                        Text(dateFormatter.string(from: selectedDate))
                            .font(.headline)
                            .padding(.horizontal)

                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate //toggle forward date
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.bottom, 4)

                    // DatePicker
                    DatePicker("",  //allow user to choose which date to go to
                               selection: $selectedDate,
                               displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(.horizontal)
                }
                .padding()
                
                // Scrollable Meal Sections
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(["Breakfast", "Lunch", "Dinner"], id: \.self) { type in
                            MealSectionView(
                                mealType: type,
                                meals: mealsForSelectedDate.filter { $0.meal_type == type }
                            )
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .onAppear {
                fetchMeals()
            }
            //.navigationTitle("Daily Macros Page")
        }
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }
    
    func fetchMeals() {
        guard let url = URL(string: "http://localhost:3000/api/macros/\(userID)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([LoggedMeal].self, from: data)
                    DispatchQueue.main.async {
                        self.savedMeals = decoded
                    }
                } catch {
                    print("Failed to decode saved meals:", error)
                }
            }
        }.resume()
    }
}

// Meal Section Component
struct MealSectionView: View {
    var mealType: String
    var meals: [LoggedMeal]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(mealType)
                .font(.title2)
                .bold()
                .foregroundColor(.black)

            if meals.isEmpty {
                Text("No meals added yet")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(meals) { meal in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(meal.food_name)
                            .font(.headline)
                        Text("\(meal.calories) cal - \(meal.protein)g protein - \(meal.carbs)g carbs - \(meal.fats)g fat")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(6)
                    .background(Color.white)
                    .cornerRadius(8)
                }
            }

            // NavigationLink to AddMealView
            NavigationLink(destination: AddMealView(mealType: mealType)) {
                Text("Add Meal")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(10)
    }
}

struct LoggedMeal: Identifiable, Decodable {
    let id: Int
    let user_id: Int
    let food_name: String
    let serving_size: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fats: Double
    let created_at: String
    let meal_type: String?

}

#Preview {
    TaskBarView()
}
