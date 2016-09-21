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

final class PaintViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var constraintArray: [NSLayoutConstraint]!
    @IBOutlet weak var eraserButtonOutlet: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var colorPickerButtonOutlet: UIButton!
    
    var paintViewModel : PaintViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.paintViewModel = PaintViewModel()
        captureInitialTopConstraintsForBrushWidth(constraintArray: constraintArray)
        widthOptions = [10,8,6,4,2]
        hideBrushWidthButtonsAndSetTopConstraintsToZero()
    }
    
    @IBAction func eraserButtonPressed(_ sender: UIButton) {
        eraserButtonOutlet.setImage(paintViewModel.toggleEraserStatusAndSetButtonImage(), for: .normal)
    }
    
    @IBAction func thicknessSelectionAction(_ sender: UIButton) {
        hideBrushWidthButtonsAndSetTopConstraintsToZero()
        paintViewModel.thicknessActionSelection(sender: sender)
    }
    
    @IBOutlet var brushWidthCollection: [UIButton]!
    var initialConstrainTopValues = [CGFloat]()
    var widthOptions : [CGFloat]!

    func captureInitialTopConstraintsForBrushWidth(constraintArray : [NSLayoutConstraint]) {
        for constraint in constraintArray {
            initialConstrainTopValues.append(constraint.constant)
        }
    }
    
    func showBrushWidtButtonsAndSetTopConstraintsToInitialValues() {
        paintViewModel.showingBrushWidthOption = true
        
        for i in 0..<initialConstrainTopValues.count {
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.brushWidthCollection[i].isHidden = false
                strongSelf.brushWidthCollection[i].tintColor = strongSelf.paintViewModel.chosenColor
                strongSelf.constraintArray[i].constant = strongSelf.initialConstrainTopValues[i]
                strongSelf.drawPreview(button: strongSelf.brushWidthCollection[i], width: strongSelf.widthOptions[i])
                strongSelf.view.layoutIfNeeded()
            }
        }
    }
    
    func hideBrushWidthButtonsAndSetTopConstraintsToZero() {
        paintViewModel.showingBrushWidthOption = false
        for i in 0..<initialConstrainTopValues.count {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.brushWidthCollection[i].isHidden = true
                strongSelf.constraintArray[i].constant = 0
                strongSelf.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func brushWidthAction(_ sender: UIButton) {
        if paintViewModel.showingBrushWidthOption {
            hideBrushWidthButtonsAndSetTopConstraintsToZero()
            return
        }
        showBrushWidtButtonsAndSetTopConstraintsToInitialValues()
    }

    //MARK : UITouch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if paintViewModel.showingBrushWidthOption {
            hideBrushWidthButtonsAndSetTopConstraintsToZero()
            return
        }
        
        paintViewModel.swiped = false
        if let touch = touches.first  {
            paintViewModel.lastPoint = touch.location(in: self.view)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        paintViewModel.swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawLineFrom(fromPoint: paintViewModel.lastPoint, toPoint: currentPoint)
            paintViewModel.lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !paintViewModel.swiped {
            drawLineFrom(fromPoint: paintViewModel.lastPoint, toPoint: paintViewModel.lastPoint)
        }
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: 1.0)
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: paintViewModel.opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tempImageView.image = nil
    }
    
    
    //MARK : Top Three Button Methods
    @IBAction func resetAction(_ sender: UIButton) {
        mainImageView.image = nil
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        
    }

    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        if let context = UIGraphicsGetCurrentContext(){
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        paintViewModel.configureContext(context: context, fromPoint: fromPoint, toPoint: toPoint).strokePath()
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = paintViewModel.opacity
        UIGraphicsEndImageContext()
        }
    }
    
    func drawPreview(button : UIButton ,width : CGFloat) {
        UIGraphicsBeginImageContext(CGSize(width: 30, height: 30))
        if let context = UIGraphicsGetCurrentContext(){
        paintViewModel.configurePreviewContextSetting(context: context, button: button, width: width).strokePath()
        button.setImage(UIGraphicsGetImageFromCurrentImageContext(), for: .normal)
        }
        UIGraphicsEndImageContext()
    }
    
    func presentViewControllerAsPopover(viewController: UIViewController) {
        if let presentedVC = self.presentedViewController {
            if presentedVC.nibName == viewController.nibName {
                return
            }
        }
        viewController.modalPresentationStyle = .popover
        let viewPresentationController = viewController.popoverPresentationController
        if let presentationController = viewPresentationController {
           setupColorPickerPopover(presentationController: presentationController)
        }
        viewController.preferredContentSize = CGSize(width: 285, height: 450)
        self.present(viewController, animated: true, completion: nil)
    }
    
    func setupColorPickerPopover(presentationController : UIPopoverPresentationController){
        presentationController.delegate = self
        presentationController.permittedArrowDirections = .any
        presentationController.sourceView = colorPickerButtonOutlet
        presentationController.sourceRect = colorPickerButtonOutlet.bounds
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @IBAction func colorPickerButtonAction(_ sender: UIButton) {
        if paintViewModel.showingBrushWidthOption {
            hideBrushWidthButtonsAndSetTopConstraintsToZero()
        }
        let popoverVC = storyboard?.instantiateViewController(withIdentifier: "colorPickerPopover") as! ColorPickerViewController
        popoverVC.colorPickerViewModel = paintViewModel.colorPickerViewModel
        presentViewControllerAsPopover(viewController: popoverVC)
    }
}

