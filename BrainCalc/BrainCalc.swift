//
//  BrainCalc.swift
//  BrainCalc
//
//  Created by EnzoF on 28.06.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

import Foundation

class BrainCalc{
 //MARK: -var,let,enum-
    private   enum Op : CustomStringConvertible {
        case operand(Double)
        case variable(String, () -> Double?)
        case operandPi(String, () -> Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
    
    var description : String{
        get{
            switch self{
            case .operand(let operand):
                return "\(operand)"
            case .variable(_,_):
                return "M"
            case .operandPi(_,_):
                return "π"
            case .UnaryOperation(let symbol, _):
                return symbol
            case .BinaryOperation(let symbol, _):
                return symbol
            
            }
        }
    }
    
        
    var precedence: Int{
        get{
            switch self{
            case .operand(_):
                return Int.max
            case .variable(_,_):
                return Int.max
            case .operandPi(_,_):
                return Int.max
            case .UnaryOperation(_, _):
                return Int.max
            case .BinaryOperation(let symbol, _):
                switch symbol{
                    case  "-" :
                        return 1
                    case  "+" :
                        return 1
                    case  "×" :
                        return 2
                    case  "÷" :
                        return 2
                    default :
                        return Int.min
                }
            }
        }
    }
        
//    var errorReport: String?{
//        get{
//            switch self{
//                case .operand(_):
//                return nil
//                case .variable(_,_):
//                return nil
//                case .operandPi(_,_):
//                return nil
//                case .UnaryOperation(let symbol, _):
//                    switch symbol{
//                        case "√":
//                            if operation == Double -> Double{
//                                return "100"
//                            }
//                        return nil
//                    }
//                    return nil
//                case .BinaryOperation(let symbol, _):
//                    return nil
//                
//            }
//        }
//    }
}
   private var precedenceOps = [String : Int] ()
   private var precedenceStack = [Int] ()
   private var opStack = [Op] ()
   private var knownOps = [String : Op] ()
   var variableValues = [String : Double] ()
   var description:String?{
        if !opStack.isEmpty{
            var stack = opStack
            var totalString = String ()
            while !stack.isEmpty {
                let subTotalString = description(stack, precedence: precedenceStack).result!
                totalString = subTotalString + totalString
                stack = description(stack, precedence: precedenceStack).remainingOps
            }
            return totalString
        }
        return " "
    }
//MARK: -init-
    init (){
        func learnOp (op : Op) {
            knownOps[op.description] = op
            if op.description == "×" || op.description == "÷" || op.description == "-" || op.description == "+"
            {
                precedenceOps[op.description] = op.precedence
            }
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷", {$1 / $0}))
        learnOp(Op.BinaryOperation("-", {$1 - $0}))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("±", {-$0}))
        learnOp(Op.operandPi("π", {M_PI}))
        learnOp(Op.variable("M", {self.variableValues["M"]}))

    }
    
//MARK: -Metods-
       func pushOperand(symbol: String) ->Double?{
            if let variableOperand = knownOps[symbol]{
                opStack.append(variableOperand)
            }
            return evaluate()
        }
    
       func pushOperand(operand: Double) -> Double? {
            opStack.append(Op.operand(operand))
//            precedenceStack.append(Int.max)
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        if let descriptionValue = precedenceOps[symbol]{
            precedenceStack.append(descriptionValue)
        }
        evaluateAndReportErrors(opStack)
        return evaluate()
    }
    
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
        
