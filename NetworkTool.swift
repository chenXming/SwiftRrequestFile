//
//  NetworkTool.swift
//  Kongming_Swift
//
//  Created by chenXming on 2018/5/4.
//  Copyright © 2018年 bitauto. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD
// 登录服务
private var LogInBase_Url = ""
// 孔明普通服务
private var ProgressBase_Url = ""
// 发票服务
//private var BillHttpsSever = ""

/*
 * 配置你的网络环境
 */
enum  NetworkEnvironment{
    case Development
    case Test
    case Distribution
}

let CurrentNetWork : NetworkEnvironment = .Test

private func judgeNetwork(network : NetworkEnvironment = CurrentNetWork){
    
    if(network == .Development){
        
        LogInBase_Url = "http://dev-***.com/common-portal/"
        ProgressBase_Url = "http://dev-***.com/isp-kongming/"
        

    }else if(network == .Test){
        
        LogInBase_Url = "http://test-***.com/common-portal/"
        ProgressBase_Url = "http://test-***.com/isp-kongming/"
        
    }else{
        
        LogInBase_Url = "https://***.com/common-portal/"
        ProgressBase_Url = "https://***.com/isp-kongming/"
        
    }
  
}


protocol NetworkToolDelegate {
    // 登录请求
    static func goToLogin(userName:String,password:String,completionHandler: @escaping(_ dict:[String : AnyObject]) -> (), errorHandler: @escaping(_ errorMsg : String) ->(), networkFailHandler: @escaping(_ error : Error) -> ())
    //GET 请求
    static func makeGetRequest(baseUrl : String,parameters : [String:AnyObject],successHandler: @escaping(_ json:JSON) ->(),errorMsgHandler : @escaping(_ errorMsg : String) ->(),networkFailHandler:@escaping(_ error : Error) -> ())
    
    //POST 请求
    static func makePostRequest(baseUrl : String,parameters : [String:Any],successHandler: @escaping(_ json:JSON) ->(),errorMsgHandler : @escaping(_ errorMsg : String) ->(),networkFailHandler:@escaping(_ error : Error) -> ())
    
    /*  图片上传 请求
     * imageData : 图片二进制数组
     */
    static func upDataIamgeRequest(baseUrl : String,parameters : [String : String],imageArr : [UIImage],successHandler: @escaping(_ dict:JSON) ->(),errorMsgHandler : @escaping(_ errorMsg : String) -> (),networkFailHandler: @escaping(_ error:Error) -> ())
    
}

extension NetworkToolDelegate{
    
    // 图片上传
    static func upDataIamgeRequest(baseUrl : String,parameters : [String : String],imageArr : [UIImage],successHandler: @escaping(_ dict:JSON) ->(),errorMsgHandler : @escaping(_ errorMsg : String) -> (),networkFailHandler: @escaping(_ error:Error) -> ()){
        
        judgeNetwork();
        
        let URL = ProgressBase_Url + baseUrl
        
        let userCookies = UserDefaults.standard.object(forKey: "userCookies")
        
        var header : [String : String]?
        
        if(userCookies != nil){
            
            header = ["Cookie":"\(userCookies!)","Set-Cookie":"\(userCookies!)","X-Requested-With":"XMLHttpRequest","Content-Type" : "application/json; charset=utf-8"]
            
        }
        
        if(imageArr.count == 0){
            
            return;
        }

        let image = imageArr.first;
        let imageData = UIImageJPEGRepresentation(image!, 0.5)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(imageData!, withName: "file", fileName: "file.jpg", mimeType: "image/jpeg")
            //如果需要上传多个文件,就多添加几个
            //multipartFormData.append(imageData, withName: "file", fileName: "123456.jpg", mimeType: "image/jpeg")
            //......
            
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: URL, method: .post, headers: header) { (encodingResult) in
            
           // print(encodingResult)
            switch encodingResult {
            case .success(let upload, _, _):
                //连接服务器成功后，对json的处理
                upload.responseJSON { response in
                    //解包
                    guard let value = response.result.value else { return }
                    let json = JSON(value)
                    //  print(json)
                    // 请求成功 但是服务返回的报错信息
                    guard json["errorCode"].intValue == 0 else {
                        
                        if(json["errorCode"].intValue == 50000){ // Token 过期重新登录
                            
                            errorMsgHandler(json["errorMsg"].stringValue)
                            
                            SVProgressHUD.showInfo(withStatus: "授权失效,请重新登录!")
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: RELOGIN_NOTIFY), object: nil)
                            }
                            return
                        }
                        
                        errorMsgHandler(json["errorMsg"].stringValue)
                        return
                    }
                    
