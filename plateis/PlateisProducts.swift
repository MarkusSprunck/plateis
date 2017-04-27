//
//  PlateisProducts.swift
//  PLATEIS
//
//  Created by Markus Sprunck on 19/08/16.
//  Copyright (c) 2016 Markus Sprunck. All rights reserved.
//

import Foundation

public struct PlateisProducts {
    
    public static let SkipWorlds = "plateis.skip_worlds"
    
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [
        PlateisProducts.SkipWorlds
    ]
    
    public static let store = IAPHelper(productIds: PlateisProducts.productIdentifiers)
}
