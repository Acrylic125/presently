import SwiftUI
import Charts
import Combine

public struct PresentationTranscriptPart {
    let title: String
    let img: String
    let duration: Double
    let content: String
}

//@Observable
//public final class PresentationResultsViewModel {
//    
//}

struct PresentationPacingData: Identifiable {
    let id = UUID()
    let timestamp: Float
    let words: Int
    
    static func mockData() -> [PresentationPacingData] {
        var records: [PresentationPacingData] = []
        
        for i in 1...20 {
            records.append(
                PresentationPacingData(timestamp: Float(i) * 0.5, words: Int.random(in: 80...130))
            )
        }
        
        return records
    }
}

@Observable
final class ResultsViewModel {
    var pacingData: [PresentationPacingData] = []
    var transcriptParts: [PresentationTranscriptPart] = []

    var appearTransitionWorkItem: DispatchWorkItem? = nil
    var appearTransitionState: Double = 0
    
    var cell1AppearTransitionState: Double = 0
    var cell2AppearTransitionState: Double = 0
    var cell3AppearTransitionState: Double = 0
    
    var transcriptAppearTransitionState: Double = 0
    
    var chartAppearTransitionState: Double = 0
}

public struct ResultsContentView: View {
    let size: AppContentSize
    let title: String;
    @Binding var viewModel: ResultsViewModel

    private var areaBackground: Gradient {
        return Gradient(colors: [AppColors.Primary500.color, AppColors.Primary500.color.opacity(0.1)])
    }
    
