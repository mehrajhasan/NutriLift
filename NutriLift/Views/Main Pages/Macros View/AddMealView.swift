import SwiftUI

struct AddMealView: View {
    @State private var searchText: String = ""
    @State private var meals: [Meal] = []
    
    var body: some View {
        VStack {
            // Navigation Bar
            HStack {
                Button(action: {
                    // Back button action
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Add Meal")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search for a meal", text: $searchText, onEditingChanged: { isEditing in
                    if !searchText.isEmpty {
                        fetchMeals() // Fetch meals dynamically when user types
                    }
                })
                .textFieldStyle(PlainTextFieldStyle())
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray5)))
            .padding(.horizontal)
            
            // Show Best Matches only when search results exist
            if !meals.isEmpty {
                Text("Best Matches")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .foregroundColor(.white)
                    .background(Color.black)
            }
            
            // List of meals
            List(meals) { meal in
                HStack {
                    VStack(alignment: .leading) {
                        Text(meal.name)
                            .font(.headline)
                        Text("\(meal.servingSize)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("\(meal.calories) Cal")
                        .font(.headline)
                    
                    Button(action: {
                        addMeal(meal)
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .background(Color(.systemGray6))
    }
    
    // Fetch meals dynamically using API
    func fetchMeals() {
        guard let url = URL(string: "https://api.nal.usda.gov/fdc/v1/foods/search?query=\(searchText)&api_key=Li8D2HQTYvQkIHg6kYBvjGSeOWHSnWYZRbNhv7G2") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(MealResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.meals = decodedResponse.foods.map { food in
                            Meal(id: food.fdcId, name: food.description, servingSize: "1 \(food.servingSizeUnit ?? "unit")", calories: Int(food.calories ?? 0))
                        }
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
    }
    
    // Function to add a meal to user's meal log
    func addMeal(_ meal: Meal) {
        print("Added \(meal.name) to meal log")
    }
}

// Meal Struct
struct Meal: Identifiable, Decodable {
    let id: Int
    let name: String
    let servingSize: String
    let calories: Int
}

// API Response Model
struct MealResponse: Decodable {
    let foods: [Food]
}

struct Food: Decodable {
    let fdcId: Int
    let description: String
    let servingSize: Double?
    let servingSizeUnit: String?
    let calories: Double?
}

// Preview
#Preview {
    AddMealView()
}




