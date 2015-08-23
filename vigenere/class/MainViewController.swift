//
//  MainViewController.swift
//  Vigenere
//
//  Created by Vincent PUGET on 05/08/2015.
//  Copyright (c) 2015 Vincent PUGET. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    @IBOutlet weak var buttonQuit: NSButton!
    @IBOutlet weak var buttonMatrix: NSButton!
    
    @IBOutlet weak var scCrypt: NSSegmentedControl!
    
    @IBOutlet var tvInput: NSTextView!
    @IBOutlet var tvOutput: NSTextView!
    
    @IBOutlet weak var tfKey: NSTextField!
    
    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var svLeft: NSScrollView!
    @IBOutlet weak var svRight: NSScrollView!
    
    var engine:Engine!
    
    var textInput: String!
    var textKey: String!
    var isEncryp: Bool! = true
    
    override func viewWillAppear() {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(calibratedRed: 69/255, green: 69/255, blue: 69/255, alpha: 1).CGColor
        
        self.splitView.layer?.backgroundColor = NSColor(calibratedRed: 35/255, green: 35/255, blue: 35/255, alpha: 1).CGColor
        
        //le reste dans le storyboard
        self.tvInput.textColor = NSColor.whiteColor()
        self.tvInput.insertionPointColor = NSColor.whiteColor()
        
        self.scCrypt.setLabel(NSLocalizedString("encrypt", tableName: "LocalizableStrings", comment: "encrypt"), forSegment: 0)
        self.scCrypt.setLabel(NSLocalizedString("decrypt", tableName: "LocalizableStrings", comment: "decrypt"), forSegment: 1)
        
        let color = NSColor.grayColor()
        let attrs = [NSForegroundColorAttributeName: color]
        let placeHolderStr = NSAttributedString(string: NSLocalizedString("key", tableName: "LocalizableStrings", comment: "key"), attributes: attrs)
        self.tfKey.placeholderAttributedString = placeHolderStr
        self.tfKey.focusRingType = NSFocusRingType.None
        var fieldEditor: NSTextView! = self.tfKey.window?.fieldEditor(true, forObject: self.tfKey) as! NSTextView
        fieldEditor.insertionPointColor = NSColor.whiteColor()
        
        self.tvInput.string = NSLocalizedString("textHere", tableName: "LocalizableStrings", comment: "textHere")
        
        self.tvOutput.textColor = NSColor.whiteColor()
        self.tvOutput.insertionPointColor = NSColor.whiteColor()
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = NSTextAlignment.CenterTextAlignment
        self.buttonQuit.attributedTitle = NSAttributedString(string: NSLocalizedString("x", tableName: "LocalizableStrings", comment: "x"), attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : pstyle ])
        self.buttonMatrix.attributedTitle = NSAttributedString(string: NSLocalizedString("matrix", tableName: "LocalizableStrings", comment: "Matrix"), attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : pstyle ])
        

    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Vigenere"
        self.view.window?.movableByWindowBackground = true
        
        engine = Engine()
        engine.delegate = self;
        engine.startCreateMatrixProcess();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tvInput.delegate = self
        self.tfKey.delegate = self
        
        if(self.tvInput.textStorage?.string != "")
        {
            self.textInput = self.tvInput.textStorage?.string
        }
        
        self.tvInput.becomeFirstResponder()
    }
    
    override func prepareForSegue(segue:(NSStoryboardSegue!), sender: AnyObject!)
    {
        if (segue.identifier == "segue_MatrixViewController")
        {
            var matrixViewController:MatrixViewController! = segue.destinationController as! MatrixViewController;
            matrixViewController.delegate = self
        }//fin if
    }
    

    @IBAction func IBA_scCrypt(sender: AnyObject) {
        let scTmp:NSSegmentedControl! = sender as! NSSegmentedControl
        switch scTmp.selectedSegment
        {
            case 0:
                self.isEncryp = true
                break;
            case 1:
                self.isEncryp = false
                break;
            default:
                break;
        }
        
        engine.encryptOrDecrypt(self.textInput, key: self.textKey , isEncrypt: self.isEncryp)
    }
    
    @IBAction func IBA_buttonQuit(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
}

extension MainViewController {
    
    func alertMatrixEmpty()
    {
        let alert: NSAlert = NSAlert()
        alert.messageText = NSLocalizedString("alertMatrixIsEmpty", tableName: "LocalizableStrings", comment: "alertMatrixIsEmpty")
        alert.informativeText = "Vigenere"
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        alert.addButtonWithTitle(NSLocalizedString("ok", tableName: "LocalizableStrings", comment: "ok"))
        alert.addButtonWithTitle(NSLocalizedString("cancel", tableName: "LocalizableStrings", comment: "cancel"))
        let response = alert.runModal()
        
        if(response == NSAlertFirstButtonReturn)
        {
            self.performSegueWithIdentifier("segue_MatrixViewController", sender: self)
        }
        else if(response == NSAlertSecondButtonReturn)
        {
            NSLog("Annuler")
        }
    }
    
    func valueHandler(obj: NSNotification){
        if(obj.object is NSTextField){
            let tfTmp = obj.object as! NSTextField;
            self.textKey = tfTmp.stringValue
        }
        else if(obj.object is NSTextView){
            let tvTmp = obj.object as! NSTextView;
            self.textInput = tvTmp.textStorage?.string
        }
        engine.encryptOrDecrypt(self.textInput, key: self.textKey , isEncrypt: self.isEncryp)
    }
    
}

extension MainViewController: NSTextFieldDelegate {
    
    override func controlTextDidChange(obj: NSNotification) {
        self.valueHandler(obj)
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        self.valueHandler(obj)
    }
}

extension MainViewController: NSTextViewDelegate {
    func textDidChange(obj: NSNotification)
    {
        self.valueHandler(obj)
    }
}

extension MainViewController: EngineProtocol{
    func matrixNotExist()
    {
        L.v("matrixIsEmpty");
        self.alertMatrixEmpty()
    }
    
    func matrixIsCreated()
    {
        //animate view ??
        //activate field ??
        //en loading ??
        engine.encryptOrDecrypt(self.textInput, key: self.textKey , isEncrypt: self.isEncryp)
    }
    
    func outputUpdated(output:String!)
    {
        self.tvOutput.string = output
    }
}

extension MainViewController: MatrixProtocol {
    
    func matrixIsAvailable(isAvailable:Bool!) -> Void
    {
        if(isAvailable == true)
        {
            engine.startCreateMatrixProcess()
        }
    }
}