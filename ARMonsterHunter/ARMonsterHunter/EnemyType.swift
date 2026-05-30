import Foundation

enum EnemyType: String {
    case spider = "Spider"
    case zombie = "Zombie"

    var modelFileName: String {
        rawValue
    }
}
