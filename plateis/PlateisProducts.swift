//
//  PlateisProducts.swift
//  PLATEIS
//
//  Copyright (c) 2016-2017 Markus Sprunck. All rights reserved.
//

import Foundation

struct PlateisProducts {
    
    static let SkipWorlds = "plateis.skip_worlds"
    
    private static let productIdentifiers: Set<ProductIdentifier> = [
        PlateisProducts.SkipWorlds
    ]
    
    static let store = IAPHelper(productIds: PlateisProducts.productIdentifiers)
}
