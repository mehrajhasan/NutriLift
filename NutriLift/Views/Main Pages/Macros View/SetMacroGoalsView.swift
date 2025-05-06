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
    }
}

#Preview {
    SetMacroGoalsView()
}
