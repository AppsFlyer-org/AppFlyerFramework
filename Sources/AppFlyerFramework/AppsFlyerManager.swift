//
//  AppыFlyerManager.swift
//
//
//  Created by AppsFlyer
//
import AppsFlyerLib
import Combine
import AppTrackingTransparency

public final class AppsFlyerManager {
    
    private let appsFlyerDelegate: AppsFlyerDelegate
    private let appsFlyerDeepLinkDelegate: AppsFlyerDeepLinkDelegate
    private var anyCancel: Set<AnyCancellable>
    
    public let parseAppsFlyerData: ParseAppsFlyerData
    
    public init() {
        self.appsFlyerDelegate = AppsFlyerDelegate()
        self.appsFlyerDeepLinkDelegate = AppsFlyerDeepLinkDelegate()
        self.parseAppsFlyerData = ParseAppsFlyerData()
        self.anyCancel = []
    }
    
   

    public var installCompletion = PassthroughSubject<Install, Never>()
    public var completionDeepLinkResult: ((DeepLinkResult) -> Void)?
    
    public func setup(appID: String, devKey: String, interval: Double = 120){
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
    
    public func startRequestTrackingAuthorization(isIDFA: Bool){
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        AppsFlyerLib.shared().start()
        requestTrackingAuthorization(isIDFA: isIDFA)
    }
    
    private func requestTrackingAuthorization(isIDFA: Bool) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] (status) in
                guard let self = self else { return }
                switch status {
                    case .denied:
                        print("AuthorizationSatus is denied")
                        self.setupIDFA(isIDFA: isIDFA)
                    case .notDetermined:
                        print("AuthorizationSatus is notDetermined")
                        self.setupIDFA(isIDFA: isIDFA)
                    case .restricted:
                        print("AuthorizationSatus is restricted")
                        self.setupIDFA(isIDFA: isIDFA)
                    case .authorized:
                        print("AuthorizationSatus is authorized")
                        self.subscribeParseData()
                    @unknown default:
                        fatalError("Invalid authorization status")
                }
            }
        }
    }
    
    private func setupIDFA(isIDFA: Bool){
        if isIDFA {
            self.installCompletion.send(.nonOrganic([:]))
            self.parseAppsFlyerData.installGet = .nonOrganic([:])
        } else {
            if let installGet = appsFlyerDelegate.parseAppsFlyerData?.installGet {
                self.installCompletion.send(installGet)
            } else {
                self.subscribeParseData()
            }
        }
    }
    
    private func subscribeParseData(){
        appsFlyerDelegate.parseAppsFlyerData = self.parseAppsFlyerData
        appsFlyerDeepLinkDelegate.completionDeepLinkResult = completionDeepLinkResult
        self.parseAppsFlyerData.installCompletion.sink { [weak self] install in
            guard let self = self else { return }
            self.installCompletion.send(install)
        }.store(in: &anyCancel)
    }
}
