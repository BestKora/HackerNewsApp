//
//  Story.swift
//  HNewsApp
//
//  Created by Tatiana Kornilova on 24/02/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import Foundation

struct Story: Codable, Identifiable {
  let id: Int
  let title: String
  let by: String
  let time: TimeInterval
  let url: String
}

extension Story: CustomDebugStringConvertible {
  var debugDescription: String {
    return "-----\(id) \(title)\n"
  }
}

