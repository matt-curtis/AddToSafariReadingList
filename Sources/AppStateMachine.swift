//
//  AppStateMachine.swift
//  AddToSafariReadingList
//
//  Created by Matt Curtis on 2/17/19.
//  Copyright © 2019 Matt Curtis. All rights reserved.
//

import Foundation

class AppStateMachine {

	//	MARK: - State
	
	private enum State {
	
		case dormant
		case validDragInside
		case invalidDragInside
		case addingArticle
		case showingStatusFromAddingArticle
	
	}
	
	
	private var state: State = .dormant
	
	var shouldAcceptDrops: Bool {
		return state == .dormant
	}
	
	
	//	MARK: - Commands
	
	typealias Commands = [ Command ]
	
	enum Command {
		
		case highlight
		case unhighlight
		
		case switchToInvalidCursor
		case switchToDefaultCursor
		
		case switchToDefaultIcon
		case switchToInProgressIcon
		case switchToSuccessIcon
		case switchToFailureIcon
		case startTimerForReturnToDefaultIcon
	
	}
	
	
	//	MARK: - Actions
	
	func userEnteredWithInvalidDrag() -> Commands {
		guard state == .dormant else { return [] }
		
		state = .invalidDragInside
		
		return [ .switchToInvalidCursor ]
	}
	
	func userEnteredWithValidDrag() -> Commands {
		guard state == .dormant else { return [] }
		
		state = .validDragInside
		
		return [ .highlight ]
	}
	
	func userExitedDrag() -> Commands {
		switch state {
			case .validDragInside:
				state = .dormant
				
				return [ .unhighlight ]
			
			case .invalidDragInside:
				state = .dormant
				
				return [ .switchToDefaultCursor ]
			
			default: return []
		}
	}
	
	func userDroppedArticle() -> Commands {
		guard state == .validDragInside else { return [] }
		
		state = .addingArticle
		
		return [
			.unhighlight,
			.switchToInProgressIcon
		]
	}
	
	func finishedAddingArticle(succeeded: Bool) -> Commands {
		guard state == .addingArticle else { return [] }
		
		state = .showingStatusFromAddingArticle
		
		return [
			succeeded ?
				.switchToSuccessIcon :
				.switchToFailureIcon,
			
			.startTimerForReturnToDefaultIcon
		]
	}
	
	func returnToDefaultIconTimerFired() -> Commands {
		guard state == .showingStatusFromAddingArticle else { return [] }
		
		state = .dormant
		
		return [ .switchToDefaultIcon ]
	}
	
}
