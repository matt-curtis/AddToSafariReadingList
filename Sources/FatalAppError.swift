//
//  FatalAppError.swift
//  AddToSafariReadingList
//
//  Created by Matt Curtis on 2/18/19.
//  Copyright © 2019 Matt Curtis. All rights reserved.
//

import Foundation
import AppKit

enum FatalAppError {

	private static func alertAndExit(errorDescription: String) -> Never {
		let alert = NSAlert()

		alert.messageText = "Something went wrong."
		alert.informativeText = errorDescription
	
		alert.runModal()

		return fatalError(errorDescription)
	}
	
	
	static func failedToFindStatusItemButton() -> Never {
		return alertAndExit(errorDescription: "We failed to find the menu status item's button.")
	}
	
	static func failedToFindSafariSharingService() -> Never {
		return alertAndExit(errorDescription: "We failed to find the Safari sharing service.")
	}

}
