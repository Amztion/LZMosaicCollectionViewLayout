//
//  MosaicCollectionViewLayout.swift
//  LayoutDemo
//
//  Created by Liang Zhao on 2018/9/24.
//  Copyright © 2018年 Amztion. All rights reserved.
//

import UIKit

protocol MosaicCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForViewAtIndexPath: IndexPath) -> CGSize
    
    func useCustomWidthForEachColumn(in collectionView: UICollectionView) -> Bool
    
    func numberOfColumn(in colletionView: UICollectionView) -> Int
    
    func widthForColumn(of index: Int) -> CGFloat
    
    func rowMargin(in collectionView: UICollectionView) -> CGFloat
    
    func columnMargin(in collectionView: UICollectionView) -> CGFloat
 }

class MosaicCollectionViewLayout: UICollectionViewLayout {
    struct MosaicLayoutColumnItem {
        let index: Int
        var leading = 0.0
        var width = 0.0
        var height = 0.0
    }
    
    var rowMargin = 5.0
    var columnMargin = 5.0
    
    var numberOfColumn = 0
    var contentWidth: Double {
        get {
            guard let collectionView = collectionView else {
                return 0.0
            }
            
            let insets = collectionView.contentInset
            return Double(collectionView.bounds.width - (insets.left + insets.right))
        }
    }
    
    var columnItems = [MosaicLayoutColumnItem]()
    var attributedLayoutItemCaches = [IndexPath : UICollectionViewLayoutAttributes]()
    
    var delegate: MosaicCollectionViewLayoutDelegate?
    
    override func prepare() {
        super.prepare()
        
        invalidateLayout()
        configProperties()
        createLayoutAttributes()
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        
        columnItems.removeAll()
        attributedLayoutItemCaches.removeAll()
    }
    
    override var collectionViewContentSize: CGSize {
        get {
            return CGSize(width: columnItems.reduce(0.0) { $0 + $1.width }, height: columnItems[findTallestColumnIndex()].height)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributedLayoutItemCaches.values.filter { rect.intersects($0.frame) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributedLayoutItemCaches[indexPath]
    }
}

extension MosaicCollectionViewLayout {
    func configProperties() {
        guard let delegate = delegate else {
            return
        }
        
        guard let collectionView = collectionView else {
            return
        }
        
        rowMargin = Double(delegate.rowMargin(in: collectionView))
        columnMargin = Double(delegate.columnMargin(in: collectionView))
        
        numberOfColumn = delegate.numberOfColumn(in: collectionView)
        
        var widthes = [Double]()
        
        if delegate.useCustomWidthForEachColumn(in: collectionView) {
            widthes = (0..<numberOfColumn).map { Double(delegate.widthForColumn(of: $0)) }
        } else {
            let widthOfEachColumn = Double(contentWidth / Double(numberOfColumn)).rounded(.down)
            widthes = (0..<numberOfColumn).map { _ in widthOfEachColumn }
        }
        
        var lastTrailing = columnMargin * -1
        columnItems = (0..<numberOfColumn).map {
            let index = $0
            let leading = lastTrailing + columnMargin
            let width = widthes[$0]
            let height = rowMargin
            lastTrailing = leading + width
            
            return MosaicLayoutColumnItem(index: index, leading: leading, width: width, height: height)
        }
    }
}

extension MosaicCollectionViewLayout {
    func findShortestColumnIndex() -> Int {
        return columnItems.reduce(0) {
            return columnItems[$0].height > $1.height ? $1.index : $0
        }
    }
    
    func findTallestColumnIndex() -> Int {
        return columnItems.reduce(0) {
            return columnItems[$0].height < $1.height ? $1.index : $0
        }
    }
    
    func needRowSpan(for column: Int) -> Bool {
        if Int.random(in: 0..<10000) % 2 == 0 {
            if column + 1 < columnItems.count && columnItems[column + 1].height <= columnItems[column].height {
                return true
            }
            
            return false
        }
        
        return false
    }
    
    func fitSize(from originSize: CGSize, needRowSpan: Bool, in column: Int) -> CGSize {
        let width = needRowSpan && column + 1 < columnItems.count ?  columnItems[column].width + columnItems[column + 1].width + columnMargin : columnItems[column].width
        let height = Double(originSize.height * CGFloat(width) / originSize.width).rounded(.down)
        
        return CGSize(width: width, height: height)
    }
    
    func createAttributes(for size: CGSize, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let shortestIndex = findShortestColumnIndex()
        let shortestColumnItem = columnItems[shortestIndex]
        let rowSpan = needRowSpan(for: shortestIndex)
        let viewSize = fitSize(from: size, needRowSpan: rowSpan, in: shortestIndex)
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let frame = CGRect(x: CGFloat(shortestColumnItem.leading), y: CGFloat(shortestColumnItem.height + rowMargin), width: viewSize.width, height: viewSize.height)
        attributes.frame = frame

        let indexRange = rowSpan ? shortestIndex...(shortestIndex + 1) : shortestIndex...(shortestIndex)
        for index in indexRange {
            columnItems[index].height = columnItems[index].height + rowMargin + Double(frame.height)
        }
        
        return attributes
    }
    
    func createLayoutAttributes() {
        guard let delegate = delegate else {
            fatalError("delegate is not implemented")
        }
        
        guard let collectionView = collectionView else {
            return
        }
        
        let _ = (0..<(collectionView.numberOfItems(inSection: 0))).map { (row) -> UICollectionViewLayoutAttributes  in
            let indexPath = IndexPath(row: row, section: 0)
            let size = delegate.collectionView(collectionView, sizeForViewAtIndexPath: indexPath)
            
            let attributes = createAttributes(for: size, at: indexPath)
            
            attributedLayoutItemCaches[indexPath] = attributes
            
            return attributes
        }
    }
}
