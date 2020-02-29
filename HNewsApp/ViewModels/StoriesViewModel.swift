//
//  StoriesViewModel.swift
//  HNewsApp
//
//  Created by Tatiana Kornilova on 27/02/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import Foundation
import Combine
import SwiftySound

class StoriesViewModel: ObservableObject {
    private let api = NewsAPI.shared
    //input
    @Published var currentDate = Date()
    //output
    @Published var stories = [Story]()
    
    init() {
        $currentDate
            .flatMap { _ -> AnyPublisher<[Story], Never> in
                self.api.stories()
        }
        .receive(on: RunLoop.main)
        .sink(
            receiveValue: { (stories) in
                let oldIds = self.oldStories.sorted(by: {$0.id > $1.id}).map {$0.id}
                let currentIds = stories.sorted(by: {$0.id > $1.id}).map {$0.id}
                
                if oldIds.count == 0 || currentIds.first! != oldIds.first! {
                    Sound.play(file: "success.wav")
                    self.stories = stories.sorted(by: {$0.id > $1.id})
                    self.oldStories = stories.sorted(by: {$0.id > $1.id})
                }
        })
        .store(in: &self.subscriptions)
    }
    
    private var subscriptions = Set<AnyCancellable>()
    private var oldStories = [Story]()
    
    deinit {
        Sound.stopAll()
    }
}

 //                  print ("\(currentIds.count ) \(oldIds.count ) \(currentIds) --- \(oldIds)")
