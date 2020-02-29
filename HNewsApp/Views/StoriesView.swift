//
//  StoriesView.swift
//  HNReader
//
//  Created by Tatiana Kornilova on 30/01/2020.
//  Copyright © 2020 Razeware LLC. All rights reserved.
//

import SwiftUI

struct StoriesView: View {
    @ObservedObject var model = StoriesViewModelID ()
    
    private let timer = Timer.publish(every: 3, on: .main, in: .common)
    .autoconnect()
    .eraseToAnyPublisher()
    
    var body: some View {
        VStack {
            List {
                ForEach(self.model.stories) { story in
                    HStack {
                        TimeBadge(time: story.time)
                        VStack {
                            Text(story.title)
                                .font(.body)
                                .lineLimit(2)
                            PostedBy(time: story.time,
                                     currentDate: self.model.currentDate)
                        }
                    }
                    .padding()
                }
            }
        } //VStack
        .onReceive(timer) { self.model.currentDate = $0 }
    }
}

struct StoriesView_Previews: PreviewProvider {
    static var previews: some View {
        StoriesView()
    }
}







