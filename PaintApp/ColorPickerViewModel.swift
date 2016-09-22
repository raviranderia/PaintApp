//
//  ColorPickerViewModel.swift
//  PaintApp
//
//  Created by RAVI RANDERIA on 9/20/16.
//  Copyright © 2016 RAVI RANDERIA. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let color = coreImageColor
        return (color.red, color.green, color.blue, color.alpha)
    }
}

struct ColorPickerViewModel {
    
    // Global variables
    //cannot be private as it is reset to zero on viewDidLoad in Controller as ColorPickerViewModel is a class and being passed around
    var tag: Int = 0
    private var color: UIColor = UIColor.gray
    private(set) var chosenColor : UIColor!
    private var columns = 10
    private var rows = 16
    
    
    //preseting 160 colors
    var numberOfItemsInSection : Int {
        return columns
    }
    
    var numberOfSections : Int {
        return rows
    }
    
    mutating func cellForItemAtIndexPath(cell : UICollectionViewCell,indexPath : IndexPath) -> UICollectionViewCell {
        cell.backgroundColor = UIColor.clear
        cell.tag = tag
        tag += 1
        return cell
    }
    
    mutating func didSelectItemAtIndexPath(cell : UICollectionViewCell,indexPath : IndexPath,completion : (Bool) -> ()) {
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
    
    private func hexStringToUIColor (hex:String) -> UIColor {
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
