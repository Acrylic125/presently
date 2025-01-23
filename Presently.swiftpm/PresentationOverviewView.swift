import SwiftUI

@Observable
final class PresentationOverviewViewModel {
    var appearTransitionWorkItem: DispatchWorkItem? = nil
    var appearTransitionState: Double = 0
}

struct PresentationOverviewRegularView: View {
    let title: String;
    let context: [StringToken];
    @Binding var viewModel: PresentationOverviewViewModel

    var goTo: ((_ viewType: PresentationViewType) -> Void)?
    var onClose: (() -> Void)?
    
    var body: some View {
        PresentationRegularLayoutView(
            imageAppearAnimationState: viewModel.appearTransitionState
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Context")
                    .frame(
                        alignment: .leading
                    )
                    .font(.system(size: AppFontSize.xl2.rawValue, weight: .medium))
                    .foregroundStyle(AppColors.Gray400.color)
                TokenizedTextView(tokens: context)
                    .font(.system(size: AppFontSize.xl2.rawValue, weight: .medium))
                    .opacity(viewModel.appearTransitionState)
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
        .title(title)
        .img("playground")

        // Toolbar
        PresentationToolbar(
            toolbarAppearTransitionState: viewModel.appearTransitionState,
            size: .large
        ) {
            AppButton(action: {
                guard let goTo else {
                    return
                }
                goTo(.Prepare)
                HapticsImpactLight.impactOccurred()
            }) {
                Text("Prepare")
            }
            .variant(.ghost)
            .size(.large)
            
            AppButton(action: {
                guard let goTo else {
                    return
                }
                goTo(.Present)
                HapticsImpactLight.impactOccurred()
            }) {
                Text("Start")
            }
            .size(.large)
        }
        
        PresentationViewCloseButton(onClose: {
            guard let onClose else {
                return
            }
            onClose()
        })
    }
    
}

struct PresentationOverviewCompactView: View {
    let title: String;
    let context: [StringToken];
    @Binding var viewModel: PresentationOverviewViewModel

    var goTo: ((_ viewType: PresentationViewType) -> Void)?
    var onClose: (() -> Void)?

    var body: some View {
        PresentationCompactLayoutView(
            imageAppearAnimationState: viewModel.appearTransitionState
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Context")
                    .frame(
                        alignment: .leading
                    )
                    .font(.system(size: AppFontSize.lg.rawValue, weight: .medium))
                    .foregroundStyle(AppColors.Gray400.color)
                TokenizedTextView(tokens: context)
                    .font(.system(size: AppFontSize.lg.rawValue, weight: .medium))
                    .opacity(viewModel.appearTransitionState)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .topLeading
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.Gray900.color)
                    .stroke(AppColors.Gray700.color, lineWidth: 1)
            )
        }
        .title(title)
        .img("playground")

        // Toolbar
        PresentationToolbar(
            toolbarAppearTransitionState: viewModel.appearTransitionState,
            size: .large
        ) {
            AppButton(action: {
                guard let goTo else {
                    return
                }
                goTo(.Prepare)
                HapticsImpactLight.impactOccurred()
            }) {
                Text("Prepare")
            }
            .variant(.ghost)
            
            AppButton(action: {
                guard let goTo else {
                    return
                }
                goTo(.Present)
                HapticsImpactLight.impactOccurred()
            }) {
                Text("Start")
            }
        }
        
        PresentationViewCloseButton(onClose: {
            guard let onClose else {
                return
            }
            onClose()
        })
    }
}

struct PresentationOverviewView: View {
    let title: String;
    let context: [StringToken];
    
    @Binding var viewType: PresentationViewType
    @State var viewModel = PresentationOverviewViewModel()
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if (horizontalSizeClass == .compact) {
             PresentationOverviewCompactView(
                title: title,
                context: context,
                viewModel: $viewModel,
                goTo: self.goTo,
                onClose: self.onClose
            ).onAppear() {
                animateIn()
            }
        } else {
             PresentationOverviewRegularView(
                title: title,
                context: context,
                viewModel: $viewModel,
                goTo: self.goTo,
                onClose: self.onClose
            ).onAppear() {
                animateIn()
            }
        }
    }
    
    func onClose() {
        if (viewModel.appearTransitionWorkItem != nil) {
            viewModel.appearTransitionWorkItem!.cancel()
        }
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
