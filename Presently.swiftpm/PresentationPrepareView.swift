import SwiftUI

@Observable
final class PresentationPrepareViewModel {
    var appearTransitionWorkItem: DispatchWorkItem? = nil
    var appearTransitionState: Double = 0
    
    var expandTransitionState: Double = 1

    // Pagination
    var page = 0;
    var nPage = 0;
    var isPageTransitioning: Bool = false;
    
    func goToPage(newPage: Int) {
        if (isPageTransitioning) {
            return
        }
        
        nPage = newPage
        isPageTransitioning = true
        appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.15)) {
                self.appearTransitionState = 0
            } completion: {
                self.page = newPage
                withAnimation(.easeOut(duration: 0.15)) {
                    self.appearTransitionState = 1
                } completion: {
                    self.isPageTransitioning = false
                }
            }
        }
        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
    }
}

struct PresentationPrepareRegularView: View {
    let title: String;
    let presentationParts: [PresentationPart];
    @Binding var viewModel: PresentationPrepareViewModel

    var goTo: ((_ viewType: PresentationViewType) -> Void)?
    var onClose: (() -> Void)?
    
    @State var hintsExpanded = false
    
    func animateExpand() {
        viewModel.expandTransitionState = 0
        withAnimation(.easeInOut(duration: 0.3)) {
            self.viewModel.expandTransitionState = 1
        }
    }
    
    var body: some View {
        let page = viewModel.page
        let nPage = viewModel.nPage
        let isPageTransitioning = viewModel.isPageTransitioning

        let safeAreaInsets = getSafeAreaInset()
        let presentationPart = presentationParts[page]
        
        let lastPage = (presentationParts.count - 1)
        let isFirstPage = nPage <= 0
        let isLastPage = nPage >= lastPage

        PresentationRegularLayoutView(
            imageAppearAnimationState: $viewModel.appearTransitionState
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
                
                if (presentationPart.hint != nil) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Context")
                                .frame(
                                    alignment: .leading
                                )
                                .font(.system(size: AppFontSize.xl2.rawValue, weight: .medium))
                                .foregroundStyle(AppColors.Gray400.color)
                            Spacer()
                            if (hintsExpanded) {
                                AppButton(action: {
                                    viewModel.expandTransitionState = 1
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        self.viewModel.expandTransitionState = 0
                                    } completion: {
                                        hintsExpanded = false
                                    }
                                    HapticsImpactLight.impactOccurred()
                                }) {
                                    HStack {
                                        Text("Show Hints")
                                        Image(systemName: "chevron.down")
                                    }
                                }
                                .variant(.ghost)
                                .size(.large)
                                .paddingHorz(0)
                                .paddingVert(0)
                                .opacity(viewModel.expandTransitionState)
                                .onAppear() {
                                    animateExpand()
                                }
                            } else {
                                AppButton(action: {
                                    hintsExpanded = true
                                    HapticsImpactLight.impactOccurred()
                                }) {
                                    HStack {
                                        Text("Hide Hints")
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                .variant(.ghost)
                                .size(.large)
                                .paddingHorz(0)
                                .paddingVert(0)
                                .opacity(viewModel.expandTransitionState)
                                .onAppear() {
                                    animateExpand()
                                }
                            }
                        }
                        
                        if (hintsExpanded) {
                            TokenizedTextView(tokens: presentationPart.hint!)
                                .font(.system(size: AppFontSize.xl2.rawValue, weight: .medium))
                                .opacity(viewModel.expandTransitionState)
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

        // Toolbar
        VStack {
            HStack {
                Spacer()
                HStack {
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
                    
                    Text("\(page + 1)")
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
                            guard let goTo else {
                                return
                            }
                            goTo(.Present)
                            HapticsImpactLight.impactOccurred()
                        }) {
                            Text("Start")
                        }
                        .size(.large)
                        .opacity(
                            nPage <= presentationParts.count ? viewModel.appearTransitionState : 1
                        )
                    } else {
                        AppButton(action: {
                            guard let goTo else {
                                return
                            }
                            goTo(.Present)
                            HapticsImpactLight.impactOccurred()
                        }) {
                            Text("Start")
                        }
                        .variant(.ghost)
                        .size(.large)
                        .opacity(
                            nPage >= presentationParts.count ? viewModel.appearTransitionState : 1
                        )
                    }
                }
                .frame(
                    alignment: .center
                )
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.Gray800.color.opacity(0.75))
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
            guard let onClose else {
                return
            }
            onClose()
        })
    }
    
}

