//
//  ColorPickerViewController.swift
//  PaintApp
//
//  Created by RAVI RANDERIA on 9/19/16.
//  Copyright © 2016 RAVI RANDERIA. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Global variables
    var tag: Int = 0
    var color: UIColor = UIColor.gray
    var delegate: ViewController? = nil
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString : String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString = cString.substring(from: cString.index(after: cString.startIndex))
        }
        
        if cString.characters.count != 6 {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath)
        cell.backgroundColor = UIColor.clear
        cell.tag = tag
        tag += 1
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var colorPalette: Array<String>
        
        // Get colorPalette array from plist file
        let path = Bundle.main.path(forResource: "colorPalette", ofType: "plist")
        let pListArray = NSArray(contentsOfFile: path!)
        
        if let colorPalettePlistFile = pListArray {
            colorPalette = colorPalettePlistFile as! [String]
            
            let cell: UICollectionViewCell  = collectionView.cellForItem(at: indexPath as IndexPath)! as UICollectionViewCell
            let hexString = colorPalette[cell.tag]
            color = hexStringToUIColor(hex: hexString)
            self.view.backgroundColor = color
            self.dismiss(animated: true, completion: nil)
            delegate?.setButtonColor(color: color)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
