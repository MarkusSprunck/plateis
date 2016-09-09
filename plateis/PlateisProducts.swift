//
//  PlateisProducts.swift
//  PLATEIS
//
//  Created by Markus Sprunck on 19/08/16.
//  Copyright (c) 2016 Markus Sprunck. All rights reserved.
//

import Foundation

public struct PlateisProducts {
    
    public static let SkipLevelsRage = "plateis.skip_levels"

    private static let productIdentifiers: Set<ProductIdentifier> = [
        PlateisProducts.SkipLevelsRage
    ]
    
    public static let store = IAPHelper(productIds: PlateisProducts.productIdentifiers)
}
