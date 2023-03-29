//
//  AppsFlyerDeepLinkDelegate.swift
//  
//
//  Created by AppsFlyer
//
import AppsFlyerLib
import Foundation

final class AppsFlyerDeepLinkDelegate: NSObject, DeepLinkDelegate {
    
    var completion: ((Any?) -> Void)?
    var completionDeepLinkResult: ((DeepLinkResult) -> Void)?
    
    public func didResolveDeepLink(_ result: DeepLinkResult) {
        var fruitNameStr: String?
        completionDeepLinkResult?(result)
        switch result.status {
            case .notFound:
                print("[AFSDK] Deep link not found")
                return
            case .failure:
                print("Error %@", result.error!)
                return
            case .found:
                print("[AFSDK] Deep link found")
        }
        
        guard let deepLinkObj:DeepLink = result.deepLink else {
            print("[AFSDK] Could not extract deep link object")
            return
        }
        
        if deepLinkObj.clickEvent.keys.contains("deep_link_sub2") {
            let ReferrerId:String = deepLinkObj.clickEvent["deep_link_sub2"] as! String
            print("[AFSDK] AppsFlyer: Referrer ID: \(ReferrerId)")
        } else {
            print("[AFSDK] Could not extract referrerId")
        }
        
        let deepLinkStr:String = deepLinkObj.toString()
        print("[AFSDK] DeepLink data is: \(deepLinkStr)")
        
        if( deepLinkObj.isDeferred == true) {
            print("[AFSDK] This is a deferred deep link")
        }
        else {
            NSLog("[AFSDK] This is a direct deep link")
        }
        
        fruitNameStr = deepLinkObj.deeplinkValue
        completion?(fruitNameStr)
    }
}
