import SwiftUI

enum AppColors: String {
  case Primary50 = "primary50"
  case Primary100 = "primary100"
  case Primary200 = "primary200"
  case Primary300 = "primary300"
  case Primary400 = "primary400"
  case Primary500 = "primary500"
  case Primary600 = "primary600"
  case Primary700 = "primary700"
  case Primary800 = "primary800"
  case Primary900 = "primary900"
  case Primary950 = "primary950"

  case Gray50 = "gray50"
  case Gray100 = "gray100"
  case Gray200 = "gray200"
  case Gray300 = "gray300"
  case Gray400 = "gray400"
  case Gray500 = "gray500"
  case Gray600 = "gray600"
  case Gray700 = "gray700"
  case Gray800 = "gray800"
  case Gray900 = "gray900"
  case Gray950 = "gray950"

  var uiColor: UIColor {
    guard let color = UIColor(named: self.rawValue) else {
      // Fallback to a default color if the named color is not found
      print("Warning: Color \(self.rawValue) not found in asset catalog")
      return .gray
    }
    return color
  }

  var color: Color {
    return Color(self.uiColor)
  }
}
