//
//  ViewController.swift
//  PaintApp
//
//  Created by RAVI RANDERIA on 9/19/16.
//  Copyright © 2016 RAVI RANDERIA. All rights reserved.
//

import UIKit
import CoreGraphics

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let color = coreImageColor
        return (color.red, color.green, color.blue, color.alpha)
    }
}

final class ViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var eraserButtonOutlet: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    var eraserOn = Bool()
    
    
    @IBAction func eraserButtonPressed(_ sender: UIButton) {
        
        
        
        if eraserOn{
            eraserOn = false
            eraserButtonOutlet.imageView?.animationImages = [#imageLiteral(resourceName: "eraser")]
            eraserButtonOutlet.imageView?.animationDuration = 1.0
            eraserButtonOutlet.imageView?.startAnimating()
            return
        }
        eraserOn = true
        eraserButtonOutlet.imageView?.animationImages = [#imageLiteral(resourceName: "magicEraser")]
        eraserButtonOutlet.imageView?.animationDuration = 1.0
        eraserButtonOutlet.imageView?.startAnimating()
    }
    
    
    @IBOutlet weak var colorPickerButtonOutlet: UIButton!
    
    var lastPoint = CGPoint.zero
    
    var red: CGFloat {
        if eraserOn {
            return UIColor.white.components.red
        }
        return colorPickerButtonOutlet.currentTitleColor.components.red
    }
    var green: CGFloat {
        if eraserOn {
            return UIColor.white.components.green
        }
        return colorPickerButtonOutlet.currentTitleColor.components.green
    }
    var blue: CGFloat {
        if eraserOn {
            return UIColor.white.components.blue
        }
        return colorPickerButtonOutlet.currentTitleColor.components.blue
    }
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    //this is where the brush hits the paper
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first  {
            lastPoint = touch.location(in: self.view)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
        }
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: 1.0)
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tempImageView.image = nil
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        mainImageView.image = nil
    }
    
    @IBAction func settingsAction(_ sender: UIButton) {
        
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        if let context = UIGraphicsGetCurrentContext(){
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
            
        context.setLineCap(CGLineCap.round)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(red: red,
                               green: green,
                               blue: blue,
                               alpha: 1)
        context.setBlendMode(CGBlendMode.normal)
        
        context.strokePath()
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        }
    }
    
    
    @IBAction func colorPickerButtonAction(_ sender: UIButton) {
        let popoverVC = storyboard?.instantiateViewController(withIdentifier: "colorPickerPopover") as! ColorPickerViewController
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: 85, height: 30)
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
            popoverController.permittedArrowDirections = .any
            popoverController.delegate = self
            popoverVC.delegate = self
        }
        present(popoverVC, animated: true, completion: nil)
    }
    
    // Override the iPhone behavior that presents a popover as fullscreen
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    
    
    func setButtonColor (color: UIColor) {
        colorPickerButtonOutlet.setTitleColor(color, for:UIControlState.normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}

