//
//  AppDelegate.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 13.08.22.
//

import UIKit
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    
    var window: UIWindow?
    let bag = DisposeBag()

    // MARK: - App Life Cycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        let success = NewsFileManager(decoderType: JsonNewsDecoder.self, encoderType: JsonNewsEncoder.self).retrieveItems()
//        print(success)
        
//        NetworkService
//            .shared
//            .sendHttpRequest(
//                urlString: Constants.APIEndpoint.xmlDataBaseUrl.rawValue + Constants.APIEndpoint.xmlDataNewsVideoAndAudioTechnologyEndpoint.rawValue,
//                httpMethod: .get)
//            .observe(on: SerialDispatchQueueScheduler(qos: .default))
//            .subscribe(onNext: { (networkReponse) in
//                guard let data = networkReponse.data else {
//                    return
//                }
//
//                let news = XmlNewsDecoder(data: data).decode()
//                let success = NewsFileManager(decoderType: JsonNewsDecoder.self, encoderType: JsonNewsEncoder.self).storeItems(news!)
//                print(success)
//            })
//            .disposed(by: bag)
        
//        NetworkService
//            .shared
//            .sendHttpRequest(
//                urlString: Constants.APIEndpoint.jsonDataBaseUrl.rawValue + Constants.APIEndpoint.jsonDataTopHeadlinesEndpoint.rawValue,
//                httpMethod: .get,
//                queryParametrs: [
//                    "sources" : "techcrunch",
//                    "apiKey" : "97ba815035ae4381b223377b2df975ab"
//                ]
//            )
//            .observe(on: SerialDispatchQueueScheduler(qos: .default))
//            .subscribe(onNext: { (networkReponse) in
//                guard let data = networkReponse.data else {
//                    return
//                }
//
//                let initDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                let objectsDictArray = initDict?["articles"] as? [[AnyHashable:Any]]
//                let finalData = try? JSONSerialization.data(withJSONObject: objectsDictArray, options: [])
//
//                let news = JsonNewsDecoder(data: finalData!).decode()
//
//                let success = NewsFileManager(decoderType: JsonNewsDecoder.self, encoderType: JsonNewsEncoder.self).storeItems(news!)
//                print(success)
//            })
//            .disposed(by: bag)
        
        // Override point for customization after application launch.
        return true
    }
}