    public var body: some View {
        let pacingData = viewModel.pacingData
        let parts = viewModel.transcriptParts
        
        let maxTimestamp = pacingData.map { $0.timestamp }.max() ?? 0
        let intervalPoints = Array(stride(from: 0, through: maxTimestamp, by: maxTimestamp / 4))
        
        let gridSpacing: CGFloat = size == .large ? 20 : 12
        let containerPadding: CGFloat = size == .large ? 24 : 12
        let containerBorderRadius: CGFloat = size == .large ? 16 : 8
        let containerContentSpacing: CGFloat = size == .large ? 8 : 4
        
        let headerFontSize: AppFontSize = size == .large ? .xl2 : .lg
        let textFontSize: AppFontSize = size == .large ? .xl3 : .xl
        let transcriptTextFontSize: AppFontSize = size == .large ? .xl2 : .lg
        
        let sectionSpacing: CGFloat = size == .large ? 24 : 16
        
        VStack(alignment: .leading, spacing: sectionSpacing) {
            Text(title)
                .frame(
                    maxWidth: size == .small ? 320 : 440,
                    alignment: .leading
                )
                .foregroundStyle(AppColors.Gray50.color)
                .font(.system(size: size == .large ? AppFontSize.xl4.rawValue : AppFontSize.xl3.rawValue, weight: .black))
            
            VStack(alignment: .leading, spacing: gridSpacing) {
                Text("Overview")
                    .foregroundStyle(AppColors.Gray50.color)
                    .font(.system(size: headerFontSize.rawValue, weight: .medium))

                Grid(
                    horizontalSpacing: gridSpacing,
                    verticalSpacing: gridSpacing
                ) {
                    let durationCell = VStack(alignment: .leading, spacing: containerContentSpacing) {
                        if size == .large {
                            Spacer()
                        }
                        Text("Duration")
                            .frame(
                                alignment: .leading
                            )
                            .foregroundStyle(AppColors.Gray300.color)
                            .font(.system(size: headerFontSize.rawValue, weight: .medium))
                        Text("3m")
                            .frame(
                                alignment: .leading
                            )
                            .foregroundStyle(AppColors.Gray50.color)
                            .font(.system(size: textFontSize.rawValue, weight: .medium))
                        if size == .large {
                            Spacer()
                        }
                    }
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: size == .large ? .infinity : nil,
                            alignment: .leading
                        )
                        .padding(containerPadding)
                        .background(
                            RoundedRectangle(cornerRadius: containerBorderRadius)
                                .fill(AppColors.Gray900.color)
                                .stroke(AppColors.Gray700.color, lineWidth: 1)
                        )
                        .opacity(viewModel.cell2AppearTransitionState)
                        .scaleEffect(viewModel.cell2AppearTransitionState)
                        .onAppear() {
                            withAnimation(.easeInOut(duration: 0.5).delay(0.15)) {
                                viewModel.cell2AppearTransitionState = 1
                            }
                        }

                    let wpmCell = VStack(alignment: .leading, spacing: containerContentSpacing) {
                        if size == .large {
                            Spacer()
                        }
                        Text("Average Speed")
                            .frame(
                                alignment: .leading
                            )
                            .foregroundStyle(AppColors.Gray300.color)
                            .font(.system(size: headerFontSize.rawValue, weight: .medium))
                        Text("120 wpm")
                            .frame(
                                alignment: .leading
                            )
                            .foregroundStyle(AppColors.Gray50.color)
                            .font(.system(size: textFontSize.rawValue, weight: .medium))
                        if size == .large {
                            Spacer()
                        }
                    }
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: size == .large ? .infinity : nil,
                            alignment: .leading
                        )
                        .padding(containerPadding)
                        .background(
                            RoundedRectangle(cornerRadius: containerBorderRadius)
                                .fill(AppColors.Gray900.color)
                                .stroke(AppColors.Gray700.color, lineWidth: 1)
                        )
                        .opacity(viewModel.cell3AppearTransitionState)
                        .scaleEffect(viewModel.cell3AppearTransitionState)
                        .onAppear() {
                            withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
                                viewModel.cell3AppearTransitionState = 1
                            }
                        }

                    GridRow {
                        VStack(alignment: .leading) {
                            Text("Pacing")
                                .frame(
                                    maxWidth: 300,
                                    alignment: .leading
                                )
                                .foregroundStyle(AppColors.Gray300.color)
                                .font(.system(size: headerFontSize.rawValue, weight: .medium))
                                .padding(.horizontal, containerPadding)
                            
                            Chart(pacingData) {
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
                                
                                RuleMark(y: .value("Average", 50))
                                    .foregroundStyle(AppColors.Primary500.color)
                                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                            }
                            .chartYAxis {
                                AxisMarks() { value in
                                    AxisValueLabel() {
                                        if let timestamp = value.as(Float.self) {
                                            Text(String(format: "%.1f", timestamp))
                                                .foregroundStyle(AppColors.Gray300.color)
                                        }
                                    }
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: intervalPoints) { value in
                                    AxisValueLabel(centered: true) {
                                        if let timestamp = value.as(Float.self) {
                                            Text(String(format: "%.1f", timestamp))
                                                .foregroundStyle(AppColors.Gray300.color)
                                        }
                                    }
                                }
                            }
                            .chartXScale(domain: 0 ... 10)
                            .chartYScale(domain: 0 ... 130)
                            .frame(height: 240)
                        }
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: size == .large ? .infinity : nil
                        )
                        .padding(.vertical, containerPadding)
                        .background(
                            RoundedRectangle(cornerRadius: containerBorderRadius)
                                .fill(AppColors.Gray900.color)
                                .stroke(AppColors.Gray700.color, lineWidth: 1)
                        )
                        .opacity(viewModel.cell1AppearTransitionState)
                        .scaleEffect(viewModel.cell1AppearTransitionState)
                        .onAppear() {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                viewModel.cell1AppearTransitionState = 1
                            }
                            
                            withAnimation(.easeInOut(duration: 0.5).delay(0.5)) {
                                viewModel.chartAppearTransitionState = 1
                            }
                        }

