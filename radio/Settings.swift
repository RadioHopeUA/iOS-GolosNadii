//
//  Settings.swift
//  radio
//
//  Created by Oleg Alekseenko on 22/10/15.
//  Copyright © 2015 Oleg Alekseenko. All rights reserved.
//

import Foundation


protocol Settings
{
	func streamLink() -> String!
	func siteLink() -> String!
	func facebookLink() -> String!
}

class HopeUA: Settings {

	func streamLink() -> String! {
		return "http://stream.radiojar.com/qpgu3a299rmtv.m3u"
	}

	func siteLink() -> String! {
		return "http://msr.ntucadventist.org"
	}

	func facebookLink() -> String! {
		return ""
	}
}

class Suahili: Settings {

	func streamLink() -> String! {
		return "http://stream.radiojar.com/qpgu3a299rmtv.m3u"
	}

	func siteLink() -> String! {
		return "http://www.morningstaradio.or.tz"
	}

	func facebookLink() -> String! {
		return "https://www.facebook.com/MorningStarRadio"
	}
}