//
//  ServiceManager.swift
//  BlockoneLab
//
//  Created by aarthur on 8/29/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import Foundation

class ServiceManager {

    func serviceRequest(_ forMethod: API_Method, args: Dictionary<String, String>?) -> URLRequest {
        let url = URL.init(string: forMethod.serviceAddress())
        var request = URLRequest.init(url: url!, timeoutInterval: 8)
        
        request.httpMethod = "POST"
        if args != nil {
            request.httpBody = self.serializeAsJSON(args!)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        return request
    }
    
    func startService(forMethod: API_Method, args: Dictionary<String, String>?, completionClosure:@escaping (Error?,Dictionary<String, Any>?)->()) {
        let task = URLSession.shared.dataTask(with: self.serviceRequest(forMethod, args: args),
                                              completionHandler: { (payload: Data?, response: URLResponse?, error: Error?) in
            completionClosure(error,self.parseJSON(payload))
        })
        task.resume()
    }
    
    func parseJSON(_ payload: Data?) -> (Dictionary<String,Any>?) {
        guard let dataResponse = payload else {
                return nil
        }
        do{
            //here dataResponse received from a network request
            let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
            
            guard let jsonDict = jsonResponse as? [String: Any] else {
                return nil
            }
            return jsonDict

        } catch let parsingError {
            print("JSON parse error ", parsingError)
        }
        return nil
    }
    
    func serializeAsJSON(_ args: Dictionary<String,String>) -> Data? {
        var body: Data? = nil
        
        do {
            body = try JSONSerialization.data(withJSONObject: args, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }

        return body
    }
    
}
