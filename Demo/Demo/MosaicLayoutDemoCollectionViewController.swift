
//  MosaicLayoutDemoCollectionViewController.swift
//  Demo
//
//  Created by Liang Zhao on 2018/9/25.
//  Copyright © 2018年 Amztion. All rights reserved.
//

import UIKit
import LZMosaicCollectionViewLayout

private let reuseIdentifier = "MosaicLayoutCell"

class MosaicLayoutDemoCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = (collectionView.collectionViewLayout as? MosaicCollectionViewLayout) {
            layout.delegate = self
        }
    }
}

extension MosaicLayoutDemoCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MosaicCollectionViewCell
        cell.textLabel.text = "\(indexPath)"
        
        let red = CGFloat.random(in: 0..<1.0)
        let green = CGFloat.random(in:  0..<1.0)
        let blue = CGFloat.random(in: 0..<1.0)
        cell.contentView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        
        return cell
    }
}

extension MosaicLayoutDemoCollectionViewController: MosaicCollectionViewLayoutDelegate {
    func useCustomWidthForEachColumn(in collectionView: UICollectionView) -> Bool {
        return false
    }
    
    func numberOfColumn(in colletionView: UICollectionView) -> Int {
        return 2
    }
    
    func widthForColumn(of index: Int) -> CGFloat {
        return CGFloat.random(in: 100..<150)
    }
    
    func collectionView(_ collectionView: UICollectionView, sizeForViewAtIndexPath: IndexPath) -> CGSize {
        //        return CGSize(width: CGFloat.random(in: 100..<375), height: CGFloat.random(in: 100..<375))
        
        let biggerSize = CGSize(width: 100, height: 100)
        let smallerSize = CGSize(width: 100, height: 50)
        
        return Int.random(in: 0..<10000) % 2 == 0 ? biggerSize : smallerSize
    }
    
    func rowMargin(in collectionView: UICollectionView) -> CGFloat {
        return 0.0
    }
    
    func columnMargin(in collectionView: UICollectionView) -> CGFloat {
        return 0.0
    }
}
