//
//  Models.swift
//  
//
//  Created by AppsFlyer
//

import Foundation

public enum Install {
    case organic
    case nonOrganic([String: String]?)
}

public enum AfStatus: String {
    case organic = "Organic"
    case nonOrganic = "Non-organic"
    case none
}

public enum Key: String {
    case pid
    case af_channel
    case c
    case af_adset
    case af_ad
}

public enum Analog: String {
    case utmSource = "utm_source"
    case utmMedium = "utm_medium"
    case utmCampaign = "utm_campaign"
    case utmContent = "utm_content"
    case utmTerm = "utm_term"
}
