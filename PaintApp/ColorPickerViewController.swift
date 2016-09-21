//
//  ColorPickerViewController.swift
//  PaintApp
//
//  Created by RAVI RANDERIA on 9/19/16.
//  Copyright © 2016 RAVI RANDERIA. All rights reserved.
//

import UIKit

final class ColorPickerViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    var colorPickerViewModel : ColorPickerViewModel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPickerViewModel.tag = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorPickerViewModel.numberOfItemsInSection
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return colorPickerViewModel.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath)
        return colorPickerViewModel.cellForItemAtIndexPath(cell: cell, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell: UICollectionViewCell  = collectionView.cellForItem(at: indexPath as IndexPath)! as UICollectionViewCell
        colorPickerViewModel.didSelectItemAtIndexPath(cell: cell, indexPath: indexPath) { (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
