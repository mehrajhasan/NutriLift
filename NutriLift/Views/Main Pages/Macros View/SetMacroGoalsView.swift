import SwiftUI

struct SetMacroGoalsView: View {
    @AppStorage("userId") var userID: Int = 0   //get logged in users ID
    //use for storing user input
    @State private var calorieGoal = ""
    @State private var proteinGoal = ""
    @State private var carbsGoal = ""
    @State private var fatsGoal = ""
    @State private var showConfirmation = false
    
    
    var body: some View {
        VStack(spacing: 20) {
            // page title
            Text("Set Your Daily Macro Goals")
            .font(.title)
            .bold()
            .padding(.top)

            // protein input text
            TextField("Protein (g)", text: $proteinGoal)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            // carbs input text
            TextField("Carbs (g)", text: $carbsGoal)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            // fats input text
            TextField("Fats (g)", text: $fatsGoal)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            //save button. Integrating with backend POST route soon
            Button("Save Goals") {
                saveMacroGoals()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top)
            Spacer()
        }
        .padding()
        .onAppear { //if user already has macro goals, it should upload automatically
            fetchMacroGoals()
        }
        .alert("Macro Goals Saved!", isPresented: $showConfirmation) {  //when user clicks to Save Goal, showConfirmation becomes true and displays "Macro Goals Saved!"
            Button("OK", role: .cancel) { }
        }
    }
    
    func fetchMacroGoals() {
        guard let url = URL(string: "http://localhost:3000/api/macro_goals/\(userID)")
        else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase //tells swift to match snack_case keys like how it is in DB for macro_goals
                do {
                    let decoded = try decoder.decode(MacroGoals.self, from: data)
                    DispatchQueue.main.async {
                        print("Fetched goals: \(decoded)")
                        self.proteinGoal = decoded.proteinGoal
                        self.carbsGoal = decoded.carbsGoal
                        self.fatsGoal = decoded.fatsGoal
                        self.calorieGoal = decoded.caloriesGoal
                    }
                } catch {
                    print("Decoding error:", error.localizedDescription)
                    if let rawString = String(data: data, encoding: .utf8) {
                        print("Raw server response:", rawString)
                    }
                }
            }
        }.resume()
    }
    
    func saveMacroGoals() {
        guard let url = URL(string: "http://localhost:3000/api/macro_goals") else {
            return  //exit if URL is bad
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //post request since sending new data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")  //letting server know that request is in JSON format (application/json)
        
        let body: [String: Any] = [ //dictionary for user's input
            "user_id": userID,
            "protein_goal": Double(proteinGoal) ?? 0,   //convert from string to numbers, if not, keep as 0
            "carbs_goal": Double(carbsGoal) ?? 0,
            "fats_goal": Double(fatsGoal) ?? 0,
            "calories_goal": calculateCalories()
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)    //body dictionary encoded into JSON format
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error saying macros goal", error.localizedDescription)
                return
            }
            guard let data = data else {
                print("No response data received")
                return
            }
            if let response = try? JSONSerialization.jsonObject(with: data) {
                print("Macros goal saved:", response)
                DispatchQueue.main.async {  //when server responds correctly, switch to main thread. show confirmation to show success message
                    showConfirmation = true
                }
            }
        }.resume()
    }
    
    func calculateCalories() -> Double {    //convert protein, fat, carbs to numbers, then calculate the total
        let protein = Double(proteinGoal) ?? 0
        let carbs = Double(carbsGoal) ?? 0
        let fats = Double(fatsGoal) ?? 0
        return (protein * 4) + (carbs * 4) + (fats * 9)
    }
}

struct MacroGoals: Codable {
    let proteinGoal: String
    let carbsGoal: String
    let fatsGoal: String
    let caloriesGoal: String
}

#Preview {
    SetMacroGoalsView()
}
