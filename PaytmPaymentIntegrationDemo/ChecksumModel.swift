//
//  ChecksumModel.swift
//  PaytmPaymentIntegrationDemo
//
//  Created by Jony on 06/08/19.
//  Copyright © 2019 Jony. All rights reserved.
//

import Foundation

public struct CheckSumModel :Decodable {
    public var CHECKSUMHASH : String?
    public  var ORDER_ID : String?
    public var payt_STATUS : String?
}

