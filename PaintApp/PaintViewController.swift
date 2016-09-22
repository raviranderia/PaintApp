//
//  ViewController.swift
//  PaintApp
//
//  Created by RAVI RANDERIA on 9/19/16.
//  Copyright © 2016 RAVI RANDERIA. All rights reserved.
//

import UIKit
import CoreGraphics



final class PaintViewController: UIViewController, UIPopoverPresentationControllerDelegate, ColorPickerViewControllerDelegate {
    
    @IBOutlet var constraintArray: [NSLayoutConstraint]!
    @IBOutlet weak var eraserButtonOutlet: UIButton!
    @IBOutlet weak var colorPickerButtonOutlet: UIButton!
    @IBOutlet var brushWidthCollection: [UIButton]!
    
    private var paintViewModel = PaintViewModel()
    private var drawingPadUIView: DrawingPadUIView!
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawingPadUIView = DrawingPadUIView(paintViewModel: paintViewModel)
        containerView.addSubview(drawingPadUIView)
        paintViewModel.captureInitialTopConstraintsForBrushWidth(constraintArray: constraintArray)
        hideBrushWidthButtonsAndSetTopConstraintsToZero()
    }

    @IBAction func eraserButtonPressed(_ sender: UIButton) {
        eraserButtonOutlet.setImage(paintViewModel.toggleEraserStatusAndSetButtonImage(), for: .normal)
    }
    
    @IBAction func thicknessSelectionAction(_ sender: UIButton) {
        hideBrushWidthButtonsAndSetTopConstraintsToZero()
        paintViewModel.thicknessActionSelection(sender: sender)
    }
    
    @IBAction func brushWidthAction(_ sender: UIButton) {
        if paintViewModel.showingBrushWidthOption {
            hideBrushWidthButtonsAndSetTopConstraintsToZero()
            return
        }
        showBrushWidtButtonsAndSetTopConstraintsToInitialValues()
    }
    
    @IBAction func colorPickerButtonAction(_ sender: UIButton) {
        if paintViewModel.showingBrushWidthOption {
            hideBrushWidthButtonsAndSetTopConstraintsToZero()
        }
        let popoverVC = storyboard?.instantiateViewController(withIdentifier: "colorPickerPopover") as! ColorPickerViewController
        popoverVC.delegate = self
        presentViewControllerAsPopover(viewController: popoverVC)
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        drawingPadUIView.setImageToNil()
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        screenShotMethod()
    }
  
    // MARK: ColorPickerViewControllerDelegate
    func colorPickerViewController(controller: ColorPickerViewController, didSelectColor color: UIColor) {
        paintViewModel.setChosenColor(color: color)
        print(color)
    }
    
    // MARK: BrushWidthMenu
    private func showBrushWidtButtonsAndSetTopConstraintsToInitialValues() {
        paintViewModel.showingBrushWidthOption = true
        
        for i in 0..<paintViewModel.initialConstrainTopValues.count {
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.brushWidthCollection[i].isHidden = false
                strongSelf.brushWidthCollection[i].tintColor = strongSelf.paintViewModel.returnChosenColor()
                strongSelf.constraintArray[i].constant = strongSelf.paintViewModel.initialConstrainTopValues[i]
                strongSelf.drawingPadUIView.drawPreview(button: strongSelf.brushWidthCollection[i], width: strongSelf.paintViewModel.widthOptions[i])
                strongSelf.view.layoutIfNeeded()
            }
        }
    }
    
    private func hideBrushWidthButtonsAndSetTopConstraintsToZero() {
        paintViewModel.showingBrushWidthOption = false
        for i in 0..<paintViewModel.initialConstrainTopValues.count {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.brushWidthCollection[i].isHidden = true
                strongSelf.constraintArray[i].constant = 0
                strongSelf.view.layoutIfNeeded()
            })
        }
    }

    // MARK: UIPopoverPresentationControllerDelegate
    private func presentViewControllerAsPopover(viewController: UIViewController) {
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
    
    private func setupColorPickerPopover(presentationController : UIPopoverPresentationController){
        presentationController.delegate = self
        presentationController.permittedArrowDirections = .any
        presentationController.sourceView = colorPickerButtonOutlet
        presentationController.sourceRect = colorPickerButtonOutlet.bounds
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    private func screenShotMethod(){
        if let image = drawingPadUIView.takeScreenshot() {
            shareImage(image: image)
        }
    }
    
    private func shareImage(image:UIImage) {
        let img: UIImage = image
        let shareItems:Array = [img]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = paintViewModel.activityTypeList
        self.present(activityViewController, animated: true, completion: nil)
    }
    
   }

