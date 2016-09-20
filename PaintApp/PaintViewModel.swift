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
