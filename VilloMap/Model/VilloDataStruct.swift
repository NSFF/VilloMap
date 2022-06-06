//
//  VilloDataStruct.swift
//  VilloMap
//
//  Created by Huei Li Yap on 06/06/2022.
//

import Foundation

struct VilloDataStruct : Codable {
    let timeStamp: String
    let features: [FeatureEle]
}
struct FeatureEle : Codable {
    let bbox: Array<Double>
    let geometry: GeometryEle
    let properties: PropertiesEle
    
    struct GeometryEle : Codable {
        let coordinates: Array<Double>
    }
    struct PropertiesEle : Codable {
        let status: String // Open/Closed?
        let mu_nl: String // municipality
        let pccp: String // zipcode
        let address_nl: String // street
    }
}
