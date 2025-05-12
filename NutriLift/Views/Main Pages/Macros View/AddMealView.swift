import SwiftUI

struct AddMealView: View {
    var mealType: String //receives meal type from button tapped
    var selectedDate: Date //to add meal for the date user chooses and not real time
    @State private var showAddSuccess = false
    @Environment(\.presentationMode) var presentationMode //sees current status of view
    @AppStorage("userId") var userID: Int = 0 //changed user_id to userID as thats what was used in loginview. Maybe that is current issue with userid constantly storing on user id 30? As notes by Jairo: when a user logs in, we set the primary key (user_id) into a foreign key (userID) that other tables on db use. So contacting primary key won't work
    @State private var searchText: String = ""
    @State private var meals: [Meal] = []
    
    var body: some View {
        //NavigationView {
        VStack {
            // Navigation Bar
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() //.dismiss() tells view to close
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
                    // Navigate to detailed view
                    NavigationLink(destination: MealDetailView(meal: meal)) {
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
                        
                        //Image(systemName: "chevron.right")
                        //.foregroundColor(.gray)
                    }
                    
                    // Add-to-DB button
                    Button(action: {
                        addMeal(meal)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        //.padding(.leading, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 5)
            }
        }
        .background(Color(.systemGray6))
        .alert("Meal Has Been Added Successfully!", isPresented: $showAddSuccess) {
            Button("OK", role: .cancel) { }
        }
    }
    
    // Fetch meals dynamically using API
    func fetchMeals() {
        guard let encodedQuery = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://localhost:3000/api/usda/search/\(encodedQuery)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([Food].self, from: data)
                    DispatchQueue.main.async {
                        self.meals = decoded.map { food in
                            Meal(
                                id: food.fdcId,
                                name: food.description,
                                servingSize: "\(food.servingSize ?? 1.0) \(food.servingSizeUnit ?? "unit")",
                                calories: Int(food.calories ?? 0),
                                nutrients: food.foodNutrients
                            )
                        }
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    
    // Function to add a meal to user's meal log
    func addMeal(_ meal: Meal) {
        // Extract macros from USDA data
        let protein = meal.nutrients.first(where: { $0.nutrientName == "Protein" })?.value ?? 0
        let carbs = meal.nutrients.first(where: { $0.nutrientName == "Carbohydrate, by difference" })?.value ?? 0
        let fats = meal.nutrients.first(where: { $0.nutrientName == "Total lipid (fat)" })?.value ?? 0
        
        guard let url = URL(string: "http://localhost:3000/api/macros") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //let isoFormatter = ISO8601DateFormatter()
        //let formattedDate = isoFormatter.string(from: selectedDate)   //was causing date to be stored in next date. possibly a time zone issue?
        
        
        let dateFormatter = DateFormatter() //apple dev formatter that converts between date objects to strings
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)    //should treat all time like they're same
        let formattedDate = dateFormatter.string(from: selectedDate) + "T00:00:00.000Z" //convert selectedDate into string, then append to make time to midnight UTC to match database timestamps
        
        let body: [String: Any] = [
            "user_id": userID,
            "food_name": meal.name,
            "serving_size": meal.servingSize,
            "calories": meal.calories,
            "protein": protein,
            "carbs": carbs,
            "fats": fats,
            "meal_type": mealType,
            "created_at": formattedDate
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Failed to encode meal: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Meal save error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No response data from server.")
                return
            }
            
            if let response = try? JSONSerialization.jsonObject(with: data) {
                print("Meal saved to macros:", response)
                DispatchQueue.main.async {
                    showAddSuccess = true
                }
            }
        }.resume()
    }
    
}

struct Meal: Identifiable, Decodable {
    let id: Int
    let name: String
    let servingSize: String
    let calories: Int
    var nutrients: [Nutrient] = []
}

struct Food: Decodable {
    let fdcId: Int
    let description: String
    let servingSize: Double?
    let servingSizeUnit: String?
    let foodNutrients: [Nutrient]
    
    var calories: Double? {
        return foodNutrients.first(where: { $0.nutrientName == "Energy" })?.value
    }
}

struct Nutrient: Identifiable, Decodable {
    var id = UUID() // mutable now
    let nutrientName: String
    let value: Double?
    let unitName: String?
    
    private enum CodingKeys: String, CodingKey {
        case nutrientName
        case value
        case unitName
    }
}

// Preview
#Preview {
    AddMealView(mealType: "Breakfast", selectedDate: Date())
}




