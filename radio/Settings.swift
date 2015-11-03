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
	func twitterLink() -> String!
	func vkLink() -> String!
	func podStepLink() -> String!
}


class HopeUA: Settings {

	func streamLink() -> String! {
		return "http://stream.hope.ua:7777/golos/64"
	}

	func siteLink() -> String! {
		return "http://radio.hope.ua"
	}

	func facebookLink() -> String! {
		return "https://www.facebook.com/golosnadii"
	}

	func twitterLink() -> String! {
		return "https://twitter.com/golosnadii"
	}

	func vkLink() -> String! {
		return "https://vk.com/golosnadii"
	}

	func podStepLink() -> String! {
		return "http://podster.fm/user/golosnadii"
	}
}