//
//  DSFSparklinePieGraphView.swift
//  DSFSparklines
//
//  Created by Darren Ford on 12/2/21.
//  Copyright © 2021 Darren Ford. All rights reserved.
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

/// A sparkline that draws a simple pie chart
@IBDesignable
public class DSFSparklinePieGraphView: DSFSparklineCoreView {
	/// The data to be displayed in the pie.
	///
	/// The values become a percentage of the total value stored within the
	/// dataStore, and as such each value ends up being drawn as a fraction of the total.
	/// So for example, if you want the pie chart to represent the number of red cars vs. number of
	/// blue cars, you just set the values directly.
	@objc public var dataSource: [CGFloat] = [] {
		didSet {
			self.dataDidChange()
		}
	}

	/// The stroke color for the pie chart
	#if os(macOS)
	@IBInspectable public var strokeColor: NSColor? {
		didSet {
			self.updateDisplay()
		}
	}
	#else
	@IBInspectable public var strokeColor: UIColor? {
		didSet {
			self.updateDisplay()
		}
	}
	#endif

	/// The width of the stroke line
	@IBInspectable public var lineWidth: CGFloat = 0.5 {
		didSet {
			self.updateDisplay()
		}
	}

	/// Should the pie chart animate in?
	@IBInspectable public var animated: Bool = false

	/// The length of the animate-in duration
	@IBInspectable public var animationDuration: CGFloat = 0.25

	/// The palette to use when drawing the pie chart
	@objc public var palette = DSFSparklinePalette.shared {
		didSet {
			self.updateDisplay()
		}
	}

	// MARK: - Privates

	internal var animationLayer: ArbitraryAnimationLayer?
	internal var fractionComplete: CGFloat = 0
	internal var total: CGFloat = 0.0
}