                    if json["result"].dictionary != nil{
                        
                        successHandler(json["result"])
                        return
                    }else{
                        
                        successHandler(json)
                        return
                    }
                }
                /*
                //获取上传进度
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                    print("图片上传进度: \(progress.fractionCompleted)")
                }
               */
                
            case .failure(let encodingError):
                
                networkFailHandler(encodingError)
                //打印连接失败原因
              //  print(encodingError)
                
            }
        }
    }
    
    // Get 请求
    static func makeGetRequest(baseUrl : String,parameters : [String:AnyObject],successHandler: @escaping(_ json:JSON) ->(),errorMsgHandler : @escaping(_ errorMsg : String) ->(),networkFailHandler:@escaping(_ error : Error) -> ()){
        
        judgeNetwork();

        let URL = ProgressBase_Url + baseUrl
        
        let dict = parameters
        let userCookies = UserDefaults.standard.object(forKey: "userCookies")
        
        
        var header : [String : String]?
        
        if(userCookies != nil){
            
            header = ["Cookie":"\(userCookies!)","Set-Cookie":"\(userCookies!)","X-Requested-With":"XMLHttpRequest"]
            
        }
        
        Alamofire.request(URL, method: .get, parameters: dict, encoding: URLEncoding.default, headers: header).responseJSON { (response) in
            
            print("resopnse===\(response)")
            // 网络连接或者服务错误的提示信息
            guard response.result.isSuccess else
            { networkFailHandler(response.error!); return }
            
            if let value = response.result.value {
                let json = JSON(value)
                // 请求成功 但是服务返回的报错信息
                guard json["errorCode"].intValue == 0 else {
                    
                    if(json["errorCode"].intValue == 50000){ // Token 过期重新登录
                        
                        errorMsgHandler(json["errorMsg"].stringValue)
                        
                        SVProgressHUD.showInfo(withStatus: "授权失效,请重新登录!")
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: RELOGIN_NOTIFY), object: nil)
                        }
                        return
                    }
                    
                    errorMsgHandler(json["errorMsg"].stringValue)
                    
                    return
                }
                
                if json["result"].dictionary != nil{
                    
                    successHandler(json["result"])
                    return
                }else{
                    
                    successHandler(json)
                    return
                }
            }
        }
    }
    
    static func makePostRequest(baseUrl : String,parameters : [String:Any],successHandler: @escaping(_ json:JSON) ->(),errorMsgHandler : @escaping(_ errorMsg : String) ->(),networkFailHandler:@escaping(_ error : Error) -> ()){
        
        let manager = SessionManager.default
        manager.delegate.sessionDidReceiveChallenge = {
            session,challenge in
            return    (URLSession.AuthChallengeDisposition.useCredential,URLCredential(trust:challenge.protectionSpace.serverTrust!))
        }
        
        
        judgeNetwork();
        
        let URL = ProgressBase_Url + baseUrl
        
        let userCookies = UserDefaults.standard.object(forKey: "userCookies")
    
        var header : [String : String]?
        
        if(userCookies != nil){
            
            header = ["Cookie":"\(userCookies!)","Set-Cookie":"\(userCookies!)","X-Requested-With":"XMLHttpRequest","Content-Type" : "application/json; charset=utf-8"]

        }
        // JSONEncoding 与 URLEncoding 服务接受数据的区别
        Alamofire.request(URL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            
            print(response.response?.allHeaderFields as Any)
            print(response);
            // 网络连接或者服务错误的提示信息
            guard response.result.isSuccess else
            {
                networkFailHandler(response.error!);
                return
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                //  print(json)
                // 请求成功 但是服务返回的报错信息
                guard json["errorCode"].intValue == 0 else {
                    
                    if(json["errorCode"].intValue == 50000){ // Token 过期重新登录
                        
                        errorMsgHandler(json["errorMsg"].stringValue)
                        
                        SVProgressHUD.showInfo(withStatus: "授权失效,请重新登录!")
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5) {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: RELOGIN_NOTIFY), object: nil)
                        }
                        return
                    }
                    
                    errorMsgHandler(json["errorMsg"].stringValue)
                    return
                }
                if json["result"].dictionary != nil{
                    
                    successHandler(json["result"])
                    return
                }else{
                    
                    successHandler(json)
                    return
                }
            }
        }
    }
 
    
    static func goToLogin(userName:String,password:String,completionHandler: @escaping(_ dict:[String : AnyObject]) -> (), errorHandler: @escaping(_ errorMsg : String) ->(), networkFailHandler: @escaping(_ error : Error) -> ()){
        
        
        judgeNetwork();
        let url = LogInBase_Url + "common/portal/login"

        
        let dict = ["username":userName,"password":password,"apt":"3"]
        Alamofire.request(url, method: .get, parameters: dict, encoding:URLEncoding.default, headers: nil).responseJSON { (response) in

            print(response)
            
            // 网络连接或者服务错误的提示信息
            guard response.result.isSuccess else
            { networkFailHandler(response.error!); return }
            // 保存 cookies
            let headerFields = response.response?.allHeaderFields as! [String : String]
            let userCookie =  headerFields["Set-Cookie"]
           // print("userCookie>>>>>>\(userCookie ?? "0000000")")
            UserDefaults.standard.set(userCookie, forKey: "userCookies")
            UserDefaults.standard.synchronize()
            
            if let value = response.result.value {
                let json = JSON(value)
                print(json)
                // 请求成功 但是服务返回的报错信息
                guard json["errorCode"].intValue == 0 else { errorHandler(json["errorMsg"].stringValue); return }
                
                if let resultDict = json["result"].dictionary{
                    
                    completionHandler(resultDict as [String : AnyObject])

                }
            }
        }
    }
}

struct NetworkTool: NetworkToolDelegate {}



