import AVFoundation
import Charts
import Speech
import SwiftUI

struct PresentationSelectionView: View {

  let size: AppContentSize

  @State var All: [Presentation] = [
    AppPresentations.PlaygroundObservationsPresentation,
    AppPresentations.ArtOfCommunicationPresentation,
  ]

  var body: some View {
    let containerPadding: CGFloat = size == .large ? 24 : 12
    let containerBorderRadius: CGFloat = size == .large ? 16 : 8
    let containerTextSize: AppFontSize = size == .large ? .xl2 : .lg

    if size == .large {
      let gridCols = 3
      let gridRows: Int = (All.count / gridCols) + 1

      Grid(
        horizontalSpacing: 24,
        verticalSpacing: 24
      ) {
        ForEach(0..<gridRows, id: \.self) { rowIndex in
          GridRow {
            ForEach(0..<gridCols, id: \.self) { colIndex in
              let presentationIndex = gridRows * rowIndex + colIndex
              if presentationIndex >= All.count {
                VStack {
                }
                .background(Color.blue)
                .frame(
                  maxWidth: .infinity,
                  minHeight: 40
                )
              } else {
                let presentation = All[presentationIndex]
                NavigationLink(
                  destination: PresentationView(
                    presentation: presentation
                  )
                ) {
                  VStack(
                    spacing: 24
                  ) {
                    VStack {
                      Image(presentation.imgRegular)
                        .resizable()
                        .scaledToFit()
                    }
                    .aspectRatio(4 / 3, contentMode: .fit)
                    VStack(alignment: .leading) {
                      Text(presentation.title)
                        .frame(
                          maxWidth: 440,
                          alignment: .leading
                        )
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(AppColors.Gray50.color)
                        .font(.system(size: containerTextSize.rawValue, weight: .black))
                    }
                    .padding(.horizontal, containerPadding)
                    .padding(.bottom, containerPadding)
                  }
                  .frame(
                    maxWidth: .infinity
                  )
                  .background(
                    RoundedRectangle(cornerRadius: containerBorderRadius)
                      .fill(AppColors.Gray900.color)
                      .stroke(AppColors.Gray700.color, lineWidth: 1)
                  )
                }
              }
            }
          }
        }
      }
    } else {
      VStack(
        alignment: .leading,
        spacing: 24
      ) {
        ForEach(0..<All.count, id: \.self) { index in
          let presentation = All[index]

          NavigationLink(
            destination: PresentationView(
              presentation: presentation
            )
          ) {
            HStack(
              spacing: 24
            ) {
              VStack {
                Image(presentation.imgCompact)
                  .resizable()
                  .scaledToFit()
              }
              .aspectRatio(1 / 1, contentMode: .fit)
              HStack {
                Text(presentation.title)
                  .frame(
                    maxWidth: 440,
                    alignment: .leading
                  )
                  .multilineTextAlignment(.leading)
                  .foregroundStyle(AppColors.Gray50.color)
                  .font(.system(size: containerTextSize.rawValue, weight: .black))
                Spacer()
              }
              .frame(
                maxWidth: .infinity
              )
              .padding(.trailing, containerPadding)
            }
            .frame(
              maxWidth: .infinity,
              alignment: .leading
            )
            .background(
              RoundedRectangle(cornerRadius: containerBorderRadius)
                .fill(AppColors.Gray900.color)
                .stroke(AppColors.Gray700.color, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: containerBorderRadius))
          }
        }
      }
      .frame(
        maxWidth: .infinity
      )
    }

  }
}

struct ContentView: View {

  @State private var microphonePermission: AVAudioApplication.recordPermission = .undetermined
  @State private var speechRecognitionPermission: SFSpeechRecognizerAuthorizationStatus =
    .notDetermined

  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  var body: some View {
    let safeAreaInsets = getSafeAreaInset()

    let size: AppContentSize = horizontalSizeClass == .regular ? .large : .small

    let headerTextSize: AppFontSize = horizontalSizeClass == .regular ? .xl4 : .xl3

    VStack(alignment: .leading) {
      if microphonePermission == .granted && speechRecognitionPermission == .authorized {
        ScrollView {
          VStack(alignment: .leading) {
            Text("Get Practicing")
              .frame(
                maxWidth: 440,
                alignment: .leading
              )
              .foregroundStyle(AppColors.Gray50.color)
              .font(.system(size: headerTextSize.rawValue, weight: .black))

            PresentationSelectionView(
              size: size
            )
            .frame(
              maxHeight: .infinity,
              alignment: .leading
            )
          }
          .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
          )
        }
        .frame(
          maxWidth: .infinity,
          maxHeight: .infinity,
          alignment: .leading
        )
        .safeAreaPadding(safeAreaInsets)
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
      } else {
        PermissionScreen(
          microphonePermission: $microphonePermission,
          speechRecognitionPermission: $speechRecognitionPermission
        )
      }
    }
    .onAppear {
      validatePermissions()
    }
    .onReceive(
      NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
    ) { _ in
      validatePermissions()
    }
    .ignoresSafeArea()
    .navigationBarBackButtonHidden()
    .background(AppColors.Gray950.color)
  }

  private func validatePermissions() {
    self.microphonePermission = AVAudioApplication.shared.recordPermission
    self.speechRecognitionPermission = SFSpeechRecognizer.authorizationStatus()
  }

}
