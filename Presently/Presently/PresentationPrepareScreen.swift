import SwiftUI

@Observable
final class PresentationPrepareViewModel {
    var appearTransitionWorkItem: DispatchWorkItem? = nil
    var appearTransitionState: Double = 0
    
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

struct PresentationPrepareContentView: View {
    let size: AppContentSize
    let presentationPart: PresentationPart
    @Binding var viewModel: PresentationPrepareViewModel
    
    var body: some View {
        let containerPadding: CGFloat = size == .large ? 24 : 12
        let containerSpacing: CGFloat = size == .large ? 12 : 8
        let containerBorderRadius: CGFloat = size == .large ? 16 : 8
        let containerTextSize: AppFontSize = size == .large ? .xl2 : .lg
        let titleTextSize: AppFontSize = size == .large ? .xl2 : .xl

        VStack(alignment: .leading, spacing: size == .large ? 24 : 16) {
            Text(presentationPart.title)
                .frame(
                    maxWidth: 400,
                    alignment: .leading
                )
                .font(.system(size: titleTextSize.rawValue, weight: .black))
                .foregroundStyle(AppColors.Gray50.color)
                .opacity(viewModel.appearTransitionState * viewModel.pageTransitionState)

            VStack(alignment: .leading, spacing: containerSpacing) {
                Text("Talking Points")
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
            .padding(containerPadding)
            .background(
                RoundedRectangle(cornerRadius: containerBorderRadius)
                    .fill(AppColors.Gray900.color)
                    .stroke(AppColors.Gray700.color, lineWidth: 1)
            )
            .opacity(viewModel.appearTransitionState)

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
                .padding(containerPadding)
                .background(
                    RoundedRectangle(cornerRadius: containerBorderRadius)
                        .fill(AppColors.Gray900.color)
                        .stroke(AppColors.Gray700.color, lineWidth: 1)
                )
                .opacity(viewModel.appearTransitionState)
            }
        }
    }
}

struct PresentationPrepareScreen: View {
    let title: String;
    let presentationParts: [PresentationPart];

    @Binding var viewType: PresentationViewType
    @State var viewModel = PresentationPrepareViewModel()
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
        
        let buttonSize: AppButtonSize = horizontalSizeClass == .regular ? .large : .small
        let toolbarSize: PresentationToolbarSize = horizontalSizeClass == .regular ? .large : .small

        if horizontalSizeClass == .regular {
            PresentationRegularLayoutView(
                imageAppearAnimationState: viewModel.appearTransitionState * viewModel.pageTransitionState
            ) {
                PresentationPrepareContentView(
                    size: .large,
                    presentationPart: presentationPart,
                    viewModel: $viewModel
                )
            }
            .title(title)
            .img(presentationPart.img)
        } else {
            PresentationCompactLayoutView(
                imageAppearAnimationState: viewModel.appearTransitionState * viewModel.pageTransitionState
            ) {
                PresentationPrepareContentView(
                    size: .small,
                    presentationPart: presentationPart,
                    viewModel: $viewModel
                )
            }
            .title(title)
            .img(presentationPart.img)
        }

        PresentationToolbar(
            toolbarAppearTransitionState: viewModel.appearTransitionState,
            size: toolbarSize
        ) {
            AppButton(action: {
                viewModel.goToPage(newPage: page - 1)
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
                    speechRecognizer.resetSession()
                    speechRecognizer.start(partId: presentationParts[0].id)
                    goTo(viewType: .Present)
                }) {
                    Text("Start")
                }
                .size(buttonSize)
                .opacity(
                    nPage <= presentationParts.count ? viewModel.pageTransitionState : 1
                )
            } else {
                AppButton(action: {
                    speechRecognizer.resetSession()
                    speechRecognizer.start(partId: presentationParts[0].id)
                    goTo(viewType: .Present)
                }) {
                    Text("Start")
                }
                .variant(.ghost)
                .size(buttonSize)
                .opacity(
                    nPage >= presentationParts.count ? viewModel.pageTransitionState : 1
                )
            }
        }
        
        PresentationViewCloseButton(onClose: self.onClose)
            .onAppear() {
                animateIn()
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
        
        viewModel.appearTransitionState = 0
        viewModel.appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeIn(duration: 0.3)) {
                self.viewModel.appearTransitionState = 1
            }
        }
        DispatchQueue.main.async(execute: viewModel.appearTransitionWorkItem!)
    }
    
    func goTo(viewType: PresentationViewType) {
        if (viewModel.appearTransitionWorkItem != nil) {
            viewModel.appearTransitionWorkItem!.cancel()
        }
        
        viewModel.appearTransitionState = 1
        viewModel.appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.3)) {
                self.viewModel.appearTransitionState = 0
            } completion: {
                self.viewType = viewType
            }
        }
        DispatchQueue.main.async(execute: viewModel.appearTransitionWorkItem!)
    }

}
