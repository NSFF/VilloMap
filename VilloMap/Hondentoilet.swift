//
//  Hondentoilet.swift
//  VilloMap
//
//  Created by Huei Li Yap on 06/06/2022.
//

import Foundation

struct Hondentoilet:Codable {
    var adres:String
    var coordinaat:Coordinaat

    enum CodingKeys: String, CodingKey {
            case adres = "adrvoisnl"
            case coordinaat = "wgs84_lalo"
        }

}

struct Coordinaat:Codable{
    var lat:Double
    var lon:Double
}
