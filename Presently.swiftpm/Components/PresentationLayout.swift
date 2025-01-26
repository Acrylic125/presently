import SwiftUI

struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        // Hacky fix: Stupid annoying issue with listening to container views such as VStack.
        value = value ?? nextValue()
    }
}

struct PresentationRegularLayoutView<Content: View>: View {
    
    var imageAppearAnimationState: Double
    var stageAppearAnimationState: Double
    @State private var rightContentHeight: CGFloat = 0

    let content: Content
    private var title: String = ""
    private var img: String = ""
    
    init(imageAppearAnimationState: Double, stageAppearAnimationState: Double, @ViewBuilder content: () -> Content) {
        self.imageAppearAnimationState = imageAppearAnimationState
        self.stageAppearAnimationState = stageAppearAnimationState
        self.content = content()
    }

    init(imageAppearAnimationState: Double, @ViewBuilder content: () -> Content) {
        self.imageAppearAnimationState = imageAppearAnimationState
        self.stageAppearAnimationState = 1
        self.content = content()
    }
    
    var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        let pimgHeight = 480.0
        
        let topPadding = 48.0
        let bottomPadding = 120.0
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
                            .opacity(stageAppearAnimationState)
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

struct PresentationCompactLayoutView<Content: View>: View {
    
    var imageAppearAnimationState: Double
    var stageAppearAnimationState: Double

    let content: Content
    private var title: String = ""
    private var img: String = ""

    init(imageAppearAnimationState: Double, stageAppearAnimationState: Double, @ViewBuilder content: () -> Content) {
        self.imageAppearAnimationState = imageAppearAnimationState
        self.stageAppearAnimationState = stageAppearAnimationState
        self.content = content()
    }
    
    init(imageAppearAnimationState: Double, @ViewBuilder content: () -> Content) {
        self.imageAppearAnimationState = imageAppearAnimationState
        self.stageAppearAnimationState = 1
        self.content = content()
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
                            .opacity(stageAppearAnimationState)
                    }

                    ZStack {
                        Image(img)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                maxHeight: pimgHeight * 3/4
                            )
                            .scaleEffect(imageAppearAnimationState)
                    }
                }
                .frame(
                    height: pimgHeight
                )
                
                VStack {
                    content
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
    }
    
    public func title(_ v: String) -> PresentationCompactLayoutView {
        var c = self
        c.title = v
        return c
    }
    
    public func img(_ v: String) -> PresentationCompactLayoutView {
        var c = self
        c.img = v
        return c
    }

}
