import SwiftUI

struct PresentationPresentView: View {
    let title: String;
    let presentationParts: [PresentationPart];
    
    @Binding var viewType: PresentationViewType
    
    // Animation page transitioning states
    @State private var page = 0;
    @State private var nPage = 0;
    @State private var isPageTransitioning: Bool = false;
    @State private var appearTransitionWorkItem: DispatchWorkItem?
    @State private var appearTransitionState: Double = 0;
    @State private var appearVXTransitionState: Double = 0;

    @State private var expandHints = false
    
    func animateIn() {
        if (appearTransitionWorkItem != nil) {
            appearTransitionWorkItem!.cancel()
        }
        
        isPageTransitioning = true
        appearTransitionState = 0
        appearVXTransitionState = 0
        appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeIn(duration: 0.3)) {
                appearTransitionState = 1
                isPageTransitioning = false
            }
            withAnimation(.easeIn(duration: 1.0)) {
                appearVXTransitionState = 1
            }
        }
        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
    }
    
    func goTo(viewType: PresentationViewType) {
        if (appearTransitionWorkItem != nil) {
            appearTransitionWorkItem!.cancel()
        }
        
        isPageTransitioning = true
        appearTransitionState = 1
        appearVXTransitionState = 1
        appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.3)) {
                appearTransitionState = 0
                appearVXTransitionState = 0
                isPageTransitioning = false
                self.viewType = viewType
            }
        }
        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
    }
    
    func transitionPage(newPage: Int) {
        if (isPageTransitioning) {
            return
        }
        
        nPage = newPage
        isPageTransitioning = true
        appearTransitionWorkItem = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.15)) {
                appearTransitionState = 0
            } completion: {
                page = newPage
                withAnimation(.easeOut(duration: 0.15)) {
                    appearTransitionState = 1
                } completion: {
                    isPageTransitioning = false
                }
            }
        }
        DispatchQueue.main.async(execute: appearTransitionWorkItem!)
    }

    var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        let pimgHeight = 220.0
        
        let presentationPart = presentationParts[page]
        
        let lastPage = (presentationParts.count - 1)
        let isFirstPage = nPage <= 0
        let isLastPage = nPage >= lastPage
        
        // Visual Effects
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

        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .frame(
                        maxWidth: 300,
                        alignment: .leading
                    )
                    .foregroundStyle(AppColors.Gray50.color)
                    .fontWeight(.black)
                    .font(.title)
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
                            .scaleEffect(x: 1, y: 0.75)
                            .frame(
                                height: pimgHeight
                            )
                            .offset(y: pimgHeight * 0.5)
                            .clipped()
                    }
                    
                    ZStack {
                        Image(presentationPart.img)
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
                        Text("Describe the scene")
                            .frame(
                                alignment: .leading
                            )
                            .font(.headline)
                            .foregroundStyle(AppColors.Gray400.color)
                        TokenizedTextView(tokens: presentationPart.content)
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

                if (presentationPart.hint != nil) {
                    let hint = presentationPart.hint!
                    VStack() {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hints")
                                .frame(
                                    alignment: .leading
                                )
                                .font(.headline)
                                .foregroundStyle(AppColors.Gray400.color)
                            DisclosureGroup("Toggle Hints") {
                                TokenizedTextView(tokens: hint)
                                    .opacity(appearTransitionState)
                            }
                            .foregroundStyle(AppColors.Primary500.color)
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
                    Text("Stuck? Hints give you ideas on what you can elaborate on. They are not always given so don't rely on hints!")
                        .font(.caption)
                        .foregroundStyle(AppColors.Gray500.color)
                        .padding(.horizontal, 24)
                }
            }
            .safeAreaPadding(safeAreaInsets)
            .padding(.top, 24)
            .padding(.bottom, 120)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        
        // Bottom Toolbar
        VStack {
            HStack {
                Spacer()
                HStack {
                    Button(action: {
                        transitionPage(newPage: page - 1)
                        HapticsImpactLight.impactOccurred()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Back")
                                .font(.body)
                        }
                        .foregroundColor(AppColors.Gray50.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                    }
                    .opacity(isFirstPage ? 0.3 : 1)
                    .disabled(isFirstPage || isPageTransitioning)
                    
                    Text("\(page + 1)")
                        .foregroundColor(AppColors.Gray400.color)

                    Button(action: {
                        transitionPage(newPage: page + 1)
                        HapticsImpactLight.impactOccurred()
                    }) {
                        HStack {
                            Text("Next")
                                .font(.body)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(AppColors.Gray50.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                    }
                    .opacity(isLastPage ? 0.3 : 1)
                    .disabled(isLastPage || isPageTransitioning)

                    Button(action: {
                        viewType = .Present
                        HapticsImpactLight.impactOccurred()
                    }) {
                        if (page >= lastPage) {
                            HStack {
                                Text("Done")
                                    .font(.body)
                            }
                            .fontWeight(.black)
                            .foregroundColor(AppColors.Gray50.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppColors.Primary600.color)
                                    .stroke(AppColors.Primary500.color, lineWidth: 1)
                            )
                            .opacity(
                                nPage <= presentationParts.count ? appearTransitionState : 1
                            )
                        } else {
                            HStack {
                                Text("Done")
                                    .font(.body)
                            }
                            .fontWeight(.black)
                            .foregroundColor(AppColors.Primary500.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .opacity(
                                nPage >= presentationParts.count ? appearTransitionState : 1
                            )
                        }
                    }
                }
                .frame(
                    alignment: .center
                )
                .padding(.vertical, 4)
                .padding(.horizontal, 4)
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
        .padding(.horizontal, 12)
        .padding(.bottom, 48)
        // Will attach to toolbar but can be placed anywhere.
        .onAppear() {
            animateIn()
        }
    }
}
