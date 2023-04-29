//
//  AppsFlyerDelegate.swift
//  
//
//  Created by AppsFlyer
//
import AppsFlyerLib
import Foundation

final public class AppsFlyerDelegate: NSObject, AppsFlyerLibDelegate {
    
    private let parseAppsFlyerData = ParseAppsFlyerData()
    
    public var urlParameters: (([String: String]?) -> Void)?
    
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        self.parseAppsFlyerData.parseCampaign(conversionInfo)
    }
    
    public func onConversionDataFail(_ error: Error) {
        self.parseAppsFlyerData.installCompletion.send(.nonOrganic([:]))
        print("Error server data: class: AppsFlyerGetData ->, function: onConversionDataFail -> data: onConversionDataSuccess ->, description: ", error.localizedDescription)
    }
    
    public func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        print("\(attributionData)")
    }
    
    public func onAppOpenAttributionFailure(_ error: Error) {
        print(error)
    }
    
    override init(){}
}
