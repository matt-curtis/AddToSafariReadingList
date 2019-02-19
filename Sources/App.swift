//
//  App.swift
//  AddToSafariReadingList
//
//  Created by Matt Curtis on 2/16/19.
//  Copyright © 2019 Matt Curtis. All rights reserved.
//

import Cocoa

@NSApplicationMain class App: NSObject, NSApplicationDelegate, StatusItemManagerDragDelegate, NSSharingServiceDelegate {

	//	MARK: - Properties
	
	private let stateMachine = AppStateMachine()

	private let statusItemManager: StatusItemManager
	
	private let addToReadingListShareService: NSSharingService
	
	
	//	MARK: - Init
	
	override init() {
		//	Acquire sharing service
	
		guard let service = NSSharingService(named: .addToSafariReadingList) else {
			FatalAppError.failedToFindSafariSharingService()
		}
	
		addToReadingListShareService = service
	
		defer {
			service.delegate = self
		}
	
		//	Status item manager
	
		statusItemManager = StatusItemManager(acceptedDragTypes: [ .URL, .string ])
	
		defer {
			statusItemManager.dragDelegate = self
		}
		
		//	Create menu
	
		let menu = NSMenu()
	
		let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(quitMenuItemClicked), keyEquivalent: "")
	
		defer {
			quitMenuItem.target = self
		}
	
		menu.addItem(quitMenuItem)
	
		statusItemManager.menu = menu
	
		super.init()
	}
	
	
	//	MARK: - Application Lifecycle
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		NSApp.setActivationPolicy(.prohibited)
	}
	
	
	//	MARK: - Status Item Button Menu
	
	@objc private func quitMenuItemClicked() {
		NSApp.terminate(nil)
	}
	
	
	//	MARK: - Drag and Drop
	
	func dragEntered(withPasteboard pasteboard: NSPasteboard) -> Bool {
		guard
			stateMachine.shouldAcceptDrops,
			parseURLs(onPasteboard: pasteboard).count > 0
		else {
			performCommands { $0.userEnteredWithInvalidDrag() }
			
			return false
		}
	
		performCommands { $0.userEnteredWithValidDrag() }
		
		return true
	}
	
	func performDropAction(withPasteboard pasteboard: NSPasteboard) -> Bool {
		let urls = parseURLs(onPasteboard: pasteboard)
	
		addURLsToReadingList(urls: urls)
	
		performCommands { $0.userDroppedArticle() }
	
		return true
	}
	
	func dragExited() {
		performCommands { $0.userExitedDrag() }
	}
	
	
	//	MARK: - Pasteboard Parsing

	private func parseURLs(onPasteboard pasteboard: NSPasteboard) -> [ URL ] {
		//	Parse URLs
	
		var urls: [ URL ] = []
	
		if let url = NSURL(from: pasteboard) {
			urls.append(url as URL)
		} else if let string = pasteboard.string(forType: .string) {
			urls.append(contentsOf:
				string
					.components(separatedBy: .newlines)
					.map { $0.trimmingCharacters(in: .whitespaces) }
					.compactMap { URL(string: $0) }
			)
		}
	
		return urls.filter { $0.scheme != nil && $0.host != nil }
	}
	
	
	//	MARK: - Sharing
	
	private func addURLsToReadingList(urls: [ URL ]) {
		addToReadingListShareService.perform(withItems: urls)
	}
	
	
	func sharingService(_ sharingService: NSSharingService, didShareItems items: [Any]) {
		performCommands { $0.finishedAddingArticle(succeeded: true) }
	}
	
	func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [Any], error: Error) {
		performCommands { $0.finishedAddingArticle(succeeded: false) }
	}
	
	
	//	MARK: - State
	
	private func performCommands(_ action: (AppStateMachine) -> AppStateMachine.Commands) {
		for command in action(stateMachine) {
			perform(command: command)
		}
	}
	
	private func perform(command: AppStateMachine.Command) {
		switch command {
			case .switchToInvalidCursor:
				NSCursor.operationNotAllowed.push()
			
			case .switchToDefaultCursor:
				NSCursor.operationNotAllowed.pop()
			
			case .highlight:
				statusItemManager.setIsHighlighted(true)
			
			case .unhighlight:
				statusItemManager.setIsHighlighted(false)
			
			case .switchToDefaultIcon:
				statusItemManager.render(status: .initial)
	
			case .switchToInProgressIcon:
				statusItemManager.render(status: .pending)
			
			case .switchToSuccessIcon:
				statusItemManager.render(status: .success)
	
			case .switchToFailureIcon:
				statusItemManager.render(status: .failure)
	
			case .startTimerForReturnToDefaultIcon:
				let timer = Timer(timeInterval: 1, repeats: false) {
					[weak self] _ in
	
					self?.performCommands { $0.returnToDefaultIconTimerFired() }
				}
	
				RunLoop.main.add(timer, forMode: .common)
		}
	}

}
