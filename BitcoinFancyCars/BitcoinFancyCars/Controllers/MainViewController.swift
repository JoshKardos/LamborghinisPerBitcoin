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
	
	let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCUSD"//url format for api
	var bitcoinPrice = 0.0
	static var lamboModelsDB = [Car(model: "Gallardo", price: 400000), Car(model:"Van", price:900)]
	//static var lamboModelsDB = returnCars()
	
	var carIndexToDelete = 0
	
	//Pre-setup IBOutlets
	
	@IBOutlet weak var ratioLabel: UILabel!
	@IBOutlet weak var bitcoinPriceLabel: UILabel!
	@IBOutlet weak var currencyPicker: UIPickerView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		getBitcoinData(url: baseURL)
		currencyPicker.delegate = self
		currencyPicker.dataSource = self
		
		
		
		
		
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
			updateRatio(price: Double(MainViewController.lamboModelsDB[row].price).rounded(), row: row)
		}
	}
	
	func updateRatio(price: Double, row: Int){
		
		let ratio = bitcoinPrice/price
		
		ratioLabel.text = "1 Bitcoin = \(String(ratio)) \(MainViewController.lamboModelsDB[row].model)(s)"
	}
	
	
	@IBAction func deleteIt(_ sender: Any) {
		//array must always have at least one car
		if MainViewController.lamboModelsDB.count > 1{
			MainViewController.lamboModelsDB.remove(at: carIndexToDelete)
			currencyPicker.reloadAllComponents()
		} else {
			print("Could not delete")
		}
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
			bitcoinPriceLabel.text = String("$\(bitcoinResult)")
			self.bitcoinPrice = bitcoinResult
		}
		else{
			bitcoinPriceLabel.text = "Price unavailable"
		}
	}
	
	
	
	
	
}


