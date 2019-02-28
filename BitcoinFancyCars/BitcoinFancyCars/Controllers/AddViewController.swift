//
//  AddViewController.swift
//  BitcoinFancyCars
//
//  Created by Josh Kardos on 9/8/18.
//  Copyright © 2018 JoshTaylorKardos. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddViewController: UIViewController {

    @IBOutlet weak var modelLabelField: UITextField!
    @IBOutlet weak var priceLabelField: UITextField!
    
    @IBAction func submit(_ sender: Any) {
        
        if modelLabelField.text!.trimmingCharacters(in: .whitespaces) != "" && priceLabelField.text!.trimmingCharacters(in: .whitespaces) != ""{
            
                priceLabelField.isEnabled = false
                modelLabelField.isEnabled = false
                
            let newCar = Car(model: modelLabelField.text!, price: Double(priceLabelField.text!)!)
                
                MainViewController.lamboModelsDB.append(newCar)
                self.priceLabelField.isEnabled = true
                self.modelLabelField.isEnabled = true
                self.performSegue(withIdentifier: "AfterAddingCarGoHome", sender: self)
            
        } else {
            
            //one of the fields is empty
            print("One of the fields was empty")
            
        }
	
	
		
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		
		UIView.animate(withDuration: 0.5){
			
			//self.heightConstraint.constant = 308
			//self.view.layoutIfNeeded()//if constatint or anything has changed, redraw the hole thing
			
		}
	}
	
	

}

