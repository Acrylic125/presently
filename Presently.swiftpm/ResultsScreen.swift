import SwiftUI
import Charts
import Combine

public struct PresentationTranscriptPart {
    let title: String
    let img: String
    let duration: Int
    let content: String
}

struct PresentationPacingData: Identifiable {
    let id = UUID()
    let timestamp: Float
    let words: Float
}

@Observable
final class ResultsViewModel {
    var pacingData: [PresentationPacingData] = []
    var transcriptParts: [PresentationTranscriptPart] = []
    var duration: Int = 0
    
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
                        Text(formatTime(viewModel.duration))
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
                            
                            let timestamps = pacingData.map { $0.timestamp }
                            let words = pacingData.map { $0.words }
                            
                            let minTimestamp = pacingData.count > 0 ? timestamps.min()! : 0
                            let maxTimestamp = pacingData.count > 0 ? timestamps.max()! : 0
                            let minWords = pacingData.count > 0 ? words.min()! : 0
                            let maxWords = pacingData.count > 0 ? words.max()! : 0
                            
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
                            .chartXScale(domain: minTimestamp ... maxTimestamp)
                            .chartYScale(domain: minWords ... maxWords * 1.25)
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
                            HStack(alignment: .center, spacing: 48) {
                                VStack(alignment: .leading, spacing: 8) {
                                    VStack {
                                        Image(part.img)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    .frame(
                                        width: 160
                                    )
                                    Text(formatTime(part.duration))
                                        .frame(
                                            width: 160,
                                            alignment: .center
                                        )
                                        .foregroundStyle(AppColors.Gray300.color)
                                        .font(.system(size: headerFontSize.rawValue, weight: .medium))
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
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    VStack {
                                        Image(part.img)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    .frame(width: 96)
                                    Spacer()
                                    Text(formatTime(part.duration))
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
            self.onAppear()
        }
    }
    
    func onAppear() {
        speechRecognizer.$transcriptions.sink { value in
            var transcriptionParts: [PresentationTranscriptPart] = []
            
            if value.count <= 0 {
                self.viewModel.transcriptParts = []
                self.viewModel.duration = 0
                self.viewModel.pacingData = []
                return
            }
            
            var tallyDuration: Int = 0
            for transcriptionRawPart in value {
                let bestTranscript = transcriptionRawPart.bestTranscript
                if bestTranscript.segments.count <= 0 {
                    print("No segments found.")
                    continue
                }
                let lastSegment = bestTranscript.segments[bestTranscript.segments.count - 1]
                let duration = Int((lastSegment.timestamp + lastSegment.duration) * 1_000)
                tallyDuration += duration
                
                let presentationPart = presentationParts.first { v in
                    return transcriptionRawPart.partId == v.id
                }
                
                transcriptionParts.append(
                    .init(
                        title: presentationPart?.title ?? "No Title",
                        img: presentationPart?.img ?? "No Image",
                        duration: duration,
                        content: bestTranscript.formattedString
                    )
                )
            }
            
            var pacingData: [PresentationPacingData] = []
            if tallyDuration > 0 {
                let bucketSize = max(tallyDuration / 1_000, 1_000)
                var bucketIndex: Int = 0
                var bucketFilledAcc = 0
                
                var transcriptionRawPartIndex = 0
                var transcriptionRawPartSegmentIndex = 0
                var baseTimestamp: Int = 0
                
                var words: Float = 0
                
                while true {
                    if value.count <= 0 || transcriptionRawPartIndex >= value.count {
                        break
                    }
                    
                    let durationAcc = bucketIndex * bucketSize + bucketFilledAcc
                    
                    // If the bucket is filled, we will save the current bucket and prepare for the next bucket.
                    if bucketFilledAcc >= bucketSize {
                        print("Words: \(words)")
                        pacingData.append(
                            .init(
                                timestamp: Float(durationAcc) / 1_000,
                                words: (60 * words)
                            )
                        )
                        bucketIndex += 1
                        bucketFilledAcc = 0
                        words = 0
                    }
                    
                    let transcriptionRawPart = value[transcriptionRawPartIndex]
                    let transcriptionRawPartSegments = transcriptionRawPart.segments
                    // Move to next segment if the index cursor overflows.
                    if transcriptionRawPartSegments.count <= 0 || transcriptionRawPartSegmentIndex >= transcriptionRawPartSegments.count {
                        transcriptionRawPartIndex += 1
                        transcriptionRawPartSegmentIndex = 0
                        if transcriptionRawPart.segments.count > 0 {
                            let lastSegment = transcriptionRawPart.segments[transcriptionRawPartSegments.count - 1]
                            baseTimestamp += Int((lastSegment.timestamp + lastSegment.duration) * 1_000)
                        }
                        continue
                    }
                    
                    let segment = transcriptionRawPartSegments[transcriptionRawPartSegmentIndex]
                    
                    // First we check if the segment starting time matches up with the duration acc.
                    // This is to factor in gaps between segments.
                    let startingTime = (baseTimestamp + Int(segment.timestamp) * 1000)
                    if durationAcc < startingTime {
                        // E.g. Starting time = 1000, durationAcc = 700
                        // Case 1: Bucket size = 200, BucketFilledAcc = 100, gapDurationUsed = 100
                        // Case 2: Bucket size = 200, BucketFilledAcc = 0, gapDurationUsed = 200
                        // Case 3: Bucket size = 400, BucketFilledAcc = 0, gapDurationUsed = 300
                        let gapDurationUsed = min(startingTime - durationAcc, bucketSize, bucketSize - bucketFilledAcc)
                        bucketFilledAcc += gapDurationUsed
                        print("Gap \(gapDurationUsed)")
                        continue
                    }
                    let endingTime = startingTime + Int(segment.duration * 1000)
                    if durationAcc >= endingTime {
                        transcriptionRawPartSegmentIndex += 1
                        continue
                    }
                    
                    let segmentInDuration = durationAcc - startingTime
                    // E>g. Duration 1000,
                    // Case 1: Bucket size = 1100, Segment in duration = 0, segmentDurationUsed = 1000
                    // Case 2: Bucket size = 300, Segment in duration = 200, segmentDurationUsed = 300
                    // Case 3: Bucket size = 500, Segment in duration = 600, segmentDurationUsed = 400
                    let segmentDurationUsed = min(Int(segment.duration * 1000) - segmentInDuration, bucketSize, bucketSize - bucketFilledAcc)
                    bucketFilledAcc += segmentDurationUsed
                    print("Segment \(segmentDurationUsed) P1 = \(Int(segment.duration * 1000) - segmentInDuration) P2 = \(bucketSize) P3 = \(bucketSize - bucketFilledAcc)")

                    words += Float(segment.substring.count) * Float(segmentDurationUsed) / Float(bucketSize)
                }
            }
            
            self.viewModel.transcriptParts = transcriptionParts
            self.viewModel.duration = tallyDuration
            self.viewModel.pacingData = pacingData
        }.store(in: &self.cancellableBag)
        viewModel.pacingData = [] // PresentationPacingData.mockData()
        animateIn()
        
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
