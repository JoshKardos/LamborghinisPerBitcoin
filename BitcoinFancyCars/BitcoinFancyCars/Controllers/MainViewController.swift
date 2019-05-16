//
//  ViewController.swift
//  BitcoinFancyCars
//
//  Created by Josh Kardos on 9/7/18.
//  Copyright © 2018 JoshTaylorKardos. All rights reserved.
//


//when lamborghinih is clicked, remove "+" and "delete" buttons


import UIKit
import Alamofire
import SwiftyJSON
import CoreData
import ProgressHUD
import AVFoundation


class MainViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, AVAudioPlayerDelegate {
    
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static var soundOn = true
    static let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTCUSD"
    //url format for api
    static let ratioLabelPlaceholder = "Spin the wheel to see how many cars one bitcoin will get you"
    static let emptyGaragePlaceholder = "Add a car to your garage to view the ratio"
    var carIndexToDelete = 0
    static var lamboModelsDB = [Lamborghini(model: "Aventador", price: 421145), Lamborghini(model:"Huracan", price:207369), Lamborghini(model: "Urus", price: 200000), Lamborghini( model: "Diablo", price: 375000), Lamborghini(model: "Gallardo", price: 210000), Lamborghini(model: "Murcielago", price: 380000)]
    //aventador, huracan, urus price found at https://www.caranddriver.com/lamborghini
    
    static var myGarage = [Car]()
    
    var carsInPickerWheel = [AnyObject](){
        didSet{
            currencyPicker.reloadAllComponents()
            ratioLabel.text = MainViewController.ratioLabelPlaceholder
        }
    }
    
    
    
    let lamboRequest = "https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMake/lamborghini?format=json"
    ///https://api.cars.com/VehicleMarketSummary/1.0/rest/reports/vehicledetails/metrics? make=Acura&model=MDX&vehicleYear=2014&cpoIndicator=N&zipCode=10538,12345,99999 &startDate=05/03/2016&endDate=05/03/2016&apikey=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    
    
    var bitcoinPrice = Double(){
        didSet{
            bitcoinPriceLabel.text = String("$\(bitcoinPrice)")
            let rowSelected = currencyPicker.selectedRow(inComponent: 0)
            if rowSelected >= self.carsInPickerWheel.count{
                ratioLabel.text = MainViewController.ratioLabelPlaceholder
            } else {
                updateRatio(car: self.carsInPickerWheel[rowSelected])
            }
            
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
    
    
    @IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var bitcoinPriceLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var timeLabel:UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    static var audioPlayer : AVAudioPlayer!
    
    @IBOutlet weak var soundButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        MainViewController.playSound(soundName: "start", soundNameExtension: "wav")
        //start at lamborghini cars
        removeButtons()
        carsInPickerWheel = MainViewController.lamboModelsDB
        
        loadCars()
        
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
        return carsInPickerWheel.count
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) ->
        //title of car
        String? {//titles
            if let car = carsInPickerWheel[row] as? Car {
                return car.model
            } else if let car = carsInPickerWheel[row] as? Lamborghini{
                return car.model
            }
            return nil
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        if carsInPickerWheel.count > row{
            print("SELECTED ROW \(row)")
            carIndexToDelete = row
            updateRatio(car: carsInPickerWheel[row])
            
        }
        
    }
    
    @IBAction func deleteIt(_ sender: Any) {
        
        if MainViewController.myGarage.count > 1{
            
            MainViewController.context.delete(MainViewController.myGarage[carIndexToDelete])
            
            MainViewController.myGarage.remove(at: carIndexToDelete)
            carsInPickerWheel = MainViewController.myGarage
            
            currencyPicker.reloadAllComponents()
            currencyPicker.selectRow(0, inComponent: 0, animated: true)
            
             MainViewController.playSound(soundName: "deleteHorn", soundNameExtension: "wav")
            
        } else if MainViewController.myGarage.count == 1{
            
            MainViewController.context.delete(MainViewController.myGarage[0])
            
            MainViewController.myGarage.remove(at: 0)
            carsInPickerWheel = MainViewController.myGarage
            
            currencyPicker.reloadAllComponents()
            
            ratioLabel.text = MainViewController.ratioLabelPlaceholder
            
            MainViewController.playSound(soundName: "deleteHorn", soundNameExtension: "wav")
            
            
        } else {
            
            ProgressHUD.showError("There is no cars to delete from your garage")
            return
        }
        
        //TODO: - Alerrt
        //negative beeping noise
        
        AddViewController.save()
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        
        getBitcoinData(url: MainViewController.baseURL)
        
        //TODO: - resfresh noise
        MainViewController.playSound(soundName: "waterDrop", soundNameExtension: "wav")
        refreshButton.isEnabled = false
        refreshButton.isHidden = true
        let _ = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(enableRefreshButton), userInfo: nil, repeats: false)
        
    }
    
