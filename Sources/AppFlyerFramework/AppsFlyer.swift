//
//  AppыFlyerManager.swift
//
//
//  Created by AppsFlyer
//
import AppsFlyerLib
import Combine
import AppTrackingTransparency

public final class AppыFlyerManager {
    
    private let appsFlyerDelegate = AppsFlyerDelegate()
    private let appsFlyerDeepLinkDelegate = AppsFlyerDeepLinkDelegate()
    private let parseAppsFlyerData = ParseAppsFlyerData()
    
    public var appsFlayerInstall: Install?
    public var installCompletion = PassthroughSubject<Install, Never>()
    public var completionDeepLinkResult: ((DeepLinkResult) -> Void)?
    
    public func setup(appID: String, devKey: String, interval: Double = 120){
        self.setup()
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: interval)
        AppsFlyerLib.shared().appsFlyerDevKey     = devKey
        AppsFlyerLib.shared().appleAppID          = appID
        AppsFlyerLib.shared().delegate            = self.appsFlyerDelegate
        AppsFlyerLib.shared().deepLinkDelegate    = self.appsFlyerDeepLinkDelegate
        AppsFlyerLib.shared().isDebug             = true
        AppsFlyerLib.shared().useUninstallSandbox = true
        AppsFlyerLib.shared().minTimeBetweenSessions = 10
        AppsFlyerLib.shared().start(completionHandler: { (dictionary, error) in
            if (error != nil){
                print(error ?? "")
                return
            } else {
                print(dictionary ?? "")
                return
            }
        })
    }
    
    public func setDebag(isDebug: Bool){
        AppsFlyerLib.shared().isDebug = isDebug
    }
    
    public func startRequestTrackingAuthorization(){
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        AppsFlyerLib.shared().start()
        requestTrackingAuthorization()
    }
    
    private func requestTrackingAuthorization() {
        self.setup()
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] (status) in
                guard let self = self else { return }
                switch status {
                    case .denied:
                        print("AuthorizationSatus is denied")
                        self.appsFlayerInstall = .nonOrganic([:])
                        self.installCompletion.send(.nonOrganic([:]))
                    case .notDetermined:
                        print("AuthorizationSatus is notDetermined")
                        self.appsFlayerInstall = .nonOrganic([:])
                        self.installCompletion.send(.nonOrganic([:]))
                    case .restricted:
                        print("AuthorizationSatus is restricted")
                        self.appsFlayerInstall = .nonOrganic([:])
                        self.installCompletion.send(.nonOrganic([:]))
                    case .authorized:
                        print("AuthorizationSatus is authorized")
                    @unknown default:
                        fatalError("Invalid authorization status")
                }
            }
        } 
    }
    
    private func setup(){
        appsFlyerDeepLinkDelegate.completionDeepLinkResult = completionDeepLinkResult
        self.parseAppsFlyerData.installCompletion = { [weak self] install in
            guard let self = self else { return }
            guard let install = install else {
                self.installCompletion.send(.nonOrganic([:]))
                return
            }
            self.installCompletion.send(install)
        }
    }
    
    public init(){}
}
