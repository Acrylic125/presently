import SwiftUI
import AVFoundation
import Charts

//struct MeetingView: View {
//    @StateObject var speechRecognizer = SpeechRecognizer()
//    
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 16.0)
//                .fill(.green)
//            VStack {
//                Button("Button title") {
//                    print(speechRecognizer.transcriptions)
//                    print(speechRecognizer.transcript)
//                }
//            }
//        }
//        .padding()
//        .foregroundColor(.black)
//        .onAppear {
//            startScrum()
//        }
//        .onDisappear {
//        }
//        .navigationBarTitleDisplayMode(.inline)
//    }
//    
//    private func startScrum() {
////        scrumTimer.reset(lengthInMinutes: scrum.lengthInMinutes, attendees: scrum.attendees)
////        scrumTimer.speakerChangedAction = {
////            player.seek(to: .zero)
////            player.play()
////        }
//        speechRecognizer.resetTranscript()
//        speechRecognizer.startTranscribing()
////        scrumTimer.startScrum()
//    }
//    
//    private func endScrum() {
//        speechRecognizer.stopTranscribing()
//    
////        scrumTimer.stopScrum()
////        let newHistory = History(attendees: scrum.attendees)
////        scrum.history.insert(newHistory, at: 0)
//    }
//}


//struct MeetingView_Previews: PreviewProvider {
//    static var previews: some View {
//        MeetingView(scrum: .constant(DailyScrum.sampleData[0]))
//    }
//}

class SessionManager: ObservableObject {
    var isLoggedIn: Bool = false {
        didSet {
            rootId = UUID()
        }
    }
    
    @Published
    var rootId: UUID = UUID()
}

struct ContentView: View {
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Get Practicing!")
                    .foregroundStyle(AppColors.Gray50.color)
                    .fontWeight(.bold)
                    .font(.title)
                NavigationLink("Results") {
                    ResultsView(title: "Playground Observations")
                }
                NavigationLink("Presentation") {
                    PresentationView(title: "Playground Observations")
                }
                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .leading
            )
        }
        .navigationBarBackButtonHidden()
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(AppColors.Gray950.color)
    }
}
