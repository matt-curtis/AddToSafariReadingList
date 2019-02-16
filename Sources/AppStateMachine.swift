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
		case pendingArticleAdd
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
		
		case switchToDefaultIcon
		case switchToInProgressIcon
		case switchToSuccessIcon
		case switchToFailureIcon
		case startTimerForReturnToDefaultIcon
	
	}
	
	
	//	MARK: - Actions
	
	func userEnteredWithValidDrag() -> Commands {
		guard state == .dormant else { return [] }
		
		state = .pendingArticleAdd
		
		return [ .highlight ]
	}
	
	func userExitedDrag() -> Commands {
		guard state == .pendingArticleAdd else { return [] }
		
		state = .dormant
		
		return [ .unhighlight ]
	}
	
	func userDroppedArticle() -> Commands {
		guard state == .pendingArticleAdd else { return [] }
		
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
