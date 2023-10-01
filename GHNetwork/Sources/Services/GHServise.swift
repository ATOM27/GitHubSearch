//
//  GHServise.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 22.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
import Alamofire

protocol GHService: AnyObject {
    associatedtype RequestType: GHEndPointRequest

    var APIURLLink: String { get }
    var headers: [String: String] { get }
//swiftlint:disable:next function_parameter_count
    func request(_ with: RequestType,
                 _ method: HTTPMethod,
                 _ parameters: Parameters,
                 _ encoding: ParameterEncoding,
                 cancelPreviousRequests: Bool,
                 completion: @escaping (DefaultDataResponse) -> Void)
    func decodeResponse<Type: GHResponse, Protocol>(_ response: DefaultDataResponse,
                                                    type: Type.Type) -> GHResult<Protocol>

    func createRequest(_ url: String,
                       _ method: HTTPMethod,
                       _ parameters: Parameters,
                       _ encoding: ParameterEncoding,
                       _ headers: HTTPHeaders) -> DataRequest
}

extension GHService {
    var session: SessionManager {
        return Alamofire.SessionManager.default
    }

    func request(_ with: RequestType,
                 _ method: HTTPMethod,
                 _ parameters: Parameters = [:],
                 _ encoding: ParameterEncoding = URLEncoding.default,
                 cancelPreviousRequests: Bool,
                 completion: @escaping (DefaultDataResponse) -> Void) {
        if cancelPreviousRequests {
            session.session.getTasksWithCompletionHandler { (sessionDataTask, _, _) in
                sessionDataTask.forEach({ $0.cancel() })
            }
        }
        let request = self.createRequest(with.endPoint, method, parameters, encoding, self.headers)
        request.response { (result) in
            completion(result)
        }.resume()
    }

    func decodeResponse<Type: GHResponse, Protocol>(_ response: DefaultDataResponse,
                                                    type: Type.Type) -> GHResult<Protocol> {
        var value: GHResult<Protocol>
        guard let data = response.data else {
            value = GHResult(value: nil, error: GHError.defaultError.description)
            return value
        }
        value = self.decode(type.self, from: data)
        return value
    }

    func createRequest(_ url: String,
                       _ method: HTTPMethod,
                       _ parameters: Parameters,
                       _ encoding: ParameterEncoding = URLEncoding.default,
                       _ headers: HTTPHeaders) -> DataRequest {
        let url: URLConvertible = (APIURLLink as NSString).appendingPathComponent(url)
        #if DEBUG
        debugPrint("Request url -> \(url)")
        #endif
        return self.session.request(url,
                                    method: method,
                                    parameters: parameters,
                                    encoding: encoding,
                                    headers: headers)
    }

    private func decode<Type: GHResponse, Result>(_ value: Type.Type, from data: Data) -> GHResult<Result> {

        let decoder = JSONDecoder()

        do {
            let cont = try decoder.decode(Type.self, from: data)
            guard let result = cont.containerValue as? Result else {
                return GHResult(value: nil, error: GHError.wrongProtocol(protocolName: "\(Result.self)").description)
            }
            return GHResult(value: result, error: nil)
        } catch _ {
            return GHResult(value: nil, error: GHError.defaultError.description + " (too many requests)")
        }
    }

}
