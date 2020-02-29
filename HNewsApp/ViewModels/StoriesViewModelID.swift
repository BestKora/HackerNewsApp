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
    @Published var currentDate = Date()
    //output
    @Published var stories = [Story]()
    
    init() {
        $currentDate
            .flatMap { _ -> AnyPublisher<[Int], Never> in
                self.api.storyIDs()
                .map { (currentIds) in
                  if self.oldIds.count == 0 ||
                     currentIds.first! != self.oldIds.first! {
                     let ids = Array(currentIds.prefix( self.api.maxStories))
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
                 Sound.play(file: "success.wav")
                 self.stories = stories
           })
          .store(in: &self.subscriptions)
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var oldIds = [Int]()
    
    deinit {
        Sound.stopAll()
    }
}

// let currentIDs = stories.map{$0.id}
// print ("......\(currentIDs.count) \(self.oldStoryIDs.count )  \(currentIDs) --- \(self.oldStoryIDs)")
