//
//  DSFSparklineBarGraphView+Private.swift
//  DSFSparklines
//
//  Created by Darren Ford on 16/1/20.
//  Copyright © 2019 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public extension DSFSparklineWinLossGraphView {
	
	#if os(macOS)
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		if let ctx = NSGraphicsContext.current?.cgContext {
			self.drawWinLossGraph(primary: ctx)
		}
	}
	#else
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		if let ctx = UIGraphicsGetCurrentContext() {
			self.drawWinLossGraph(primary: ctx)
		}
	}
	#endif

	private func drawWinLossGraph(primary: CGContext) {
		guard let dataSource = self.dataSource else {
			return
		}

		let integralRect = self.bounds.integral

		// This represents the _full_ width of a bar within the graph, including the spacing.
		let componentWidth: Int = Int(integralRect.width) / Int(dataSource.windowSize)

		// The width of the BAR component
		let barWidth = componentWidth - Int(barSpacing)

		// The left offset in order to center X
		let xOffset: Int = (Int(self.bounds.width) - (componentWidth * Int(dataSource.windowSize))) / 2

		// Map the +ve values to true, the -ve (and 0) to false
		let winLoss: [Bool] = dataSource.data.map { $0 > 0 }
		let hasWin = (winLoss.firstIndex(of: true) != nil)
		let hasLoss = (winLoss.firstIndex(of: false) != nil)

		let graphLineWidth: CGFloat = 1 / self.retinaScale() * CGFloat(self.lineWidth)

		let midPoint = Int(bounds.midY.rounded())
		let barHeight = Int(integralRect.midY) - Int(self.lineWidth)

		primary.usingGState { outer in

			outer.setShouldAntialias(false)
			outer.setRenderingIntent(.relativeColorimetric)
			outer.interpolationQuality = .none

			if dataSource.counter < dataSource.windowSize {
				let pos = Int(dataSource.counter) * componentWidth
				let clipRect = integralRect.divided(atDistance: CGFloat(pos + xOffset), from: .maxXEdge).slice
				outer.clip(to: clipRect.integral)
			}

			if hasWin {
				outer.usingGState { winState in
					let winPath = CGMutablePath()
					for point in winLoss.enumerated() {
						guard point.element == true else { continue }

						let x = xOffset + point.offset * componentWidth
						let rect = CGRect(x: x, y: 1, width: barWidth, height: barHeight)
						winPath.addRect(rect.integral)
					}
					winPath.closeSubpath()
					winState.addPath(winPath)
					winState.setFillColor(self.winColor.withAlphaComponent(0.3).cgColor)
					winState.setStrokeColor(self.winColor.cgColor)
					winState.setLineWidth(graphLineWidth)
					winState.drawPath(using: .fillStroke)
				}
			}

			if hasLoss {
				outer.usingGState { lossState in
					let lossPath = CGMutablePath()
					for point in winLoss.enumerated() {
						guard point.element == false else { continue }

						let x = xOffset + point.offset * componentWidth
						let rect = CGRect(x: x, y: midPoint + 1, width: barWidth, height: barHeight)
						lossPath.addRect(rect.integral)
					}
					lossPath.closeSubpath()
					lossState.addPath(lossPath)
					lossState.setFillColor(self.lossColor.withAlphaComponent(0.3).cgColor)
					lossState.setStrokeColor(self.lossColor.cgColor)
					lossState.setLineWidth(graphLineWidth)
					lossState.drawPath(using: .fillStroke)
				}
			}
		}
	}
}
