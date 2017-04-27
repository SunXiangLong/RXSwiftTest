//
//  XiaoMaBaoAPI.swift
//  RXSwiftTest
//
//  Created by xiaomabao on 2017/4/24.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
import RxSwift
import Moya
import Result
import PKHUD

public let disposeBag = DisposeBag()
/// 默认域名
let  baseURLStr = "https://api.xiaomabao.com/";
//let appendedParams: Dictionary<String, String> = [:]
/// 默认header
let headerFields: Dictionary<String, String> = [
    "device": "iOS",
    "version": String(UIDevice.version()),
    "channel":"APPStore"
    
]
private func JSONResponseDataFormatter(_ data: Data) -> Data {
    
    
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        
        return data // fallback to original data if it can't be serialized.
    }
}
/// 一个闭包当XiaoMaBao存在的时候 添加header
let endpointClosure = { (target: XiaoMaBao) -> Endpoint<XiaoMaBao> in
    
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    
    return Endpoint<XiaoMaBao>(url: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
        
        //        .adding(parameters: appendedParams as [String : AnyObject])
        .adding(newHTTPHeaderFields: headerFields)
}


let  XiaoMabaoProvider =  RxMoyaProvider<XiaoMaBao>(endpointClosure: endpointClosure,plugins: [NetworkLoggerPlugin(verbose: false, responseDataFormatter: JSONResponseDataFormatter),RequestAlertPlugin()])


public enum XiaoMaBao {
    case getCategoryGoods(id:String,page:String)
    
}

/// 自定义插件实现请求添加HUD
final class RequestAlertPlugin: PluginType {
    
    func willSend(_ request: RequestType, target: TargetType) {
        //实现发送请求前需要做的事情
        HUD.dimsBackground = false;
        HUD.show(.systemActivity)
    }
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        HUD.hide()
        guard case Result.failure(_) = result else { return }//只监听失败
        HUD.flash(.error, delay: 1)
        print(result)
        
    }
    
}

// MARK: - 请求的参数
extension XiaoMaBao:TargetType{
    
    public var baseURL: URL { return URL(string: baseURLStr)!}
    
    public var path: String {
        switch self {
        case .getCategoryGoods(let id, let page):
            return "AffordablePlanet/get_category_goods/\(id.urlEscaped)/\(page)"
            
        }
    }
    public var method: Moya.Method {
        return .get
    }
    public var parameters: [String: Any]? {
        switch self {
        case .getCategoryGoods(_, _):
            return nil
            
        }
    }
    public var task: Task {
        return .request
    }
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    public var validate: Bool {
        switch self {
        case .getCategoryGoods(_, _):
            return true
            
        }
    }
    public var sampleData: Data {
        switch self {
        case .getCategoryGoods(_, _):
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        }
    }
    
}

// MARK: - 字符串转url字符串
private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}
