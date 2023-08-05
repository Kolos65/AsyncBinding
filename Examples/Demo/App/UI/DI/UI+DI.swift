//
//  UI+DI.swift
//  AsyncBindingDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 05..
//

import Resolver

extension Resolver {
    static func registerUI() {
        register { HomeScreenViewModel() }
    }
}
