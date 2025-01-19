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

struct OverallData: Identifiable {
    let id = UUID()
    let timestamp: Float
    let words: Int
    
    static func mockData() -> [OverallData] {
        var records: [OverallData] = []
        
        for i in 1...20 {
            records.append(
                OverallData(timestamp: Float(i) * 0.5, words: Int.random(in: 80...130))
            )
        }
        
        return records
    }
}

struct DemoChart: View {
  @State private var overallData = OverallData.mockData()

  private var areaBackground: Gradient {
      return Gradient(colors: [AppColors.Primary500.color, AppColors.Primary500.color.opacity(0.1)])
  }

    var body: some View {
        let maxTimestamp = overallData.map { $0.timestamp }.max() ?? 0
        let intervalPoints = Array(stride(from: 0, through: maxTimestamp, by: maxTimestamp / 4))
        
        Chart(overallData) {
            LineMark(
                x: .value("Timestamp", $0.timestamp),
                y: .value("Words", $0.words)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(AppColors.Primary500.color)
            
            AreaMark(
                x: .value("Timestamp", $0.timestamp),
                y: .value("Words", $0.words)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(areaBackground)
        }
        .chartXAxis {
            AxisMarks(values: intervalPoints) { value in
                AxisValueLabel(centered: true) {
                    if let timestamp = value.as(Float.self) {
                        Text(String(format: "%.1f", timestamp))
                    }
                }
            }
        }
//        .chartYAxis {
//            AxisMarks(position: .leading)
//        }
        .chartXScale(domain: 0 ... 10)
        .chartYScale(domain: 0 ... 130)
        .frame(height: 300)
        .padding()
    }
}

class SessionManager: ObservableObject {
    var isLoggedIn: Bool = false {
        didSet {
            rootId = UUID()
        }
    }
    
    @Published
    var rootId: UUID = UUID()
}

struct ResultsView: View {
    let title: String;
    
    func getSafeAreaInset() -> UIEdgeInsets {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let safeAreaInsets = scene?.windows.first?.safeAreaInsets ?? .zero
        return safeAreaInsets
    }
    
    var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        
        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack {
                    VStack(alignment: .leading) {
                        Text(title)
                            .frame(
                                maxWidth: 300,
                                alignment: .leading
                            )
                            .foregroundStyle(AppColors.Gray50.color)
                            .fontWeight(.bold)
                            .font(.title)
                        Spacer()
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .leading
                    )
                }
                .safeAreaPadding(
                    .init(
                        top: safeAreaInsets.top,
                        leading: safeAreaInsets.left,
                        bottom: safeAreaInsets.bottom,
                        trailing: safeAreaInsets.right
                    )
                )
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            ZStack {
                Color.blue
            }
            .frame(width: 50, height: 50)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .background(AppColors.Gray950.color)
    }

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
