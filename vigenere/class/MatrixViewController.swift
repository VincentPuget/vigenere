//
//  MainViewController.swift
//  Vigenere
//
//  Created by Vincent PUGET on 05/08/2015.
//  Copyright (c) 2015 Vincent PUGET. All rights reserved.
//

import Cocoa

protocol MatrixProtocol
{
    func matrixIsAvailable(isAvailable:Bool!) -> Void
}

class MatrixViewController: NSViewController {
    
    @IBOutlet weak var buttonValidate: NSButton!
    @IBOutlet weak var buttonCancel: NSButton!
    
    @IBOutlet weak var tfMatrixName: NSTextField!
    @IBOutlet var tvMatrix: NSTextView!
    
    @IBOutlet weak var viewBackground: NSView!
    
    var delegate:MatrixProtocol!
    
    var isNewMatrix:Bool! = true;
    var matrixObj:Matrix!;
    
    override func viewWillAppear() {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(calibratedRed: 69/255, green: 69/255, blue: 69/255, alpha: 1).CGColor
        
        self.viewBackground.layer?.backgroundColor = NSColor(calibratedRed: 35/255, green: 35/255, blue: 35/255, alpha: 1).CGColor
        
        self.tvMatrix.textColor = NSColor.whiteColor()
        self.tvMatrix.insertionPointColor = NSColor.whiteColor()
        
        let color = NSColor.grayColor()
        let attrs = [NSForegroundColorAttributeName: color]
        let placeHolderStr = NSAttributedString(string: NSLocalizedString("matrixName", tableName: "LocalizableStrings", comment: "Matrix name"), attributes: attrs)
        self.tfMatrixName.placeholderAttributedString = placeHolderStr
        self.tfMatrixName.focusRingType = NSFocusRingType.None
        let fieldEditor: NSTextView! = self.tfMatrixName.window?.fieldEditor(true, forObject: self.tfMatrixName) as! NSTextView
        fieldEditor.insertionPointColor = NSColor.whiteColor()
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = NSTextAlignment.Center
        self.buttonValidate.attributedTitle = NSAttributedString(string: NSLocalizedString("save", tableName: "LocalizableStrings", comment: "Save"), attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : pstyle ])
        self.buttonCancel.attributedTitle = NSAttributedString(string: NSLocalizedString("cancel", tableName: "LocalizableStrings", comment: "Cancel"), attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : pstyle ])
        
        let widthConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 460)
        self.view.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 260)
        self.view.addConstraint(heightConstraint)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Vigenere"
        
        self.view.window?.movableByWindowBackground = true
        
        
        self.tfMatrixName.currentEditor()?.moveToEndOfLine(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tvMatrix.delegate = self
        self.tfMatrixName.delegate = self
        
        matrixObj = DataSingleton.instance.getMatrixObject();
        
        if(matrixObj != nil)
        {
            self.isNewMatrix = false;
            self.tfMatrixName.stringValue = matrixObj.name
            self.tvMatrix.string = matrixObj.matrix
        }
        else
        {
            self.isNewMatrix = true;
            self.tfMatrixName.stringValue = ""
            self.tvMatrix.string = ""
        }
    }
    

    @IBAction func IBA_buttonCancel(sender: AnyObject) {
        self.dismissViewController(self)
    }
    @IBAction func IBA_buttonValidate(sender: AnyObject) {
        var saveIsOk = false;
        if(self.isNewMatrix == true)
        {
            saveIsOk = DataSingleton.instance.saveNewMatrix(self.tfMatrixName.stringValue, matrix: self.tvMatrix.textStorage?.string)
        }
        else{
            saveIsOk = DataSingleton.instance.saveThisMatrix(self.matrixObj, name: self.tfMatrixName.stringValue, matrix: self.tvMatrix.textStorage?.string)
        }
        
        self.delegate.matrixIsAvailable(saveIsOk)
        self.dismissViewController(self)
    }
}

extension MatrixViewController: NSTextFieldDelegate {
    
    override func controlTextDidChange(obj: NSNotification) {
        
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        
    }
}

extension MatrixViewController: NSTextViewDelegate {
    func textDidChange(obj: NSNotification)
    {
        
    }
}