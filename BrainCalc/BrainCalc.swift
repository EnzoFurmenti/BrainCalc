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
    }
   private var opStack = [Op] ()
   private var knownOps = [String : Op] ()
   var variableValues = [String : Double] ()
   var description:String?{
        if !opStack.isEmpty{
            var stack = opStack
            var totalString = String ()
            while !stack.isEmpty {
                let subTotalString = evaluate1(stack).result!
                totalString = subTotalString + totalString
                stack = evaluate1(stack).remainingOps
            }
            return totalString
        }
        return " "
    }
//MARK: -init-
    init (){
        func learnOp (op : Op) {
            knownOps[op.description] = op
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
        
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
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
        print ("\(description)")
        return result
    }
    
    private func evaluate1(ops: [Op]) -> (result: String? , remainingOps: [Op]){
        var resultString = String()
        var remainingOps = ops
        if !ops.isEmpty {
            let op = remainingOps.removeLast()
            switch op {
            case .operand(let operand):
                if operand == M_PI{
                    return ("", remainingOps)
                }
                return ("\(operand)" , remainingOps)
            case .variable(let variable , _):
                return (variable , remainingOps)
            case .operandPi(let operandPi , _):
               return (operandPi , remainingOps)
            case .UnaryOperation(let operate , _ ):
                let operandEvaluation = evaluate1(remainingOps)
                if let operand = operandEvaluation.result{
                    resultString = operate + "(" + operand + ")"
                }
                else{
                    resultString = operate + "?"
                }
                return (resultString , operandEvaluation.remainingOps)
            case .BinaryOperation(let operate,_):
                let op1Evaluation = evaluate1(remainingOps)
                if let operand1 = op1Evaluation.result {
                    if operand1 != ""{
                        if operand1 != ""{
                            resultString = operand1
                            let op2Evaluation = evaluate1(op1Evaluation.remainingOps)
                            if let operand2 = op2Evaluation.result{
                                if operand2 != ""{
                                    resultString = "(" + operand2 + operate + operand1 + ")"
                                }
                                else{
                                    resultString = operand1 + "?" + ")"
                                }
                            }
                            return (resultString, op2Evaluation.remainingOps)
                        }
                    }
                    else
                    {
                       resultString = "(" + "?" + "\(operate)" + "?" + ")"
                        return (resultString, op1Evaluation.remainingOps)
                    }
                }
                else{
                    return (resultString, remainingOps)
                    
                }
            }
        }
        return (resultString, remainingOps)
    }
    func clearOp(){
        opStack.removeAll()
    }

}