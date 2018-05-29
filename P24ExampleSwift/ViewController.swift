//
//  ViewController.swift
//  P24ExampleSwift
//
//  Created by Arkadiusz Macudziński on 12.02.2016.
//  Copyright © 2016 DialCom24. All rights reserved.
//

import UIKit

class ViewController: UIViewController, P24TransferDelegate {
 
    
    let merchantId = Int32(64195)

    @IBOutlet weak var textViewResult: UILabel!
    @IBOutlet weak var sandnoxSwitch: UISwitch!
    @IBOutlet weak var tokenUrl: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        P24SdkConfig.setCertificatePinningEnabled(true);
    }

    func getCrc() -> String {
        return sandnoxSwitch.isOn ? "d27e4cb580e9bbfe" : "b36147eeac447028"
    }
    
    func sessionId() -> String {
        let alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
        var sId = "";
        
        for _ in 0...25 {
            let r = (Int) (arc4random() % 62);
            
            let c = alphabet[alphabet.index(alphabet.startIndex, offsetBy: r)];
            sId.append(c);
        }
        
        print("Session id: %@", sId);
        return sId;
    }
    
    func clearInfo() {
        textViewResult.text = ""
        textViewResult.backgroundColor = UIColor.clear
    }

    @IBAction func trnRequestClicked(_ sender: Any) {
        clearInfo()
        startTrnRequest();
    }
    
    @IBAction func trnDirectClicked(_ sender: Any) {
        clearInfo()
        startTrnDirect()
    }
    
    @IBAction func passageClicked(_ sender: Any) {
        clearInfo()
        startPassage()
    }
    @IBAction func expresClicked(_ sender: Any) {
        clearInfo()
        startExpress();
    }
    
    
    func getTokenOrUrl() -> String? {
        if (tokenUrl!.text?.count == 0) {
            textViewResult.text = "You have to set transaction token or express transaction URL"
            textViewResult.backgroundColor = UIColor.red
            return nil
        }
        return tokenUrl.text!
    }
    
    func startTrnRequest() {
        if let token = getTokenOrUrl() {
            let params = P24TrnRequestParams.init(token: token)!
            params.sandbox = sandnoxSwitch.isOn
            P24.startTrnRequest(params, in: self, delegate: self)
        }
    }
    
    func startTrnDirect() {
        let params = P24TrnDirectParams.init(transactionParams: getTransactionParams())!
        params.sandbox = sandnoxSwitch.isOn
        P24.startTrnDirect(params, in: self, delegate: self)
    }
    
    func startPassage() {
        let params = P24TrnDirectParams.init(transactionParams: getPassageTransactionParams())!
        params.sandbox = sandnoxSwitch.isOn
        P24.startTrnDirect(params, in: self, delegate: self)
    }
    
    func startExpress() {

        if let url = getTokenOrUrl() {
            let params = P24ExpressParams.init(url: url);
            P24.startExpress(params, in: self, delegate: self);
        }
    }
    
    
    func getTransactionParams() -> P24TransactionParams {
    
        let transaction = P24TransactionParams()
        transaction.merchantId = merchantId
        transaction.crc = getCrc()
        transaction.sessionId = sessionId()
        transaction.address = "Test street"
        transaction.amount = 1
        transaction.city = "Poznań"
        transaction.zip = "61-600"
        transaction.client = "John Smith"
        transaction.country = "PL"
        transaction.language = "pl"
        transaction.currency = "PLN"
        transaction.email = "test124@test.pl"
        transaction.phone = "1223134134"
        transaction.desc = "description"
//        transaction.method = 181;
        
        return transaction
    }
    
    
    func getPassageTransactionParams() -> P24TransactionParams {
        let transaction = getTransactionParams()
        setPassageCart(transaction)

        return transaction
    }
    
    func setPassageCart(_ transaction: P24TransactionParams) {
        let cart = P24PassageCart()
        
        var item = P24PassageItem(name: "Product 1")!
        item.desc = "description 1"
        item.quantity = 1
        item.price = 100
        item.number = 1
        item.targetAmount = 100
        item.targetPosId = 51987
        
        cart.addItem(item)
        
        item = P24PassageItem(name:"Product 2")
        item.desc = "description 2"
        item.quantity = 1
        item.price = 100
        item.number = 1
        item.targetAmount = 100
        item.targetPosId = 51986
        cart.addItem(item)
        
        transaction.amount = 200;
        transaction.passageCart = cart;
    }
    
    // MARK: P24TransferDeleagate
    func p24TransferOnSuccess() {
        textViewResult.text = "Transaction success"
        textViewResult.backgroundColor = UIColor.green
    }
    
    func p24TransferOnCanceled() {
        textViewResult.text = "Transaction cancelled"
        textViewResult.backgroundColor = UIColor.orange
    }
    
    func p24Transfer(onError errorCode: String!) {
        textViewResult.text = "Transaction error \(errorCode)"
        textViewResult.backgroundColor = UIColor.red
    }

}





