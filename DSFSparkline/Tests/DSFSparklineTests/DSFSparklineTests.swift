//
//  DSFSparklinesTests.swift
//  DSFSparklinesTests
//
//  Created by Darren Ford on 20/6/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import XCTest
@testable import DSFSparkline

class DSFSparklineTests: XCTestCase {

	override func setUp() {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

//	func testPerformanceExample() {
//		// This is an example of a performance test case.
//		self.measure {
//			// Put the code you want to measure the time of here.
//		}
//	}

	func testBlah() {

		let dd = SparklineWindow<CGFloat>(windowSize: 10, dataRange: (-100 ... 100))

		// Default values for the initializer
		XCTAssertEqual(dd.raw.count, 10)
		XCTAssertEqual(dd.normalized.count, 10)

		XCTAssertEqual(dd.raw, [-100, -100, -100, -100, -100, -100, -100, -100, -100, -100])
		XCTAssertEqual(dd.normalized, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

		XCTAssertTrue(dd.push(value: 0))
		XCTAssertTrue(dd.push(value: 1))

		XCTAssertEqual(dd.raw.count, 10)
		XCTAssertEqual(dd.normalized.count, 10)

		XCTAssertEqual(dd.normalized, [0, 0, 0, 0, 0, 0, 0, 0, 0.5, 0.505])

		// Check outside range
		XCTAssertFalse(dd.push(value: 200))
	}

	func testDynamicallyRanged() {
		let dd = SparklineWindow<CGFloat>(windowSize: 10)

		// Default values for the initializer
		XCTAssertEqual(dd.raw.count, 10)
		XCTAssertEqual(dd.normalized.count, 10)

		XCTAssertEqual(dd.raw, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
		XCTAssertEqual(dd.normalized, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

		XCTAssertTrue(dd.push(value: 10))
		XCTAssertEqual(dd.normalized, [0, 0, 0, 0, 0, 0, 0, 0, 0, 1])

		XCTAssertTrue(dd.push(value: 20))
		XCTAssertEqual(dd.normalized, [0, 0, 0, 0, 0, 0, 0, 0, 0.5, 1])

		XCTAssertTrue(dd.push(value: -20))
		XCTAssertEqual(dd.normalized, [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.75, 1.0, 0.0])

		XCTAssertTrue(dd.push(value: -10))
		XCTAssertEqual(dd.normalized, [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.75, 1.0, 0.0, 0.25])
	}

	func testResizing() {
		let dd = SparklineWindow<CGFloat>(windowSize: 10)
		XCTAssertEqual(dd.raw.count, 10)

		dd.set(values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
		XCTAssertEqual(dd.normalized, [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0])

		dd.set(values: [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5])
		XCTAssertEqual(dd.normalized, [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0])

		/// Resizing
		dd.set(values: [-5, -4, -3, -2, -1, 0])
		XCTAssertEqual(dd.normalized, [0.0, 0.2, 0.4, 0.6, 0.8, 1.0])

		dd.set(values: [-5, -4, -3, -2, -1, 0, 1, 2])
		XCTAssertEqual(dd.normalized, [0.0, 0.14285714285714285, 0.2857142857142857, 0.42857142857142855,
									   0.5714285714285714, 0.7142857142857143, 0.8571428571428571, 1.0])

		dd.reset()
		dd.windowSize = 3
		XCTAssertEqual(0, dd.counter)
		XCTAssertTrue(dd.push(value: 1))
		XCTAssertEqual(dd.raw, [0.0, 0.0, 1.0])
		XCTAssertEqual(dd.normalized, [0.0, 0.0, 1.0])
		XCTAssertEqual(1, dd.counter)
		XCTAssertTrue(dd.push(value: 2))
		XCTAssertEqual(dd.raw, [0.0, 1.0, 2.0])
		XCTAssertEqual(dd.normalized, [0.0, 0.5, 1.0])
		XCTAssertEqual(2, dd.counter)
		XCTAssertTrue(dd.push(value: 3))
		XCTAssertEqual(dd.raw, [1.0, 2.0, 3.0])
		XCTAssertEqual(dd.normalized, [0.0, 0.5, 1.0])
		XCTAssertEqual(3, dd.counter)
		XCTAssertTrue(dd.push(value: 4))
		XCTAssertEqual(dd.raw, [2.0, 3.0, 4.0])
		XCTAssertEqual(dd.normalized, [0.0, 0.5, 1.0])
		XCTAssertEqual(4, dd.counter)
	}

	func testWindowSizeChanging() {
		let dd = SparklineWindow<CGFloat>(windowSize: 20)
		dd.set(values: [1.0, 2.0, 3.0, 4.0])

		dd.windowSize = 7
		XCTAssertEqual([0.0, 0.0, 0.0, 1.0, 2.0, 3.0, 4.0], dd.raw)

		dd.windowSize = 3
		XCTAssertEqual([2.0, 3.0, 4.0], dd.raw)
	}

	func testDataSource() {

		let ds = DSFSparklineDataSource(windowSize: 10, range: -10 ... 10)
		XCTAssertTrue(ds.push(value: 5))
		XCTAssertFalse(ds.push(value: 50))
		XCTAssertEqual(ds.data, [0, 0, 0, 0, 0, 0, 0, 0, 0, 5])
		XCTAssertEqual(ds.normalized, [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.75])

		// With no range, adding 5 here makes the implicit range to 0 ... 5
		let ds2 = DSFSparklineDataSource(windowSize: 5)
		XCTAssertTrue(ds2.push(value: 5))
		XCTAssertEqual(ds2.data, [0, 0, 0, 0, 5])
		XCTAssertEqual(ds2.normalized, [0, 0, 0, 0, 1])

		// With no range, adding -5 here makes the implicit range to -5 ... 5
		XCTAssertTrue(ds2.push(value: -5))
		XCTAssertEqual(ds2.data, [0, 0, 0, 5, -5])
		XCTAssertEqual(ds2.normalized, [0.5, 0.5, 0.5, 1, 0])

		// With no range, adding -5 here makes the implicit range to -5 ... 5
		XCTAssertTrue(ds2.push(value: 10))
		XCTAssertTrue(ds2.push(value: -3))
		XCTAssertEqual(ds2.data, [0, 5, -5, 10, -3])
		XCTAssertEqual(ds2.normalized, [0.3333333333333333, 0.6666666666666666, 0.0, 1.0, 0.13333333333333333])

		ds2.windowSize = 3
		XCTAssertEqual(ds2.data, [-5, 10, -3])
		XCTAssertEqual(ds2.normalized, [0.0, 1.0, 0.13333333333333333])

		ds2.windowSize = 10
		XCTAssertEqual(ds2.data, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -5.0, 10.0, -3.0])
		XCTAssertEqual(ds2.normalized,
							[0.3333333333333333, 0.3333333333333333, 0.3333333333333333, 0.3333333333333333, 0.3333333333333333,
							 0.3333333333333333, 0.3333333333333333, 0.0, 1.0, 0.13333333333333333])

		ds2.reset()
		XCTAssertEqual(ds2.data, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0])

		ds2.set(values: [0, 1, 2, 3, 4, 5, 6])
		XCTAssertEqual(7, ds2.windowSize)
		XCTAssertEqual(ds2.data, [0, 1, 2, 3, 4, 5, 6])
	}
}
