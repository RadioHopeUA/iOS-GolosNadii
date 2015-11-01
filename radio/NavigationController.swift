//
//  NavigationController.swift
//  radio
//
//  Created by Oleg Alekseenko on 18/10/15.
//  Copyright © 2015 Oleg Alekseenko. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

	override func childViewControllerForStatusBarStyle() -> UIViewController? {
		return self.topViewController;
	}

}
