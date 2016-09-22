//
//  PaintViewModel.swift
//  PaintApp
//
//  Created by RAVI RANDERIA on 9/20/16.
//  Copyright © 2016 RAVI RANDERIA. All rights reserved.
//

import Foundation
import UIKit

final class PaintViewModel {
    
    var swiped = false
    var eraserOn = Bool()
    var lastPoint = CGPoint.zero
    var showingBrushWidthOption = Bool()
    
    private(set) var initialConstrainTopValues = [CGFloat]()
    private(set) var brushWidth: CGFloat = 10.0
    private(set) var opacity: CGFloat = 1.0
    private(set) var widthOptions : [CGFloat] = [10,8,6,4,2]
    private(set) var activityTypeList : [UIActivityType] = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo,UIActivityType.airDrop,UIActivityType.assignToContact,UIActivityType.message,UIActivityType.postToFacebook,UIActivityType.mail,UIActivityType.saveToCameraRoll]
    
    private var chosenColor : UIColor!
    
    func returnChosenColor() -> UIColor {
        if eraserOn {
            return UIColor.white
        }
        if let chosenColor = chosenColor {
            return chosenColor
        }
        return UIColor.black
    }
    
    func setChosenColor(color : UIColor) {
        self.chosenColor = color
    }
    
    func captureInitialTopConstraintsForBrushWidth(constraintArray : [NSLayoutConstraint]) {
        for constraint in constraintArray {
            initialConstrainTopValues.append(constraint.constant)
        }
    }
    
    func thicknessActionSelection(sender : UIButton) {
        let buttonTag = sender.tag
        switch buttonTag {
        case 0 :
            brushWidth = 2
        case 1 :
            brushWidth = 4
        case 2 :
            brushWidth = 6
        case 3 :
            brushWidth = 8
        case 4 :
            brushWidth = 10
        default :
            brushWidth = 2
        }
    }
    
    func toggleEraserStatusAndSetButtonImage() -> UIImage {
        if eraserOn {
            eraserOn = false
            return #imageLiteral(resourceName: "eraser")
        }
        eraserOn = true
        return #imageLiteral(resourceName: "magicEraser")
    }
}
