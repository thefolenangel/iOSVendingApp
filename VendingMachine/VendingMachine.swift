//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by Screencast on 12/6/16.
//  Copyright © 2016 Treehouse Island, Inc. All rights reserved.
//

import Foundation
import UIKit

enum VendingSelection: String {
    case soda
    case dietSoda
    case chips
    case cookie
    case sandwich
    case wrap
    case candyBar
    case popTart
    case water
    case fruitJuice
    case sportsDrink
    case gum
    
    func icon () -> UIImage {
        if let image = UIImage(named: self.rawValue){
            return image
            
        } else {
            return #imageLiteral(resourceName: "default")
            }
    }
}

protocol VendingItem {
    var price: Double { get }
    var quantity: Int { get set }
}

protocol VendingMachine {
    var selection: [VendingSelection] { get }
    var inventory: [VendingSelection: VendingItem] { get set }
    var amountDeposited: Double { get set }
    
    init(inventory: [VendingSelection: VendingItem])
    func vend(_ quantity: Int, _ selection: VendingSelection) throws
    func deposit(_ amount: Double)
}

struct Item: VendingItem {
    let price: Double
    var quantity: Int
}
enum InventoryError: Error {
    case InvalidRes
    case ConvError
    case InvalidSelect
}
class PListConverter{
    static func dictionary(fromFile name: String, ofType type:String) throws -> [String: AnyObject] {
        //get a path to the resource
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw InventoryError.InvalidRes
        }
        guard let dicionary = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
            throw InventoryError.ConvError
        }
        
        return dicionary
    }
}
class InventoryUnarchiver {
    static func VendingInvertory(fromDictonary dict: [String: AnyObject]) throws -> [VendingSelection:VendingItem] {
        var inventory: [VendingSelection : VendingItem] = [:]
        for (key, value) in dict {
            if let itemDic = value as? [String: AnyObject], let price = itemDic["price"] as? Double, let quant = itemDic["quantity"] as? Int {
                let item = Item (price: price, quantity: quant)
                guard let selection = VendingSelection (rawValue: key) else {
                    throw InventoryError.InvalidSelect
                }
                inventory.updateValue(item, forKey: selection)
            }
        }
        return inventory
    }
}
enum VendingMachineError : Error {
    case invalidSelection
    case otofStock
    case insufFunds (required: Double)
}
class FoodVendingMachine: VendingMachine {
    let selection: [VendingSelection] = [.soda, .dietSoda, .chips, .cookie, .wrap, .sandwich, .candyBar, .popTart, .water, .fruitJuice, .sportsDrink, .gum]
    var inventory: [VendingSelection : VendingItem]
    var amountDeposited: Double = 10.0
    
    required init(inventory: [VendingSelection : VendingItem]) {
        self.inventory = inventory
    }
    
    func vend(_ quantity: Int, _ selection: VendingSelection) throws {
        guard var item = inventory[selection] else {
            throw VendingMachineError.invalidSelection
        }
        guard item.quantity >= quantity else {
            throw VendingMachineError.otofStock
        }
        let totalPrice = item.price * Double(quantity)
        if amountDeposited >= totalPrice {
            amountDeposited -= totalPrice
            item.quantity -= quantity
            
            inventory.updateValue(item, forKey: selection)
        } else {
            let amountNeeded = totalPrice - amountDeposited
            throw VendingMachineError.insufFunds(required: amountNeeded)
        }
    }
    
    func deposit(_ amount: Double) {
    }
}










































