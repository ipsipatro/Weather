//
//  ObservableConvertibleType+Extension.swift
//  Weather
//
//  Created by Ipsi Patro on 14/03/2023.
//

import RxCocoa
import RxSwift

extension ObservableConvertibleType {
    func asDriverLogError(_ file: StaticString = #file, _ line: UInt = #line) -> SharedSequence<DriverSharingStrategy, Element> {
        return asDriver(onErrorRecover: {
            print("Error:", $0, " in file:", file, " atLine:", line)
            return .empty()
        })
    }
}
