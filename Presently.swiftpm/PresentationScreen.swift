import SwiftUI

struct TokenizedTextView: View {
    let tokens: [StringToken]
    
    var body: some View {
        tokens.reduce(Text("")) { partialResult, token in
            partialResult + Text(token.text)
                .foregroundColor(token.type == .highlight ? AppColors.Primary500.color : AppColors.Gray50.color)
        }
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
        let pimgHeight = 260.0
        
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
                                maxHeight: pimgHeight * 2/3
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
            .padding(.vertical, 24)
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
//            HStack {
//                Spacer()
//                HStack(spacing: 12) {
//                    Button(action: {
//                        viewType = .Prepare
//                        HapticsImpactLight.impactOccurred()
//                    }) {
//                        HStack {
//                            Text("Prepare")
//                        }
//                        .foregroundColor(AppColors.Primary500.color)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 12)
//                        .background(
//                            RoundedRectangle(cornerRadius: 12)
//                                .fill(AppColors.Gray900.color)
//                                .stroke(AppColors.Primary500.color, lineWidth: 1)
//                        )
//                    }
//                    
//                    Button(action: {
//                        viewType = .Present
//                        HapticsImpactLight.impactOccurred()
//                    }) {
//                        HStack {
//                            Text("Start")
//                                .fontWeight(.black)
//                        }
//                        .foregroundColor(AppColors.Gray50.color)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 12)
//                        .background(
//                            RoundedRectangle(cornerRadius: 12)
//                                .fill(AppColors.Primary700.color)
//                                .stroke(AppColors.Primary500.color, lineWidth: 1)
//                        )
//                    }
//                }
//                .frame(
//                    alignment: .center
//                )
//                Spacer()
//            }
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
    
    @Binding var viewType: PresentationViewType

    var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        let pimgHeight = 260.0
        
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
                                maxHeight: pimgHeight * 2/3
                            )
                    }
                }
                .frame(
                    height: pimgHeight
                )
                
                VStack() {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Suggested Talking Points")
                            .frame(
                                alignment: .leading
                            )
                            .font(.headline)
                            .foregroundStyle(AppColors.Gray400.color)
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor ")
                            .frame(
                                alignment: .leading
                            )
                            .font(.body)
                            .foregroundStyle(AppColors.Gray50.color)
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
            .padding(.vertical, 24)
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
                    
                    Text("99")
                        .foregroundColor(AppColors.Gray400.color)

                    Button(action: {
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

//                    Button(action: {
//                        viewType = .Present
//                        HapticsImpactLight.impactOccurred()
//                    }) {
//                        HStack {
//                            Text("Start")
//                                .font(.body)
//                        }
//                        .fontWeight(.black)
//                        .foregroundColor(AppColors.Primary500.color)
//                        .padding(.leading, 12)
//                        .padding(.trailing, 16)
//                        .padding(.vertical, 16)
//                    }
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
                PresentationPrepareView(title: title, viewType: $viewType)
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
