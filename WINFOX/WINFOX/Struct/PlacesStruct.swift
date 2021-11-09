//
//  PlacesStruct.swift
//  WINFOX
//
//  Created by  Svetlana Frolova on 06.11.2021.
//

import Foundation

struct PlacesStruct: Decodable {
    let image: String
    let name: String
    let id: String
    let latitide: Double
    let longitude: Double
    let desc: String
}
