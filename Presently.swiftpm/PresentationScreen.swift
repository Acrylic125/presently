import SwiftUI

struct TokenizedTextView: View {
    let tokens: [StringToken]
    
    var body: some View {
        tokens.reduce(Text("")) { partialResult, token in
            partialResult + Text(token.text)
                .foregroundColor(token.type == .highlight ? AppColors.Primary500.color : AppColors.Gray50.color)
        }
        .frame(maxHeight: .infinity)
    }
}

enum PresentationViewType {
    case Overview, Prepare, Present
}

struct PresentationOverviewView: View {
    let title: String;
    let context: [StringToken];
    
    @Binding var viewType: PresentationViewType

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
                            .font(.headline)
                            .foregroundStyle(AppColors.Gray400.color)
                        TokenizedTextView(tokens: context)
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
        
        VStack {
            HStack {
                Spacer()
                HStack(spacing: 12) {
                    Button(action: {
                        viewType = .Prepare
                        HapticsImpactLight.impactOccurred()
                    }) {
                        HStack {
                            Text("Prepare")
                                .font(.body)
                        }
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.Primary500.color)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                    }
                    Button(action: {
                        viewType = .Present
                        HapticsImpactLight.impactOccurred()
                    }) {
                        HStack {
                            Text("Start")
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
    }
}

struct PresentationPrepareView: View {
    let title: String;
    let presentationParts: [PresentationPart];
    
    @Binding var viewType: PresentationViewType
    
    // Animation page transitioning states
    @State private var page = 0;
    @State private var nPage = 0;
    @State private var isPageTransitioning: Bool = false;
    @State private var pageTransitionState: Double = 1;
    
    @State private var expandHints = false
    
    func transitionPage(newPage: Int) {
        if (isPageTransitioning) {
            return
        }
        
        nPage = newPage
        isPageTransitioning = true
        withAnimation(.easeOut(duration: 0.15)) {
            pageTransitionState = 0
        } completion: {
            page = newPage
            withAnimation(.easeOut(duration: 0.15)) {
                pageTransitionState = 1
            } completion: {
                isPageTransitioning = false
            }
        }
    }
    
    var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        let pimgHeight = 220.0
        
        let presentationPart = presentationParts[page]
        
        let lastPage = (presentationParts.count - 1)
        let isFirstPage = nPage <= 0
        let isLastPage = nPage >= lastPage

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
                            .scaleEffect(x: 1, y: 0.5)
                            .frame(
                                height: pimgHeight
                            )
                            .offset(y: pimgHeight * 0.25)
                            .clipped()
                    }
                    
                    ZStack {
                        Image(presentationPart.img)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                maxHeight: pimgHeight * 3/4
                            )
                            .scaleEffect(pageTransitionState)
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
                            .opacity(pageTransitionState)
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
                                    .opacity(pageTransitionState)
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
                                Text("Start")
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
                                nPage <= presentationParts.count ? pageTransitionState : 1
                            )
                        } else {
                            HStack {
                                Text("Start")
                                    .font(.body)
                            }
                            .fontWeight(.black)
                            .foregroundColor(AppColors.Primary500.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .opacity(
                                nPage >= presentationParts.count ? pageTransitionState : 1
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
    }
}

struct PresentationView: View {
    
    let title: String;
    
    @State var viewType: PresentationViewType = .Overview
    
    var body: some View {
        let safeAreaInsets = getSafeAreaInset()

        ZStack(alignment: .topLeading) {
            if (viewType == .Overview) {
                PresentationOverviewView(title: title, context: AppPresentations.PlaygroundObservationsPresentation.context, viewType: $viewType)
            }
            else if (viewType == .Prepare) {
                PresentationPrepareView(title: title, presentationParts: AppPresentations.PlaygroundObservationsPresentation.parts, viewType: $viewType)
            }

            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Button(action: {
                        if (viewType == .Prepare || viewType == .Present) {
                            viewType = .Overview
                        }
                        
                        HapticsImpactLight.impactOccurred()
                    }) {
                        HStack {
                            Image(systemName: "multiply")
                        }
                        .foregroundColor(AppColors.Gray50.color)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            Circle()
                                .fill(AppColors.Gray700.color.opacity(0.5))
                                .stroke(AppColors.Gray700.color, lineWidth: 1)
                        )
                    }
                }
                .frame(
                    maxHeight: .infinity,
                    alignment: .topTrailing
                )
            }
            .frame(
                maxHeight: .infinity,
                alignment: .topTrailing
            )
            .safeAreaPadding(safeAreaInsets)
            .padding(.top, 12)
            .padding(.horizontal, 12)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .frame(
            maxHeight: .infinity
        )
        .background(AppColors.Gray950.color)
    }

}
