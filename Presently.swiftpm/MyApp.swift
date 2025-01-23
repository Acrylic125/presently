import SwiftUI

//struct TempView: View {
//    
//    @State var t: Task<(), Error>?
//    
//    var body: some View {
//        VStack {
//            Button(action: {
//                self.t?.cancel()
//                self.t = Task {
//                    print("Hello")
//                    try await Task.sleep(nanoseconds: 2_000_000_000)
//                    print("World")
//                }
//            }) {
//                Text("Run Task")
//            }
//            Button(action: {
//                print("Cancelling")
//                self.t?.cancel()
//            }) {
//                Text("Cancel Task")
//            }
//        }
//    }
//}

@main
struct MyApp: App {
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
    }
}
