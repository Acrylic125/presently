import SwiftUI

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
    @Binding var appearVXTransitionState: Double
    
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

        PresentationPresentVX(appearVXTransitionState: $viewModel.vxTransitionState)
        
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
                    guard let goTo else {
                        return
                    }
                    goTo(.Overview)
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
                    guard let goTo else {
                        return
                    }
                    goTo(.Present)
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
        
        PresentationViewCloseButton(onClose: {
            guard let onClose else {
                return
            }
            onClose()
        })
    }
    
}

struct PresentationPresentCompactView: View {
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
        
        PresentationPresentVX(appearVXTransitionState: $viewModel.vxTransitionState)

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
                    guard let goTo else {
                        return
                    }
                    goTo(.Overview)
                    HapticsImpactLight.impactOccurred()
                }) {
                    Text("Done")
                }
                .opacity(
                    nPage <= presentationParts.count ? viewModel.pageTransitionState : 1
                )
            } else {
                AppButton(action: {
                    guard let goTo else {
                        return
                    }
                    goTo(.Overview)
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
            guard let onClose else {
                return
            }
            onClose()
        })
    }
}

struct PresentationPresentView: View {
    let title: String;
    let presentationParts: [PresentationPart];

    @Binding var viewType: PresentationViewType
    @State var viewModel = PresentationPresentViewModel()
    
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

}





