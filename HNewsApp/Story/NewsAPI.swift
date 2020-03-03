//
//  NewsAPI.swift
//  HNewsApp
//
//  Created by Tatiana Kornilova on 24/02/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import Foundation
import Combine

enum Endpoint {
  static let baseURL = URL(string: "https://hacker-news.firebaseio.com/v0/")!
  
  case newstories,topstories,beststories
  case story(Int)
  
  var url: URL {
    switch self {
    case .newstories:
      return Endpoint.baseURL.appendingPathComponent("newstories.json")
    case .topstories:
             return Endpoint.baseURL.appendingPathComponent("topstories.json")
    case .beststories:
        return Endpoint.baseURL.appendingPathComponent("beststories.json")
    case .story(let id):
      return Endpoint.baseURL.appendingPathComponent("item/\(id).json")
    }
  }
    init? (index: Int) {
           switch index {
           case 0: self = .newstories
           case 1: self = .topstories
           case 2: self = .beststories
           default: return nil
           }
       }
}

//struct NewsAPI {
class NewsAPI {
    static let shared = NewsAPI()
    
    // Maximum number of stories to fetch (reduce for lower API strain during development).
    var maxStories = 10
    
    // Асинхронная выборка на основе URL
    func fetch<T: Decodable>(_ url: URL) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: url)                // 1
            .map { $0.data}                                          // 2
            .decode(type: T.self, decoder: JSONDecoder())            // 3
            .receive(on: RunLoop.main)                               // 4
            .eraseToAnyPublisher()                                   // 5
    }
    
    // выборка истории по идентификатору id
    func story(id: Int) -> AnyPublisher<Story, Never> {
        fetch(Endpoint.story(id).url)                                   // 3
            .catch { _ in Empty() }                                     // 4
            .eraseToAnyPublisher()                                      // 5
    }
    
    // выборка историй по endpoint
    func stories(from endpoint: Endpoint) -> AnyPublisher<[Story], Never> {
        fetch( endpoint.url)                                             // 3
            .catch { _ in Empty() }                                      // 4
            .filter { !$0.isEmpty }                                      // 5
            .flatMap { storyIDs in self.mergedStories(ids: storyIDs)}    // 6
            .collect(maxStories)                                         // 7
            .map { stories in  stories.sorted (by: {$0.id > $1.id})}     // 8
            .eraseToAnyPublisher()                                       // 9
    }
    
    // выборка идентификаторов историй по endpoint
       func storyIDs(from endpoint: Endpoint) -> AnyPublisher<[Int], Never> {
           fetch(endpoint.url)                                            // 3
               .catch { _ in Empty() }                                    // 4
               .filter { !$0.isEmpty }                                    // 5
               .eraseToAnyPublisher()                                     // 6
       }
    
    // выборка историй по их идентификаторам
    func mergedStories(ids storyIDs: [Int]) -> AnyPublisher<Story, Never> {
        let storyIDs = Array(storyIDs.prefix(maxStories))
        precondition(!storyIDs.isEmpty)
        
        let initialPublisher = story(id: storyIDs[0])
        let remainder = Array(storyIDs.dropFirst())
        
        return remainder.reduce(initialPublisher) {
            (combined, id) -> AnyPublisher<Story, Never> in
            combined.merge(with: story(id: id))
                .eraseToAnyPublisher()
        }
    }
}

/*
// выборка истории по идентификатору id
func story(id: Int) -> AnyPublisher<Story, Never> {
    URLSession.shared.dataTaskPublisher(for: Endpoint.story(id).url) // 1
        .map { $0.0 }                                                    // 2
        .decode(type: Story.self, decoder: JSONDecoder())                // 3
        .catch { _ in Empty() }                                          // 4
        .eraseToAnyPublisher()                                           // 5
}

// выборка историй
func stories(from endpoint: Endpoint) -> AnyPublisher<[Story], Never> {
    URLSession.shared.dataTaskPublisher(for: endpoint.url)           // 1
        .map { $0.0 }                                                // 2
        .decode(type: [Int].self, decoder: JSONDecoder())            // 3
        .catch { _ in Empty() }                                      // 4
        .filter { !$0.isEmpty }                                      // 5
        .flatMap { storyIDs in  self.mergedStories(ids: storyIDs)}   // 6
        .collect(maxStories)                                         // 7
        .map { stories in stories.sorted (by: {$0.id > $1.id})}      // 8
        .eraseToAnyPublisher()                                       // 9
}

func storyIDs(from endpoint: Endpoint) -> AnyPublisher<[Int], Never> {
    URLSession.shared.dataTaskPublisher(for: endpoint.url)           // 1
        .map { $0.0 }                                                // 2
        .decode(type: [Int].self, decoder: JSONDecoder())            // 3
        .catch { _ in Empty() }                                      // 4
        .eraseToAnyPublisher()                                       // 5
}
*/

