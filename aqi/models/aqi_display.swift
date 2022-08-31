//
//  aqi_display.swift
//  aqi
//
//  Created by aoi on 8/31/20.
//  Copyright © 2020 kc_cc. All rights reserved.
//

import Foundation

struct aqiDisplay: Codable {
    let city: String //San Francisco, CA - Current Air Quality
    let pubDate: String //Mon, 31 Aug 2020 09:45:11 PDT
    let aqi_value: String //Moderate - 95 AQI - Particle Pollution (2.5 microns)
}
