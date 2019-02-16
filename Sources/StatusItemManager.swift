//
//  StatusItemManager.swift
//  AddToSafariReadingList
//
//  Created by Matt Curtis on 2/16/19.
//  Copyright © 2019 Matt Curtis. All rights reserved.
//

import Foundation
import Cocoa

class StatusItemManager: NSObject, NSWindowDelegate, NSDraggingDestination {

	//	MARK: - Properties
	
	private let statusItem: NSStatusItem
	
	
	weak var dragDelegate: StatusItemManagerDragDelegate?
	
	
	//	MARK: - UI
	
	private let statusIndicatorView: StatusIndicatorView
	
	
	private let button: NSButton
	
	private var window: NSWindow? {
		return button.window
	}
	
	var menu: NSMenu? {
		get {
			return statusItem.menu
		}
		
		set {
			statusItem.menu = newValue
		}
	}
	

	//	MARK: - Init

	init(acceptedDragTypes dragTypes: [ NSPasteboard.PasteboardType ]) {
		//	Status item
		
		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
		statusItem.behavior = [ .terminationOnRemoval ]
		
		//	Aquire and configure button
		
		guard let button = statusItem.button else {
			FatalAppError.failedToFindStatusItemButton()
		}
		
		self.button = button
		
		//	Add status indicator view
		
		statusIndicatorView = StatusIndicatorView()
		
		statusIndicatorView.frame = button.bounds
		
		button.addSubview(statusIndicatorView)
		
		NotificationCenter.default.addObserver(forName: NSView.boundsDidChangeNotification, object: button, queue: nil) {
			[weak button, weak statusIndicatorView] _ in
			
			if let button = button, let statusIndicatorView = statusIndicatorView {
				statusIndicatorView.frame = button.bounds
			}
		}
		
		super.init()
		
		//	Configure window for drag
		//	registerForDraggedTypes will forward all drag events to us as the window's delegate:
		
		window?.registerForDraggedTypes(dragTypes)
		window?.delegate = self
	}
	
	
	//	MARK: - Status Item Drag Events
	
	func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		if dragDelegate?.dragEntered(withPasteboard: sender.draggingPasteboard) == true {
			return [ .copy ]
		}
		
		return []
	}
	
	func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		if dragDelegate?.performDropAction(withPasteboard: sender.draggingPasteboard) == true {
			return true
		}
		
		return false
	}
	
	func draggingEnded(_ sender: NSDraggingInfo) {
		dragDelegate?.dragExitedOrEnded()
	}
	
	func draggingExited(_ sender: NSDraggingInfo?) {
		dragDelegate?.dragExitedOrEnded()
	}
	
	
	//	MARK: - Rendering
	
	func setIsHighlighted(_ isHighlighted: Bool) {
		button.highlight(isHighlighted)
	}
	
	func render(status: StatusIndicatorView.Status) {
		statusIndicatorView.render(status: status)
	}

}

protocol StatusItemManagerDragDelegate: class {

	func dragEntered(withPasteboard pasteboard: NSPasteboard) -> Bool
	
	func performDropAction(withPasteboard pasteboard: NSPasteboard) -> Bool
	
	func dragExitedOrEnded()

}
