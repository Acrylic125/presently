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

struct PresentationView: View {
    
    let title: String;
    
    @State var viewType: PresentationViewType = .Overview
    
    var body: some View {
        let safeAreaInsets = getSafeAreaInset()

        ZStack(alignment: .topLeading) {
            if (viewType == .Overview) {
                PresentationOverviewView(title: title, context: AppPresentations.PlaygroundObservationsPresentation.context, viewType: $viewType)
            } else if (viewType == .Prepare) {
                PresentationPrepareView(title: title, presentationParts: AppPresentations.PlaygroundObservationsPresentation.parts, viewType: $viewType)
            } else {
                PresentationPresentView(title: title, presentationParts: AppPresentations.PlaygroundObservationsPresentation.parts, viewType: $viewType)
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
