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

class MainViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
	
	let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCUSD"//url format for api
	var bitcoinPrice = 0.0
	var lamboModels = ["Huracan" ,"Aventador", "Urus"]
	var lamboPrices = [203295, 402995, 200000]
	var finalURL = ""
	
	//Pre-setup IBOutlets
	
	@IBOutlet weak var ratioLabel: UILabel!
	@IBOutlet weak var bitcoinPriceLabel: UILabel!
	@IBOutlet weak var currencyPicker: UIPickerView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		currencyPicker.delegate = self
		currencyPicker.dataSource = self
		getBitcoinData(url: baseURL)
		
	}
	
	
	
	//TODO: Place your 3 UIPickerView delegate methods here
	func numberOfComponents(in pickerView: UIPickerView) -> Int {//amount of columns
		return 1
	}
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {//amount of rows
		return lamboModels.count
	}
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) ->
		//title of car
		String? {//titles
		return lamboModels[row]
	}
	
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
		
		let index = Int(row)
		//TO DO: Choose lamborghini model
		print(lamboPrices[row])
		
		updateRatio(price: Double(lamboPrices[row]), index: index)
		
	}
	
	func updateRatio(price: Double, index: Int){
		
		let ratio = bitcoinPrice/price
		
		ratioLabel.text = "1 Bitcoin = \(String(ratio)) Lamborghini \(lamboModels[index])"
	}
	
	


	//
	//    //MARK: - Networking
	//    /***************************************************************/
	
	func getBitcoinData(url: String) {
		Alamofire.request(url, method: .get)
			.responseJSON { response in
				if response.result.isSuccess {
					
					print("Sucess! Got the bitcoin data")
					let bitcoinJSON : JSON = JSON(response.result.value!)
					self.updateBitcoinData(json: bitcoinJSON)
					
				} else {
					print("Error: \(String(describing: response.result.error))")
					self.bitcoinPriceLabel.text = "Connection Issues"
				}
		}
		
	}
	
	
	
	
	
	//    //MARK: - JSON Parsing
	//    /***************************************************************/
	
	func updateBitcoinData(json : JSON) {
		print("HI")
		if let bitcoinResult = json["ask"].double {
			bitcoinPriceLabel.text = String("$\(bitcoinResult)")
			self.bitcoinPrice = bitcoinResult
		}
		else{
			bitcoinPriceLabel.text = "Price unavailable"
		}
	}
	
	
	
	
	
}


