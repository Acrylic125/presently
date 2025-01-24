import SwiftUI
import Combine
import AVFoundation

@Observable
final class PresentationPresentViewModel {
    var appearTransitionWorkItem: DispatchWorkItem? = nil
    var appearTransitionState: Double = 0
    
    var vxTransitionState: Double = 0

    var hintsExpanded = false
    var hintsExpandTransitionState: Double = 1
    
    // Pagination
    var page = 0;
    var nPage = 0;
    var pageTransitionState: Double = 1
    var isPageTransitioning: Bool = false;
    
    func animateExpand() {
        self.hintsExpandTransitionState = 0
        withAnimation(.easeInOut(duration: 0.3)) {
            self.hintsExpandTransitionState = 1
        }
    }

    func goToPage(newPage: Int) {
        if (isPageTransitioning) {
            return
        }
        
        nPage = newPage
        isPageTransitioning = true
        appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.15)) {
                self.pageTransitionState = 0
            } completion: {
                self.page = newPage
                withAnimation(.easeOut(duration: 0.15)) {
                    self.pageTransitionState = 1
                } completion: {
                    self.isPageTransitioning = false
                }
            }
        }
        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
    }
}

struct PresentationPresentVX: View {
    var appearVXTransitionState: Double
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            stops: [
                                .init(color: AppColors.Primary500.color.opacity(0.25), location: 0),
                                .init(color: AppColors.Primary300.color.opacity(0.0), location: 1)
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
            
            // To add audio effect
            VStack {
                
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )

            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            stops: [
                                .init(color: AppColors.Primary300.color.opacity(0.0), location: 0),
                                .init(color: AppColors.Primary500.color.opacity(0.25), location: 1)
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
        }
        .frame(
            maxHeight: .infinity,
            alignment: .bottomTrailing
        )
        .opacity(appearVXTransitionState)
    }
}

struct PresentationPresentRegularView: View {
    let title: String;
    let presentationParts: [PresentationPart];
    @Binding var viewModel: PresentationPresentViewModel

    var goTo: ((_ viewType: PresentationViewType) -> Void)?
    var onClose: (() -> Void)?
    
    var body: some View {
        let page = viewModel.page
        let nPage = viewModel.nPage
        let isPageTransitioning = viewModel.isPageTransitioning

        let presentationPart = presentationParts[page]
        
        let lastPage = (presentationParts.count - 1)
        let isFirstPage = nPage <= 0
        let isLastPage = nPage >= lastPage
        
        PresentationPresentVX(appearVXTransitionState: viewModel.vxTransitionState)
        
        PresentationRegularLayoutView(
            imageAppearAnimationState: viewModel.appearTransitionState * viewModel.pageTransitionState
        ) {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Context")
                        .frame(
                            alignment: .leading
                        )
                        .font(.system(size: AppFontSize.xl2.rawValue, weight: .medium))
                        .foregroundStyle(AppColors.Gray400.color)
                    TokenizedTextView(tokens: presentationPart.content)
                        .font(.system(size: AppFontSize.xl2.rawValue, weight: .medium))
                        .opacity(viewModel.appearTransitionState * viewModel.pageTransitionState)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.Gray900.color)
                        .stroke(AppColors.Gray700.color, lineWidth: 1)
                )
                
