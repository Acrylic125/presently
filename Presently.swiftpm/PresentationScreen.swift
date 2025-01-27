import SwiftUI

struct TokenizedTextView: View {
    let tokens: [StringToken]
    
    var body: some View {
        tokens.reduce(Text("")) { partialResult, token in
            partialResult + Text(token.text)
                .foregroundColor(token.type == .highlight ? AppColors.Primary500.color : AppColors.Gray50.color)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: .infinity)
        .lineSpacing(4)
    }
}

public enum PresentationToolbarSize {
    case small, large
}

struct PresentationToolbar<Content: View>: View {
    
    var toolbarAppearTransitionState: Double
    let size: PresentationToolbarSize
    let content: Content
    
    init(toolbarAppearTransitionState: Double,
         size: PresentationToolbarSize,
         @ViewBuilder content: () -> Content) {
        self.toolbarAppearTransitionState = toolbarAppearTransitionState
        self.size = size
        self.content = content()
    }

    var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        
        VStack {
            if (size == .large) {
                HStack {
                    Spacer()
                    HStack(spacing: 8) {
                        content
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
                    .opacity(toolbarAppearTransitionState)
                    .scaleEffect(
                        x: toolbarAppearTransitionState,
                        y: 0.5 + (toolbarAppearTransitionState * 0.5)
                    )
                    .offset(
                        y: (1 - toolbarAppearTransitionState) * 24
                    )
                    Spacer()
                }
            } else {
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        content
                    }
                    .frame(
                        alignment: .center
                    )
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.Gray900.color.opacity(0.75))
                            .stroke(AppColors.Gray700.color, lineWidth: 1)
                    )
                    .opacity(toolbarAppearTransitionState)
                    .scaleEffect(
                        x: toolbarAppearTransitionState,
                        y: 0.5 + (toolbarAppearTransitionState * 0.5)
                    )
                    .offset(
                        y: (1 - toolbarAppearTransitionState) * 24
                    )
                    Spacer()
                }
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

struct PresentationViewCloseButton: View {
    let onClose: () -> Void
    
    var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button(action: {
                    onClose()
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
        .padding(.top, 24)
        .padding(.horizontal, 24)
    }
}

enum PresentationViewType {
    case Overview, Prepare, Present, Results
}

struct PresentationView: View {
    
    let title: String;
    
    @State var viewType: PresentationViewType = .Overview
    @StateObject var speechRecognizer = SpeechRecgonizer()

    var body: some View {
        ZStack(alignment: .topLeading) {
            if (viewType == .Overview) {
                PresentationOverviewView(
                    title: title,
                    context: AppPresentations.PlaygroundObservationsPresentation.context,
                    firstPartId: AppPresentations.PlaygroundObservationsPresentation.parts[0].id,
                    viewType: $viewType,
                    speechRecognizer: speechRecognizer
                )
            } else if (viewType == .Prepare) {
                PresentationPrepareView(
                    title: title,
                    presentationParts: AppPresentations.PlaygroundObservationsPresentation.parts,
                    viewType: $viewType,
                    speechRecognizer: speechRecognizer
                )
            } else if (viewType == .Results) {
                ResultsView(
                    title: title,
                    speechRecognizer: speechRecognizer
                )
            } else {
                PresentationPresentView(
                    title: title,
                    presentationParts: AppPresentations.PlaygroundObservationsPresentation.parts,
                    viewType: $viewType,
                    speechRecognizer: speechRecognizer
                )
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .frame(
            maxHeight: .infinity
        )
        .background(AppColors.Gray950.color)
    }

}
