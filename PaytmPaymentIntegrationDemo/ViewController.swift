//
//  ViewController.swift
//  PaytmPaymentIntegrationDemo
//
//  Created by Jony on 05/08/19.
//  Copyright © 2019 Jony. All rights reserved.
/*
 Video on youtube:
 https://www.youtube.com/watch?v=0AkYtrzIECA
 Local Server Path:
 http://localhost:8888/PaytChecksumPHP/generateChecksum.php
 
 * Test Merchant ID.:  NuEPQU81601438163571 Test Account Secret Key:  h2U!Ohym_!MZbs3A 
 Testing account:
 https://developer.paytm.com/docs/testing-integration
 */


import UIKit 
import PaymentSDK

class ViewController: UIViewController {

    var checkSum:CheckSumModel?
    var txnController = PGTransactionViewController()
    var serv = PGServerEnvironment()
    var params = [String:String]()
    var order_ID:String?
    var cust_ID:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        order_ID = randomString(length: 5)
        cust_ID = randomString(length: 6)
        params = ["MID": PaytmConstants.MID,
                  "ORDER_ID": order_ID,
                  "CUST_ID": cust_ID,
                  "MOBILE_NO": "7777777777",
                  "EMAIL": "username@emailprovider.com",
                  "CHANNEL_ID":PaytmConstants.CHANNEL_ID,
                  "INDUSTRY_TYPE_ID":PaytmConstants.INDUSTRY_TYPE_ID,
                  "WEBSITE": PaytmConstants.WEBSITE,
                  "TXN_AMOUNT": "10.00",
                  "CALLBACK_URL" :PaytmConstants.CALLBACK_URL+order_ID!
            ] as! [String : String]
    }
    
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
//    http://localhost:8888/PaytChecksumPHP/generateChecksum.php
    
    private func getCheckSumAPICall(){
        // Always check internet before call server.
        // en0: for LAN
        // en1 for Wifi
//        let apiStruct = ApiStruct(url: "http://172.29.40.121:8888/PaytChecksumPHP/generateChecksum.php", method: .post, body: params)
        let apiStruct = ApiStruct(url: "http://192.168.2.38:8888/PaytChecksumPHP/generateChecksum.php", method: .post, body: params)
        WSManager.shared.getJSONResponse(apiStruct: apiStruct, success: { (checkSumModel: CheckSumModel) in
            self.setupPaytm(checkSum: checkSumModel.CHECKSUMHASH!, params: self.params)
        }) { (error) in
            print(error)
        }
    }
    
    private func setupPaytm(checkSum:String,params:[String:String]) {
        serv = serv.createStagingEnvironment()
        let type :ServerType = .eServerTypeStaging
        let order = PGOrder(orderID: "", customerID: "", amount: "", eMail: "", mobile: "")
        order.params = params
        //"CHECKSUMHASH":"oCDBVF+hvVb68JvzbKI40TOtcxlNjMdixi9FnRSh80Ub7XfjvgNr9NrfrOCPLmt65UhStCkrDnlYkclz1qE0uBMOrmu
        order.params["CHECKSUMHASH"] = checkSum
        self.txnController =  (self.txnController.initTransaction(for: order) as? PGTransactionViewController)!
        self.txnController.title = "Paytm Payments"
        self.txnController.setLoggingEnabled(true)
        
        if(type != ServerType.eServerTypeNone) {
            self.txnController.serverType = type;
        } else {
            return
        }
        self.txnController.merchant = PGMerchantConfiguration.defaultConfiguration()
        self.txnController.delegate = self
        self.navigationController?.pushViewController(self.txnController
            , animated: true)
    }
    
    //MARK: - Button Action
    @IBAction func payActionButton(_ sender: Any) {
        getCheckSumAPICall()
    }
    
}

extension ViewController : PGTransactionDelegate {
    //this function triggers when transaction gets finished
    func didFinishedResponse(_ controller: PGTransactionViewController, response responseString: String) {
        let msg : String = responseString
        var titlemsg : String = ""
        if let data = responseString.data(using: String.Encoding.utf8) {
            do {
                if let jsonresponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] , jsonresponse.count > 0{
                    titlemsg = jsonresponse["STATUS"] as? String ?? ""
                }
            } catch {
                print("Something went wrong")
            }
        }
        let actionSheetController: UIAlertController = UIAlertController(title: titlemsg , message: msg, preferredStyle: .alert)
        let cancelAction : UIAlertAction = UIAlertAction(title: "OK", style: .cancel) {
            action -> Void in
            controller.navigationController?.popViewController(animated: true)
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    //this function triggers when transaction gets cancelled
    func didCancelTrasaction(_ controller : PGTransactionViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    //Called when a required parameter is missing.
    func errorMisssingParameter(_ controller : PGTransactionViewController, error : NSError?) {
        controller.navigationController?.popViewController(animated: true)
    }
}