                        if size == .large {
                            Grid(
                                horizontalSpacing: gridSpacing,
                                verticalSpacing: gridSpacing
                            ) {
                                GridRow {
                                    durationCell
                                }
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                                
                                GridRow {
                                    wpmCell
                                }
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity
                                )
                            }
                            .frame(
                                maxWidth: 300,
                                maxHeight: .infinity
                            )
                        }
                    }
                   
                    if size == .small {
                        HStack(spacing: gridSpacing) {
                            durationCell
                            wpmCell
                        }
                    }
                }
                .frame(
                    maxHeight: size == .large ? 320 : nil
                )
            }
            
            VStack(alignment: .leading, spacing: gridSpacing) {
                Text("Transcript")
                    .foregroundStyle(AppColors.Gray50.color)
                    .font(.system(size: headerFontSize.rawValue, weight: .medium))
                
                LazyVStack(spacing: gridSpacing) {
                    ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                        if size == .large {
                            HStack(spacing: 48) {
                                VStack(spacing: 8) {
                                    VStack {
                                        Image(part.img)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    .frame(width: 240)
                                    Text("3 min")
                                        .frame(
                                            alignment: .center
                                        )
                                        .foregroundStyle(AppColors.Gray300.color)
                                        .font(.system(size: headerFontSize.rawValue, weight: .medium))
                                    Spacer()
                                }
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(part.title)
                                        .frame(
                                            alignment: .leading
                                        )
                                        .foregroundStyle(AppColors.Primary500.color)
                                        .font(.system(size: headerFontSize.rawValue, weight: .bold))
                                    Text(part.content)
                                        .lineSpacing(4)
                                        .frame(
                                            maxWidth: 800,
                                            alignment: .leading
                                        )
                                        .foregroundStyle(AppColors.Gray50.color)
                                        .font(.system(size: transcriptTextFontSize.rawValue, weight: .medium))
                                }
                            }
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .leading
                            )
                            .padding(containerPadding)
                            .background(
                                RoundedRectangle(cornerRadius: containerBorderRadius)
                                    .fill(AppColors.Gray900.color)
                                    .stroke(AppColors.Gray700.color, lineWidth: 1)
                            )
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    VStack {
                                        Image(part.img)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    .frame(width: 96)
                                    Spacer()
                                    Text("3 min")
                                        .frame(
                                            alignment: .center
                                        )
                                        .foregroundStyle(AppColors.Gray300.color)
                                        .font(.system(size: headerFontSize.rawValue, weight: .medium))
                                }
                                Text(part.title)
                                    .frame(
                                        alignment: .leading
                                    )
                                    .foregroundStyle(AppColors.Primary500.color)
                                    .font(.system(size: headerFontSize.rawValue, weight: .bold))
                                Text(part.content)
                                    .lineSpacing(4)
                                    .frame(
                                        maxWidth: 800,
                                        alignment: .leading
                                    )
                                    .foregroundStyle(AppColors.Gray50.color)
                                    .font(.system(size: transcriptTextFontSize.rawValue, weight: .medium))
                            }
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .leading
                            )
                            .padding(containerPadding)
                            .background(
                                RoundedRectangle(cornerRadius: containerBorderRadius)
                                    .fill(AppColors.Gray900.color)
                                    .stroke(AppColors.Gray700.color, lineWidth: 1)
                            )
                        }
                        
                    }
                }
                .opacity(viewModel.transcriptAppearTransitionState)
                .onAppear() {
                    withAnimation(.easeInOut(duration: 1)) {
                        viewModel.transcriptAppearTransitionState = 1
                    }
                }

            }
            .padding(.top, 16)

        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
    
}

extension Binding {
    @MainActor
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

public struct ResultsView: View {
    let title: String;
    let presentationParts: [PresentationPart];

    @State var pacingData = PresentationPacingData.mockData()
    @State var viewModel = ResultsViewModel()
    @ObservedObject var speechRecognizer: SpeechRecgonizer

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.dismiss) private var dismiss
    
    @State var cancellableBag = Set<AnyCancellable>()