                if (presentationPart.hint != nil) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Hints")
                                .frame(
                                    alignment: .leading
                                )
                                .font(.system(size: AppFontSize.xl2.rawValue, weight: .medium))
                                .foregroundStyle(AppColors.Gray400.color)
                            Spacer()
                            if (viewModel.hintsExpanded) {
                                AppButton(action: {
                                    viewModel.hintsExpandTransitionState = 1
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        self.viewModel.hintsExpandTransitionState = 0
                                    } completion: {
                                        viewModel.hintsExpanded = false
                                    }
                                    HapticsImpactLight.impactOccurred()
                                }) {
                                    HStack {
                                        Text("Hide Hints")
                                        Image(systemName: "chevron.down")
                                    }
                                }
                                .variant(.ghost)
                                .size(.large)
                                .paddingHorz(0)
                                .paddingVert(0)
                                .opacity(
                                    // Mimic opacity press animation, latter half. 0.1s latter. Transition animation takes 0.3s
                                    (min(viewModel.hintsExpandTransitionState * 3, 1)) * 0.7 + 0.3
                                )
                                .onAppear() {
                                    viewModel.animateExpand()
                                }
                            } else {
                                AppButton(action: {
                                    viewModel.hintsExpanded = true
                                    HapticsImpactLight.impactOccurred()
                                }) {
                                    HStack {
                                        Text("Show Hints")
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                .variant(.ghost)
                                .size(.large)
                                .paddingHorz(0)
                                .paddingVert(0)
                                .opacity(
                                    // Mimic opacity press animation, latter half. 0.1s latter. Transition animation takes 0.3s
                                    (min(viewModel.hintsExpandTransitionState * 3, 1)) * 0.7 + 0.3
                                )
                                .onAppear() {
                                    viewModel.animateExpand()
                                }
                            }
                        }
                        
                        if (viewModel.hintsExpanded) {
                            TokenizedTextView(tokens: presentationPart.hint!)
                                .font(.system(size: AppFontSize.xl2.rawValue, weight: .medium))
                                .opacity(viewModel.hintsExpandTransitionState * viewModel.appearTransitionState * viewModel.pageTransitionState)
                                .foregroundStyle(AppColors.Primary500.color)
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.Gray900.color)
                            .stroke(AppColors.Gray700.color, lineWidth: 1)
                    )
                }
            }
            
        }
        .title(title)
        .img("playground")

        PresentationToolbar(
            toolbarAppearTransitionState: viewModel.appearTransitionState,
            size: .large
        ) {
            AppButton(action: {
                viewModel.goToPage(newPage: page - 1)
                HapticsImpactLight.impactOccurred()
            }) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Back")
                }
                .foregroundStyle(AppColors.Primary50.color)
            }
            .variant(.ghost)
            .size(.large)
            .opacity(isFirstPage ? 0.3 : 1)
            .disabled(isFirstPage || isPageTransitioning)
            
            Text("\(page + 1) / \(lastPage + 1)")
                .font(.system(size: AppFontSize.xl.rawValue, weight: .medium))
                .foregroundColor(AppColors.Gray400.color)
            
            AppButton(action: {
                viewModel.goToPage(newPage: page + 1)
                HapticsImpactLight.impactOccurred()
            }) {
                HStack {
                    Text("Next")
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(AppColors.Primary50.color)
            }
            .variant(.ghost)
            .size(.large)
            .opacity(isLastPage ? 0.3 : 1)
            .disabled(isLastPage || isPageTransitioning)
            
            if (page >= lastPage) {
                AppButton(action: {
                    goTo?(.Overview)
                    HapticsImpactLight.impactOccurred()
                }) {
                    Text("Done")
                }
                .size(.large)
                .opacity(
                    nPage <= presentationParts.count ? viewModel.pageTransitionState : 1
                )
            } else {
                AppButton(action: {
                    goTo?(.Present)
                    HapticsImpactLight.impactOccurred()
                }) {
                    Text("Done")
                }
                .variant(.ghost)
                .size(.large)
                .opacity(
                    nPage >= presentationParts.count ? viewModel.pageTransitionState : 1
                )
            }
            
        }
        
        VStack {
            Spacer()
            VStack(spacing: 40) {
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.Primary500.color))
//                    .scaleEffect(12)
                LoadingSpinner(size: 80)
                
                VStack(spacing: 12) {
                    Text("Please Stand By")
                        .foregroundStyle(AppColors.Gray50.color)
                        .font(.system(size: AppFontSize.xl3.rawValue, weight: .bold))
                        .frame(
                            maxWidth: 320,
                            alignment: .center
                        )
                    Text("We are setting up your mic.")
                        .foregroundStyle(AppColors.Gray100.color)
                        .font(.system(size: AppFontSize.xl.rawValue, weight: .medium))
                        .frame(
                            maxWidth: 320,
                            alignment: .center
                        )
                }
            }
            .frame(
                maxWidth: .infinity
            )
            Spacer()
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(
            .black.opacity(0.5)
        )

        PresentationViewCloseButton(onClose: {
            onClose?()
        })
    }
    
}

struct PresentationPresentCompactView: View {
    let title: String;
    let presentationParts: [PresentationPart];
    
    @Binding var viewModel: PresentationPresentViewModel
//    @ObservedObject var speechRecognizer: SpeechRecgonizer
    
    var goTo: ((_ viewType: PresentationViewType) -> Void)?
    var onClose: (() -> Void)?
    
