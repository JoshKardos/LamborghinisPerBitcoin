//
//  ViewController.swift
//  BitcoinFancyCars
//
//  Created by Josh Kardos on 9/7/18.
//  Copyright © 2018 JoshTaylorKardos. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase

class MainViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    static let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCUSD"
    //url format for api
    var bitcoinPrice = Double(){
        didSet{
            
            bitcoinPriceLabel.text = String("$\(bitcoinPrice)")
            let rowSelected = currencyPicker.selectedRow(inComponent: 0)
            updateRatio(carPrice: MainViewController.lamboModelsDB[rowSelected].price, row: rowSelected)
        
        }
    }
    var timePriceLastSet = NSDate(){
        didSet{
            //date formatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy, hh:mm:ss"
            let time = dateFormatter.string(from: timePriceLastSet as Date)
            timeLabel.text = "Last Refreshed at \(time)"
        }
    }
    
    static var lamboModelsDB = [Car(model: "Gallardo", price: 400000), Car(model:"Van", price:900)]
    //static var lamboModelsDB = returnCars()
    
    var carIndexToDelete = 0
    
    //Pre-setup IBOutlets
    
    @IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var bitcoinPriceLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var timeLabel:UILabel!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        currencyPicker.selectRow(0, inComponent: 0, animated: false)
        
        getBitcoinData(url: MainViewController.baseURL)
        
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
        refreshButton.layer.cornerRadius = 7
        
        
    }
    //TODO: Place your 3 UIPickerView delegate methods here
    func numberOfComponents(in pickerView: UIPickerView) -> Int {//amount of columns
        
        return 1
        
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {//amount of rows
        
        return MainViewController.lamboModelsDB.count
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) ->
        //title of car
        String? {//titles
            return MainViewController.lamboModelsDB[row].model
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        //TO DO: Choose lamborghini model
        if MainViewController.lamboModelsDB.count > row{
            carIndexToDelete = row
            updateRatio(carPrice: MainViewController.lamboModelsDB[row].price, row: row)
        }
    }
    
    @IBAction func deleteIt(_ sender: Any) {
        //array must always have at least one car
        if MainViewController.lamboModelsDB.count > 1{
            MainViewController.lamboModelsDB.remove(at: carIndexToDelete)
            currencyPicker.reloadAllComponents()
            updateRatio(carPrice: bitcoinPrice ,row: currencyPicker.selectedRow(inComponent: 0))
            
        } else {
            
            //TODO: - Alerrt
            //alert here that says cant delete, must have at least one car in picker
            
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        
        getBitcoinData(url: MainViewController.baseURL)
        //TODO: - resfresh noise
        
    }
    
    
    func updateRatio(carPrice: Double, row: Int){

        var ratio = bitcoinPrice/carPrice
        ratio = round(100000 * ratio) / 100000
        print("Ratio \(ratio)")
        ratioLabel.text = "1 Bitcoin = \(String(ratio)) \(MainViewController.lamboModelsDB[row].model)(s)"
        
    }
    
    //
    //    //MARK: - Networking
    //    /***************************************************************/
    func getBitcoinData(url: String) {
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let bitcoinJSON : JSON = JSON(response.result.value!)
                    self.updateBitcoinData(json: bitcoinJSON)
                    
                } else {
                    self.bitcoinPriceLabel.text = "Connection Issues"
                }
        }
        
    }
    
    //    //MARK: - JSON Parsing
    //    /***************************************************************/
    func updateBitcoinData(json : JSON) {
        if let bitcoinResult = json["ask"].double {
            
            self.bitcoinPrice = bitcoinResult
            
            timePriceLastSet = NSDate()
    
        }
        else{
            bitcoinPriceLabel.text = "Price unavailable"
        }
    }
}

