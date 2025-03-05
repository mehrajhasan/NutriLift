import SwiftUI

struct forgotpasswordView: View {
    @State private var email: String = ""
    @State private var isEmailSent = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("NutriLift")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Text("Forgot Password")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Text("Enter your email address and we’ll send you a link to reset your password.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 30)

                Button(action: {
                    sendResetLink()
                }) {
                    Text("Send Reset Link")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 30)
                }
                .disabled(email.isEmpty)
                .opacity(email.isEmpty ? 0.5 : 1.0)

                if isEmailSent {
                    Text("A reset link has been sent to your email.")
                        .foregroundColor(.green)
                        .font(.body)
                }

                Spacer()

                // Navigation Link to LoginView
                NavigationLink(destination: loginView()) {
                    Text("Back to Login")
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                }
            }
            .padding(.top, 50)
        }
    }

    func sendResetLink() {
        isEmailSent = true
    }
}

#Preview {
    forgotpasswordView()
}
