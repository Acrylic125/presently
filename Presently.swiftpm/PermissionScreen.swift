import SwiftUI

struct PermissionStatusBadge: View {
    let allowed: Bool
    
    var body: some View {
        if allowed {
            VStack {
                Text("Allowed")
                    .foregroundStyle(AppColors.Green100.color)
                    .font(.system(size: AppFontSize.lg.rawValue, weight: .black))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.Green400.color.opacity(0.5))
            )
        } else {
            VStack {
                Text("Not Allowed")
                    .foregroundStyle(AppColors.Gray50.color)
                    .font(.system(size: AppFontSize.lg.rawValue, weight: .black))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.Gray800.color)
                    .stroke(AppColors.Gray700.color, lineWidth: 1)
            )
        }
    }
}

struct PermissionScreen: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isMicrophoneAuthorized: Bool
    var isSpeechRecognitionAuthorized: Bool
    
    var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        let size: AppContentSize = horizontalSizeClass == .regular ? .large : .small
        
        let padding: CGFloat = size == .large ? 24 : 12
        let iconSize: CGFloat = size == .large ? 48 : 32
        let headerTextSize: AppFontSize = size == .large ? .xl4 : .xl3
        
        let containerPadding: CGFloat = size == .large ? 24 : 12
        let containerSpacing: CGFloat = size == .large ? 16 : 12
        let containerBorderRadius: CGFloat = size == .large ? 16 : 8
        let containerTitleSize: AppFontSize = size == .large ? .xl3 : .xl2
        let containerTextSize: AppFontSize = size == .large ? .xl2 : .lg
        
        let buttonSize: AppButtonSize = size == .large ? .large : .small
        
        let content = VStack {
            VStack(alignment: .leading, spacing: containerSpacing) {
                Text(size == .large ? "Permission Needed!" : "Permission\nNeeded!")
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(AppColors.Gray50.color)
                    .font(.system(size: headerTextSize.rawValue, weight: .black))
                
                VStack(spacing: containerSpacing) {
                    HStack {
                        VStack {
                            Image(systemName: "mic")
                                .resizable()
                                .scaledToFit()
                        }
                        .foregroundStyle(AppColors.Primary500.color)
                        .frame(
                            width: iconSize,
                            height: iconSize
                        )
                        
                        Spacer()
                        
                        PermissionStatusBadge(allowed: isMicrophoneAuthorized)
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    Text("Microphone")
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .font(.system(size: containerTitleSize.rawValue, weight: .bold))
                        .foregroundStyle(AppColors.Gray50.color)
                    Text("We use your microphone to capture your presentation")
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .font(.system(size: containerTextSize.rawValue, weight: .bold))
                        .foregroundStyle(AppColors.Gray400.color)
                }
                .frame(
                    maxWidth: .infinity
                )
                .padding(containerPadding)
                .background(
                    RoundedRectangle(cornerRadius: containerBorderRadius)
                        .fill(AppColors.Gray900.color)
                        .stroke(AppColors.Gray700.color, lineWidth: 1)
                )
                
                VStack(spacing: containerSpacing) {
                    HStack {
                        VStack {
                            Image(systemName: "recordingtape.circle")
                                .resizable()
                                .scaledToFit()
                        }
                        .foregroundStyle(AppColors.Primary500.color)
                        .frame(
                            width: iconSize,
                            height: iconSize
                        )
                        
                        Spacer()
                        
                        PermissionStatusBadge(allowed: isSpeechRecognitionAuthorized)
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    Text("Recognizer")
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .font(.system(size: containerTitleSize.rawValue, weight: .bold))
                        .foregroundStyle(AppColors.Gray50.color)
                    Text("We use your device to transcribe and analyze what you presented.")
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .font(.system(size: containerTextSize.rawValue, weight: .bold))
                        .foregroundStyle(AppColors.Gray400.color)
                    
                }
                .frame(
                    maxWidth: .infinity
                )
                .padding(containerPadding)
                .background(
                    RoundedRectangle(cornerRadius: containerBorderRadius)
                        .fill(AppColors.Gray900.color)
                        .stroke(AppColors.Gray700.color, lineWidth: 1)
                )
                
                VStack {
                    AppButton(action: {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }) {
                        Text("Allow in Settings")
                    }
                    .size(buttonSize)
                    .variant(.ghost)
                }
                .frame(
                    maxWidth: .infinity
                )
            }
            .frame(
                maxWidth: 720,
                maxHeight: .infinity
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .safeAreaPadding(safeAreaInsets)
        .padding(.horizontal, padding)

        VStack {
            content
//            if size == .large {
//               content
//            } else {
//                ScrollView {
//                    content
//                }
//                .frame(
//                    maxWidth: .infinity,
//                    maxHeight: .infinity
//                )
//            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .background(AppColors.Gray950.color)
    }
}
