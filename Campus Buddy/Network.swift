import UIKit
import Foundation
import Alamofire

class Network {
    
    // GET
    func getRequestWithoutHeader(_ url: String, params: Dictionary<String,AnyObject>, completion: @escaping (_ parsedJSON: Any, _ statusCode: Int) -> Void, failed: @escaping (_ errorMsg: JSON) -> Void) {
        
        debugPrint("url in sendGetRequestWithoutHeader call: \(url)")
        
        let alamoFireManager : Alamofire.SessionManager?
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20 // seconds
        configuration.timeoutIntervalForResource = 20
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)
        
        Alamofire.request( url, method : .get, parameters: params)
            .responseJSON { response in
                
                //print("%%% sendGetRequestWithoutHeader STATUS : \(url) : \((response.response?.statusCode))")
                
                switch response.result {
                case .success:
                    let parsedJson = JSON(response.result.value!)
                  //  debugPrint("**sendGetRequestWithoutHeader success** \(url) ** \(parsedJson)")
                   // debugPrint(parsedJson)
                    completion(response.result.value!, (response.response?.statusCode)!)
                    
                case .failure( _):
                    debugPrint("**sendGetRequestWithoutHeader failure** \(url) ** \(response.result.error!._code)")
                    do {
                        let dataJson = try JSONSerialization.jsonObject(with: response.data!, options:JSONSerialization.ReadingOptions(rawValue: 0))
                        guard let JSONDictionary :NSDictionary = dataJson as? NSDictionary else {
                            return
                        }
                        let parsedJson = JSON(JSONDictionary)
                        failed(parsedJson)
                    }
                    catch _ as NSError {
                        let errorMessage = self.handlingFailureCases((response.result.error?._code)!)
                        let error = ["message":errorMessage]
                        let json = JSON(error)
                        failed(json)
                        
                        debugPrint("**sendGetRequestWithoutHeader failure** \(url) ** \(json)")
                    }
                }
                
        }
    }
    
    
    func getRequestWithHeader(_ url: String, params: Dictionary<String,AnyObject>, completion: @escaping (_ parsedJSON: JSON, _ statusCode: Int) -> Void, failed: @escaping (_ errorMsg: JSON) -> Void) {
        
        debugPrint("url in sendGetRequestWithHeader call: \(url)")
        
        let headers: Dictionary<String,String> = ["Authorization": "JWT \(Utils().checkNSUserDefault("JWT_key"))"]
        
        let alamoFireManager : Alamofire.SessionManager?
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20 // seconds
        configuration.timeoutIntervalForResource = 20
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)
        
        Alamofire.request(url, method: .get, parameters: params, headers: headers)
            .responseJSON { response in
                
                //print("%%% sendGetRequestWithHeader STATUS  : \(url) : \((response.response?.statusCode))")
                
                switch response.result {
                case .success:
                    let parsedJson = JSON(response.result.value!)
                    debugPrint("**sendGetRequestWithHeader success** \(url) ** \(parsedJson)")
                    completion(parsedJson, (response.response?.statusCode)!)
                    
                case .failure( _):
                    debugPrint("**sendGetRequestWithHeader failure** \(url) ** \(response.result.error!._code)")
                    
                    do {
                        let dataJson = try JSONSerialization.jsonObject(with: response.data!, options:JSONSerialization.ReadingOptions(rawValue: 0))
                        guard let JSONDictionary :NSDictionary = dataJson as? NSDictionary else {
                            return
                        }
                        let parsedJson = JSON(JSONDictionary)
                        failed(parsedJson)
                        
                    }
                    catch _ as NSError {
                        let errorMessage = self.handlingFailureCases((response.result.error?._code)!)
                        let error = ["message":errorMessage]
                        let json = JSON(error)
                        failed(json)
                        
                        debugPrint("**sendGetRequestWithHeader failure** \(url) *##* \(json)")
                        
                    }
                    
                }
        }
    }
    
    
    // POST
    
    func postRequestWithoutHeader(_ url: String, params: Dictionary<String,AnyObject>, completion: @escaping (_ parsedJSON: JSON, _ statusCode: Int) -> Void, failed: @escaping (_ errorMsg: JSON) -> Void){
        
        debugPrint("url in postCallWithoutHeader call: \(url)")
        
        var alamoFireManager : Alamofire.SessionManager?
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20 // seconds
        configuration.timeoutIntervalForResource = 20
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)
        
        Alamofire.request( url, method: .post, parameters: params ,encoding : JSONEncoding.default).validate()
            .responseJSON { response in
                
                //print("%%% postCallWithoutHeader STATUS : \(url) : \((response.response?.statusCode))")
                
                switch response.result {
                case .success:
                    let parsedJson = JSON(response.result.value!)
                    debugPrint("**postCallWithoutHeader success** \(url) ** \(parsedJson)")
                    completion(parsedJson, (response.response?.statusCode)!)
                    
                case .failure( _):
                    
                    if(response.response?.statusCode != nil && (response.response?.statusCode)! >= 200 && (response.response?.statusCode)! <= 299) {
                        let parsedJson = JSON([:])
                        completion(parsedJson, (response.response?.statusCode)!)
                        break
                    }
                    
                    debugPrint("**postCallWithoutHeader failure** \(url) ** \(response.result.error!._code)")
                    
                    do {
                        let dataJson = try JSONSerialization.jsonObject(with: response.data!, options:JSONSerialization.ReadingOptions(rawValue: 0))
                        guard let JSONDictionary :NSDictionary = dataJson as? NSDictionary else {
                            return
                        }
                        
                        let parsedJson = JSON(JSONDictionary)
                        failed(parsedJson)
                    }
                    catch _ as NSError {
                        let errorMessage = self.handlingFailureCases((response.result.error?._code)!)
                        let error = ["message":errorMessage]
                        let json = JSON(error)
                        failed(json)
                        
                        debugPrint("**postCallWithoutHeader failure** \(url) ** \(json)")
                    }
                }
                
        }
    }
    
    
    func postRequestWithHeader(_ url: String, params: Dictionary<String,AnyObject>, completion: @escaping (_ parsedJSON: JSON, _ statusCode: Int) -> Void, failed: @escaping (_ errorMsg: JSON) -> Void){
        
        debugPrint("url in postCallWithHeader call: \(url)")
        
        let headers: HTTPHeaders = ["Authorization": "JWT \(Utils().checkNSUserDefault("JWT_key"))"]
        
        let alamoFireManager : Alamofire.SessionManager?
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20 // seconds
        configuration.timeoutIntervalForResource = 20
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)
        
        
        Alamofire.request(url as URLConvertible, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).validate()
            .responseJSON { response in
                
                //print("%%% postCallWithHeader STATUS : \(url) : \((response.response?.statusCode))")
                
                switch response.result {
                case .success:
                    let parsedJson = JSON(response.result.value!)
                    debugPrint("**postCallWithHeader success** \(url) ** \(parsedJson)")
                    completion(parsedJson, (response.response?.statusCode)!)
                    
                case .failure( _):
                    
                    if((response.response?.statusCode)! >= 200 && (response.response?.statusCode)! <= 299) {
                        let parsedJson = JSON([:])
                        completion(parsedJson, (response.response?.statusCode)!)
                        break
                    }
                    
                    debugPrint("**postCallWithHeader failure** \(url) ** \(response.result.error!._code)")
                    
                    do {
                        let dataJson = try JSONSerialization.jsonObject(with: response.data!, options:JSONSerialization.ReadingOptions(rawValue: 0))
                        guard let JSONDictionary :NSDictionary = dataJson as? NSDictionary else {
                            return
                        }
                        
                        let parsedJson = JSON(JSONDictionary)
                        failed(parsedJson)
                    }
                    catch _ as NSError {
                        let errorMessage = self.handlingFailureCases((response.result.error?._code)!)
                        let error = ["message":errorMessage]
                        let json = JSON(error)
                        failed(json)
                        
                        debugPrint("**postCallWithHeader failure** \(url) ** \(json)")
                    }
                }
                
        }
    }
    
    
    //MARK: UPLOAD
    
    func uploadFileRequestWithHeader(_ url: String,image: UIImage, completion: @escaping (_ parsedJSON: JSON, _ statusCode: Int) -> Void, failed: @escaping (_ errorMsg: JSON) -> Void){
        
        debugPrint("url in uploadFileRequestWithHeader call: \(url)")
        
        
        if Reachability.isConnectedToNetwork() {
            
            let headers: HTTPHeaders = ["Authorization": "JWT \(Utils().checkNSUserDefault("JWT_key"))"]
            
            let alamoFireManager : Alamofire.SessionManager?
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 20 // seconds
            configuration.timeoutIntervalForResource = 20
            alamoFireManager = Alamofire.SessionManager(configuration: configuration)
            
            let uploadurl : URLRequestConvertible = try! URLRequest(url: URL(string: url)!, method: .post, headers: headers) as URLRequestConvertible
            let imageData: Data =  UIImagePNGRepresentation(image)!//UIImageJPEGRepresentation(image, 0.5)!
            
            Alamofire.upload(multipartFormData: {
                multipartFormData in
                
                multipartFormData.append(imageData, withName: "file", fileName: "eazespot_ios_image.png", mimeType: "image/png")
            }, with: uploadurl,
               encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    print("Success")
                    upload.responseJSON { response in
                        
                        print("UUUU : \(response.result)")
                        print("UUUU1 : \(response.result.isFailure)")
                        
                        if(response.result.isFailure == true)
                        {
                            print("Failure")
                            
                            failed([])
                            
                        }else{
                            if JSON(response.result.value!) != JSON.null {
                                let parsedJson = JSON(response.result.value!)
                                
                                print("UPLOAD success : \(parsedJson)")
                                
                                completion(parsedJson, (response.response?.statusCode)!)
                            }
                        }
                        
                    }
                case .failure(let encodingError):
                    print("Failure")
                    print(encodingError)
                    
                    failed([])
                    
                }
            })
            
        } else {
            failed([])
        }
        
        

    }
    
    
    
    
    func uploadVideoRequestWithHeader(_ url: String, videoPath: NSURL, completion: @escaping (_ parsedJSON: JSON, _ statusCode: Int) -> Void, failed: @escaping (_ errorMsg: JSON) -> Void){
        
        debugPrint("url in uploadVideoRequestWithHeader call: \(url)")
        
        
        if Reachability.isConnectedToNetwork() {
            
            let headers: HTTPHeaders = ["Authorization": "JWT \(Utils().checkNSUserDefault("JWT_key"))"]
            
            let alamoFireManager : Alamofire.SessionManager?
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 20 // seconds
            configuration.timeoutIntervalForResource = 20
            alamoFireManager = Alamofire.SessionManager(configuration: configuration)
            
            let uploadurl : URLRequestConvertible = try! URLRequest(url: URL(string: url)!, method: .post, headers: headers) as URLRequestConvertible
            
            
            var movieData: Data?
            do {
                movieData = try NSData(contentsOfFile: (videoPath.relativePath)!, options: NSData.ReadingOptions.alwaysMapped) as Data
            } catch _ {
                movieData = nil
                //return
            }
            
            
            if (movieData != nil) {
                Alamofire.upload(multipartFormData: {
                    multipartFormData in
                    
                    multipartFormData.append(movieData!, withName: "file", fileName: "eazespot_ios_video.mov", mimeType: "video/mov")
                }, with: uploadurl,
                   encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        print("Success")
                        upload.responseJSON { response in
                            
                            print("UUUU : \(response.result)")
                            print("UUUU1 : \(response.result.isFailure)")
                            
                            if(response.result.isFailure == true)
                            {
                                print("Failure")
                                
                                failed([])
                                
                            }else{
                                if JSON(response.result.value!) != JSON.null {
                                    let parsedJson = JSON(response.result.value!)
                                    
                                    print("UPLOAD success : \(parsedJson)")
                                    
                                    completion(parsedJson, (response.response?.statusCode)!)
                                }
                            }
                            
                        }
                    case .failure(let encodingError):
                        print("Failure")
                        print(encodingError)
                        
                        failed([])
                        
                    }
                })
            }
            
            
        } else {
            failed([])
        }
        
        
        
    }
    

    // PUT
    
    func putRequestWithoutHeader(_ url: String, params: Dictionary<String,AnyObject>, completion: @escaping (_ parsedJSON: JSON) -> Void, failed: @escaping (_ errorMsg: JSON) -> Void) {
        
        debugPrint("url in putRequestWithoutHeader call: \(url)")
        
        let alamoFireManager : Alamofire.SessionManager?
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20 // seconds
        configuration.timeoutIntervalForResource = 20
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)
        
        Alamofire.request( url, method: .put, parameters: params)
            .responseJSON { response in
                
                //print("%%% putRequestWithoutHeader STATUS  : \(url) : \(response.response?.statusCode)")
                
                switch response.result {
                case .success:
                    let parsedJson = JSON(response.result.value!)
                    debugPrint("**putRequestWithoutHeader success** \(url) ** \(parsedJson)")
                    completion(parsedJson)
                    
                case .failure( _):
                    
                    debugPrint("**putRequestWithoutHeader failure** \(url) ** \(response.result.error!._code)")
                    
                    do {
                        let dataJson = try JSONSerialization.jsonObject(with: response.data!, options:JSONSerialization.ReadingOptions(rawValue: 0))
                        guard let JSONDictionary :NSDictionary = dataJson as? NSDictionary else {
                            return
                        }
                        
                        let parsedJson = JSON(JSONDictionary)
                        failed(parsedJson)
                    }
                    catch _ as NSError {
                        let errorMessage = self.handlingFailureCases((response.result.error?._code)!)
                        let error = ["message":errorMessage]
                        let json = JSON(error)
                        failed(json)
                        
                        debugPrint("**putRequestWithoutHeader failure** \(url) ** \(json)")
                    }
                }
                
        }
    }
    
    
    func putRequestWithHeader(_ url: String, params: Dictionary<String,AnyObject>, completion: @escaping (_ parsedJSON: JSON, _ statusCode: Int) -> Void, failed: @escaping (_ errorMsg: JSON) -> Void){
        
        debugPrint("url in putRequestWithHeader call: \(url)")
        
        let headers: HTTPHeaders = ["Authorization": "JWT \(Utils().checkNSUserDefault("JWT_key"))"]
        
        let alamoFireManager : Alamofire.SessionManager?
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20 // seconds
        configuration.timeoutIntervalForResource = 20
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)
        
        Alamofire.request( url as URLConvertible, method: .put, parameters: params, encoding : JSONEncoding.default, headers: headers).validate()
            .responseJSON { response in
                
                //print("%%% putRequestWithHeader STATUS : \(url) : \(response.response?.statusCode)")
                
                switch response.result {
                case .success:
                    let parsedJson = JSON(response.result.value!)
                    debugPrint("**putRequestWithHeader success** \(url) ** \(parsedJson)")
                    completion(parsedJson, (response.response?.statusCode)!)
                    
                case .failure( _):
                    
                    if(response.response?.statusCode != nil && (response.response?.statusCode)! >= 200 && (response.response?.statusCode)! <= 299) {
                        let parsedJson = JSON([:])
                        completion(parsedJson, (response.response?.statusCode)!)
                        break
                    }
                    
                    debugPrint("**putRequestWithHeader failure** \(url) ** \(response.result.error!._code)")
                    
                    do {
                        let dataJson = try JSONSerialization.jsonObject(with: response.data!, options:JSONSerialization.ReadingOptions(rawValue: 0))
                        guard let JSONDictionary :NSDictionary = dataJson as? NSDictionary else {
                            return
                        }
                        
                        let parsedJson = JSON(JSONDictionary)
                        failed(parsedJson)
                    }
                    catch _ as NSError {
                        let errorMessage = self.handlingFailureCases((response.result.error?._code)!)
                        let error = ["message":errorMessage]
                        let json = JSON(error)
                        failed(json)
                        
                        debugPrint("**putRequestWithHeader failure** \(url) *##* \(json)")
                    }
                }

        }
    }
    
    
    // DELETE
    
    func deleteRequestWithHeader(_ url: String, params: Dictionary<String,AnyObject>, completion: @escaping (_ parsedJSON: JSON, _ statusCode: Int) -> Void, failed: @escaping (_ errorMsg: JSON) -> Void) {
        
        debugPrint("url in deleteRequestWithHeader call: \(url)")
        
        let headers: HTTPHeaders = ["Authorization": "JWT \(Utils().checkNSUserDefault("JWT_key"))"]
        
        let alamoFireManager : Alamofire.SessionManager?
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20 // seconds
        configuration.timeoutIntervalForResource = 20
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)
        
        Alamofire.request( url as URLConvertible , method: .delete , parameters: params, encoding : JSONEncoding.default, headers: headers).validate()
            .responseJSON { response in
                
                //print("%%% deleteRequestWithHeader STATUS  : \(url) : \(response.response?.statusCode)")
                
                switch response.result {
                case .success:
                    let parsedJson = JSON(response.result.value!)
                    debugPrint("**deleteRequestWithHeader success** \(url) ** \(parsedJson)")
                    completion(parsedJson, (response.response?.statusCode)!)
                    
                case .failure( _):
                    
                    if(response.response?.statusCode != nil && (response.response?.statusCode)! >= 200 && (response.response?.statusCode)! <= 299) {
                        let parsedJson = JSON([:])
                        completion(parsedJson, (response.response?.statusCode)!)
                        break
                    }
                    
                    debugPrint("**deleteRequestWithHeader failure** \(url) ** \(response.result.error!._code)")
                    
                    do {
                        let dataJson = try JSONSerialization.jsonObject(with: response.data!, options:JSONSerialization.ReadingOptions(rawValue: 0))
                        guard let JSONDictionary :NSDictionary = dataJson as? NSDictionary else {
                            return
                        }
                        
                        let parsedJson = JSON(JSONDictionary)
                        failed(parsedJson)
                    }
                    catch _ as NSError {
                        let errorMessage = self.handlingFailureCases((response.result.error?._code)!)
                        let error = ["message":errorMessage]
                        let json = JSON(error)
                        failed(json)
                        
                        debugPrint("**deleteRequestWithHeader failure** \(url) *##* \(json)")
                    }
                }
                
        }
    }
    
    
    // FAILURE CASES
    
    func handlingFailureCases(_ statusCode: Int) -> String{
        print(statusCode)
        var errorMsg: String!
        switch statusCode{
        case 401:
            errorMsg = "Your login session has expired due to multiple logins! Please try logging in again"
        case 402 ... 499:
            errorMsg = "An error Occured"
        case 500 ... 510:
            errorMsg = "The server failed to fulfill an apparently valid request."
        case 900 :
            errorMsg = "An error Occured"
        case -1020 ... -1001:
            errorMsg = "Server couldn't be reached. Please try again later"
        default:
            errorMsg = "Server failed to fulfill request"
        }
        return errorMsg
    }
   

}
