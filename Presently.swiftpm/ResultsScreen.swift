import SwiftUI
import Charts

struct OverallData: Identifiable {
    let id = UUID()
    let timestamp: Float
    let words: Int
    
    static func mockData() -> [OverallData] {
        var records: [OverallData] = []
        
        for i in 1...20 {
            records.append(
                OverallData(timestamp: Float(i) * 0.5, words: Int.random(in: 80...130))
            )
        }
        
        return records
    }
}

public struct ResultsRegularView: View {
    let title: String;
    let overallData: [OverallData]
    
    private var areaBackground: Gradient {
        return Gradient(colors: [AppColors.Primary500.color, AppColors.Primary500.color.opacity(0.1)])
    }

    public var body: some View {
        let maxTimestamp = overallData.map { $0.timestamp }.max() ?? 0
        let intervalPoints = Array(stride(from: 0, through: maxTimestamp, by: maxTimestamp / 4))
        
        let gridSpacing: Double = 20
        
        HStack(spacing: gridSpacing) {
            VStack(alignment: .leading) {
                Text("Pacing")
                    .frame(
                        maxWidth: 300,
                        alignment: .leading
                    )
                    .foregroundStyle(AppColors.Gray300.color)
                    .font(.system(size: AppFontSize.xl2.rawValue, weight: .medium))
                    .padding(.horizontal, 12)
                
                Chart(overallData) {
                    LineMark(
                        x: .value("Timestamp", $0.timestamp),
                        y: .value("Words", $0.words)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(AppColors.Primary500.color)
                    
                    AreaMark(
                        x: .value("Timestamp", $0.timestamp),
                        y: .value("Words", $0.words)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(areaBackground)
                    
                    RuleMark(y: .value("Average", 50))
                        .foregroundStyle(AppColors.Primary500.color)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                }
                .chartYAxis {
                    AxisMarks() { value in
                        AxisValueLabel() {
                            if let timestamp = value.as(Float.self) {
                                Text(String(format: "%.1f", timestamp))
                                    .foregroundStyle(AppColors.Gray300.color)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: intervalPoints) { value in
                        AxisValueLabel(centered: true) {
                            if let timestamp = value.as(Float.self) {
                                Text(String(format: "%.1f", timestamp))
                                    .foregroundStyle(AppColors.Gray300.color)
                            }
                        }
                    }
                }
                .chartXScale(domain: 0 ... 10)
                .chartYScale(domain: 0 ... 130)
                .frame(height: 240)
            }
            .frame(
                maxWidth: .infinity
            )
            .padding(.bottom, 12)
            .padding(.top, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.Gray900.color)
                    .stroke(AppColors.Gray700.color, lineWidth: 1)
            )
            
            VStack(spacing: gridSpacing) {
                VStack(alignment: .leading, spacing: 4) {
                    Spacer()
                    Text("Duration")
                        .frame(
                            alignment: .leading
                        )
                        .foregroundStyle(AppColors.Gray300.color)
                        .font(.system(size: AppFontSize.xl2.rawValue, weight: .medium))
                    Text("3m")
                        .frame(
                            alignment: .leading
                        )
                        .foregroundStyle(AppColors.Gray50.color)
                        .font(.system(size: AppFontSize.xl3.rawValue, weight: .medium))
                    Spacer()
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .leading
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.Gray900.color)
                        .stroke(AppColors.Gray700.color, lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Spacer()
                    Text("Average Speed")
                        .frame(
                            alignment: .leading
                        )
                        .foregroundStyle(AppColors.Gray300.color)
                        .font(.system(size: AppFontSize.xl2.rawValue, weight: .medium))
                    Text("120 wpm")
                        .frame(
                            alignment: .leading
                        )
                        .foregroundStyle(AppColors.Gray50.color)
                        .font(.system(size: AppFontSize.xl3.rawValue, weight: .medium))
                    Spacer()
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .leading
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.Gray900.color)
                        .stroke(AppColors.Gray700.color, lineWidth: 1)
                )
            }
            .frame(
                maxWidth: 300
            )

        }
        
    }
}

public struct ResultsCompactView: View {
    let title: String;
    let overallData: [OverallData]
    
    private var areaBackground: Gradient {
        return Gradient(colors: [AppColors.Primary500.color, AppColors.Primary500.color.opacity(0.1)])
    }

    public var body: some View {
        let maxTimestamp = overallData.map { $0.timestamp }.max() ?? 0
        let intervalPoints = Array(stride(from: 0, through: maxTimestamp, by: maxTimestamp / 4))
        
        VStack(alignment: .leading) {
            Text("Pacing")
                .frame(
                    maxWidth: 300,
                    alignment: .leading
                )
                .foregroundStyle(AppColors.Gray300.color)
                .font(.system(size: AppFontSize.lg.rawValue, weight: .medium))
                .padding(.horizontal, 12)
            
            Chart(overallData) {
                LineMark(
                    x: .value("Timestamp", $0.timestamp),
                    y: .value("Words", $0.words)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(AppColors.Primary500.color)
                
                AreaMark(
                    x: .value("Timestamp", $0.timestamp),
                    y: .value("Words", $0.words)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(areaBackground)
                
                RuleMark(y: .value("Average", 50))
                    .foregroundStyle(AppColors.Primary500.color)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
            }
            .chartYAxis {
                AxisMarks() { value in
                    AxisValueLabel() {
                        if let timestamp = value.as(Float.self) {
                            Text(String(format: "%.1f", timestamp))
                                .foregroundStyle(AppColors.Gray300.color)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: intervalPoints) { value in
                    AxisValueLabel(centered: true) {
                        if let timestamp = value.as(Float.self) {
                            Text(String(format: "%.1f", timestamp))
                                .foregroundStyle(AppColors.Gray300.color)
                        }
                    }
                }
            }
            .chartXScale(domain: 0 ... 10)
            .chartYScale(domain: 0 ... 130)
            .frame(height: 240)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .topLeading
        )
        .padding(.bottom, 12)
        .padding(.top, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.Gray900.color)
                .stroke(AppColors.Gray700.color, lineWidth: 1)
        )
        
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Duration")
                    .frame(
                        alignment: .leading
                    )
                    .foregroundStyle(AppColors.Gray300.color)
                    .font(.system(size: AppFontSize.lg.rawValue, weight: .medium))
                Text("3m")
                    .frame(
                        alignment: .leading
                    )
                    .foregroundStyle(AppColors.Gray50.color)
                    .font(.system(size: AppFontSize.lg.rawValue, weight: .medium))
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Average Speed")
                    .frame(
                        alignment: .leading
                    )
                    .foregroundStyle(AppColors.Gray300.color)
                    .font(.system(size: AppFontSize.lg.rawValue, weight: .medium))
                Text("120 wpm")
                    .frame(
                        alignment: .leading
                    )
                    .foregroundStyle(AppColors.Gray50.color)
                    .font(.system(size: AppFontSize.lg.rawValue, weight: .medium))
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
        
    }
}

public struct ResultsView: View {
    let title: String;
    
    @State var overallData = OverallData.mockData()
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    public var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        
        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(title)
                            .frame(
                                maxWidth: horizontalSizeClass == .compact ? 320 : 440,
                                alignment: .leading
                            )
                            .foregroundStyle(AppColors.Gray50.color)
                            .font(.system(size: AppFontSize.xl3.rawValue, weight: .black))
                        
                        if (horizontalSizeClass == .compact) {
                            ResultsCompactView(title: title, overallData: overallData)
                        } else {
                            ResultsRegularView(title: title, overallData: overallData)
                        }
                        
                        Spacer()
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .leading
                    )
                }
                .safeAreaPadding(safeAreaInsets)
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .background(AppColors.Gray950.color)
    }

}
