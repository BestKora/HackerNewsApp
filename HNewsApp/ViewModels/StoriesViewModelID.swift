//
//  StoriesViewModelID.swift
//  HNewsApp
//
//  Created by Tatiana Kornilova on 28/02/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import Foundation
import Combine
import SwiftySound

class StoriesViewModelID: ObservableObject {
    private let api = NewsAPI.shared
    //input
    @Published var indexEndpoint: Int = 0
    @Published var currentDate = Date()
    //output
    @Published var stories = [Story]()
    
    init() {
        Publishers.CombineLatest( $currentDate,$indexEndpoint)
            .flatMap { (time, indexEndpoint) -> AnyPublisher<[Int], Never> in
                self.api.storyIDs(from: Endpoint( index: indexEndpoint)!)
                .map { (currentIds) in
                     let ids = Array(currentIds.prefix( self.api.maxStories))
                     
                  if self.oldIds.count == 0 || ids.first! != self.oldIds.first! {
                     self.oldIds = ids
                     return ids
                    } else { return [Int()] }
                }
                .eraseToAnyPublisher()
             }
            .flatMap { storyIDs -> AnyPublisher<[Story], Never> in
               self.api.mergedStories(ids: storyIDs)
                .collect()
                .catch { _ in Empty() }
                .filter { !$0.isEmpty }
                .map { stories in stories.sorted (by: {$0.id > $1.id})}
                .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink (receiveValue: { (stories) in
                if stories.count > 0 {
                 Sound.play(file: "success.wav")
                 self.stories = stories
                }
           })
          .store(in: &self.subscriptions)
    }
    private var subscriptions = Set<AnyCancellable>()
    
    private var oldIds = [Int]()
    
    deinit {
        Sound.stopAll()
    }
}

 //             print ("......\(ids.count) \(self.oldIds.count )  \(ids)\n ---------- \(self.oldIds)")
