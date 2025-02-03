import Foundation

PlaygroundPage.current.needsIndefiniteExecution = true

// 信号機のパターン
enum TrafficLightState: @unchecked Sendable {
    case red
    case green
    case yellow
    case redFlashing
    
//　時間の配分
    var duration: TimeInterval {
        switch self {
        case .red:
            return 10.0
        case .green:
            return 8.0
        case .yellow:
            return 3.0
        case .redFlashing:
            return 1.0
        }
    }
    
    var description: String {33
        switch self {
        case .red:
            return "赤"
        case .green:
            return "緑"
        case .yellow:
            return "黄色"
        case .redFlashing:
            return "赤（点滅）"
        }
    }
}

@MainActor
final class TrafficLight: @unchecked Sendable {
    var currentState: TrafficLightState = .red
    var timer: Timer?
    // 信号機に問題が発生した場合のエラー
    var isError = false
    
    init() {
        startTrafficLightCycle()
    }
    
    func startTrafficLightCycle() {
        print("信号の色は \(currentState.description)です")
        scheduleNextState()
    }
    
    func scheduleNextState() {
        timer?.invalidate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + currentState.duration) { [weak self] in
            self?.moveToNextState()
        }
    }
    
    func moveToNextState() {
        // エラーの場合は変わらない
        if isError {
            return
        }
        
        switch currentState {
        case .red:
            currentState = .green
        case .green:
            currentState = .yellow
        case .yellow:
            currentState = .red
        case .redFlashing:
            currentState = .red
        }
        
        print("\(currentState.description)に変わります")
        scheduleNextState()
    }
    
    func stopTrafficLight() {
        timer?.invalidate()
        timer = nil
        print("信号停止")
    }
    
    // エラーの場合のファンクション
    func errorInTrafficLight() {
        isError = true
        currentState = .redFlashing
        print("信号は現在機能停止中です")
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            if self?.currentState == .redFlashing {
                self?.currentState = .red
            } else {
                self?.currentState = .redFlashing
            }
            print("警告: \(self?.currentState.description ?? "")")
        }
    }
    
    // 信号復旧ファンクション
    func resetFromError() {
        isError = false
        timer?.invalidate()
        currentState = .red
        print("信号は復旧しました")
        startTrafficLightCycle()
    }
}
