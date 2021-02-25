//
//  File.swift
//  
//
//  Created by Darren Ford on 24/2/21.
//

import QuartzCore

public extension DSFSparklineOverlay {
	@objc(DSFSparklineOverlayTablet) class Tablet: DSFSparklineDataSourceOverlay {

		static let greenStroke = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0, 1, 0, 1])!
		static let greenFill = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0, 1, 0, 0.3])!
		static let redStroke = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1, 0, 0, 1])!
		static let redFill = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1, 0, 0, 0.3])!


		/// The width of the stroke for the tablet
		@objc public var lineWidth: CGFloat = 1.0 {
			didSet {
				self.setNeedsDisplay()
			}
		}

		/// The spacing (in pixels) between each bar
		@objc public var barSpacing: CGFloat = 1.0 {
			didSet {
				self.setNeedsDisplay()
			}
		}

		/// The color to draw the win tablets
		@objc public var winStrokeColor: CGColor = Tablet.greenStroke {
			didSet {
				self.setNeedsDisplay()
			}
		}

		/// The color to draw the 'win' boxes
		@objc public var winFillColor: CGColor = Tablet.greenFill {
			didSet {
				self.setNeedsDisplay()
			}
		}

		/// The color to draw the win tablets
		@objc public var lossStrokeColor: CGColor = Tablet.redStroke {
			didSet {
				self.setNeedsDisplay()
			}
		}

		/// The color to draw the 'win' boxes
		@objc public var lossFillColor: CGColor = Tablet.redFill {
			didSet {
				self.setNeedsDisplay()
			}
		}

		public override func drawGraph(context: CGContext, bounds: CGRect, scale: CGFloat) -> CGRect {
			self.drawTabletGraph(context: context, bounds: bounds, scale: scale)
		}
	}
}

private extension DSFSparklineOverlay.Tablet {
	func drawTabletGraph(context: CGContext, bounds: CGRect, scale: CGFloat) -> CGRect {
		guard let dataSource = self.dataSource else {
			return bounds
		}

		let integralRect = bounds.insetBy(dx: 0, dy: 1)
		let windowSize = CGFloat(dataSource.windowSize)

		// The amount of space left in the rect once we've removed the bar spacing for all elements
		let w = integralRect.width - (windowSize * (self.barSpacing + self.lineWidth))

		// The size of a circle
		let circleSize = min(w / CGFloat(windowSize), integralRect.height)

		// This represents the _full_ width of a circle, including the spacing.
		let componentWidth = circleSize + self.barSpacing + self.lineWidth

		// The left offset in order to center X
		let xOffset: CGFloat = (integralRect.width - (componentWidth * windowSize)) / 2

		// Map the +ve values to true, the -ve (and 0) to false
		let winLoss: [Int] = dataSource.data.map {
			if $0 > 0 { return 1 }
			return -1
		}

		let midPoint = bounds.midY

		context.usingGState { outer in

			if dataSource.counter < dataSource.windowSize {
				let pos = CGFloat(dataSource.counter) * componentWidth
				let clipRect = integralRect.divided(atDistance: CGFloat(pos + xOffset + CGFloat(self.barSpacing / 2)), from: .maxXEdge).slice
				outer.clip(to: clipRect.integral)
			}

			let winPath = CGMutablePath()
			let lossPath = CGMutablePath()

			for point in winLoss.enumerated() {
				let x = xOffset + CGFloat(point.offset) * componentWidth
				if point.element == 1 {
					let rect = CGRect(x: x, y: midPoint - (circleSize / 2), width: circleSize, height: circleSize)
					winPath.addEllipse(in: rect.integral)
				}
				else if point.element == -1 {
					let rect = CGRect(x: x, y: midPoint - (circleSize / 2), width: circleSize, height: circleSize)
					lossPath.addEllipse(in: rect.integral)
				}
			}

			if !winPath.isEmpty {
				outer.usingGState { winState in
					winState.addPath(winPath)
					winState.setFillColor(self.winFillColor)
					winState.setStrokeColor(self.winStrokeColor)
					winState.setLineWidth(self.lineWidth)
					winState.drawPath(using: .fillStroke)
				}
			}

			if !lossPath.isEmpty {
				outer.usingGState { lossState in
					lossState.addPath(lossPath)
					lossState.setFillColor(self.lossFillColor)
					lossState.setStrokeColor(self.lossStrokeColor)
					lossState.setLineWidth(self.lineWidth)
					lossState.drawPath(using: .fillStroke)
				}
			}
		}

		return bounds
	}
}
