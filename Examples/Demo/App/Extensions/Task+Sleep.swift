//
//  Task+Sleep.swift
//  AsyncBindingDemo
//
//  Created by Kolos Foltanyi on 2023. 08. 05..
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(for seconds: TimeInterval) async {
        // swiftlint:disable:next force_try
        try! await sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
