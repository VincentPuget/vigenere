//
//  L.swift
//  mowa
//
//  Created by Vincent PUGET on 26/02/2015.
//  Copyright (c) 2015 JPM & Associes. All rights reserved.
//

import Cocoa

struct L
{
    static func v(anyObjects:AnyObject!...) -> Void
    {
        if(Const.App.DEBUG)
        {
            for anyObject:AnyObject! in anyObjects
            {
                print(anyObject);
            }
        }
    }
}
