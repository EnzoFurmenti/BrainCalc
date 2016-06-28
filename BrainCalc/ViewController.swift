//
//  ViewController.swift
//  BrainCalc
//
//  Created by EnzoF on 27.06.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
//MARK: -global var-
    var isZeroOnDisplay : Bool = true
    var operandStack = Array <Double> ()
    var displayValue : Double{
    
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        
        }
        
        set{
            display.text = "\(newValue)"
            isZeroOnDisplay = true
        
        }
    }
    
//MARK: -Outlets-
    @IBOutlet weak var display: UILabel!
 
//MARK: -Action-
    @IBAction func apendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if isZeroOnDisplay{
            display.text = digit
            isZeroOnDisplay = false
        }
        else{
            display.text = display.text! + digit
        }
    }
    
    @IBAction func enter() {
        isZeroOnDisplay = true
        operandStack.append(displayValue)
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        switch operation {
        case "×":performOperation {$0 * $1}
        case "÷":performOperation {$1 / $0}
        case "-":performOperation {$1 - $0}
        case "+":performOperation {$0 + $1}
        default:
            NSLog("Error in operate(sender:\(sender.currentTitle))")
            break
        }
        
    }
    
    
//MARK: -Override metods-
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
//MARK: -Metods-
    
    func performOperation(operation:(Double, Double)->Double){
        if operandStack.count >= 2{
            displayValue = operation(operandStack.removeLast(),operandStack.removeLast())
            enter()
        }
    }
}

