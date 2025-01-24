import SwiftUI
import Combine
import AVFoundation

@Observable
final class PresentationPresentViewModel {
    var appearTransitionWorkItem: DispatchWorkItem? = nil
    var appearTransitionState: Double = 0
    
    var vxTransitionState: Double = 0
    
    var showStatusViewAppearState: Double = 0
    var shouldShowSttusView: Bool = false
    
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

struct PresentstionPresentStatusView: View {
    let size: AppContentSize
    let state: SpeechRecognizerState
    let error: Error?
    
    var body: some View {
        
        if (state == .inactive) {
            let buttonSize: AppButtonSize = size == .large ? .large : .small
            
            let spacing: CGFloat = size == .large ? 24 : 12
            let textSpacing: CGFloat = size == .large ? 12 : 8
            let buttonSpacing: CGFloat = size == .large ? 16 : 12
            let iconSize: CGFloat = size == .large ? 48 : 32
            
            let containerPadding: CGFloat = size == .large ? 24 : 12
            let containerBorderRadius: CGFloat = size == .large ? 16 : 12

            let headerFontSize: AppFontSize = size == .large ? .xl3 : .xl
            let textFontSize: AppFontSize = size == .large ? .xl : .lg

            VStack {
                Spacer()
                VStack(spacing: spacing) {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(AppColors.Red400.color)
                    }
                    .frame(
                        height: iconSize
                    )
                    .clipped()
                    
                    VStack(spacing: textSpacing) {
                        if let error {
                            Text("Something went wrong!")
                                .foregroundStyle(AppColors.Red400.color)
                                .font(.system(size: headerFontSize.rawValue, weight: .bold))
                                .multilineTextAlignment(.center)
                            Text(asErrorMessage(error: error))
                                .foregroundStyle(AppColors.Gray100.color)
                                .font(.system(size: textFontSize.rawValue, weight: .medium))
                                .multilineTextAlignment(.center)
                        } else {
                            Text("Presentation paused!")
                                .foregroundStyle(AppColors.Primary500.color)
                                .font(.system(size: headerFontSize.rawValue, weight: .bold))
                                .multilineTextAlignment(.center)
                            Text("The Presentation is currently not being recorded.")
                                .foregroundStyle(AppColors.Gray100.color)
                                .font(.system(size: textFontSize.rawValue, weight: .medium))
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    HStack(spacing: buttonSpacing) {
                        AppButton(action: {}) {
                            Text("Back")
                        }
                        .size(buttonSize)
                        .variant(.ghost)
                        
                        AppButton(action: {}) {
                            Text("Retry")
                        }
                        .size(buttonSize)
                    }
                    
                }
                .frame(
                    maxWidth: 480
                )
                .padding(.horizontal, containerPadding)
                .padding(.top, containerPadding + spacing)
                .padding(.bottom, containerPadding)
                .background(
                    RoundedRectangle(cornerRadius: containerBorderRadius)
                        .fill(AppColors.Gray950.color)
                        .stroke(AppColors.Red400.color, lineWidth: 1)
                )
                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .padding(24)
            .background(
                .black.opacity(0.5)
            )
        } else if (state == .starting) {
            let spacing: CGFloat = size == .large ? 40 : 32
            let textSpacing: CGFloat = size == .large ? 12 : 8

            let loaderSize: Double = size == .large ? 80 : 64
            let headerFontSize: AppFontSize = size == .large ? .xl3 : .xl
            let textFontSize: AppFontSize = size == .large ? .xl : .lg
            
            VStack {
                Spacer()
                VStack(spacing: spacing) {
                    LoadingSpinner(size: loaderSize)
                    
                    VStack(spacing: textSpacing) {
                        Text("Please Stand By")
                            .foregroundStyle(AppColors.Gray50.color)
                            .font(.system(size: headerFontSize.rawValue, weight: .bold))
                            .frame(
                                maxWidth: 320,
                                alignment: .center
                            )
                        Text("We are setting up your mic.")
                            .foregroundStyle(AppColors.Gray100.color)
                            .font(.system(size: textFontSize.rawValue, weight: .medium))
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
        }
    }
}

struct PresentationPresentContentView: View {
    let size: AppContentSize
    let presentationPart: PresentationPart
    @Binding var viewModel: PresentationPresentViewModel
    
    var body: some View {
        let containerPadding: CGFloat = size == .large ? 24 : 12
        let containerSpacing: CGFloat = size == .large ? 12 : 8
        let containerBorderRadius: CGFloat = size == .large ? 16 : 8
        let containerTextSize: AppFontSize = size == .large ? .xl2 : .lg
        
        VStack(spacing: size == .large ? 24 : 16) {
            VStack(alignment: .leading, spacing: containerSpacing) {
                Text("Context")
                    .frame(
                        alignment: .leading
                    )
                    .font(.system(size: containerTextSize.rawValue, weight: .medium))
                    .foregroundStyle(AppColors.Gray400.color)
                TokenizedTextView(tokens: presentationPart.content)
                    .font(.system(size: containerTextSize.rawValue, weight: .medium))
                    .opacity(viewModel.appearTransitionState * viewModel.pageTransitionState)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding(.horizontal, containerPadding)
            .padding(.vertical, containerPadding)
            .background(
                RoundedRectangle(cornerRadius: containerBorderRadius)
                    .fill(AppColors.Gray900.color)
                    .stroke(AppColors.Gray700.color, lineWidth: 1)
            )
            
            if (presentationPart.hint != nil) {
                VStack(alignment: .leading, spacing: containerSpacing) {
                    HStack {
                        Text("Hints")
                            .frame(
                                alignment: .leading
                            )
                            .font(.system(size: containerTextSize.rawValue, weight: .medium))
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
                            .font(.system(size: containerTextSize.rawValue, weight: .medium))
                            .opacity(viewModel.appearTransitionState * viewModel.hintsExpandTransitionState * viewModel.pageTransitionState)
                            .foregroundStyle(AppColors.Primary500.color)
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(.horizontal, containerPadding)
                .padding(.vertical, containerPadding)
                .background(
                    RoundedRectangle(cornerRadius: containerBorderRadius)
                        .fill(AppColors.Gray900.color)
                        .stroke(AppColors.Gray700.color, lineWidth: 1)
                )
            }
        }
    }
}

struct PresentationPresentView: View {
    let title: String;
    let presentationParts: [PresentationPart];

    @Binding var viewType: PresentationViewType
    @State var viewModel = PresentationPresentViewModel()
    @ObservedObject var speechRecognizer: SpeechRecgonizer

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        let page = viewModel.page
        let nPage = viewModel.nPage
        let isPageTransitioning = viewModel.isPageTransitioning
        
        let presentationPart = presentationParts[page]
        
        let lastPage = (presentationParts.count - 1)
        let isFirstPage = nPage <= 0
        let isLastPage = nPage >= lastPage
        
        let appContentSize: AppContentSize = horizontalSizeClass == .regular ? .large : .small
        let buttonSize: AppButtonSize = horizontalSizeClass == .regular ? .large : .small
        let toolbarSize: PresentationToolbarSize = horizontalSizeClass == .regular ? .large : .small
        
        PresentationPresentVX(appearVXTransitionState: viewModel.vxTransitionState)
        
        if horizontalSizeClass == .regular {
            PresentationRegularLayoutView(
                imageAppearAnimationState: viewModel.appearTransitionState * viewModel.pageTransitionState
            ) {
                PresentationPresentContentView(
                    size: .large,
                    presentationPart: presentationPart,
                    viewModel: $viewModel
                )
            }
            .title(title)
            .img("playground")
        } else {
            PresentationCompactLayoutView(
                imageAppearAnimationState: viewModel.appearTransitionState * viewModel.pageTransitionState
            ) {
                PresentationPresentContentView(
                    size: .small,
                    presentationPart: presentationPart,
                    viewModel: $viewModel
                )
            }
            .title(title)
            .img("playground")
        }
        
        PresentationToolbar(
            toolbarAppearTransitionState: viewModel.appearTransitionState,
            size: toolbarSize
        ) {
            AppButton(action: {
                viewModel.goToPage(newPage: page - 1)
                HapticsImpactLight.impactOccurred()
            }) {
                HStack {
                    Image(systemName: "arrow.left")
                    if (horizontalSizeClass == .regular) {
                        Text("Back")
                    }
                }
                .foregroundStyle(AppColors.Primary50.color)
            }
            .variant(.ghost)
            .size(buttonSize)
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
                    if (horizontalSizeClass == .regular) {
                        Text("Next")
                    }
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(AppColors.Primary50.color)
            }
            .variant(.ghost)
            .size(buttonSize)
            .opacity(isLastPage ? 0.3 : 1)
            .disabled(isLastPage || isPageTransitioning)
            
            if (page >= lastPage) {
                AppButton(action: {
                    goTo(viewType: .Overview)
                    HapticsImpactLight.impactOccurred()
                }) {
                    Text("Done")
                }
                .size(buttonSize)
                .opacity(
                    nPage <= presentationParts.count ? viewModel.pageTransitionState : 1
                )
            } else {
                AppButton(action: {
                    goTo(viewType: .Overview)
                    HapticsImpactLight.impactOccurred()
                }) {
                    Text("Done")
                }
                .variant(.ghost)
                .size(buttonSize)
                .opacity(
                    nPage >= presentationParts.count ? viewModel.pageTransitionState : 1
                )
            }
        }
        
        if viewModel.shouldShowSttusView {
            PresentstionPresentStatusView(
                size: appContentSize,
                state: speechRecognizer.state,
                error: speechRecognizer.error
            )
            .opacity(self.viewModel.showStatusViewAppearState)
            .onAppear() {
                viewModel.showStatusViewAppearState = 0
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.viewModel.showStatusViewAppearState = 1
                }
            }
        }
        
        PresentationViewCloseButton(onClose: self.onClose)
            .onAppear() {
                animateIn()
            }
            .onDisappear() {
                speechRecognizer.stop()
            }
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
        
        viewModel.shouldShowSttusView = false
        
        viewModel.vxTransitionState = 0
        viewModel.appearTransitionState = 0
        viewModel.appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeIn(duration: 0.3)) {
                self.viewModel.appearTransitionState = 1
            } completion: {
                viewModel.shouldShowSttusView = true
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
                self.viewModel.showStatusViewAppearState = 0
            } completion: {
                self.viewType = viewType
            }
        }
        DispatchQueue.main.async(execute: viewModel.appearTransitionWorkItem!)
    }
    
}
