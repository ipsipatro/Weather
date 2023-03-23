//
//  HttpCommunicationService.swift
//  Weather
//
//  Created by Ipsi Patro on 14/03/2023.
//

import Foundation
import Alamofire
import RxSwift

protocol HttpCommunicationServiceable {
    func get(url: String) -> Single<Data?>
}

// This class contains methods to send actual api request
final class HttpCommunicationService: HttpCommunicationServiceable {
    
    // get api request
    func get(url: String) -> Single<Data?> {
        return Single<Data?>.create { subscription in
            
            let request = Alamofire.request(url, method: .get)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success:
                        subscription(.success(response.data))

                    case .failure(let error):
                        subscription(.failure(error))
                    }
                }

            return Disposables.create {
                request.cancel()
            }
        }
    }
}




