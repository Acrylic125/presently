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

struct PresentationPrepareRegularView: View {
    let title: String;
    let presentationParts: [PresentationPart];
    @Binding var viewModel: PresentationPrepareViewModel

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
                                        Text("Show Hints")
                                        Image(systemName: "chevron.down")
                                    }
                                }
                                .variant(.ghost)
                                .size(.large)
                                .paddingHorz(0)
                                .paddingVert(0)
                                .opacity(viewModel.hintsExpandTransitionState)
                                .onAppear() {
                                    viewModel.animateExpand()
                                }
                            } else {
                                AppButton(action: {
                                    viewModel.hintsExpanded = true
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
                                .opacity(viewModel.hintsExpandTransitionState)
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
            toolbarAppearTransitionState: $viewModel.appearTransitionState,
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
                    nPage <= presentationParts.count ? viewModel.pageTransitionState : 1
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
                    nPage >= presentationParts.count ? viewModel.pageTransitionState : 1
                )
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

struct PresentationPrepareCompactView: View {
    let title: String;
    let presentationParts: [PresentationPart];
    @Binding var viewModel: PresentationPrepareViewModel

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
                                        Text("Show Hints")
                                        Image(systemName: "chevron.down")
                                    }
                                }
                                .variant(.ghost)
                                .paddingHorz(0)
                                .paddingVert(0)
                                .opacity(viewModel.hintsExpandTransitionState)
                            } else {
                                AppButton(action: {
                                    viewModel.hintsExpanded = true
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
                                .opacity(viewModel.hintsExpandTransitionState)
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
            toolbarAppearTransitionState: $viewModel.appearTransitionState,
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
            .size(.small)
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
                    nPage <= presentationParts.count ? viewModel.pageTransitionState : 1
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
                    nPage >= presentationParts.count ? viewModel.pageTransitionState : 1
                )
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
