import SwiftUI

@Observable
final class PresentationOverviewViewModel {
    @Binding var viewType: PresentationViewType
    
    var appearTransitionWorkItem: DispatchWorkItem? = nil
    var appearTransitionState: Double = 0
    
    init(viewType: Binding<PresentationViewType>) {
        self._viewType = viewType
    }
    
    func animateIn() {
        if (appearTransitionWorkItem != nil) {
            appearTransitionWorkItem!.cancel()
        }
        
        appearTransitionState = 0
        appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeIn(duration: 0.3)) {
                self.appearTransitionState = 1
            }
        }
        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
    }
    
    func goTo(viewType: PresentationViewType) {
        if (appearTransitionWorkItem != nil) {
            appearTransitionWorkItem!.cancel()
        }
        
        appearTransitionState = 1
        appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.3)) {
                self.appearTransitionState = 0
            } completion: {
                print("Completed")
                self.viewType = viewType
            }
        }
        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
    }
}

struct PresentationOverviewRegularView: View {
    let title: String;
    let context: [StringToken];
    
    @Binding var viewType: PresentationViewType
    
    @State private var appearTransitionWorkItem: DispatchWorkItem?
    @State private var appearTransitionState: Double = 0

    func animateIn() {
        if (appearTransitionWorkItem != nil) {
            appearTransitionWorkItem!.cancel()
        }
        
        appearTransitionState = 0
        appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeIn(duration: 0.3)) {
                appearTransitionState = 1
            }
        }
        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
    }
    
    func goTo(viewType: PresentationViewType) {
        if (appearTransitionWorkItem != nil) {
            appearTransitionWorkItem!.cancel()
        }
        
        appearTransitionState = 1
        appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.3)) {
                appearTransitionState = 0
            } completion: {
                print("Completed")
                self.viewType = viewType
            }
        }
        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
    }
    
    var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        
        PresentationRegularLayoutView(
            imageAppearAnimationState: $appearTransitionState
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
                    .opacity(appearTransitionState)
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
        // Will attach to toolbar but can be placed anywhere.
        .onAppear() {
            animateIn()
        }

        // Toolbar
        VStack {
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    AppButton(action: {
                        goTo(viewType: .Prepare)
                        HapticsImpactLight.impactOccurred()
                    }) {
                        Text("Prepare")
                    }
                    .variant(.ghost)
                    .size(.large)

                    AppButton(action: {
                        goTo(viewType: .Present)
                        HapticsImpactLight.impactOccurred()
                    }) {
                        Text("Start")
                    }
                    .size(.large)
                }
                .frame(
                    alignment: .center
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.Gray900.color.opacity(0.75))
                        .stroke(AppColors.Gray700.color, lineWidth: 1)
                )
                Spacer()
            }
        }
        .frame(
            maxHeight: .infinity,
            alignment: .bottomTrailing
        )
        .safeAreaPadding(safeAreaInsets)
        .padding(.horizontal, 24)
        .padding(.bottom, 48)
        
        PresentationViewCloseButton(onClose: {
            if (appearTransitionWorkItem != nil) {
                appearTransitionWorkItem!.cancel()
            }
        })
    }
}

struct PresentationOverviewCompactView: View {
    let title: String;
    let context: [StringToken];
    
    @Binding var viewType: PresentationViewType
    
    @State private var appearTransitionWorkItem: DispatchWorkItem?
    @State private var appearTransitionState: Double = 0
    
    func animateIn() {
        if (appearTransitionWorkItem != nil) {
            appearTransitionWorkItem!.cancel()
        }
        
        appearTransitionState = 0
        appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeIn(duration: 0.3)) {
                appearTransitionState = 1
            }
        }
        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
    }
    
    func goTo(viewType: PresentationViewType) {
        if (appearTransitionWorkItem != nil) {
            appearTransitionWorkItem!.cancel()
        }
        
        appearTransitionState = 1
        appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.3)) {
                appearTransitionState = 0
            } completion: {
                self.viewType = viewType
            }
        }
        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
    }

    var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        
        PresentationCompactLayoutView(
            imageAppearAnimationState: $appearTransitionState
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
                    .opacity(appearTransitionState)
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
        // Will attach to toolbar but can be placed anywhere.
        .onAppear() {
            animateIn()
        }

        // Toolbar
        VStack {
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    AppButton(action: {
                        goTo(viewType: .Prepare)
                        HapticsImpactLight.impactOccurred()
                    }) {
                        Text("Prepare")
                    }
                    .variant(.ghost)

                    AppButton(action: {
                        goTo(viewType: .Present)
                        HapticsImpactLight.impactOccurred()
                    }) {
                        Text("Start")
                    }
                }
                .frame(
                    alignment: .center
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.Gray900.color.opacity(0.75))
                        .stroke(AppColors.Gray700.color, lineWidth: 1)
                )
                Spacer()
            }
        }
        .frame(
            maxHeight: .infinity,
            alignment: .bottomTrailing
        )
        .safeAreaPadding(safeAreaInsets)
        .padding(.horizontal, 24)
        .padding(.bottom, 48)
        
        PresentationViewCloseButton(onClose: {
            if (appearTransitionWorkItem != nil) {
                appearTransitionWorkItem!.cancel()
            }
        })
    }
}


struct PresentationOverviewView: View {
    let title: String;
    let context: [StringToken];
    
    @Binding var viewType: PresentationViewType

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if (horizontalSizeClass == .compact) {
            PresentationOverviewCompactView(
                title: title,
                context: context,
                viewType: $viewType
            )
        } else {
            PresentationOverviewRegularView(
                title: title,
                context: context,
                viewType: $viewType
            )
        }
    }
}
