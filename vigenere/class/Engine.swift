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
    func outputUpdated(output:String!) -> Void
}

class Engine: NSObject {
    
    var delegate:EngineProtocol!
    var isOk:Bool! = false;
    
    var matrixObj:Matrix!
    var source:Array<String>!;
    var matrix:Array<Array<String>>!;
    
    override init()
    {
        super.init();
        
        //self.startCreateMatrixProcess()
    }
    
    func startCreateMatrixProcess()
    {
        self.matrixObj = self.getMatrixObject()
        
        if(self.matrixObj == nil)
        {
            self.delegate.matrixNotExist()
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
    
    func getMatrixObject() -> Matrix
    {
        let matrixObjTmp:Matrix! = DataSingleton.instance.getMatrixObject()
        return matrixObjTmp
    }
    
    func createSource() -> Array<String>
    {
        //transform string to array
        var sourceTmp:Array<String>! = map(self.matrixObj.matrix) { s -> String in String(s) }
        //on ajoute les sauts de ligne à la main... pas trouver d'autre méthode pour le moment.
        sourceTmp.append("\r");
        sourceTmp.append("\n");
        
        return sourceTmp;
    }
    
    func encryptOrDecrypt(input:String! , key:String! , isEncrypt:Bool!)
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
    
    func createMatrix(source:Array<String>) -> Array<Array<String>> {
        var i:Int = 0
        var incJ:Int = 0
        var nbRowSource:Int = source.count
        
        var matrix:Array<Array<String>> = Array<Array<String>>()
        
        for i ; i < nbRowSource; i++
        {
            var matrixTmp:Array<String> = Array<String>()
            var j:Int = incJ
            
            for j ; j < source.count ; j++
            {
                matrixTmp.append(source[j])
            }
            
            var delta:Int = nbRowSource - (nbRowSource - incJ)
            if(delta > 0)
            {
                for var k:Int = 0 ; k < delta ; k++
                {
                    matrixTmp.append(source[k])
                }
            }
            incJ++
            
            matrix.append(matrixTmp)
        }
        
        return matrix
    }
    
    func encrypt(str:String , key:String) -> String {
        
        let arrayStrToEncrypt:Array<String> = map(str) { String($0) }
        
        let arrayKey:Array<String> = map(key) { String($0) }
        
        var strCrypted:String = ""
        
        var incKey:Int = 0
        
        for var i:Int = 0 ; i < arrayStrToEncrypt.count ; i++
        {
            //On récupère l'index de la première lettre de la clé dans le tableau source
            var indexKey:Int! = find(self.source , arrayKey[incKey])
            if(indexKey == nil)
            {
                return "ERREUR KEY, un caractère à crypter n'est pas dans la matrice."
            }
            
            //on récupère la ligne de la matrix (un tableau) correspond à l'index de la première lettre de la clé dans le tableau source
            var rowMatrix:Array<String> = self.matrix[indexKey]
            
            //On récupère l'index de la première lettre de la phrase à crypté dans le tableau source
            var indexStr:Int! = find(self.source , arrayStrToEncrypt[i]);
            
            if(indexStr == nil)
            {
                return "ERREUR STR, un caractère à crypter n'est pas dans la matrice."
            }
            
            //on récupère la valeur de cette lettre dans le tableau fournis par l'index de la clé
            var letterCrypted:String! = rowMatrix[indexStr]
            
            strCrypted += letterCrypted
            
            
            incKey++
            
            if(incKey == arrayKey.count)
            {
                incKey = 0
            }
        }
        
        return strCrypted
    }
    
    func decrypt(str:String , key:String) -> String {
        let arrayStrToDecrypt:Array<String> = map(str) { String($0) }
        
        let arrayKey:Array<String> = map(key) { String($0) }
        
        var strDecrypted:String = ""
        
        var incKey:Int = 0
        
        for var i:Int = 0 ; i < arrayStrToDecrypt.count ; i++
        {
            //On récupère l'index de la première lettre de la clé dans le tableau source
            var indexKey:Int! = find(self.source , arrayKey[incKey])
            if(indexKey == nil)
            {
                return "ERREUR, un caractère à crypter n'est pas dans la matrice."
            }
            
            //on récupère la ligne de la matrix (un tableau) correspond à l'index de la première lettre de la clé dans le tableau source
            var rowMatrix:Array<String> = self.matrix[indexKey]
            
            //On récupère l'index de la lettre de la phrase à decrypté dans le tableau fournis par l'index de la clé
            var indexStr:Int! = find(rowMatrix , arrayStrToDecrypt[i])
            if(indexStr == nil)
            {
                return "ERREUR, un caractère à crypter n'est pas dans la matrice."
            }
            
            //on récupère la valeur de cette lettre dans le tableau source
            var letterDecrypted:String! = self.source[indexStr]
            
            strDecrypted += letterDecrypted
            
            incKey++
            
            if(incKey == arrayKey.count)
            {
                incKey = 0
            }
        }
        
        return strDecrypted
    }
    
}
