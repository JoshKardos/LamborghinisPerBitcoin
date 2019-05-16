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
import CoreData
import ProgressHUD

class AddViewController: UIViewController {
    
    @IBOutlet weak var modelLabelField: UITextField!
    @IBOutlet weak var priceLabelField: UITextField!
    
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var delegate : MainViewController?
    
    override func viewDidLoad() {
        goBackButton.layer.cornerRadius = 7
        submitButton.layer.cornerRadius = 7
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submit(_ sender: Any) {
        
        if modelLabelField.text!.trimmingCharacters(in: .whitespaces) != "" && priceLabelField.text!.trimmingCharacters(in: .whitespaces) != ""{
            
            priceLabelField.isEnabled = false
            modelLabelField.isEnabled = false
            
            let newCar = Car(context: MainViewController.context)
            newCar.model = modelLabelField.text!
            newCar.price = Double(priceLabelField.text!)!
            
            MainViewController.myGarage.append(newCar)
            self.priceLabelField.isEnabled = true
            self.modelLabelField.isEnabled = true
            
            AddViewController.save()
            
            
            self.dismiss(animated: true) {
                
                //TODO: - Beeping Noise
                   self.delegate?.carsInPickerWheel = MainViewController.myGarage
                MainViewController.playSound(soundName: "addHorn", soundNameExtension: "wav")
                
            }
//            self.performSegue(withIdentifier: "AfterAddingCarGoHome", sender: self)
            
        } else {
            
            //one of the fields is empty
            print("One of the fields was empty")
            
            
            //TODO: - Alert
            //must fill both spots
            ProgressHUD.showError("One of the fields is empty")
        }
        
        
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5){
            
            //self.heightConstraint.constant = 308
            //self.view.layoutIfNeeded()//if constatint or anything has changed, redraw the hole thing
            
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    static func save(){
        do{
            try MainViewController.context.save()
        } catch {
            print("ERRROROROROR!")
        }
    }
    
}

