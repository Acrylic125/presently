import SwiftUI

struct PermissionCard: View {

  var size: AppContentSize
  var icon: String
  var title: String
  var description: String
  var allowed: Bool

  var body: some View {
    let containerPadding: CGFloat = size == .large ? 24 : 12
    let containerSpacing: CGFloat = size == .large ? 16 : 12
    let containerBorderRadius: CGFloat = size == .large ? 16 : 8
    let containerTitleSize: AppFontSize = size == .large ? .xl3 : .xl2
    let containerTextSize: AppFontSize = size == .large ? .xl2 : .lg

    let iconSize: CGFloat = size == .large ? 48 : 32

    VStack(spacing: containerSpacing) {
      HStack {
        VStack {
          Image(systemName: icon)
            .resizable()
            .scaledToFit()
        }
        .foregroundStyle(AppColors.Primary500.color)
        .frame(
          width: iconSize,
          height: iconSize
        )

        Spacer()

        PermissionStatusBadge(allowed: allowed)
      }
      .frame(
        maxWidth: .infinity,
        alignment: .leading
      )
      Text(title)
        .frame(
          maxWidth: .infinity,
          alignment: .leading
        )
        .font(.system(size: containerTitleSize.rawValue, weight: .bold))
        .foregroundStyle(AppColors.Gray50.color)
      Text(description)
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

  }

}
