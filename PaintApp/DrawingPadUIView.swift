//
//  DrawingPadUIView.swift
//  PaintApp
//
//  Created by RAVI RANDERIA on 9/21/16.
//  Copyright © 2016 RAVI RANDERIA. All rights reserved.
//

import UIKit

final class DrawingPadUIView: UIView {
    private var paintViewModel : PaintViewModel!
    private var mainImageView : UIImageView!
    
    init(paintViewModel : PaintViewModel) {
        super.init(frame: UIScreen.main.bounds)
        self.paintViewModel = paintViewModel
        mainImageView = UIImageView(frame: self.bounds)
        self.addSubview(mainImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    func setImageToNil(){
        self.mainImageView.image = nil
    }
    
    //MARK: UITouch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("began")
        if paintViewModel.showingBrushWidthOption {
            return
        }
        paintViewModel.swiped = false
        if let touch = touches.first  {
            paintViewModel.lastPoint = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        paintViewModel.swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            drawLineFrom(fromPoint: paintViewModel.lastPoint, toPoint: currentPoint)
            paintViewModel.lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ended")
        if !paintViewModel.swiped {
            drawLineFrom(fromPoint: paintViewModel.lastPoint, toPoint: paintViewModel.lastPoint)
        }
        UIGraphicsBeginImageContext(self.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), blendMode: .normal, alpha: 1.0)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    // MARK: CGContext
    private func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(self.frame.size)
        if let context = UIGraphicsGetCurrentContext(){
            self.mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
            configureContext(context: context, fromPoint: fromPoint, toPoint: toPoint).strokePath()
            self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    func drawPreview(button : UIButton ,width : CGFloat) {
        UIGraphicsBeginImageContext(CGSize(width: 30, height: 30))
        if let context = UIGraphicsGetCurrentContext(){
            configurePreviewContextSetting(context: context, button: button, width: width).strokePath()
            button.setImage(UIGraphicsGetImageFromCurrentImageContext(), for: .normal)
        }
        UIGraphicsEndImageContext()
    }
    
    private func configurePreviewContextSetting(context : CGContext,button : UIButton,width : CGFloat) -> CGContext {
        context.setLineCap(.round)
        context.setLineWidth(width)
        context.setStrokeColor(red: paintViewModel.returnChosenColor().components.red,
                               green: paintViewModel.returnChosenColor().components.green,
                               blue: paintViewModel.returnChosenColor().components.blue,
                               alpha: 1)
        context.move(to: CGPoint(x: button.bounds.midX, y: button.bounds.midY))
        context.addLine(to: CGPoint(x: button.bounds.midX, y: button.bounds.midY))
        return context
    }
    
    private func configureContext(context : CGContext,fromPoint : CGPoint,toPoint : CGPoint) -> CGContext {
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        context.setLineCap(CGLineCap.round)
        context.setLineWidth(paintViewModel.brushWidth)
        context.setStrokeColor(red: paintViewModel.returnChosenColor().components.red,
                               green: paintViewModel.returnChosenColor().components.green,
                               blue: paintViewModel.returnChosenColor().components.blue,
                               alpha: 1)
        context.setBlendMode(CGBlendMode.normal)
        return context
    }
    
    func takeScreenshot() -> UIImage? {
        //Create the UIImage
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.layer.backgroundColor = UIColor.white.cgColor
        mainImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return image
        }
        UIGraphicsEndImageContext()
        return nil
    }
    

    

}
