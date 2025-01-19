import SwiftUI

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
