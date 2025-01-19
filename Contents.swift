// new_branch
import Foundation
import PlaygroundSupport


PlaygroundPage.current.needsIndefiniteExecution = true

// 信号機のパターン
enum TrafficLightState: @unchecked Sendable {
    case red
    case green
    case yellow
    
//　時間の配分
    var duration: TimeInterval {
        switch self {
        case .red:
            return 10.0
        case .green:
            return 8.0
        case .yellow:
            return 3.0
        }
    }
    
    var description: String {
        switch self {
        case .red:
            return "赤"
        case .green:
            return "緑"
        case .yellow:
            return "黄色"
        }
    }
}

@MainActor
final class TrafficLight: @unchecked Sendable {
    var currentState: TrafficLightState = .red
    var timer: Timer?
    
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
        switch currentState {
        case .red:
            currentState = .green
        case .green:
            currentState = .yellow
        case .yellow:
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
}


let trafficLight = TrafficLight()

DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
    trafficLight.stopTrafficLight()
    PlaygroundPage.current.finishExecution()
}

