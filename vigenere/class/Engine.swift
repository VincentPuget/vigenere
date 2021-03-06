//
//  Engine.swift
//  Vigenere
//
//  Created by Vincent PUGET on 08/08/2015.
//  Copyright (c) 2015 Vincent PUGET. All rights reserved.
//

import Cocoa

protocol EngineProtocol
{
    func matrixNotExist() -> Void
    func matrixIsCreated() -> Void
    func outputUpdated(_ output:String!) -> Void
}

class Engine: NSObject {
    
    var delegate:EngineProtocol!
    var isOk:Bool! = false;
    
    var matrixObj:Matrix?
    var source:Array<String>!;
    var matrix:Array<Array<String>>!;
    
    override init()
    {
        super.init();
    }
    
    func startCreateMatrixProcess()
    {
//        DataSingleton.instance.dropAllMatrix();
        
        self.matrixObj = self.getMatrixObject()
        
        if(self.matrixObj == nil)
        {
            if(DataSingleton.instance.createDefaultMatrix()){
                self.startCreateMatrixProcess()
            }
        }
        else if(self.matrixObj != nil && (self.matrixObj?.matrix == "" || self.matrixObj?.matrix == nil))
        {
            if(DataSingleton.instance.setDefaultMatrix(self.matrixObj)){
                self.startCreateMatrixProcess()
            }
        }
        else
        {
            self.source = self.createSource()
            
            if(self.source != nil && self.source.count != 0)
            {
                self.matrix = self.createMatrix(self.source)
                
                if(self.matrix != nil && self.matrix.count != 0)
                {
                    self.isOk = true;
                    self.delegate.matrixIsCreated()
                }
                else
                {
                    //Error
                }
            }
            else
            {
                //Error
            }
        }
    }

    
    func getMatrixObject() -> Matrix?
    {
        let matrixObjTmp:Matrix! = DataSingleton.instance.getMatrixObject()
        return matrixObjTmp
    }
    
    func createSource() -> Array<String>
    {
        //transform string to array
        var sourceTmp:Array<String>! = self.matrixObj!.matrix.characters.map { s -> String in String(s) }
        //on ajoute les sauts de ligne à la main... pas trouver d'autre méthode pour le moment.
        sourceTmp.append("\r");
        sourceTmp.append("\n");
        
        return sourceTmp;
    }
    
    func encryptOrDecrypt(_ input:String! , key:String! , isEncrypt:Bool!)
    {
        var output:String = ""
        
        if(input != nil && input == "" || self.isOk == false)
        {
            self.delegate.outputUpdated(output)
        }
        else if(input != nil && key != nil && input != "" && key != "")
        {
            if(isEncrypt == true) {
                output = self.encrypt(input , key: key)
            }
            else {
                output = self.decrypt(input , key: key)
            }
        }
        
        self.delegate.outputUpdated(output)
    }
    
    func createMatrix(_ source:Array<String>) -> Array<Array<String>> {
        let nbRowSource:Int = source.count
        
        var matrix:Array<Array<String>> = Array<Array<String>>()
        
        var incJ:Int = 0
        
        for _:Int in 0  ..< nbRowSource
        {
            var matrixTmp:Array<String> = Array<String>()
            for j:Int in incJ  ..< source.count
            {
                matrixTmp.append(source[j])
            }
            
            let delta:Int = nbRowSource - (nbRowSource - incJ)
            if(delta > 0)
            {
                for k:Int in 0  ..< delta
                {
                    matrixTmp.append(source[k])
                }
            }
            incJ += 1
            
            matrix.append(matrixTmp)
        }
        
        return matrix
    }
    
    func encrypt(_ str:String , key:String) -> String {
        
        let arrayStrToEncrypt:Array<String> = str.characters.map { String($0) }
        
        let arrayKey:Array<String> = key.characters.map { String($0) }
        
        var strCrypted:String = ""
        
        var incKey:Int = 0
        
        for i:Int in 0  ..< arrayStrToEncrypt.count
        {
            //On récupère l'index de la première lettre de la clé dans le tableau source
            let indexKey:Int! = self.source.index(of: arrayKey[incKey])
            if(indexKey == nil)
            {
                return NSLocalizedString("warningMissingCharMatrix", tableName: "LocalizableStrings", comment: "warningMissingCharMatrix")
            }
            
            //on récupère la ligne de la matrix (un tableau) correspond à l'index de la première lettre de la clé dans le tableau source
            var rowMatrix:Array<String> = self.matrix[indexKey]
            
            //On récupère l'index de la première lettre de la phrase à crypté dans le tableau source
            let indexStr:Int! = self.source.index(of: arrayStrToEncrypt[i]);
            
            if(indexStr == nil)
            {
                return NSLocalizedString("warningMissingCharMatrix", tableName: "LocalizableStrings", comment: "warningMissingCharMatrix")
            }
            
            //on récupère la valeur de cette lettre dans le tableau fournis par l'index de la clé
            let letterCrypted:String! = rowMatrix[indexStr]
            
            strCrypted += letterCrypted
            
            
            incKey += 1
            
            if(incKey == arrayKey.count)
            {
                incKey = 0
            }
        }
        
        return strCrypted
    }
    
    func decrypt(_ str:String , key:String) -> String {
        let arrayStrToDecrypt:Array<String> = str.characters.map { String($0) }
        
        let arrayKey:Array<String> = key.characters.map { String($0) }
        
        var strDecrypted:String = ""
        
        var incKey:Int = 0
        
        for i:Int in 0  ..< arrayStrToDecrypt.count
        {
            //On récupère l'index de la première lettre de la clé dans le tableau source
            let indexKey:Int! = self.source.index(of: arrayKey[incKey])
            if(indexKey == nil)
            {
                return NSLocalizedString("warningMissingCharMatrix", tableName: "LocalizableStrings", comment: "warningMissingCharMatrix")
            }
            
            //on récupère la ligne de la matrix (un tableau) correspond à l'index de la première lettre de la clé dans le tableau source
            let rowMatrix:Array<String> = self.matrix[indexKey]
            
            //On récupère l'index de la lettre de la phrase à decrypté dans le tableau fournis par l'index de la clé
            let indexStr:Int! = rowMatrix.index(of: arrayStrToDecrypt[i])
            if(indexStr == nil)
            {
                return NSLocalizedString("warningMissingCharMatrix", tableName: "LocalizableStrings", comment: "warningMissingCharMatrix")
            }
            
            //on récupère la valeur de cette lettre dans le tableau source
            let letterDecrypted:String! = self.source[indexStr]
            
            strDecrypted += letterDecrypted
            
            incKey += 1
            
            if(incKey == arrayKey.count)
            {
                incKey = 0
            }
        }
        
        return strDecrypted
    }
    
}
