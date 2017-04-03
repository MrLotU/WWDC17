import UIKit

//MARK: BoardDelegate
public protocol BoardDelegate {
    func getCell(forCoordinate coordinate: Coordinate) -> Cell?
    func didGameEnd() -> Bool
    func gameDidEnd()
}

//MARK: CellState
public enum CellState {
    case Empty, Filled, Taken
    
    var image: UIImage {
        switch self {
        case .Empty: return UIImage(named: "Empty")!
        case .Filled: return UIImage(named: "Filled")!
        case .Taken: return UIImage(named: "Taken")!
        }
    }
}

//MARK: Coordinate
public struct Coordinate {
    let x: Int
    let y: Int
}
