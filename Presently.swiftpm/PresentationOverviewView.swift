import SwiftUI

struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        // Hacky fix: Stupid annoying issue with listening to container views such as VStack.
        value = value ?? nextValue()
    }
}

struct PresentationOverviewRegularView: View {
    let title: String;
    let context: [StringToken];
    
    @Binding var viewType: PresentationViewType
    
    @State private var appearTransitionWorkItem: DispatchWorkItem?
    @State private var appearTransitionState: Double = 0
    @State private var rightContentHeight: CGFloat = 0

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
        let pimgHeight = 480.0
        
        let topPadding = 48.0
        let bottomPadding = 240.0
        let centerRightContentTopPadding = max((UIScreen.main.bounds.height - rightContentHeight - topPadding - bottomPadding) / 2, 0)

        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .frame(
                        maxWidth: 440,
                        alignment: .leading
                    )
                    .foregroundStyle(AppColors.Gray50.color)
                    .font(.system(size: AppFontSize.xl4.rawValue, weight: .black))
                    .padding(.horizontal, 24)
                Spacer()
                ZStack {
                    ZStack {
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(
                                        stops: [
                                            .init(color: AppColors.Gray700.color.opacity(0.75), location: 0),
                                            .init(color: AppColors.Gray700.color.opacity(0.0), location: 0.5)
                                        ]
                                    ),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .scaleEffect(x: 1, y: 0.5)
                            .frame(
                                height: pimgHeight
                            )
                            .offset(y: pimgHeight * 0.25)
                            .clipped()
                    }
                    
                    ZStack {
                        Image("pimg_full_playground_observations")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                maxHeight: pimgHeight * 3/4
                            )
                            .scaleEffect(appearTransitionState)
                    }
                }
                .frame(
                    height: pimgHeight
                )
                Spacer()
            }
            .padding(.vertical, 48)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )

            VStack(alignment: .center) {
                ScrollView {
                    VStack {
                        VStack( spacing: 12) {
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
                        .frame(
                            maxHeight: .infinity
                        )
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(key: ViewSizeKey.self, value: geometry.size)
                            }
                        )
                    }
                    .safeAreaPadding(safeAreaInsets)
                    .padding(.top, topPadding + centerRightContentTopPadding)
                    .padding(.bottom, bottomPadding)
                }
                .onPreferenceChange(ViewSizeKey.self) { size in
                    rightContentHeight = size.height
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
            }
            .frame(
                maxWidth: 480,
                maxHeight: .infinity
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .onAppear() {
            animateIn()
        }
        
        // Toolbar
        VStack {
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    Button(action: {
                        goTo(viewType: .Prepare)
                        HapticsImpactLight.impactOccurred()
                    }) {
                        HStack {
                            Text("Prepare")
                                .font(.system(size: AppFontSize.xl.rawValue, weight: .medium))
                        }
                        .foregroundColor(AppColors.Primary500.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                    }
                    Button(action: {
                        goTo(viewType: .Present)
                        HapticsImpactLight.impactOccurred()
                    }) {
                        HStack {
                            Text("Start")
                                .font(.system(size: AppFontSize.xl.rawValue, weight: .medium))
                        }
                        .foregroundColor(AppColors.Gray50.color)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColors.Primary600.color)
                                .stroke(AppColors.Primary500.color, lineWidth: 1)
                        )
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
                print("Completed")
                self.viewType = viewType
            }
        }
        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
    }

    var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        let pimgHeight = 220.0
        
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .frame(
                        maxWidth: 300,
                        alignment: .leading
                    )
                    .foregroundStyle(AppColors.Gray50.color)
                    .font(.system(size: AppFontSize.xl3.rawValue, weight: .black))
                    .padding(.horizontal, 24)
                ZStack {
                    ZStack {
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(
                                        stops: [
                                            .init(color: AppColors.Gray700.color.opacity(0.75), location: 0),
                                            .init(color: AppColors.Gray700.color.opacity(0.0), location: 0.5)
                                        ]
                                    ),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .scaleEffect(x: 1, y: 0.5)
                            .frame(
                                height: pimgHeight
                            )
                            .offset(y: pimgHeight * 0.25)
                            .clipped()
                    }

                    ZStack {
                        Image("pimg_full_playground_observations")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                maxHeight: pimgHeight * 3/4
                            )
                            .scaleEffect(appearTransitionState)
                    }
                }
                .frame(
                    height: pimgHeight
                )
                
                VStack() {
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
                .padding(.horizontal, 24)

            }
            .safeAreaPadding(safeAreaInsets)
            .padding(.top, 24)
            .padding(.bottom, 120)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        
        // Toolbar
        VStack {
            HStack {
                Spacer()
                HStack(spacing: 12) {
                    Button(action: {
                        goTo(viewType: .Prepare)
                        HapticsImpactLight.impactOccurred()
                    }) {
                        HStack {
                            Text("Prepare")
                                .font(.system(size: AppFontSize.md.rawValue, weight: .medium))
                        }
                        .foregroundColor(AppColors.Primary500.color)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                    }
                    Button(action: {
                        goTo(viewType: .Present)
                        HapticsImpactLight.impactOccurred()
                    }) {
                        HStack {
                            Text("Start")
                                .font(.system(size: AppFontSize.md.rawValue, weight: .black))
                        }
                        .foregroundColor(AppColors.Gray50.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppColors.Primary600.color)
                                .stroke(AppColors.Primary500.color, lineWidth: 1)
                        )
                    }
                }
                .frame(
                    alignment: .center
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
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
            if (appearTransitionWorkItem != nil) {
                appearTransitionWorkItem!.cancel()
            }
        })
        .onAppear() {
            animateIn()
        }
    }
}


struct PresentationOverviewView: View {
    let title: String;
    let context: [StringToken];
    
    @Binding var viewType: PresentationViewType

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        let pimgHeight = 220.0
            
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
