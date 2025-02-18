import SwiftUI
import FirebaseAuth

struct RegisterView: View {
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

            Button(action: register) {
                Text("Register")
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }

            Button(action: {
                isRegistering = false
            }) {
                Text("Already have an account? Login")
                    .padding()
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }

    private func register() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = "Registration failed: \(error.localizedDescription)"
                print("Error registering: \(error.localizedDescription)")
            } else {
                appDelegate.isLoggedIn = true
                print("User registered successfully")
            }
        }
    }
}