    var body: some View {
        let page = viewModel.page
        let nPage = viewModel.nPage
        let isPageTransitioning = viewModel.isPageTransitioning

        let presentationPart = presentationParts[page]
        
        let lastPage = (presentationParts.count - 1)
        let isFirstPage = nPage <= 0
        let isLastPage = nPage >= lastPage
        
        PresentationPresentVX(appearVXTransitionState: viewModel.vxTransitionState)

        PresentationCompactLayoutView(
            imageAppearAnimationState: viewModel.appearTransitionState * viewModel.pageTransitionState
        ) {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Context")
                        .frame(
                            alignment: .leading
                        )
                        .font(.system(size: AppFontSize.lg.rawValue, weight: .medium))
                        .foregroundStyle(AppColors.Gray400.color)
                    TokenizedTextView(tokens: presentationPart.content)
                        .font(.system(size: AppFontSize.lg.rawValue, weight: .medium))
                        .opacity(viewModel.appearTransitionState * viewModel.pageTransitionState)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.Gray900.color)
                        .stroke(AppColors.Gray700.color, lineWidth: 1)
                )
                
                if (presentationPart.hint != nil) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Hints")
                                .frame(
                                    alignment: .leading
                                )
                                .font(.system(size: AppFontSize.lg.rawValue, weight: .medium))
                                .foregroundStyle(AppColors.Gray400.color)
                            Spacer()
                            if (viewModel.hintsExpanded) {
                                AppButton(action: {
                                    viewModel.hintsExpandTransitionState = 1
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        self.viewModel.hintsExpandTransitionState = 0
                                    } completion: {
                                        viewModel.hintsExpanded = false
                                    }
                                    HapticsImpactLight.impactOccurred()
                                }) {
                                    HStack {
                                        Text("Hide Hints")
                                        Image(systemName: "chevron.down")
                                    }
                                }
                                .variant(.ghost)
                                .paddingHorz(0)
                                .paddingVert(0)
                                .opacity(
                                    // Mimic opacity press animation, latter half. 0.1s latter. Transition animation takes 0.3s
                                    (min(viewModel.hintsExpandTransitionState * 3, 1)) * 0.7 + 0.3
                                )
                                .onAppear() {
                                    viewModel.animateExpand()
                                }
                            } else {
                                AppButton(action: {
                                    viewModel.hintsExpanded = true
                                    HapticsImpactLight.impactOccurred()
                                }) {
                                    HStack {
                                        Text("Show Hints")
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                .variant(.ghost)
                                .paddingHorz(0)
                                .paddingVert(0)
                                .opacity(
                                    // Mimic opacity press animation, latter half. 0.1s latter. Transition animation takes 0.3s
                                    (min(viewModel.hintsExpandTransitionState * 3, 1)) * 0.7 + 0.3
                                )
                                .onAppear() {
                                    viewModel.animateExpand()
                                }
                            }
                        }
                        
                        if (viewModel.hintsExpanded) {
                            TokenizedTextView(tokens: presentationPart.hint!)
                                .font(.system(size: AppFontSize.lg.rawValue, weight: .medium))
                                .opacity(viewModel.appearTransitionState * viewModel.hintsExpandTransitionState * viewModel.pageTransitionState)
                                .foregroundStyle(AppColors.Primary500.color)
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.Gray900.color)
                            .stroke(AppColors.Gray700.color, lineWidth: 1)
                    )
                }
            }
        }
        .title(title)
        .img("playground")

        PresentationToolbar(
            toolbarAppearTransitionState: viewModel.appearTransitionState,
            size: .small
        ) {
            AppButton(action: {
                viewModel.goToPage(newPage: page - 1)
                HapticsImpactLight.impactOccurred()
            }) {
                HStack {
                    Image(systemName: "arrow.left")
                }
                .foregroundStyle(AppColors.Primary50.color)
            }
            .size(.small)
            .variant(.ghost)
            .opacity(isFirstPage ? 0.3 : 1)
            .disabled(isFirstPage || isPageTransitioning)
            
            Text("\(page + 1) / \(lastPage + 1)")
                .font(.system(size: AppFontSize.lg.rawValue, weight: .medium))
                .foregroundColor(AppColors.Gray400.color)
            
            AppButton(action: {
                viewModel.goToPage(newPage: page + 1)
                HapticsImpactLight.impactOccurred()
            }) {
                HStack {
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(AppColors.Primary50.color)
            }
            .size(.small)
            .variant(.ghost)
            .opacity(isLastPage ? 0.3 : 1)
            .disabled(isLastPage || isPageTransitioning)
            
            if (page >= lastPage) {
                AppButton(action: {
                    goTo?(.Overview)
                    HapticsImpactLight.impactOccurred()
                }) {
                    Text("Done")
                }
                .opacity(
                    nPage <= presentationParts.count ? viewModel.pageTransitionState : 1
                )
            } else {
                AppButton(action: {
                    goTo?(.Overview)
                    HapticsImpactLight.impactOccurred()
                }) {
                    Text("Done")
                }
                .variant(.ghost)
                .opacity(
                    nPage >= presentationParts.count ? viewModel.pageTransitionState : 1
                )
            }
        }
        
        PresentationViewCloseButton(onClose: {
            onClose?()
        })
    }
}

