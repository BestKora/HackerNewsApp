//
//  NewsAPI.swift
//  HNewsApp
//
//  Created by Tatiana Kornilova on 24/02/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import Foundation
import Combine

enum EndPoint {
  static let baseURL = URL(string: "https://hacker-news.firebaseio.com/v0/")!
  
  case stories
  case story(Int)
  
  var url: URL {
    switch self {
    case .stories:
      return EndPoint.baseURL.appendingPathComponent("newstories.json")
    case .story(let id):
      return EndPoint.baseURL.appendingPathComponent("item/\(id).json")
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
        URLSession.shared.dataTaskPublisher(for: url)             // 1
            .map { $0.data}                                          // 2
            .decode(type: T.self, decoder: JSONDecoder())            // 3
            .receive(on: RunLoop.main)                               // 4
            .eraseToAnyPublisher()                                   // 5
    }
    
    // выборка истории по идентификатору id
    func story(id: Int) -> AnyPublisher<Story, Never> {
        fetch(EndPoint.story(id).url)                                   // 3
            .catch { _ in Empty() }                                     // 4
            .eraseToAnyPublisher()                                      // 5
    }
    
    // выборка историй
    func stories() -> AnyPublisher<[Story], Never> {
        fetch(EndPoint.stories.url)                                      // 3
            .catch { _ in Empty() }                                      // 4
            .filter { !$0.isEmpty }                                      // 5
            .flatMap { storyIDs in self.mergedStories(ids: storyIDs)}    // 6
            .collect(maxStories)                                         // 7
            .map { stories in  stories.sorted (by: {$0.id > $1.id})}     // 8
            .eraseToAnyPublisher()                                       // 9
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
    
    func storyIDs() -> AnyPublisher<[Int], Never> {
        fetch(EndPoint.stories.url)
            .catch { _ in Empty() }
            .filter { !$0.isEmpty }
            .eraseToAnyPublisher()
    }
}

/*
// выборка истории по идентификатору id
func story(id: Int) -> AnyPublisher<Story, Never> {
    URLSession.shared.dataTaskPublisher(for: EndPoint.story(id).url) // 1
        .map { $0.0 }                                                    // 2
        .decode(type: Story.self, decoder: JSONDecoder())                // 3
        .catch { _ in Empty() }                                          // 4
        .eraseToAnyPublisher()                                           // 5
}

// выборка историй
func stories() -> AnyPublisher<[Story], Never> {
    URLSession.shared.dataTaskPublisher(for: EndPoint.stories.url) // 1
        .map { $0.0 }                                                // 2
        .decode(type: [Int].self, decoder: JSONDecoder())            // 3
        .catch { _ in Empty() }                                      // 4
        .filter { !$0.isEmpty }                                      // 5
        .flatMap { storyIDs in  self.mergedStories(ids: storyIDs)}   // 6
        .collect(maxStories)                                         // 7
        .map { stories in stories.sorted (by: {$0.id > $1.id})}      // 8
        .eraseToAnyPublisher()                                       // 9
}
}
func storyIDs() -> AnyPublisher<[Int], Never> {
    URLSession.shared.dataTaskPublisher(for: EndPoint.stories.url) // 1
        .map { $0.0 }                                                // 2
        .decode(type: [Int].self, decoder: JSONDecoder())            // 3
        .catch { _ in Empty() }                                      // 4
        .eraseToAnyPublisher()                                       // 5
}
*/

