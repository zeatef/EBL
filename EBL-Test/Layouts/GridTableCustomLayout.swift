//
//  GridTableCustomLayout.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 2/22/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit

class GridTableCustomLayout: UICollectionViewFlowLayout {
    
    //A 2D array that contains attributes for each cell in the grid.
    private var allAttributes: [[UICollectionViewLayoutAttributes]] = []
    private var contentSize = CGSize.zero
    
    //Size of the collection view
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    //Called whenever the collection view layout is invalidated.
    //Set up allAttributes here for performance measures.
    override func prepare() {
        setupAttributes()
        updateStickyItemsPositions()
        
        let lastItemFrame = allAttributes.last?.last?.frame ?? .zero
        contentSize = CGSize(width: lastItemFrame.maxX, height: lastItemFrame.maxY)
    }
    
    //Setup the 2D array with attributes for every cell in the grid.
    private func setupAttributes() {
        //Re-initialize the 2D array as the older version may be no longer valid.
        allAttributes = []
        
        //Set the x and y offset variables that will be used later on in this method.
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        
        //Iterate over all rows within a grid. (Section = Row, ItemsInSection = Coloumn)
        for row in 0..<collectionView!.numberOfSections {
            
            //Make preparations before we calculate attributes for next row.
            //Each row must begin with 0 position, thus we need to reset xOffset.
            //Attributes of each row are stored in rowAttrs array.
            var rowAttrs: [UICollectionViewLayoutAttributes] = []
            xOffset = 0
            
            //Iterate over all columns within a row.
            for col in 0..<collectionView!.numberOfItems(inSection: row) {
                
                //Calculate a frame of a cell.
                let itemSize = size(forRow: row, column: col)
                let indexPath = IndexPath(row: row, column: col)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral
                
                rowAttrs.append(attributes)
                
                xOffset += itemSize.width
            }
            
            yOffset += rowAttrs.last?.frame.height ?? 0.0
            allAttributes.append(rowAttrs)
        }
    }
    
    //The method size(forRow:,column:) asks a flow layout delegate to provide the size for an item and does several safety checks.
    //The validations enforce all flow layout delegates to return sizes of the cells.
    private func size(forRow row: Int, column: Int) -> CGSize {
        guard let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout,
            let size = delegate.collectionView?(collectionView!, layout: self, sizeForItemAt: IndexPath(row: row, column: column)) else {
                assertionFailure("Implement collectionView(_,layout:,sizeForItemAt: in UICollectionViewDelegateFlowLayout")
                return .zero
        }
        
        return size
    }
    
    //Before rendering its cells, the collection view calls layoutAttributesForElements(in:) that returns an array of cells attributes.
    //Instead of drawing all cells at once, the collection view passes visible rectangle to that method and expects it to return attributes only for the visible cells which has a positive impact on performance
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for rowAttrs in allAttributes {
            for itemAttrs in rowAttrs where rect.intersects(itemAttrs.frame) {
                layoutAttributes.append(itemAttrs)
            }
        }
        
        return layoutAttributes
    }
    
    //MARK: - Sticky Coloumns and Rows Methods
    var stickyRowsCount = 0 {
        didSet {
            invalidateLayout()
        }
    }
    
    var stickyColumnsCount = 0 {
        didSet {
            invalidateLayout()
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    private func updateStickyItemsPositions() {

        for row in 0..<collectionView!.numberOfSections {
            for col in 0..<collectionView!.numberOfItems(inSection: row) {
                let attributes = allAttributes[row][col]
                
                if row < stickyRowsCount {
                    var frame = attributes.frame
                    frame.origin.y += collectionView!.contentOffset.y
                    attributes.frame = frame
                }
                
                if col < stickyColumnsCount {
                    var frame = attributes.frame
                    frame.origin.x += collectionView!.contentOffset.x
                    attributes.frame = frame
                }
                
                attributes.zIndex = zIndex(forRow: row, column: col)
            }
        }
    }
    
    //MARK: - Z-Index Methods
    private func zIndex(forRow row: Int, column col: Int) -> Int {
        if row < stickyRowsCount && col < stickyColumnsCount {
            return ZOrder.staticStickyItem
        } else if row < stickyRowsCount || col < stickyColumnsCount {
            return ZOrder.stickyItem
        } else {
            return ZOrder.commonItem
        }
    }
    
    private enum ZOrder {
        static let commonItem = 0
        static let stickyItem = 1
        static let staticStickyItem = 2
    }
    
}

//MARK: - Index Path Extenstion
//Utility method that converts row and column into IndexPath
private extension IndexPath {
    init(row: Int, column: Int) {
        self = IndexPath(item: column, section: row)
    }
}
