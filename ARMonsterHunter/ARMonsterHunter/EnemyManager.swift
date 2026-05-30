import ARKit
import RealityKit
import SwiftUI

@MainActor
final class EnemyManager {
    private weak var arView: ARView?
    private var enemies: [Entity] = []

    private let spawnDistance: Float = 1.7
    private let spiderScale = SIMD3<Float>(repeating: 0.01)
    private let fallbackCubeSize: Float = 0.22
    private let enemyMoveSpeed: Float = 0.18

    func configure(arView: ARView) {
        self.arView = arView
    }

    func spawn(_ type: EnemyType) {
        guard let arView else { return }

        let enemy = loadEnemyEntity(type)
        enemy.name = "enemy-\(type.rawValue)"
        enemy.generateCollisionShapes(recursive: true)

        let cameraTransform = arView.cameraTransform
        let cameraPosition = cameraTransform.translation
        let forward = -SIMD3<Float>(
            cameraTransform.matrix.columns.2.x,
            cameraTransform.matrix.columns.2.y,
            cameraTransform.matrix.columns.2.z
        )
        let spawnPosition = cameraPosition + normalize(forward) * spawnDistance

        let anchor = AnchorEntity(world: spawnPosition)
        anchor.addChild(enemy)
        arView.scene.addAnchor(anchor)
        enemies.append(enemy)
    }

    func shootFromCenter() -> Bool {
        guard let arView else { return false }

        let centerPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        guard let hitEntity = arView.entity(at: centerPoint),
              let enemy = enemyEntity(from: hitEntity) else {
            return false
        }

        playPopEffect(at: enemy.position(relativeTo: nil))
        remove(enemy)
        return true
    }

    func moveEnemiesTowardCamera() {
        guard let arView else { return }

        let cameraPosition = arView.cameraTransform.translation
        let frameStep = enemyMoveSpeed / 30.0

        for enemy in enemies {
            let currentPosition = enemy.position(relativeTo: nil)
            let direction = cameraPosition - currentPosition
            let distance = length(direction)

            guard distance > 0.35 else { continue }
            enemy.setPosition(currentPosition + normalize(direction) * frameStep, relativeTo: nil)
        }
    }

    private func loadEnemyEntity(_ type: EnemyType) -> Entity {
        // Place Spider.usdz at ARMonsterHunter/Assets/Models/Spider/Spider.usdz,
        // then add it to the Xcode target so it is copied into the app bundle.
        if let modelURL = modelURL(for: type),
           let entity = try? Entity.load(contentsOf: modelURL) {
            entity.scale = scale(for: type)
            return entity
        }

        let material = SimpleMaterial(color: .red, roughness: 0.35, isMetallic: false)
        let cube = ModelEntity(mesh: .generateBox(size: fallbackCubeSize), materials: [material])
        cube.scale = SIMD3<Float>(repeating: 1)
        return cube
    }

    private func modelURL(for type: EnemyType) -> URL? {
        let fileName = type.modelFileName

        if let url = Bundle.main.url(forResource: fileName, withExtension: "usdz") {
            return url
        }

        return Bundle.main.url(
            forResource: fileName,
            withExtension: "usdz",
            subdirectory: "Assets/Models/\(fileName)"
        )
    }

    private func scale(for type: EnemyType) -> SIMD3<Float> {
        switch type {
        case .spider:
            return spiderScale
        case .zombie:
            return SIMD3<Float>(repeating: 0.01)
        }
    }

    private func enemyEntity(from entity: Entity) -> Entity? {
        var current: Entity? = entity

        while let candidate = current {
            if enemies.contains(where: { $0 === candidate }) {
                return candidate
            }
            current = candidate.parent
        }

        return nil
    }

    private func remove(_ enemy: Entity) {
        enemies.removeAll { $0 === enemy }
        enemy.parent?.removeFromParent()
    }

    private func playPopEffect(at position: SIMD3<Float>) {
        guard let arView else { return }

        let smokeMaterial = SimpleMaterial(color: UIColor.white.withAlphaComponent(0.65), roughness: 1.0, isMetallic: false)
        let smoke = ModelEntity(mesh: .generateSphere(radius: 0.08), materials: [smokeMaterial])
        smoke.position = position

        let anchor = AnchorEntity(world: position)
        anchor.addChild(smoke)
        arView.scene.addAnchor(anchor)

        var endTransform = smoke.transform
        endTransform.scale = SIMD3<Float>(repeating: 2.4)
        smoke.move(to: endTransform, relativeTo: anchor, duration: 0.25, timingFunction: .easeOut)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            anchor.removeFromParent()
        }
    }
}
