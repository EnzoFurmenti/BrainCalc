//
//  BrainCalc.swift
//  BrainCalc
//
//  Created by EnzoF on 28.06.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

import Foundation

class BrainCalc{
    
    private   enum Op : CustomStringConvertible {
        case operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
    
    var description : String{
        get{
            switch self{
            case .operand(let operand):
                return "\(operand)"
            case .UnaryOperation(let symbol, _):
                return symbol
            case .BinaryOperation(let symbol, _):
                return symbol
            
            }
        }
    }
    }
   private var opStack = [Op] ()
   private var knownOps = [String : Op]()

    init (){
        func learnOp (op :Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷"){$1 / $0}
        knownOps["-"] = Op.BinaryOperation("-"){$1 - $0}
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
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
        return result
    }
}