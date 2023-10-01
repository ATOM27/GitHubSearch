//
//  GHRepositoriesServiceImpl.swift
//  GitHubSearch
//
//  Created by Yevhen Mekhedov on 31.01.2020.
//  Copyright © 2020 Yevhen Mekhedov. All rights reserved.
//

import Foundation

class GHRepositoriesServiceImpl: GHService, GHRepositoriesService {

    private(set) var APIURLLink: String
    private(set) var headers: [String: String]

    typealias RequestType = GHRequest.Repositories

    init(apiURL: String, headers: [String: String]) {
        self.APIURLLink = apiURL
        self.headers = headers
    }

    func getUserRepositories(userName: String, page: Int, itemsInPage: Int, cancelPrevious: Bool, completion: @escaping Completion<[GHItem]>) {
        let parameters: [String: Any] = [ "page": page,
                                          "per_page": itemsInPage]
        request(.byUserName(userName: userName), .get, parameters, cancelPreviousRequests: cancelPrevious) { (response) in
            completion(self.decodeResponse(response, type: GHUserRepositoriesContainer.self))
        }
    }
}
