import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @Binding var isRegistering: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding()

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: login) {
                Text("Login")
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }

            Button(action: {
                isRegistering = true
            }) {
                Text("Don't have an account? Register")
                    .padding()
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }

    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = "Login failed: \(error.localizedDescription)"
                print("Error logging in: \(error.localizedDescription)")
            } else {
                appDelegate.isLoggedIn = true
                print("User logged in successfully")
            }
        }
    }
}
