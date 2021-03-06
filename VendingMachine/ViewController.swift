//
//  ViewController.swift
//  VendingMachine
//
//  Created by Pasan Premaratne on 12/1/16.
//  Copyright © 2016 Treehouse Island, Inc. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "vendingItem"
fileprivate let screenWidth = UIScreen.main.bounds.width

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    let vendingMachine: VendingMachine
    var currentSelection: VendingSelection?
    var quantity = 1
    
    required init?(coder aDecoder: NSCoder) {
        do{
            let dictionary = try PListConverter.dictionary(fromFile: "VendingInventory", ofType: "plist")
            let inventory = try InventoryUnarchiver.VendingInvertory(fromDictonary: dictionary)
            self.vendingMachine = FoodVendingMachine(inventory: inventory)
        } catch  let error {
            fatalError("\(error)")
        }
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCollectionViewCells()
        //print(vendingMachine.inventory)
        balanceLabel.text = "€\(vendingMachine.amountDeposited)"
        totalLabel.text = "€00.00"
        priceLabel.text = "€0.00"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setup

    func setupCollectionViewCells() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        let padding: CGFloat = 10
        let itemWidth = screenWidth/3 - padding
        let itemHeight = screenWidth/3 - padding
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
    }
    // MARK: - VENDING MACHINE
    @IBAction func purchase(){
        if let  currentSelection = currentSelection {
            do {
                try vendingMachine.vend(quantity, currentSelection)
                updateDisplay()
            } catch {
                // FIXME : Error handling needed
            }
            
            if let indexPath = collectionView.indexPathsForSelectedItems?.first{
                collectionView.deselectItem(at: indexPath, animated: true)
                updateCell(having: indexPath, selected: false)
            }
        } else {
            // FIXME: alert use
        }
    }
    func updateDisplay() {
        balanceLabel.text = "€\(vendingMachine.amountDeposited)"
        totalLabel.text = "€00.00"
        priceLabel.text = "€0.00"
    }
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vendingMachine.selection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? VendingItemCell else { fatalError() }
        let item = vendingMachine.selection[indexPath.row]
        cell.iconView.image = item.icon()
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: true)
        currentSelection = vendingMachine.selection[indexPath.row]
        
        if let currentSelection = currentSelection, let item = vendingMachine.item(forSelection: currentSelection) {
            priceLabel.text = "€\(item.price)"
            totalLabel.text = "€\(item.price * Double (quantity))"
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: false)
    }
    
    func updateCell(having indexPath: IndexPath, selected: Bool) {
        
        let selectedBackgroundColor = UIColor(red: 41/255.0, green: 211/255.0, blue: 241/255.0, alpha: 1.0)
        let defaultBackgroundColor = UIColor(red: 27/255.0, green: 32/255.0, blue: 36/255.0, alpha: 1.0)
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = selected ? selectedBackgroundColor : defaultBackgroundColor
        }
    }
    
    
}

