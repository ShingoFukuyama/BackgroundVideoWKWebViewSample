//
//  Extension.swift
//  VideoWKWebView
//
//  Created by Shingo Fukuyama on 2018/08/16.
//  Copyright © 2018 Shingo Fukuyama. All rights reserved.
//

import Foundation

public struct TargetedExtension<Base> {
    let base: Base
    init (_ base: Base) {
        self.base = base
    }
}

public protocol TargetedExtensionCompatible {
    associatedtype Compatible
    static var ext: TargetedExtension<Compatible>.Type { get }
    var ext: TargetedExtension<Compatible> { get }
}

public extension TargetedExtensionCompatible {
    public static var ext: TargetedExtension<Self>.Type {
        return TargetedExtension<Self>.self
    }
    public var ext: TargetedExtension<Self> {
        return TargetedExtension(self)
    }
}
