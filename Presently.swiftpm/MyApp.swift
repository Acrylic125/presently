import SwiftUI

//struct TempView: View {
//    @State var s: Double = 0.0
//    @State var trx: Int = 0
//
//    var body: some View {
//        VStack {
//            VStack {
//                Color.blue
//            }
//            .offset(x: (1 - s) * 500)
//            .frame(
//                width: 150,
//                height: 150
//            )
//            
//            Button(action: {
//                s = 0
//                trx += 1
//                let trx2 = trx
//                withAnimation(.easeOut(duration: 3)) {
//                    self.s = 1
//                } completion: {
//                    print("Done \(trx2)")
//                }
//            }) {
//               Text("Click me!")
//            }
//            Button(action: {
//                s = 0
//                trx += 1
//                let trx2 = trx
//                withAnimation(.easeOut(duration: 1)) {
//                    self.s = 1
//                } completion: {
//                    print("Done Fast \(trx2)")
//                }
//            }) {
//               Text("Click me Fast!")
//            }
//
//        }
//    }
//}

@main
struct MyApp: App {

    
    var body: some Scene {
        WindowGroup {
            
//            TempView()
//                .frame(
//                    maxWidth: .infinity
//                )
            NavigationStack {
                ContentView()
            }
        }
    }
}