            switch op {
            case .operand(let operand):
                return (operand, remainingOps)
            case .variable(_, let operation):
                return (operation(), remainingOps)
            case .operandPi(_,let operation):
                return (operation(), remainingOps)
            
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result{
                return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result{
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }

            }
        }
        return (nil, ops)
    }
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        //print ("\(description)")
        return result
    }
    
    
    
    private func evaluateAndReportErrors(ops: [Op]) -> (result: Double?, remainingOps: [Op],errorReport : String?){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .operand(let operand):
                return (operand, remainingOps, nil)
            case .variable(let symbol, let operation):
            if operation() == nil{
                  let errorRep = errorReport(symbol, operand1 : nil, operand2 : nil)
                  return (operation(), remainingOps, errorRep)
            }
            else{
                  return (operation(), remainingOps, nil)
            }
            case .operandPi(_,let operation):
                return (operation(), remainingOps, nil)
                
            case .UnaryOperation(let symbol, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result{
                    let errorRep = errorReport(symbol, operand1 : operand, operand2 : nil)
                     return (operation(operand), remainingOps, errorRep)
                }
                else
                {

                    let errorRep = errorReport (symbol, operand1 : nil, operand2 : nil)
                      return (nil, remainingOps, errorRep)
    
                }
            case .BinaryOperation(let symbol, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result{
                        let errorRep = errorReport (symbol, operand1 : nil, operand2 : nil)
                          return (operation(operand1,operand2), remainingOps, errorRep)
                    }
                }
                else
                {
                 let errorRep = errorReport (symbol, operand1 : nil, operand2 : nil)
                    return (nil, remainingOps, errorRep)
                }

            }
        }
        return (nil, ops, nil)
    }
    
    private func description(ops: [Op], precedence: [Int]) -> (result: String? , remainingOps: [Op], remainingPrecedence : [Int], remainingPrecedenceValue : Int?)
    {
        var resultString = String()
        var remainingOps = ops
        var remainingPrecedence = precedence
        
        if !ops.isEmpty
        {
            let op = remainingOps.removeLast()
                    switch op {
            case .operand(let operand):
                if operand == M_PI{
                    return ("", remainingOps, remainingPrecedence, nil)
                }
                return ("\(operand)" , remainingOps, remainingPrecedence ,nil)
                        
            case .variable(let variable , _):
                return (variable , remainingOps, remainingPrecedence, nil)
                        
            case .operandPi(let operandPi , _):
               return (operandPi , remainingOps, remainingPrecedence, nil)
                        
            case .UnaryOperation(let operate , _ ):
                let operandEvaluation = description(remainingOps, precedence: remainingPrecedence)
                if let operand = operandEvaluation.result{
                    resultString = operate + "(" + operand + ")"
                }
                else{
                    resultString = operate + "?"
                }
                return (resultString , operandEvaluation.remainingOps, operandEvaluation.remainingPrecedence, nil)
                        
            case .BinaryOperation(let operate,_):
                let currentPrecedenceValue = remainingPrecedence.removeLast()
                let op1Evaluation = description(remainingOps, precedence: remainingPrecedence)
                
                if let operand1 = op1Evaluation.result
                {
                    if operand1 != ""
                    {
                        if let PrecedenceValue1 = op1Evaluation.remainingPrecedenceValue
                        {
                            
                            if isSetBrackets(currentPrecedenceValue, precedenceValueOp: PrecedenceValue1)
                            {
                                resultString = "(" + operand1 + ")"
                            }
                            else
                            {
                                resultString = operand1
                            }
                        
                        }
                        else
                        {
                            resultString = operand1
                        }
                    }
                    else
                    {
                        resultString = "(" + "?" + "\(operate)" + "?" + ")"
                        return (resultString, op1Evaluation.remainingOps, op1Evaluation.remainingPrecedence, currentPrecedenceValue)
                    }
                    
                    let op2Evaluation = description(op1Evaluation.remainingOps, precedence: op1Evaluation.remainingPrecedence)

                    if let operand2 = op2Evaluation.result
                    {
                        if operand2 != ""
                        {
                            if let PrecedenceValue2 = op2Evaluation.remainingPrecedenceValue
                            {
                                if isSetBrackets(currentPrecedenceValue, precedenceValueOp: PrecedenceValue2){
                                    resultString = "(" + operand2 + ")" + operate + resultString
                                }
                                else{
                                    resultString =  operand2 + operate + resultString
                                }
                                
                                return (resultString, op2Evaluation.remainingOps, op2Evaluation.remainingPrecedence, currentPrecedenceValue)
                            }
                            else
                            {
                                resultString =  operand2 + operate + resultString
                                return (resultString, op2Evaluation.remainingOps, op2Evaluation.remainingPrecedence, currentPrecedenceValue)
                            }
                        }
                    }
                    else
                    {
                        resultString =  "?" + operate + operand1
                        return (resultString, remainingOps, remainingPrecedence, currentPrecedenceValue)
                    }
                }
                else
                {
                    resultString =  "?" + operate + "?"
                    return (resultString, remainingOps, remainingPrecedence, currentPrecedenceValue)
                }
            }
        }
         return (resultString, remainingOps, remainingPrecedence, 0)
    }
    
    func isSetBrackets (currentValue : Int, precedenceValueOp : Int)-> Bool{
        if currentValue > precedenceValueOp && precedenceValueOp < Int.max && currentValue < Int.max{
            return true
        }
        return false
    }
    func removeBrackets(){
    
    }
    
    
    func clearOp(){
        opStack.removeAll()
        precedenceStack.removeAll()
    }
    
    func undoOpStack() {
        if opStack.count > 0{
            opStack.removeLast()
        }
    }


    func errorReport (operatorName : String, operand1 : Double?, operand2 : Double?)-> String?{
        switch operatorName{
            case "√":
                if (operand1 == nil)
                 {return "110"}
                
                if (operand1! < 0)
                 {return "100"}
                
                return nil
            case "÷":
                if (operand1 == nil)
                 {return "210"}
                
                if(operand1 == 0)
                {return "200"}
                
                return nil
            case "M":
                if (operand1 == nil)
                 {return "300"}
                
                return nil
        default:
                if operand1 == nil || operand2 == nil
                {return "1000"}
                
                return nil
            
            }
    }
    
    func getErrorReport()->String?{
        if let errorReport = evaluateAndReportErrors(opStack).errorReport{
            return errorReport
        }
        else
        {
            return nil
        }
    }
}