    public var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        
        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack {
                    if viewModel.transcriptParts.count > 0 && viewModel.pacingData.count > 0 {
                        if (horizontalSizeClass == .compact) {
                            ResultsContentView(
                                size: .small,
                                title: title,
                                viewModel: $viewModel
                            )
                        } else {
                            ResultsContentView(
                                size: .large,
                                title: title,
                                viewModel: $viewModel
                            )
                        }
                    }
                }
                .safeAreaPadding(safeAreaInsets)
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            
            PresentationViewCloseButton(onClose: self.onClose)
                .onAppear() {
    //                animateIn()
                }
                .onDisappear() {
    //                speechRecognizer.stop()
                }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .background(AppColors.Gray950.color)
        .onAppear() {
            speechRecognizer.$transcriptions.sink { value in
                var transcriptionParts: [PresentationTranscriptPart] = []
               
                for transcriptionRawPart in value {
                    let bestTranscript = transcriptionRawPart.bestTranscript
                    if bestTranscript.segments.count <= 0 {
                        print("No segments found.")
                        continue
                    }
                    let lastSegment = bestTranscript.segments[bestTranscript.segments.count - 1]
                    let duration = lastSegment.timestamp + lastSegment.duration
                    
                    let presentationPart = presentationParts.first { v in
                        return transcriptionRawPart.partId == v.id
                    }
                    
                    transcriptionParts.append(
                        .init(
                            title: presentationPart?.title ?? "No Title",
                            img: presentationPart?.img ?? "No Image",
                            duration: duration,
                            content: bestTranscript.formattedString)
                    )
                    print(duration)
                }
                
                self.viewModel.transcriptParts = transcriptionParts

                
//                for transcription in value {
//                    let baseStartTime: Double = Double(transcription.checkpoints[0].startTime)
//                    var checkpointCursor = 0
//                    var contentAcc = ""
//                    for segment in transcription.segments {
//                        let checkpoint = checkpointCursor < checkpoints.count ? checkpoints[checkpointCursor] : nil
//                        let checkpointCursorNext = checkpointCursor + 1
//                        if let checkpoint, checkpointCursorNext < checkpoints.count {
//                            let nextCheckpoint = checkpoints[checkpointCursorNext]
//                            if ((baseStartTime + (segment.timestamp * 1_000)) >= Double(nextCheckpoint.startTime)) {
////                                print("New checkpoint \(checkpointCursor) -> \(checkpointCursorNext)")
//                                let checkpointPart = self.presentationParts.first { v in
//                                    return checkpoint.partId == v.id
//                                }
//                                let partContent = contentAcc
//                                contentAcc = ""
//                                checkpointCursor = checkpointCursorNext
//                                guard let checkpointPart else {
//                                    print("Presentation part of id, \(checkpoint.partId) not found")
//                                    continue
//                                }
//                                transcriptionParts.append(
//                                    .init(
//                                        title: checkpointPart.title,
//                                        img: checkpointPart.img,
//                                        duration: Double(nextCheckpoint.startTime - checkpoint.startTime),
//                                        content: partContent
//                                    )
//                                )
//                            }
//                        }
////                        print(segment.substring)
//                        if contentAcc == "" {
//                            contentAcc = segment.substring
//                        } else {
//                            contentAcc = contentAcc + " " + segment.substring
//                        }
//                        print("T = \(segment.timestamp), U = \(segment.duration)")
//                    }
//                    
//                    let checkpoint = checkpointCursor < checkpoints.count ? checkpoints[checkpointCursor] : nil
//                    if let checkpoint {
//                        let checkpointPart = self.presentationParts.first { v in
//                            return checkpoint.partId == v.id
//                        }
//                        guard let checkpointPart else {
//                            print("Presentation part of id, \(checkpoint.partId) not found")
//                            continue
//                        }
//                        transcriptionParts.append(
//                            .init(
//                                title: checkpointPart.title,
//                                img: checkpointPart.img,
//                                duration: 1000, // Double(nextCheckpoint.startTime - checkpoint.startTime),
//                                content: contentAcc
//                            )
//                        )
//                    } else {
//                        print("No checkpoint?")
//                    }
//                    
//                    print("Checkpoints:")
//                    print(checkpoints)
//                    checkpointCursor = 0
//                    //                    let baseStartTime = Double(transcription.checkpoints[0].startTime)
//                    for checkpoint in checkpoints {
//                        let t = Double(checkpoint.startTime) - baseStartTime
//                        print("\(t / 1000)s in")
//                    }
//                }
            }.store(in: &self.cancellableBag)
//            viewModel.transcriptParts = [
//                .init(title: "Hello World", img: "playground", duration: 60_000_000, content: "LLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.orem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."),
//                .init(title: "Hello 2", img: "playground", duration: 3_000_000, content: "LLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod")
//            ]
            viewModel.pacingData = PresentationPacingData.mockData()
            animateIn()
        }
        
    }
    
    func animateIn() {
        if (viewModel.appearTransitionWorkItem != nil) {
            viewModel.appearTransitionWorkItem!.cancel()
        }
        
        viewModel.appearTransitionState = 0
        viewModel.appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeIn(duration: 3)) {
                self.viewModel.appearTransitionState = 1
            }
        }
        DispatchQueue.main.async(execute: viewModel.appearTransitionWorkItem!)
    }
    
    func onClose() {
        dismiss()
    }

}
