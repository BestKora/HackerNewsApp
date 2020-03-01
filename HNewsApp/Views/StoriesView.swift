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
            Text("Hacker News")
            .font(.largeTitle)
            .padding()
            .background(Color.orange)
            
            Picker("", selection: $model.indexEndpoint){
                           Text("news").tag(0)
                           Text("top").tag(1)
                           Text("best").tag(2)
                       }
            .background(Color.orange)
            .pickerStyle(SegmentedPickerStyle())
            
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
             .onReceive(timer) { self.model.currentDate = $0 }
        } //VStack
    }
}

struct StoriesView_Previews: PreviewProvider {
    static var previews: some View {
        StoriesView()
    }
}




/*
 Text("Hacker News")
           .font(.largeTitle)
           .padding()
           .background(Color.orange)
 */


