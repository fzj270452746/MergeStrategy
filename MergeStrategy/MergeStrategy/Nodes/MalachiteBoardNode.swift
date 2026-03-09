//
//  MalachiteBoardNode.swift
//  MergeStrategy
//
//  Created by Assistant on 12/27/25.
//

import SpriteKit

/// Visual representation of the game board
final class MalachiteBoardNode: SKNode {

    // MARK: - Properties

    let gridDimension: Int
    let cellSize: CGFloat
    let cellSpacing: CGFloat = 6

    private var cellNodes: [[SKShapeNode]] = []
    private var tileNodes: [[PorcelainTileNode?]] = []

    weak var interactionDelegate: MalachiteBoardDelegate?

    // MARK: - Computed Properties

    var totalBoardSize: CGFloat {
        return CGFloat(gridDimension) * cellSize + CGFloat(gridDimension - 1) * cellSpacing
    }

    // MARK: - Initialization

    init(dimension: Int, cellSize: CGFloat) {
        self.gridDimension = dimension
        self.cellSize = cellSize
        super.init()

        isUserInteractionEnabled = true
        constructBoardVisuals()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Board Construction

    private func constructBoardVisuals() {
        // Background panel
        let panelSize = totalBoardSize + 24
        let panelBackground = SKShapeNode(rectOf: CGSize(width: panelSize, height: panelSize), cornerRadius: 16)
        panelBackground.fillColor = VelvetColorPalette.skSlatePanel.withAlphaComponent(0.8)
        panelBackground.strokeColor = VelvetColorPalette.skJadePrimary.withAlphaComponent(0.3)
        panelBackground.lineWidth = 2
        panelBackground.zPosition = -2
        addChild(panelBackground)

        // Initialize arrays
        cellNodes = Array(repeating: [], count: gridDimension)
        tileNodes = Array(repeating: Array(repeating: nil, count: gridDimension), count: gridDimension)

        // Create grid cells
        for col in 0..<gridDimension {
            for row in 0..<gridDimension {
                let cellNode = createCellNode()
                cellNode.position = calculateCellPosition(column: col, row: row)
                cellNode.name = "cell_\(col)_\(row)"
                addChild(cellNode)
                cellNodes[col].append(cellNode)
            }
        }
    }

    private func createCellNode() -> SKShapeNode {
        let cornerRadius = cellSize * 0.1
        let cell = SKShapeNode(rectOf: CGSize(width: cellSize - 2, height: cellSize - 2), cornerRadius: cornerRadius)
        cell.fillColor = VelvetColorPalette.skObsidianBackdrop.withAlphaComponent(0.6)
        cell.strokeColor = VelvetColorPalette.skJadePrimary.withAlphaComponent(0.2)
        cell.lineWidth = 1
        cell.zPosition = -1
        return cell
    }

    private func calculateCellPosition(column: Int, row: Int) -> CGPoint {
        let startX = -totalBoardSize / 2 + cellSize / 2
        let startY = -totalBoardSize / 2 + cellSize / 2

        let x = startX + CGFloat(column) * (cellSize + cellSpacing)
        let y = startY + CGFloat(row) * (cellSize + cellSpacing)

        return CGPoint(x: x, y: y)
    }

    // MARK: - Coordinate Conversion

    func coordinateFromPosition(_ position: CGPoint) -> GridCoordinate? {
        let localPos = convert(position, from: parent!)

        let startX = -totalBoardSize / 2
        let startY = -totalBoardSize / 2

        let relativeX = localPos.x - startX
        let relativeY = localPos.y - startY

        let cellPlusSpacing = cellSize + cellSpacing

        let column = Int(relativeX / cellPlusSpacing)
        let row = Int(relativeY / cellPlusSpacing)

        let coord = GridCoordinate(column, row)

        guard coord.isWithinBounds(gridSize: gridDimension) else { return nil }

        // Verify touch is within cell bounds (not in spacing)
        let cellX = CGFloat(column) * cellPlusSpacing
        let cellY = CGFloat(row) * cellPlusSpacing

        if relativeX >= cellX && relativeX <= cellX + cellSize &&
           relativeY >= cellY && relativeY <= cellY + cellSize {
            return coord
        }

        return nil
    }

    func positionFromCoordinate(_ coordinate: GridCoordinate) -> CGPoint {
        return calculateCellPosition(column: coordinate.column, row: coordinate.row)
    }

    // MARK: - Tile Management

    func placeTileNode(_ tileNode: PorcelainTileNode, at coordinate: GridCoordinate, animated: Bool = true) {
        let position = positionFromCoordinate(coordinate)
        tileNode.position = position
        tileNode.zPosition = 1
        addChild(tileNode)

        tileNodes[coordinate.column][coordinate.row] = tileNode

        if animated {
            tileNode.setScale(0)
            tileNode.alpha = 0

            let scaleAction = SKAction.scale(to: 1.0, duration: 0.2)
            scaleAction.timingMode = .easeOut
            let fadeAction = SKAction.fadeIn(withDuration: 0.15)

            tileNode.run(SKAction.group([scaleAction, fadeAction])) {
                tileNode.playPlacementAnimation()
            }
        }
    }

    func removeTileNode(at coordinate: GridCoordinate, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let tileNode = tileNodes[coordinate.column][coordinate.row] else {
            completion?()
            return
        }

        tileNodes[coordinate.column][coordinate.row] = nil

        if animated {
            tileNode.playMergeAnimation {
                tileNode.removeFromParent()
                completion?()
            }
        } else {
            tileNode.removeFromParent()
            completion?()
        }
    }

    func getTileNode(at coordinate: GridCoordinate) -> PorcelainTileNode? {
        guard coordinate.isWithinBounds(gridSize: gridDimension) else { return nil }
        return tileNodes[coordinate.column][coordinate.row]
    }

    func clearAllTiles() {
        for col in 0..<gridDimension {
            for row in 0..<gridDimension {
                tileNodes[col][row]?.removeFromParent()
                tileNodes[col][row] = nil
            }
        }
    }

    // MARK: - Cell Highlighting

    func highlightCell(at coordinate: GridCoordinate, color: SKColor) {
        guard coordinate.isWithinBounds(gridSize: gridDimension) else { return }
        let cell = cellNodes[coordinate.column][coordinate.row]
        cell.fillColor = color.withAlphaComponent(0.4)
    }

    func clearCellHighlight(at coordinate: GridCoordinate) {
        guard coordinate.isWithinBounds(gridSize: gridDimension) else { return }
        let cell = cellNodes[coordinate.column][coordinate.row]
        cell.fillColor = VelvetColorPalette.skObsidianBackdrop.withAlphaComponent(0.6)
    }

    func clearAllHighlights() {
        for col in 0..<gridDimension {
            for row in 0..<gridDimension {
                cellNodes[col][row].fillColor = VelvetColorPalette.skObsidianBackdrop.withAlphaComponent(0.6)
            }
        }
    }

    func highlightMergeCluster(_ coordinates: Set<GridCoordinate>) {
        for coord in coordinates {
            highlightCell(at: coord, color: VelvetColorPalette.skAmberHighlight)
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let coordinate = coordinateFromPosition(convert(location, to: parent!)) {
            interactionDelegate?.boardDidReceiveTouch(self, at: coordinate)
        }
    }
}

// MARK: - Board Delegate

protocol MalachiteBoardDelegate: AnyObject {
    func boardDidReceiveTouch(_ board: MalachiteBoardNode, at coordinate: GridCoordinate)
}
