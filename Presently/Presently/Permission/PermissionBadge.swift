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
