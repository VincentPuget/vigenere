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
    var isEncrypt: Bool! = true
    
    override func viewWillAppear() {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(calibratedRed: 69/255, green: 69/255, blue: 69/255, alpha: 1).cgColor
        
        self.splitView.layer?.backgroundColor = NSColor(calibratedRed: 35/255, green: 35/255, blue: 35/255, alpha: 1).cgColor
        
        //le reste dans le storyboard
        self.tvInput.textColor = NSColor.white
        self.tvInput.insertionPointColor = NSColor.white
        
        self.scCrypt.setLabel(NSLocalizedString("encrypt", tableName: "LocalizableStrings", comment: "encrypt"), forSegment: 0)
        self.scCrypt.setLabel(NSLocalizedString("decrypt", tableName: "LocalizableStrings", comment: "decrypt"), forSegment: 1)
        
        let color = NSColor.gray
        let attrs = [NSForegroundColorAttributeName: color]
        let placeHolderStr = NSAttributedString(string: NSLocalizedString("key", tableName: "LocalizableStrings", comment: "key"), attributes: attrs)
        self.tfKey.placeholderAttributedString = placeHolderStr
        self.tfKey.focusRingType = NSFocusRingType.none
        let fieldEditor: NSTextView! = self.tfKey.window?.fieldEditor(true, for: self.tfKey) as! NSTextView
        fieldEditor.insertionPointColor = NSColor.white
        
        self.tvInput.string = NSLocalizedString("textHere", tableName: "LocalizableStrings", comment: "textHere")
        
        self.tvOutput.textColor = NSColor.white
        self.tvOutput.insertionPointColor = NSColor.white
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = NSTextAlignment.center
        self.buttonQuit.attributedTitle = NSAttributedString(string: NSLocalizedString("x", tableName: "LocalizableStrings", comment: "x"), attributes: [ NSForegroundColorAttributeName : NSColor.white, NSParagraphStyleAttributeName : pstyle ])
        self.buttonMatrix.attributedTitle = NSAttributedString(string: NSLocalizedString("matrix", tableName: "LocalizableStrings", comment: "Matrix"), attributes: [ NSForegroundColorAttributeName : NSColor.white, NSParagraphStyleAttributeName : pstyle ])
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Vigenere"
        self.view.window?.isMovableByWindowBackground = true
        
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
    
    override func prepare(for segue:(NSStoryboardSegue!), sender: Any!)
    {
        if (segue.identifier == "segue_MatrixViewController")
        {
            let matrixViewController:MatrixViewController! = segue.destinationController as! MatrixViewController;
            matrixViewController.delegate = self
        }//fin if
    }
    

    @IBAction func IBA_scCrypt(_ sender: AnyObject) {
        let scTmp:NSSegmentedControl! = sender as! NSSegmentedControl
        switch scTmp.selectedSegment
        {
            case 0:
                self.isEncrypt = true
                break;
            case 1:
                self.isEncrypt = false
                break;
            default:
                break;
        }
        
        engine.encryptOrDecrypt(self.textInput, key: self.textKey , isEncrypt: self.isEncrypt)
    }
    
    @IBAction func IBA_buttonQuit(_ sender: AnyObject) {
        NSApplication.shared().terminate(self)
    }
}

extension MainViewController {
    
    func alertMatrixEmpty()
    {
        let alert: NSAlert = NSAlert()
        alert.messageText = NSLocalizedString("alertMatrixIsEmpty", tableName: "LocalizableStrings", comment: "alertMatrixIsEmpty")
        alert.informativeText = "Vigenere"
        alert.alertStyle = NSAlertStyle.warning
        alert.addButton(withTitle: NSLocalizedString("ok", tableName: "LocalizableStrings", comment: "ok"))
        alert.addButton(withTitle: NSLocalizedString("cancel", tableName: "LocalizableStrings", comment: "cancel"))
        let response = alert.runModal()
        
        if(response == NSAlertFirstButtonReturn)
        {
            self.performSegue(withIdentifier: "segue_MatrixViewController", sender: self)
        }
        else if(response == NSAlertSecondButtonReturn)
        {
            NSLog("Annuler")
        }
    }
    
    func valueHandler(_ obj: Notification){
        if(obj.object is NSTextField){
            let tfTmp = obj.object as! NSTextField;
            self.textKey = tfTmp.stringValue
        }
        else if(obj.object is NSTextView){
            let tvTmp = obj.object as! NSTextView;
            self.textInput = tvTmp.textStorage?.string
        }
        engine.encryptOrDecrypt(self.textInput, key: self.textKey , isEncrypt: self.isEncrypt)
    }
    
}

extension MainViewController: NSTextFieldDelegate {
    
    override func controlTextDidChange(_ obj: Notification) {
        self.valueHandler(obj)
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        self.valueHandler(obj)
    }
}

extension MainViewController: NSTextViewDelegate {
    func textDidChange(_ obj: Notification)
    {
        self.valueHandler(obj)
    }
}

extension MainViewController: EngineProtocol{
    func matrixNotExist()
    {
        L.v("matrixIsEmpty" as AnyObject!);
        self.alertMatrixEmpty()
    }
    
    func matrixIsCreated()
    {
        //animate view ??
        //activate field ??
        //en loading ??
        engine.encryptOrDecrypt(self.textInput, key: self.textKey , isEncrypt: self.isEncrypt)
    }
    
    func outputUpdated(_ output:String!)
    {
        self.tvOutput.string = output
    }
}

extension MainViewController: MatrixProtocol {
    
    func matrixIsAvailable(_ isAvailable:Bool!) -> Void
    {
        if(isAvailable == true)
        {
            engine.startCreateMatrixProcess()
        }
    }
}
