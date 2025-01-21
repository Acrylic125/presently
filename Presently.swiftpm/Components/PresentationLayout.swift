import SwiftUI

struct PresentationRegularLayoutView<Content: View>: View {
    
    @Binding var imageAppearAnimationState: Double
    @State private var rightContentHeight: CGFloat = 0
    
    let content: Content
    private var title: String = ""
    private var img: String = ""

    init(imageAppearAnimationState: Binding<Double>, @ViewBuilder content: () -> Content) {
        _imageAppearAnimationState = imageAppearAnimationState
        self.content = content()
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
                        Image(img)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                maxHeight: pimgHeight
                            )
                            .scaleEffect(imageAppearAnimationState)
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
                            content
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
        
        // Toolbar
        VStack {
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    Button(action: {
//                        goTo(viewType: .Prepare)
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
//                        goTo(viewType: .Present)
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
        
//        PresentationViewCloseButton(onClose: {
//            if (appearTransitionWorkItem != nil) {
//                appearTransitionWorkItem!.cancel()
//            }
//        })
    }
    
    public func title(_ v: String) -> PresentationRegularLayoutView {
        var c = self
        c.title = v
        return c
    }
    
    public func img(_ v: String) -> PresentationRegularLayoutView {
        var c = self
        c.img = v
        return c
    }

    
}
