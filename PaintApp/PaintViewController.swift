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
    
    @IBOutlet weak var eraserButtonOutlet: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    
    @IBOutlet weak var firstButtonWidthTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondButtonWidthTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdButtonWidthTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fourthButtonWidthTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fifthButtonWidthTopConstraint: NSLayoutConstraint!
    
    
    var paintViewModel : PaintViewModel!
    
    @IBAction func eraserButtonPressed(_ sender: UIButton) {
        eraserButtonOutlet.setImage(paintViewModel.toggleEraserStatusAndSetButtonImage(), for: .normal)
    }
    
    @IBAction func thicknessSelectionAction(_ sender: UIButton) {
        hideBrushWidtButtonsAndSetTopConstraintsToZero()
        let buttonTag = sender.tag
        switch buttonTag {
        case 0 :
            paintViewModel.brushWidth = 2
        case 1 :
            paintViewModel.brushWidth = 4
        case 2 :
            paintViewModel.brushWidth = 6
        case 3 :
            paintViewModel.brushWidth = 8
        case 4 :
            paintViewModel.brushWidth = 10
        default :
            paintViewModel.brushWidth = 2
        }
    }
    
    
    @IBOutlet var brushWidthCollection: [UIButton]!
    var initialConstrainTopValues = [CGFloat]()
    var widthConstraintArray : [NSLayoutConstraint]!

    func captureInitialTopConstraintsForBrushWidth(constraintArray : [NSLayoutConstraint]) {
        for constraint in constraintArray {
            initialConstrainTopValues.append(constraint.constant)
        }
    }
    
    func showBrushWidtButtonsAndSetTopConstraintsToInitialValues() {
        for i in 0..<initialConstrainTopValues.count {
            UIView.animate(withDuration: 0.5, animations: {
                self.brushWidthCollection[i].isHidden = false
                self.widthConstraintArray[i].constant = self.initialConstrainTopValues[i]
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func hideBrushWidtButtonsAndSetTopConstraintsToZero() {

        for i in 0..<initialConstrainTopValues.count {
            UIView.animate(withDuration: 0.5, animations: {
                self.brushWidthCollection[i].isHidden = true
                self.widthConstraintArray[i].constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func brushWidthAction(_ sender: UIButton) {
        if paintViewModel.showingBrushWidthOption {
            hideBrushWidtButtonsAndSetTopConstraintsToZero()
            paintViewModel.showingBrushWidthOption = false
            return
        }
        showBrushWidtButtonsAndSetTopConstraintsToInitialValues()
        paintViewModel.showingBrushWidthOption = true
    }
    
    
    
    @IBOutlet weak var colorPickerButtonOutlet: UIButton!

    //this is where the brush hits the paper
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
            // draw a single point
            drawLineFrom(fromPoint: paintViewModel.lastPoint, toPoint: paintViewModel.lastPoint)
        }
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: 1.0)
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: paintViewModel.opacity)
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
        paintViewModel.configureContext(context: context, fromPoint: fromPoint, toPoint: toPoint).strokePath()
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = paintViewModel.opacity
        UIGraphicsEndImageContext()
        }
    }
    
    func presentViewControllerAsPopover(viewController: UIViewController) {
        if let presentedVC = self.presentedViewController {
            if presentedVC.nibName == viewController.nibName {
                // The view is already being presented
                return
            }
        }
        // Specify presentation style first (makes the popoverPresentationController property available)
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
        let popoverVC = storyboard?.instantiateViewController(withIdentifier: "colorPickerPopover") as! ColorPickerViewController
        popoverVC.colorPickerViewModel = paintViewModel.colorPickerViewModel
        presentViewControllerAsPopover(viewController: popoverVC)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.paintViewModel = PaintViewModel()
        
        widthConstraintArray = [firstButtonWidthTopConstraint,secondButtonWidthTopConstraint,thirdButtonWidthTopConstraint,fourthButtonWidthTopConstraint,fifthButtonWidthTopConstraint]
        captureInitialTopConstraintsForBrushWidth(constraintArray: widthConstraintArray)
        hideBrushWidtButtonsAndSetTopConstraintsToZero()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("appeared")
        colorPickerButtonOutlet.setTitleColor(paintViewModel.chosenColor, for: .normal)
    }
}

