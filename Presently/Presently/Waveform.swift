import SwiftUI

struct AudioWaveformBar: View {
    let amplitude: CGFloat
    let spacing: CGFloat
    let color: Color
    @State private var height: CGFloat = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 4, height: height)
            .animation(.easeInOut(duration: 0.2), value: height)
            .onAppear {
                height = amplitude
            }
    }
}

struct AudioWaveformView: View {
    var amplitudes: [CGFloat]
    
    var body: some View {
        GeometryReader { geometry in
            if amplitudes.count > 0 {
                let size = geometry.size.width / CGFloat(amplitudes.count * 2)
                
                HStack(alignment: .bottom, spacing: size) {
                    ForEach(0..<amplitudes.count, id: \.self) { index in
                        let amplitude = amplitudes[index]
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(
                                        stops: [
                                            .init(color: AppColors.Gray600.color.opacity(0.5), location: 0),
                                            .init(color: AppColors.Gray700.color.opacity(0), location: 1)
                                        ]
                                    ),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: size, height: geometry.size.height * amplitude)
                            .animation(.easeInOut(duration: 0.2), value: amplitude)
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottom
                )
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .bottom
        )
        .onAppear {
//            startAnimation()
        }
    }
    
//    private func startAnimation() {
//        let barCount = 30
//        amplitudes = Array(repeating: 0, count: barCount)
//        
//        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
//            var newAmplitudes: [CGFloat] = []
//            for _ in 0..<barCount {
//                newAmplitudes.append(CGFloat.random(in: 0...0.5))
//            }
//            amplitudes = newAmplitudes
//        }
//    }
}

