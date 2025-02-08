import SwiftUI

@Observable
final class PresentationOverviewViewModel {
    var appearTransitionWorkItem: DispatchWorkItem? = nil
    var appearTransitionState: Double = 0
}

struct PresentationOverviewContentView: View {
    let size: AppContentSize
    let context: [StringToken];
    @Binding var viewModel: PresentationOverviewViewModel

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
                TokenizedTextView(tokens: context)
                    .font(.system(size: containerTextSize.rawValue, weight: .medium))
                    .opacity(viewModel.appearTransitionState)
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
            .opacity(viewModel.appearTransitionState)
        }
    }
}

struct PresentationOverviewScreen: View {
    let title: String;
    let context: [StringToken];
    let img: String;
    let firstPartId: String
    
    @Binding var viewType: PresentationViewType
    @State var viewModel = PresentationOverviewViewModel()
    @ObservedObject var speechRecognizer: SpeechRecgonizer

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let buttonSize: AppButtonSize = horizontalSizeClass == .regular ? .large : .small
        let toolbarSize: PresentationToolbarSize = horizontalSizeClass == .regular ? .large : .small

        if horizontalSizeClass == .regular {
            PresentationRegularLayoutView(
                imageAppearAnimationState: viewModel.appearTransitionState
            ) {
                PresentationOverviewContentView(
                    size: .large,
                    context: context,
                    viewModel: $viewModel
                )
            }
            .title(title)
            .img(img)
        } else {
            PresentationCompactLayoutView(
                imageAppearAnimationState: viewModel.appearTransitionState
            ) {
                PresentationOverviewContentView(
                    size: .small,
                    context: context,
                    viewModel: $viewModel
                )

            }
            .title(title)
            .img(img)
        }

        // Toolbar
        PresentationToolbar(
            toolbarAppearTransitionState: viewModel.appearTransitionState,
            size: toolbarSize
        ) {
            AppButton(action: {
                goTo(viewType: .Prepare)
            }) {
                Text("Prepare")
            }
            .variant(.ghost)
            .size(buttonSize)
            
            AppButton(action: {
                speechRecognizer.resetSession()
                speechRecognizer.start(partId: firstPartId)
                goTo(viewType: .Present)
            }) {
                Text("Start")
            }
            .size(buttonSize)
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
        dismiss()
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
