//
//  Utilities.swift
//  DSFSparklines
//
//  Created by Darren Ford on 20/12/19.
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

import Foundation
import CoreGraphics.CGContext

#if os(macOS)
import Cocoa
public typealias DSFColor = NSColor
public typealias DSFView = NSView
public typealias DSFFont = NSFont
#else
import UIKit
public typealias DSFColor = UIColor
public typealias DSFView = UIView
public typealias DSFFont = UIFont
#endif

#if canImport(SwiftUI)
import SwiftUI
#if os(macOS)
@available(macOS 10.15, *)
typealias DSFViewRepresentable = NSViewRepresentable
#else
@available(iOS 13.0, tvOS 13.0, *)
typealias DSFViewRepresentable = UIViewRepresentable
#endif
#endif

extension ExpressibleByIntegerLiteral where Self: Comparable {
	/// Clamp a value to a closed range
	/// - Parameter range: the range to clamp to
	func clamped(to range: ClosedRange<Self>) -> Self {
		return min(max(self, range.lowerBound), range.upperBound)
	}
}

extension CGContext {
	/// Execute the supplied block within a `saveGState() / restoreGState()` pair, providing a context
	/// to draw in during the execution of the block
	///
	/// - Parameter stateBlock: The block to execute within the new graphics state
	/// - Parameter context: The context to draw into within the block
	///
	/// Example usage:
	/// ```
	///    context.usingGState { (ctx) in
	///       ctx.addPath(unsetBackground)
	///       ctx.setFillColor(bgc1.cgColor)
	///       ctx.fillPath(using: .evenOdd)
	///    }
	/// ```
	func usingGState(stateBlock: (_ context: CGContext) throws -> Void) rethrows {
		self.saveGState()
		defer {
			self.restoreGState()
		}
		try stateBlock(self)
	}
}

extension DSFView {
	#if os(macOS)
	@objc func retinaScale() -> CGFloat {
		return self.window?.screen?.backingScaleFactor ?? 1.0
	}
	#else
	@objc func retinaScale() -> CGFloat {
		return self.window?.screen.scale ?? 1.0
	}
	#endif
}
