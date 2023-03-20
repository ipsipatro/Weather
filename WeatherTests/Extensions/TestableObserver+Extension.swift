//
//  TestableObserver+Extension.swift
//  WeatherTests
//
//  Created by Ipsi Patro on 18/03/2023.
//

import RxTest
import Nimble

extension TestableObserver {
    
    var elements: [Element] {
        return self.events.compactMap { $0.value.element }
    }
    
    var valueCount: Int {
        return self.events.filter { $0.value.error == nil }.count
    }
    
    var errorCount: Int {
        return self.events.filter { $0.value.error != nil }.count
    }
    
    func assertValueCount(_ count: Int, file: String = #file, line: UInt = #line) {
        expect(file: file, line: line, self.elements.count) == count
    }
    
    func assertThatAt(_ index: Int, that: @escaping (Element) -> Bool, file: String = #file, line: UInt = #line) {
        expect(file: file, line: line, that( self.elements[index])) == true
    }
}

extension TestableObserver where Element: Equatable {
    
    func assertValues(_ values: Element..., file: String = #file, line: UInt = #line) {
        expect(file: file, line: line, self.elements) == values
    }
}