//import SwiftUI
//
//struct PresentationPresentView: View {
//    let title: String;
//    let presentationParts: [PresentationPart];
//    
//    @Binding var viewType: PresentationViewType
//    
//    // Animation page transitioning states
//    @State private var page = 0;
//    @State private var nPage = 0;
//    @State private var isPageTransitioning: Bool = false;
//    @State private var appearTransitionWorkItem: DispatchWorkItem?
//    @State private var appearTransitionState: Double = 0;
//    @State private var appearVXTransitionState: Double = 0;
//
//    @State private var expandHints = false
//    
//    func animateIn() {
//        if (appearTransitionWorkItem != nil) {
//            appearTransitionWorkItem!.cancel()
//        }
//        
//        isPageTransitioning = true
//        appearTransitionState = 0
//        appearVXTransitionState = 0
//        appearTransitionWorkItem = DispatchWorkItem {
//            withAnimation(.easeIn(duration: 0.3)) {
//                appearTransitionState = 1
//            } completion: {
//                isPageTransitioning = false
//            }
//            withAnimation(.easeIn(duration: 1.0)) {
//                appearVXTransitionState = 1
//            }
//        }
//        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
//    }
//    
//    func goTo(viewType: PresentationViewType) {
//        if (appearTransitionWorkItem != nil) {
//            appearTransitionWorkItem!.cancel()
//        }
//        
//        isPageTransitioning = true
//        appearTransitionState = 1
//        appearVXTransitionState = 1
//        appearTransitionWorkItem = DispatchWorkItem {
//            withAnimation(.easeOut(duration: 0.3)) {
//                appearTransitionState = 0
//                appearVXTransitionState = 0
//            } completion: {
//                isPageTransitioning = false
//                self.viewType = viewType
//            }
//        }
//        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
//    }
//    
//    func transitionPage(newPage: Int) {
//        if (isPageTransitioning) {
//            return
//        }
//        
//        nPage = newPage
//        isPageTransitioning = true
//        appearTransitionWorkItem = DispatchWorkItem {
//            withAnimation(.easeOut(duration: 0.15)) {
//                appearTransitionState = 0
//            } completion: {
//                page = newPage
//                withAnimation(.easeOut(duration: 0.15)) {
//                    appearTransitionState = 1
//                } completion: {
//                    isPageTransitioning = false
//                }
//            }
//        }
//        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
//    }
//
//    var body: some View {
//        let safeAreaInsets = getSafeAreaInset()
//        let pimgHeight = 220.0
//        
//        let presentationPart = presentationParts[page]
//        
//        let lastPage = (presentationParts.count - 1)
//        let isFirstPage = nPage <= 0
//        let isLastPage = nPage >= lastPage
//        
//        // Visual Effects
//        VStack {
//            Rectangle()
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(
//                            stops: [
//                                .init(color: AppColors.Primary500.color.opacity(0.25), location: 0),
//                                .init(color: AppColors.Primary300.color.opacity(0.0), location: 1)
//                            ]
//                        ),
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                )
//                .frame(
//                    maxWidth: .infinity,
//                    maxHeight: .infinity
//                )
//            Rectangle()
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(
//                            stops: [
//                                .init(color: AppColors.Primary300.color.opacity(0.0), location: 0),
//                                .init(color: AppColors.Primary500.color.opacity(0.25), location: 1)
//                            ]
//                        ),
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                )
//                .frame(
//                    maxWidth: .infinity,
//                    maxHeight: .infinity
//                )
//        }
//        .frame(
//            maxHeight: .infinity,
//            alignment: .bottomTrailing
//        )
//        .opacity(appearVXTransitionState)
//
//        ScrollView {
//            VStack(alignment: .leading, spacing: 12) {
//                Text(title)
//                    .frame(
//                        maxWidth: 300,
//                        alignment: .leading
//                    )
//                    .foregroundStyle(AppColors.Gray50.color)
//                    .fontWeight(.black)
//                    .font(.title)
//                    .padding(.horizontal, 24)
//                ZStack {
//                    ZStack {
//                        Ellipse()
//                            .fill(
//                                LinearGradient(
//                                    gradient: Gradient(
//                                        stops: [
//                                            .init(color: AppColors.Gray700.color.opacity(0.75), location: 0),
//                                            .init(color: AppColors.Gray700.color.opacity(0.0), location: 0.5)
//                                        ]
//                                    ),
//                                    startPoint: .top,
//                                    endPoint: .bottom
//                                )
//                            )
//                            .scaleEffect(x: 1, y: 0.75)
//                            .frame(
//                                height: pimgHeight
//                            )
//                            .offset(y: pimgHeight * 0.5)
//                            .clipped()
//                    }
//                    
//                    ZStack {
//                        Image(presentationPart.img)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(
//                                maxHeight: pimgHeight * 3/4
//                            )
//                            .scaleEffect(appearTransitionState)
//                    }
//                }
//                .frame(
//                    height: pimgHeight
//                )
//                
//                VStack() {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Describe the scene")
//                            .frame(
//                                alignment: .leading
//                            )
//                            .font(.headline)
//                            .foregroundStyle(AppColors.Gray400.color)
//                        TokenizedTextView(tokens: presentationPart.content)
//                            .opacity(appearTransitionState)
//                    }
//                    .frame(
//                        maxWidth: .infinity,
//                        alignment: .topLeading
//                    )
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 12)
//                    .background(
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(AppColors.Gray900.color)
//                            .stroke(AppColors.Gray700.color, lineWidth: 1)
//                    )
//                }
//                .padding(.horizontal, 24)
//
//                if (presentationPart.hint != nil) {
//                    let hint = presentationPart.hint!
//                    VStack() {
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("Hints")
//                                .frame(
//                                    alignment: .leading
//                                )
//                                .font(.headline)
//                                .foregroundStyle(AppColors.Gray400.color)
//                            DisclosureGroup("Toggle Hints") {
//                                TokenizedTextView(tokens: hint)
//                                    .opacity(appearTransitionState)
//                            }
//                            .foregroundStyle(AppColors.Primary500.color)
//                        }
//                        .frame(
//                            maxWidth: .infinity,
//                            alignment: .topLeading
//                        )
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 12)
//                        .background(
//                            RoundedRectangle(cornerRadius: 8)
//                                .fill(AppColors.Gray900.color)
//                                .stroke(AppColors.Gray700.color, lineWidth: 1)
//                        )
//                    }
//                    .padding(.horizontal, 24)
//                    Text("Stuck? Hints give you ideas on what you can elaborate on. They are not always given so don't rely on hints!")
//                        .font(.caption)
//                        .foregroundStyle(AppColors.Gray500.color)
//                        .padding(.horizontal, 24)
//                }
//            }
//            .safeAreaPadding(safeAreaInsets)
//            .padding(.top, 24)
//            .padding(.bottom, 120)
//        }
//        .frame(
//            maxWidth: .infinity,
//            maxHeight: .infinity
//        )
//        
//        // Bottom Toolbar
//        VStack {
//            HStack {
//                Spacer()
//                HStack {
//                    Button(action: {
//                        transitionPage(newPage: page - 1)
//                        HapticsImpactLight.impactOccurred()
//                    }) {
//                        HStack {
//                            Image(systemName: "arrow.left")
//                            Text("Back")
//                                .font(.body)
//                        }
//                        .foregroundColor(AppColors.Gray50.color)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 12)
//                    }
//                    .opacity(isFirstPage ? 0.3 : 1)
//                    .disabled(isFirstPage || isPageTransitioning)
//                    
//                    Text("\(page + 1)")
//                        .foregroundColor(AppColors.Gray400.color)
//
//                    Button(action: {
//                        transitionPage(newPage: page + 1)
//                        HapticsImpactLight.impactOccurred()
//                    }) {
//                        HStack {
//                            Text("Next")
//                                .font(.body)
//                            Image(systemName: "arrow.right")
//                        }
//                        .foregroundColor(AppColors.Gray50.color)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 12)
//                    }
//                    .opacity(isLastPage ? 0.3 : 1)
//                    .disabled(isLastPage || isPageTransitioning)
//
//                    Button(action: {
//                        viewType = .Present
//                        HapticsImpactLight.impactOccurred()
//                    }) {
//                        if (page >= lastPage) {
//                            HStack {
//                                Text("Done")
//                                    .font(.body)
//                            }
//                            .fontWeight(.black)
//                            .foregroundColor(AppColors.Gray50.color)
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 8)
//                            .background(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .fill(AppColors.Primary600.color)
//                                    .stroke(AppColors.Primary500.color, lineWidth: 1)
//                            )
//                            .opacity(
//                                nPage <= presentationParts.count ? appearTransitionState : 1
//                            )
//                        } else {
//                            HStack {
//                                Text("Done")
//                                    .font(.body)
//                            }
//                            .fontWeight(.black)
//                            .foregroundColor(AppColors.Primary500.color)
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 8)
//                            .opacity(
//                                nPage >= presentationParts.count ? appearTransitionState : 1
//                            )
//                        }
//                    }
//                }
//                .frame(
//                    alignment: .center
//                )
//                .padding(.vertical, 4)
//                .padding(.horizontal, 4)
//                .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(AppColors.Gray800.color.opacity(0.75))
//                        .stroke(AppColors.Gray700.color, lineWidth: 1)
//                )
//                Spacer()
//            }
//        }
//        .frame(
//            maxHeight: .infinity,
//            alignment: .bottomTrailing
//        )
//        .safeAreaPadding(safeAreaInsets)
//        .padding(.horizontal, 12)
//        .padding(.bottom, 48)
//        
//        PresentationViewCloseButton(onClose: {
//            goTo(viewType: .Overview)
//        })
//        // Will attach to toolbar but can be placed anywhere.
//        .onAppear() {
//            animateIn()
//        }
//    }
//}
