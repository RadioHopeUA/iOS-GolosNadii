//
//  File.swift
//  radio
//
//  Created by Oleg Alekseenko on 13/10/15.
//  Copyright © 2015 Oleg Alekseenko. All rights reserved.
//

import UIKit

extension UIColor
{

	static func r_backColor() -> UIColor
	{
		return UIColor(red: 23.0 / 255.0, green: 25.0 / 255.0, blue: 26.0 / 255.0, alpha: 1.0)
	}
	static func r_lightColor() -> UIColor
	{
		return r_ColorWith255Values(173.0, green: 185.0, blue: 185.3, alpha: 1.0);
	}

	static private func r_ColorWith255Values(red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) -> UIColor
	{
		return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha);
	}
}