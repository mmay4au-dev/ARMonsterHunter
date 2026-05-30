import Combine
import Foundation
import RealityKit

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var score = 0

    private let enemyManager = EnemyManager()
    private var updateTimer: AnyCancellable?

    init() {
        updateTimer = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.enemyManager.moveEnemiesTowardCamera()
            }
    }

    func configure(arView: ARView) {
        enemyManager.configure(arView: arView)
    }

    func spawnSpider() {
        enemyManager.spawn(.spider)
    }

    func shoot() {
        guard enemyManager.shootFromCenter() else { return }
        score += 1
    }
}
