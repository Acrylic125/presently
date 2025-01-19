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

struct ResultsView: View {
    let title: String;
    
    @State private var overallData = OverallData.mockData()

    private var areaBackground: Gradient {
        return Gradient(colors: [AppColors.Primary500.color, AppColors.Primary500.color.opacity(0.1)])
    }
    
    func getSafeAreaInset() -> UIEdgeInsets {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let safeAreaInsets = scene?.windows.first?.safeAreaInsets ?? .zero
        return safeAreaInsets
    }
    
    var body: some View {
        let safeAreaInsets = getSafeAreaInset()
        
        let maxTimestamp = overallData.map { $0.timestamp }.max() ?? 0
        let intervalPoints = Array(stride(from: 0, through: maxTimestamp, by: maxTimestamp / 4))

        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(title)
                            .frame(
                                maxWidth: 300,
                                alignment: .leading
                            )
                            .foregroundStyle(AppColors.Gray50.color)
                            .fontWeight(.black)
                            .font(.title)
                        
                        VStack(alignment: .leading) {
                            Text("Pacing")
                                .frame(
                                    maxWidth: 300,
                                    alignment: .leading
                                )
                                .foregroundStyle(AppColors.Gray300.color)
                                .font(.headline)
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
                            VStack(alignment: .leading) {
                                Text("Duration")
                                    .frame(
                                        alignment: .leading
                                    )
                                    .foregroundStyle(AppColors.Gray300.color)
                                    .font(.headline)
                                Text("3m")
                                    .frame(
                                        alignment: .leading
                                    )
                                    .foregroundStyle(AppColors.Gray50.color)
                                    .font(.headline)
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
                            
                            VStack(alignment: .leading) {
                                Text("Average Speed")
                                    .frame(
                                        alignment: .leading
                                    )
                                    .foregroundStyle(AppColors.Gray300.color)
                                    .font(.headline)
                                Text("120 wpm")
                                    .frame(
                                        alignment: .leading
                                    )
                                    .foregroundStyle(AppColors.Gray50.color)
                                    .font(.headline)
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
                        
                        Spacer()
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .leading
                    )
                }
                .safeAreaPadding(
                    .init(
                        top: safeAreaInsets.top,
                        leading: safeAreaInsets.left,
                        bottom: safeAreaInsets.bottom,
                        trailing: safeAreaInsets.right
                    )
                )
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