    @objc func enableRefreshButton()
    {
        refreshButton.isEnabled = true
        refreshButton.isHidden = false
    }
    static func playSound(soundName: String, soundNameExtension: String){
        
        if soundOn == false {
            return
        }
        
        let soundUrl = Bundle.main.url(forResource: soundName, withExtension: soundNameExtension)
        
        
        do {
            
            if let sound = soundUrl{
                try audioPlayer = AVAudioPlayer(contentsOf: sound)
            }
            
        } catch {
            print(error)
        }
        
        audioPlayer.play()
        
    }
    func updateRatioHelper(model: String, price: Double){
        
        var ratio = bitcoinPrice/price
        ratio = round(100000 * ratio) / 100000
        
        var secondRatio = price/bitcoinPrice
        secondRatio = round(100000000 * secondRatio) / 100000000 //rounded to one hundred millionth - smallest from of a bitcoin (satoshi)
        ratioLabel.text = "1 Bitcoin = \(String(ratio)) \(model)(s) \n \n 1 \(model) = \(secondRatio) Bitcoin(s) "
        
    }
    func updateRatio(car: AnyObject){
        
        if let car = car as? Car {
            updateRatioHelper(model: car.model!, price: car.price)
        } else if let car = car as? Lamborghini{
            updateRatioHelper(model: car.model, price: car.price)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddView"{
            let destination = segue.destination as! AddViewController
            destination.delegate = self
        }
    }
    //
    //    //MARK: - Networking
    //    /***************************************************************/
    func getBitcoinData(url: String){
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let bitcoinJSON : JSON = JSON(response.result.value!)
                    self.updateBitcoinData(json: bitcoinJSON)
                    ProgressHUD.showSuccess("Bitcoin data updated")
                    
                } else {
                    self.bitcoinPriceLabel.text = "Connection Issues"
                    ProgressHUD.showError("Error fetching bitcoin data")
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
    @IBAction func segmentControllerChanged(_ sender: Any) {
        
        
        switch segmentControl.selectedSegmentIndex{
        case 0:
            carIndexToDelete = 0
            removeButtons()
            carsInPickerWheel = MainViewController.lamboModelsDB
            updateRatio(car: carsInPickerWheel[0])
            break
        case 1:
            carIndexToDelete = 0
            showButtons()
            carsInPickerWheel = MainViewController.myGarage
            if carsInPickerWheel.count > 0{
                updateRatio(car: carsInPickerWheel[0])
            } else {
                ratioLabel.text = MainViewController.emptyGaragePlaceholder
            }
            
            break
        default:
            break
            
        }
    }
    
    func removeButtons(){
        plusButton.isHidden = true
        plusButton.isEnabled = false
        
        deleteButton.isHidden = true
        deleteButton.isEnabled = false
    }
    
    func showButtons(){
        plusButton.isHidden = false
        plusButton.isEnabled = true
        
        deleteButton.isHidden = false
        deleteButton.isEnabled = true
    }
    
    @IBAction func soundPressed(_ sender: Any) {
        
        MainViewController.soundOn = !MainViewController.soundOn
        
        if MainViewController.soundOn{
            soundButton.setBackgroundImage(UIImage(named: "soundOn"), for: .normal)
        } else {
            
            soundButton.setBackgroundImage(UIImage(named: "soundOff"), for: .normal)
        }
        
    }
    func loadCars(){
        let request : NSFetchRequest<Car> = Car.fetchRequest()
        do{
            MainViewController.myGarage = try MainViewController.context.fetch(request)
        } catch {
            print("Error loading cars \(error)")
        }
    }
}

