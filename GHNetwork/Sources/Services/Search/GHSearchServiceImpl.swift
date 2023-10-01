//
//  GHSearchServiceImpl.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 22.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation
import Alamofire

class GHSearchServiceImpl: GHService, GHSearchService {

    private(set) var APIURLLink: String
    private(set) var headers: [String: String]

    typealias RequestType = GHRequest.Search

    init(apiURL: String, headers: [String: String]) {
        self.APIURLLink = apiURL
        self.headers = headers
    }
// swiftlint:disable:next function_parameter_count
    func find(name: String,
              sort: SearchRepoSort,
              page: Int, itemsInPage: Int,
              cancelPrevious: Bool,
              completion: @escaping (GHResult<[GHItem]>) -> Void) {
        let parameters: [String: Any] = ["q": name,
                                         "sort": sort.rawValue,
                                         "page": page,
                                         "per_page": itemsInPage]
        request(.searchByRepositoryName, .get, parameters, cancelPreviousRequests: cancelPrevious) { (response) in
            completion(self.decodeResponse(response, type: GHItemContainer.self))
        }
    }
}
