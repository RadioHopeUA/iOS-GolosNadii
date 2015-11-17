//
//  VolumeSlider.swift
//  radio
//
//  Created by Oleg Alekseenko on 17/11/15.
//  Copyright © 2015 Oleg Alekseenko. All rights reserved.
//

import Foundation
import MediaPlayer

class VolumeSlider: MPVolumeView {
	override func layoutSubviews() {
		super.layoutSubviews()
		recursiveRemoveAnimation(self)
	}

	func recursiveRemoveAnimation(view:UIView?){
		view?.layer.removeAllAnimations()
		for subview in view!.subviews
		{
			recursiveRemoveAnimation(subview)
		}
	}
}
