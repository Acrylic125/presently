import AVFoundation
import Speech
import SwiftUI

struct PermissionScreen: View {

  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  @Binding var microphonePermission: AVAudioApplication.recordPermission
  @Binding var speechRecognitionPermission: SFSpeechRecognizerAuthorizationStatus

  @State private var isLoading = false
  @State var permissionTransitionOutState = 1.0

  var body: some View {
    let safeAreaInsets = getSafeAreaInset()
    let size: AppContentSize = horizontalSizeClass == .regular ? .large : .small

    let padding: CGFloat = size == .large ? 24 : 12
    let headerTextSize: AppFontSize = size == .large ? .xl4 : .xl3

    let containerSpacing: CGFloat = size == .large ? 16 : 12

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

        PermissionCard(
          size: size,
          icon: "mic",
          title: "Microphone",
          description: "We use your microphone to capture your presentation",
          allowed: microphonePermission == .granted
        )
        PermissionCard(
          size: size,
          icon: "recordingtape.circle",
          title: "Recognizer",
          description: "We use your device to transcribe and analyze what you presented.",
          allowed: speechRecognitionPermission == .authorized
        )

        VStack {
          if microphonePermission == .undetermined || speechRecognitionPermission == .notDetermined
          {
            AppButton(action: self.requestPermissions) {
              Text("Allow")
            }
            .size(buttonSize)
            .disabled(isLoading)
          } else {
            AppButton(action: {
              if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
              }
            }) {
              Text("Allow in Settings")
            }
            .size(buttonSize)
            .variant(.ghost)
            .disabled(isLoading)
          }
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
    }
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity
    )
    .ignoresSafeArea()
    .navigationBarBackButtonHidden()
    .background(AppColors.Gray950.color)
    .offset(
      y: (1 - permissionTransitionOutState) * UIScreen.main.bounds.height
    )
  }

  private func requestPermissions() {
    if self.isLoading {
      return
    }

    self.isLoading = true
    Task {
      var micComplete = microphonePermission == .granted
      var recognizerComplete = speechRecognitionPermission == .authorized

      if microphonePermission == .undetermined {
        micComplete = await withCheckedContinuation { continuation in
          AVAudioApplication.requestRecordPermission { authorized in
            continuation.resume(returning: authorized)
          }
        }
      }

      if speechRecognitionPermission == .notDetermined {
        recognizerComplete = await withCheckedContinuation { continuation in
          SFSpeechRecognizer.requestAuthorization { status in
            continuation.resume(returning: status == .authorized)
          }
        }
      }

      if !(micComplete && recognizerComplete) {
        self.isLoading = false
        self.microphonePermission = AVAudioApplication.shared.recordPermission
        self.speechRecognitionPermission = SFSpeechRecognizer.authorizationStatus()
        return
      }
      withAnimation(.easeInOut(duration: 0.7)) {
        self.permissionTransitionOutState = 0.0
      } completion: {
        self.microphonePermission = AVAudioApplication.shared.recordPermission
        self.speechRecognitionPermission = SFSpeechRecognizer.authorizationStatus()
        self.isLoading = false
      }
    }
  }

}
