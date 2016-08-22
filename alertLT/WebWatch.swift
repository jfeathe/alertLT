//
//  WebWatch.swift
//  alertLT
//
//  Created by Ryan Zegray on 2016-08-22.
//  Copyright © 2016 Ryan Zegray. All rights reserved.
//

import Foundation

class WebWatchScrapper {
    
}

struct WebWatchRoute {
    var name: String
    var number: Int
}

enum WebWatchDirection: Int {
    case Northbound = 2
    case Eastbound = 1
    case Southbound = 3
    case Westbound = 4
}

struct WebWatchStop {
    var name: String
    var number: Int
}