struct PresentationPrepareCompactView: View {
    let title: String;
    let presentationParts: [PresentationPart];
    @Binding var viewModel: PresentationPrepareViewModel

    var goTo: ((_ viewType: PresentationViewType) -> Void)?
    var onClose: (() -> Void)?
    
    @State var hintsExpanded = false
    
    var body: some View {
        let page = viewModel.page
        let nPage = viewModel.nPage
        let isPageTransitioning = viewModel.isPageTransitioning

        let safeAreaInsets = getSafeAreaInset()
        let presentationPart = presentationParts[page]
        
        let lastPage = (presentationParts.count - 1)
        let isFirstPage = nPage <= 0
        let isLastPage = nPage >= lastPage

        PresentationCompactLayoutView(
            imageAppearAnimationState: $viewModel.appearTransitionState
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
                        .opacity(viewModel.appearTransitionState)
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
                            Text("Context")
                                .frame(
                                    alignment: .leading
                                )
                                .font(.system(size: AppFontSize.lg.rawValue, weight: .medium))
                                .foregroundStyle(AppColors.Gray400.color)
                            Spacer()
                            if (hintsExpanded) {
                                AppButton(action: {
                                    hintsExpanded = !hintsExpanded
                                    HapticsImpactLight.impactOccurred()
                                }) {
                                    HStack {
                                        Text("Show Hints")
                                        Image(systemName: "chevron.down")
                                    }
                                }
                                .variant(.ghost)
                                .paddingHorz(0)
                                .paddingVert(0)
                            } else {
                                AppButton(action: {
                                    hintsExpanded = !hintsExpanded
                                    HapticsImpactLight.impactOccurred()
                                }) {
                                    HStack {
                                        Text("Hide Hints")
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                .variant(.ghost)
                                .paddingHorz(0)
                                .paddingVert(0)
                            }
                        }
                        
                        if (hintsExpanded) {
                            TokenizedTextView(tokens: presentationPart.hint!)
                                .font(.system(size: AppFontSize.lg.rawValue, weight: .medium))
                                .opacity(viewModel.appearTransitionState)
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

        // Toolbar
        VStack {
            HStack(spacing: 0) {
                Spacer()
                HStack {
                    AppButton(action: {
                        viewModel.goToPage(newPage: page - 1)
                        HapticsImpactLight.impactOccurred()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                        }
                        .foregroundStyle(AppColors.Primary50.color)
                    }
                    .variant(.ghost)
                    .opacity(isFirstPage ? 0.3 : 1)
                    .disabled(isFirstPage || isPageTransitioning)
                    
                    Text("\(page + 1)")
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
                    .variant(.ghost)
                    .opacity(isLastPage ? 0.3 : 1)
                    .disabled(isLastPage || isPageTransitioning)

                    if (page >= lastPage) {
                        AppButton(action: {
                            guard let goTo else {
                                return
                            }
                            goTo(.Present)
                            HapticsImpactLight.impactOccurred()
                        }) {
                            Text("Start")
                        }
                        .opacity(
                            nPage <= presentationParts.count ? viewModel.appearTransitionState : 1
                        )
                    } else {
                        AppButton(action: {
                            guard let goTo else {
                                return
                            }
                            goTo(.Present)
                            HapticsImpactLight.impactOccurred()
                        }) {
                            Text("Start")
                        }
                        .variant(.ghost)
                        .opacity(
                            nPage >= presentationParts.count ? viewModel.appearTransitionState : 1
                        )
                    }
                }
                .frame(
                    alignment: .center
                )
                .padding(.vertical, 2)
                .padding(.horizontal, 2)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.Gray800.color.opacity(0.75))
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
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        
        PresentationViewCloseButton(onClose: {
            guard let onClose else {
                return
            }
            onClose()
        })
    }
}

struct PresentationPrepareView: View {
    let title: String;
    let presentationParts: [PresentationPart];

    @Binding var viewType: PresentationViewType
    @State var viewModel = PresentationPrepareViewModel()
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if (horizontalSizeClass == .compact) {
            PresentationPrepareCompactView(
               title: title,
               presentationParts: presentationParts,
               viewModel: $viewModel,
               goTo: goTo,
               onClose: onClose
            ).onAppear() {
               animateIn()
           }
        } else {
             PresentationPrepareRegularView(
                title: title,
                presentationParts: presentationParts,
                viewModel: $viewModel,
                goTo: goTo,
                onClose: onClose
             ).onAppear() {
                animateIn()
            }
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
