//
//  PaintViewModel.swift
//  PaintApp
//
//  Created by RAVI RANDERIA on 9/20/16.
//  Copyright © 2016 RAVI RANDERIA. All rights reserved.
//

import Foundation
import UIKit

struct PaintViewModel {
    
    var eraserOn = Bool()
    var lastPoint = CGPoint.zero
    var showingBrushWidthOption = Bool()
    var colorPickerViewModel = ColorPickerViewModel()
    
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    mutating func thicknessActionSelection(sender : UIButton) {
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
    
    func configurePreviewContextSetting(context : CGContext,button : UIButton,width : CGFloat) -> CGContext {
        
        context.setLineCap(.round)
        context.setLineWidth(width)
        context.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1)
        context.setFillColor(red: 0, green: 0, blue: 0, alpha: 1)
        context.move(to: CGPoint(x: button.bounds.midX, y: button.bounds.midY))
        context.addLine(to: CGPoint(x: button.bounds.midX, y: button.bounds.midY))
        return context
    }
    
    
    mutating func toggleEraserStatusAndSetButtonImage() -> UIImage {
        if eraserOn {
            eraserOn = false
            return #imageLiteral(resourceName: "eraser")
        }
        eraserOn = true
        return #imageLiteral(resourceName: "magicEraser")
    }
    
    var chosenColor : UIColor {
        if eraserOn {
            return UIColor.white
        }
        if let colorSet  = colorPickerViewModel.chosenColor {
            return colorSet
        }
        return UIColor.black
    }
    
    func configureContext(context : CGContext,fromPoint : CGPoint,toPoint : CGPoint) -> CGContext {
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        
        context.setLineCap(CGLineCap.round)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(red: chosenColor.components.red,
                               green: chosenColor.components.green,
                               blue: chosenColor.components.blue,
                               alpha: 1)
        context.setBlendMode(CGBlendMode.normal)
        return context
    }
    
}
