//
//  StatusIndicatorView.swift
//  AddToSafariReadingList
//
//  Created by Matt Curtis on 2/17/19.
//  Copyright © 2019 Matt Curtis. All rights reserved.
//

import Foundation
import AppKit

class StatusIndicatorView: NSView {
	
	//	MARK: - Status
	
	enum Status {
	
		case initial, pending, success, failure
		
		
		fileprivate var associatedIcon: NSImage {
			switch self {
				case .initial: return #imageLiteral(resourceName: "Default")
				case .pending: return #imageLiteral(resourceName: "In-Progress")
				case .failure: return #imageLiteral(resourceName: "Error")
				case .success: return #imageLiteral(resourceName: "Check")
			}
		}
	
	}
	
	
	//	MARK: - Properties
	
	private let imageView: NSImageView
	

	//	MARK: - Init
	
	init() {
		//	Image View
		
		imageView = NSImageView()
		
		imageView.wantsLayer = true
		
		defer {
			addSubview(imageView)
		}
		
		//	Super
		
		super.init(frame: .zero)
		
		//	Render
		
		render(status: .initial)
	}
	
	required init?(coder decoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	//	MARK: - Layout
	
	override func layout() {
		super.layout()
		
		imageView.frame = bounds
		imageView.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
	}
	
	
	//	MARK: - Rendering
	
	func render(status: Status) {
		imageView.image = status.associatedIcon
		
		imageView.layer?.removeAllAnimations()
		
		if status == .pending {
			let anim = CABasicAnimation(keyPath: "transform.rotation")
			
			anim.fromValue = 0.0
			anim.toValue = -(CGFloat.pi * 2)
			
			anim.duration = 0.5
			anim.repeatCount = .greatestFiniteMagnitude
			
			imageView.layer?.add(anim, forKey: "rotation")
		}
	}
	
}
