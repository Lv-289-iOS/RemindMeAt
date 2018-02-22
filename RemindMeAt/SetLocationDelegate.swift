//
//  SetLocationDelegate.swift
//  RemindMeAt
//
//  Created by Yurii Tsymbala on 2/18/18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

protocol SetLocationDelegate: class {
    func setLocation(location: RMALocation)
}
