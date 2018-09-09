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

	@IBOutlet weak var priceLabelField: UITextField!
	@IBOutlet weak var modelLabelField: UITextField!

	/*@IBAction func submitButton(_ sender: Any) {
		self.performSegue(withIdentifier: "AfterAddingCarGoHome", sender: self)
	}*/
	@IBAction func submit(_ sender: UIButton) {
		self.performSegue(withIdentifier: "AfterAddingCarGoHome", sender: self)
	}
	
	
	

}

