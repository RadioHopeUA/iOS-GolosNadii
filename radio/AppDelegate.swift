//
//  AppDelegate.swift
//  radio
//
//  Created by Oleg Alekseenko on 13/10/15.
//  Copyright © 2015 Oleg Alekseenko. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.

		Fabric.with([Crashlytics.self()])

		setupArrepeance()

		return true
	}

// MARK: - Appereance -

	func setupArrepeance()
	{
		let backImage = UIImage(named: "navBack");
		UINavigationBar.appearance().setBackgroundImage(backImage, forBarMetrics: .Default);
		UINavigationBar.appearance().titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.r_lightColor() ];
		UIBarButtonItem.appearance().tintColor = UIColor.r_lightColor();
	}


}

