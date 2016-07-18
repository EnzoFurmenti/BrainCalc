//
//  ViewController.swift
//  BrainCalc
//
//  Created by EnzoF on 27.06.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
//MARK: -global var and let-
    let decimalSeparator = NSNumberFormatter().decimalSeparator ?? "."
    var isZeroOnDisplay : Bool = true
    var isPiOnRow : Bool = false
    var brainCalculator = BrainCalc()
    var operandStack = Array <Double> ()
    var displayValue : Double?{
    
        get{
            if let displayText = display.text{
                if displayText != " "{
                
                    return NSNumberFormatter().numberFromString(displayText)!.doubleValue
                }
            }
            return nil
        }
        
        set{
            if newValue != nil{
                display.text = "\(newValue!)"
                isZeroOnDisplay = true
            }
            else{
                display.text = brainCalculator.getErrorReport()
                //historyRow.text = historyRow.text! + "error"
            }
        
        }
    }
    
//MARK: -Outlets-
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var decimalSeparatorLocation: UIButton!
    @IBOutlet weak var historyRow : UILabel!
 
//MARK: -Action-
    @IBAction func apendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if (digit == decimalSeparator) && (display.text?.rangeOfString(decimalSeparator) != nil)
            {return}


        if isZeroOnDisplay{
                if (digit != "0" && digit != "00" && digit != "000") || (display.text != "0"){
                    display.text = digit
                    isZeroOnDisplay = false
                }
        }
        else{
            display.text = display.text! + digit
        }
    }
    
    @IBAction func enter() {

        if isPiOnRow{
            isZeroOnDisplay = true
            isPiOnRow  = false
            addHistory(brainCalculator.description!)
        }
        else{
            if let displayVal = displayValue{
                if let result = brainCalculator.pushOperand(displayVal){
                    addHistory(brainCalculator.description!)
                    isZeroOnDisplay = true
                    displayValue = result
                }else{
                    isZeroOnDisplay = false
                    displayValue = nil
                }
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if !isZeroOnDisplay {
            enter()
        }
        if let operation = sender.currentTitle{
            if sender.currentTitle == "π"{
                isPiOnRow = true
            }
            if let result = brainCalculator.performOperation(operation){
                displayValue = result
            }else{
                displayValue = nil
            }
            addHistory(brainCalculator.description! + "=")
        }
        
    }
    @IBAction func backSpace(sender : UIButton){
        if(!isZeroOnDisplay){
            if  (display.text!).characters.count > 1{
                 display.text!.removeAtIndex( display.text!.endIndex.predecessor())
            }
            else{
                display.text = "0"
                isZeroOnDisplay = true
            }
        }
        else
        {
                brainCalculator.undoOpStack()
                addHistory(brainCalculator.description!)
                isZeroOnDisplay = true
        }
    }
    
    @IBAction func clearAll(sender : UIButton){
        display.text? = "0"
        historyRow.text = " "
        isZeroOnDisplay = true
        isPiOnRow  = false
        operandStack.removeAll()
        brainCalculator.clearOp()
        brainCalculator.variableValues.removeAll()
    }
    @IBAction func pushVariableM(sender : UIButton){
        if isZeroOnDisplay == false && display.text! != "0"{
            brainCalculator.variableValues["M"] = displayValue!
            displayValue =  brainCalculator.evaluate()
            isZeroOnDisplay = true
        }
    }
    
    @IBAction func popVariableM(sender : UIButton){
 
               brainCalculator.pushOperand("M")
        addHistory(brainCalculator.description! + "=")
               //enter()
    }
//MARK: -Override metods-
    override func viewDidLoad() {
        super.viewDidLoad()
        decimalSeparatorLocation.setTitle(decimalSeparator, forState: .Normal)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
//MARK: -Metods-
    
    func addHistory(str : String){
            historyRow.text = str
    }

}

