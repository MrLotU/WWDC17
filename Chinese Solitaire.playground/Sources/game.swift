import UIKit

//shouldPlacePawn Variable, used to store if a pawn should be placed or taken
var shouldPlacePawn: Bool = false

//MARK: Cell
open class Cell: UIView {
    var cellState: CellState {
        didSet {
            //Set image for the cellState
            imageView.image = cellState.image
        }
    }
    let imageView = UIImageView()
    var coordinate: Coordinate
    var board: BoardDelegate!
    
    public init(x: Int, y: Int) {
        //Set coordinate, frame and image
        self.coordinate = Coordinate(x: x, y: y)
        if x == 3  && y == 3 {
            self.cellState = .Empty
        } else {
            self.cellState = .Filled
        }
        super.init(frame: CGRect(x: coordinate.x * 100, y: coordinate.y * 100, width: 100, height: 100))
        self.imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.addSubview(imageView)
        self.imageView.image = cellState.image
    }
    
    func canMove(fromCell cell: Cell, to destenation: Cell?, shouldRemove: Bool) -> Bool {
        //Check if the destination cell passed in is not nil
        if let destCell = destenation {
            //Repeating process: Check if the destinationCell is 2 cells away on either side of the first cell (x/y +/- 2) and if the other coordinate is the same (can't move diagonally)
            if cell.coordinate.x + 2 == destCell.coordinate.x && cell.coordinate.y == destCell.coordinate.y && destCell.cellState == .Empty {
                //Get the cell that gets jumped over
                let cellToRemove = board?.getCell(forCoordinate: Coordinate(x: cell.coordinate.x + 1, y: cell.coordinate.y))
                if cellToRemove!.cellState == .Empty {
                    //If it's empty, return false, can't move to that field
                    return false
                } else {
                    //If it's not empty, return true, can move to that field
                    if shouldRemove {
                        //If the cell should be removed, IE: we play a move and this is not the end game check. Remove the cell
                        cellToRemove?.cellState = .Empty
                    }
                    return true
                }
            } else if cell.coordinate.x - 2 == destCell.coordinate.x && cell.coordinate.y == destCell.coordinate.y && destCell.cellState == .Empty {
                let cellToRemove = board?.getCell(forCoordinate: Coordinate(x: cell.coordinate.x - 1, y: cell.coordinate.y))
                if cellToRemove!.cellState == .Empty {
                    return false
                } else {
                    if shouldRemove {
                        cellToRemove?.cellState = .Empty
                    }
                    return true
                }
            } else if cell.coordinate.y - 2 == destCell.coordinate.y && cell.coordinate.x == destCell.coordinate.x && destCell.cellState == .Empty {
                let cellToRemove = board?.getCell(forCoordinate: Coordinate(x: cell.coordinate.x, y: cell.coordinate.y - 1))
                if cellToRemove!.cellState == .Empty {
                    return false
                } else {
                    if shouldRemove {
                        cellToRemove?.cellState = .Empty
                    }
                    return true
                }
            } else if cell.coordinate.y + 2 == destCell.coordinate.y && cell.coordinate.x == destCell.coordinate.x && destCell.cellState == .Empty {
                let cellToRemove = board?.getCell(forCoordinate: Coordinate(x: cell.coordinate.x, y: cell.coordinate.y + 1))
                if cellToRemove!.cellState == .Empty {
                    return false
                } else {
                    if shouldRemove {
                        cellToRemove?.cellState = .Empty
                    }
                    return true
                }
            } else if cell.coordinate.y == destCell.coordinate.y && cell.coordinate.x == destCell.coordinate.x {
                //If x and y match, you deselect the cell, return true, you can always move from a cell to the same cell
                return true
            }else {
                return false
            }
        } else {
            return false
        }
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            //Check if the game is over
            if !board.didGameEnd() {
                //Check if the pawn should be Placed or Taken
                //Check if the cell you want to place the pawn is empty
                if shouldPlacePawn && self.cellState == .Empty {
                    //Check if you can move to that cell
                    if canMove(fromCell: tookPawnFrom, to: self, shouldRemove: true) {
                        //If you can, fill the destination cell and empty the cell you took the pawn from
                        self.cellState = .Filled
                        tookPawnFrom.cellState = .Empty
                        //Set ShouldPlacePawn to false, next time you should pick up a pawn
                        shouldPlacePawn = false
                    } else {
                        return
                    }
                //Check if you should pick up a pawn and if the cell is filled
                } else if !shouldPlacePawn && self.cellState == .Filled {
                    //Pick up the cell (cellState = .Taken) set the tookPawnFrom variable and set shouldPlacePawn to true
                    self.cellState = .Taken
                    tookPawnFrom = self
                    shouldPlacePawn = true
                //Check if you should place the pawn and if the cell you pressed has the .Taken state IE: place a pawn in the cell you took it from
                } else if shouldPlacePawn && self.cellState == .Taken {
                    //Fill the cell and set shouldPlacePawn to false
                    self.cellState = .Filled
                    shouldPlacePawn = false
                } else {
                    return
                }
                //Check if the game is over
                if board.didGameEnd() {
                    //If the game is over, call the gameDidEnd() method
                    board.gameDidEnd()
                }
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//tookPawnFrom Variable, used to store the Cell you just emptied (cellState = .Taken)
var tookPawnFrom: Cell!

//MARK: Board
open class Board: UIView, BoardDelegate {
    
    //Function to get a cell by specifying Coordinates
    public func getCell(forCoordinate coordinate: Coordinate) -> Cell? {
        var returnCell: Cell? = nil
        //Go through all cells and check if the coordinates match the coordinates specified
        for cell in cells {
            if cell.coordinate.x == coordinate.x && cell.coordinate.y == coordinate.y {
                returnCell = cell
            }
        }
        //return the cell you got or nil if no cell was found
        return returnCell
    }
    
    //Function to check if the game has ended, either with a win or a loose
    public func didGameEnd() -> Bool {
        var filledCells: [Cell] = []
        //Get all cells that are still filled
        for cell in cells {
            if cell.cellState == .Filled || cell.cellState == .Taken {
                filledCells.append(cell)
            }
        }
        //If there's only 1 cell left, check if it's in the center of the board (check if there is a winner)
        if filledCells.count == 1 {
            if filledCells[0].coordinate.x == 3 && filledCells[0].coordinate.y == 3 {
                label.text = "Game status: You beat the game!"
                return true
            } else {
                return false
            }
        //Check if there is still a possible jump for a (filled) cell.
        } else {
            var lost: Bool = true
            for cell in filledCells {
                if cell.canMove(fromCell: cell, to: getCell(forCoordinate: Coordinate(x: cell.coordinate.x + 2, y: cell.coordinate.y)), shouldRemove: false) || cell.canMove(fromCell: cell, to: getCell(forCoordinate: Coordinate(x: cell.coordinate.x - 2, y: cell.coordinate.y)), shouldRemove: false) || cell.canMove(fromCell: cell, to: getCell(forCoordinate: Coordinate(x: cell.coordinate.x, y: cell.coordinate.y + 2)), shouldRemove: false) || cell.canMove(fromCell: cell, to: getCell(forCoordinate: Coordinate(x: cell.coordinate.x, y: cell.coordinate.y - 2)), shouldRemove: false) {
                    lost = false
                }
            }
            if lost {
                label.text = "Game status: You lost!"
            }
            return lost
        }
    }

    var cells: [Cell]
    let startAgainButton = UIButton(type: .custom)
    let label = UILabel()
    public init() {
        //set cells, frame and setup button
        self.cells = []
        super.init(frame: CGRect(x: 0, y: 0, width: 700, height: 700))
        label.frame = CGRect(x: 500, y: 0, width: 200, height: 100)
        label.text = "Game status: Playing"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        self.addSubview(label)
        startAgainButton.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        startAgainButton.setImage(UIImage(named: "playAgain"), for: .normal)
        startAgainButton.addTarget(self, action: #selector(playAgain), for: .touchUpInside)
        self.addSubview(startAgainButton)
        setup()
    }
    
    //If the game is over (message is called once game has ended, determined by the didGameEnd() function) show the startAgainButton
    public func gameDidEnd() {
        startAgainButton.isHidden = false
        startAgainButton.isEnabled = true
    }
    
    //Function to setup the view on start
    func setup() {
        var cellArray: [Cell] = []
        //Add all the cells and figure out where they should go
        for x in 0...6 {
            for y in 0...6 {
                if x > 1 && x < 5 && y < 2 {
                    let cell = Cell(x: x, y: y)
                    cell.board = self
                    self.addSubview(cell)
                    cellArray.append(cell)
                } else if y > 1 && y < 5 {
                    let cell = Cell(x: x, y: y)
                    cell.board = self
                    self.addSubview(cell)
                    cellArray.append(cell)
                } else if x > 1 && x < 5 && y > 4 {
                    let cell = Cell(x: x, y: y)
                    cell.board = self
                    self.addSubview(cell)
                    cellArray.append(cell)
                }
            }
        }
        //Set all local values and hide the startAgainButton
        self.cells = cellArray
        self.backgroundColor = UIColor.white
        startAgainButton.isEnabled = false
        startAgainButton.isHidden = true
    }
    
    //PlayAgain function for when the game is restarted
    func playAgain() {
        //Set everything back to their initial state and hide the startAgainButton
        for cell in cells {
            if cell.coordinate.x == 3 && cell.coordinate.y == 3 {
                cell.cellState = .Empty
            } else {
                cell.cellState = .Filled
            }
        }
        label.text = "Game status: Playing"
        startAgainButton.isEnabled = false
        startAgainButton.isHidden = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}










