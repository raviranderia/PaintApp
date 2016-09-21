//
//  ColorPickerViewModel.swift
//  PaintApp
//
//  Created by RAVI RANDERIA on 9/20/16.
//  Copyright © 2016 RAVI RANDERIA. All rights reserved.
//

import Foundation
import UIKit

class ColorPickerViewModel {
    
    // Global variables
    var tag: Int = 0
    var color: UIColor = UIColor.gray
    var chosenColor : UIColor!
    
    var numberOfItemsInSection : Int {
        return 10
    }
    
    var numberOfSections : Int {
        return 16
    }
    
    func cellForItemAtIndexPath(cell : UICollectionViewCell,indexPath : IndexPath) -> UICollectionViewCell {
        cell.backgroundColor = UIColor.clear
        cell.tag = tag
        tag += 1
        return cell
    }
    
    func didSelectItemAtIndexPath(cell : UICollectionViewCell,indexPath : IndexPath,completion : (Bool) -> ()) {
        var colorPalette: Array<String>
        
        // Get colorPalette array from plist file
        let path = Bundle.main.path(forResource: "colorPalette", ofType: "plist")
        let pListArray = NSArray(contentsOfFile: path!)
        
        if let colorPalettePlistFile = pListArray {
            colorPalette = colorPalettePlistFile as! [String]
            let hexString = colorPalette[cell.tag]
            color = hexStringToUIColor(hex: hexString)
            chosenColor = color
            completion(true)
        }
        completion(false)
    }
    
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
}