struct PresentationPresentView: View {
    let title: String;
    let presentationParts: [PresentationPart];

    @Binding var viewType: PresentationViewType
    @State var viewModel = PresentationPresentViewModel()
    @StateObject var speechRecognizer = SpeechRecgonizer()
    
    let temp = Temp()

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if (horizontalSizeClass == .compact) {
            PresentationPresentCompactView(
                title: title,
                presentationParts: presentationParts,
                viewModel: $viewModel,
                goTo: goTo,
                onClose: onClose
            ).onAppear() {
                animateIn()
                speechRecognizer.start()
            }
            .onDisappear() {
                speechRecognizer.stop()
            }
        } else {
            PresentationPresentRegularView(
                title: title,
                presentationParts: presentationParts,
                viewModel: $viewModel,
                goTo: goTo,
                onClose: onClose
            ).onAppear() {
                animateIn()
                speechRecognizer.start()
//                Task {
//                    try? await Task.sleep(nanoseconds: 2_000_000_000)
//                    print("Ready")
//                    let ae = await self.speechRecognizer.getAudioEngine()
//                    guard let ae else {
//                        print("Fuck!")
//                        return
//                    }
//                    print("Is running? \(ae.isRunning)")
//                    temp.temp(avAudioEngine: ae)
//                    try? await Task.sleep(nanoseconds: 2_000_000_000)
//                    print("Stopped!!!")
//                    speechRecognizer.stopTranscribing()
//
//                }
//                Task {
//                    try? await Task.sleep(nanoseconds: 1_000_000_000)
//                    print("Crashing audio")
//                    simulateAudioInterrupt()
//                }
            }
            .onDisappear() {
                print("Stopped!")
                speechRecognizer.stop()
            }
        }
    }
    
    @State var cancellables = Set<AnyCancellable>()
    
    private func simulateAudioInterrupt() {
        // Create a new audio session with different settings
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        try? audioSession.setCategory(.playback)
        try? audioSession.setActive(true)
    }

    func onClose() {
        if (viewModel.appearTransitionWorkItem != nil) {
            viewModel.appearTransitionWorkItem!.cancel()
        }
        
        goTo(viewType: .Overview)
    }
    
    func animateIn() {
        if (viewModel.appearTransitionWorkItem != nil) {
            viewModel.appearTransitionWorkItem!.cancel()
        }
        
        viewModel.vxTransitionState = 0
        viewModel.appearTransitionState = 0
        viewModel.appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeIn(duration: 0.3)) {
                self.viewModel.appearTransitionState = 1
            }
            
            withAnimation(.easeIn(duration: 0.75)) {
                self.viewModel.vxTransitionState = 1
            }
        }
        DispatchQueue.main.async(execute: viewModel.appearTransitionWorkItem!)
    }
    
    func goTo(viewType: PresentationViewType) {
        if (viewModel.appearTransitionWorkItem != nil) {
            viewModel.appearTransitionWorkItem!.cancel()
        }
        
        viewModel.appearTransitionState = 1
        viewModel.vxTransitionState = 1
        viewModel.appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.3)) {
                self.viewModel.appearTransitionState = 0
                self.viewModel.vxTransitionState = 0
            } completion: {
                self.viewType = viewType
            }
        }
        DispatchQueue.main.async(execute: viewModel.appearTransitionWorkItem!)
    }
    
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

//    private func endScrum() {
//        speechRecognizer.stopTranscribing()
//
////        scrumTimer.stopScrum()
////        let newHistory = History(attendees: scrum.attendees)
////        scrum.history.insert(newHistory, at: 0)
//    }

}

class Temp {
    func temp(avAudioEngine: AVAudioEngine) {
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleInterruption),
//                                               name: AVAudioSession.interruptionNotification,
//                                               object: AVAudioSession.sharedInstance())
//        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleInterruption),
//                                               name: AVAudioSession.routeChangeNotification,
//                                               object: AVAudioSession.sharedInstance())
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: .AVAudioEngineConfigurationChange,
                                               object: avAudioEngine)
        

    }
    
    @objc func handleInterruption(notification: Notification) {
        print("Test!")
    }
}
