//
//  ViewController.swift
//  radio
//
//  Created by Oleg Alekseenko on 13/10/15.
//  Copyright © 2015 Oleg Alekseenko. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices
import MessageUI

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {

	// MARK: - Properties -
	@IBOutlet var slider: UISlider?
	@IBOutlet var playButton: UIButton?

	var player: AVPlayer?
	let settings: Settings = HopeUA()

	var playing:Bool = false
	{
		didSet {
			playButton?.selected = playing;
		}
	}

	// MARK: - View cirle -

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		setupUI()
		setupPlayer()

		slider?.value = 1.0;
		try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)

		NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)


		let shareItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Reply, target: self, action: Selector("share:"));
		self.navigationItem.rightBarButtonItem = shareItem;
	}

	func share(sender:UIBarButtonItem?)
	{
		let alertVC = UIAlertController(title: "Поделиться", message: nil, preferredStyle: .ActionSheet);

		let fbAction = UIAlertAction(title: "Facebook", style: .Default) { (action) -> Void in
			self.openFacebook()
		};

		let vkAction = UIAlertAction(title: "Вконтакте", style: .Default) { (action) -> Void in
			self.openVK()
		};

		let twAction = UIAlertAction(title: "Twitter", style: .Default) { (action) -> Void in
			self.openTwitter()
		};

		let pdAction = UIAlertAction(title: "Podster", style: .Default) { (action) -> Void in
			self.openPodster()
		};

		let emAction = UIAlertAction(title: "Обратная связь", style: .Default) { (action) -> Void in
			self.sendMail()
		};

		let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (action) -> Void in

		};

		alertVC.addAction(fbAction)
		alertVC.addAction(vkAction)
		alertVC.addAction(twAction)
		alertVC.addAction(pdAction)
		alertVC.addAction(emAction)
		alertVC.addAction(cancelAction)

		if (alertVC.popoverPresentationController != nil)
		{
			alertVC.popoverPresentationController?.barButtonItem = sender
		}

		self.presentViewController(alertVC, animated: true, completion: nil)

	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
		self.becomeFirstResponder()
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}

	deinit{

		player?.currentItem?.removeObserver(self, forKeyPath: "status")
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	// MARK: - Setup -

	func setupPlayer()
	{
		let url = NSURL(string: settings.streamLink())
		player = AVPlayer(URL: url!)
		player?.volume = slider!.value

		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerDidEnded"), name: AVPlayerItemDidPlayToEndTimeNotification, object: player)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerDidFailed"), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: player)
	}

	func setupUI()
	{
		slider?.tintColor = UIColor.r_lightColor();
		slider?.setThumbImage(UIImage(named: "thumb"), forState: .Normal);
	}

	// MARK: - Actions -

	func updateTime(){

		if (player != nil)
		{
			let status = player?.currentItem?.asset.statusOfValueForKey("playable", error: nil);
			if status != AVKeyValueStatus.Loaded && player?.currentItem?.error != nil
			{
				showAlert()
			}
		}
	}

	@IBAction func openSite()
	{
		let url = NSURL(string:settings.siteLink())
		openURL(url)
	}

	@IBAction func openFacebook()
	{
		let url = NSURL(string: settings.facebookLink())
		openURL(url)
	}

	@IBAction func openPodster()
	{
		let url = NSURL(string: settings.podStepLink())
		openURL(url)
	}

	@IBAction func openTwitter()
	{
		let url = NSURL(string: settings.twitterLink())
		openURL(url)
	}

	@IBAction func openVK()
	{
		let url = NSURL(string: settings.vkLink())
		openURL(url)
	}


	@IBAction func sendMail()
	{
		if MFMailComposeViewController.canSendMail()
		{
			let mailVC = MFMailComposeViewController()
			mailVC.setSubject("Radio app")
			mailVC.setToRecipients(["v.dubinskij@hope.ua"])
			mailVC.mailComposeDelegate = self
			self.presentViewController(mailVC, animated: true, completion: nil);
		}
	}

	func openURL(url: NSURL?) -> ()
	{
		if(url != nil)
		{
			if UIApplication.sharedApplication().canOpenURL(url!)
			{
				if #available(iOS 9.0, *) {
				    let safari = SFSafariViewController(URL: url!)
					self.presentViewController(safari, animated: true, completion: nil);
				} else {
					UIApplication.sharedApplication().openURL(url!);
				};
			}
		}
	}

	@IBAction func playOrPause(sender:UIButton) -> ()
	{

		if(playing)
		{
			player?.pause()
		}
		else
		{
			player?.play()
		}

		playing = !playing
	}

	@IBAction func updateVolume(sender:UISlider)
	{
		player?.volume = sender.value;
	}

	func playerDidEnded(not:NSNotification)
	{
		playing = false
	}

	func playerDidFailed(not:NSNotification)
	{
		playing = false

		showAlert();
	}


	func showAlert()
	{
		let alertController = UIAlertController(title: NSLocalizedString("alert.title.error", comment: ""), message: NSLocalizedString("alert.message.error", comment: ""), preferredStyle: .Alert)
		let tryAction = UIAlertAction(title: NSLocalizedString("alert.button.retry", comment: ""), style: UIAlertActionStyle.Default) { (action) -> Void in
			self.setupPlayer()
			self.player?.play()
			self.playing = true
		}
		let cancelAction = UIAlertAction(title: NSLocalizedString("alert.button.cancel", comment: ""), style: UIAlertActionStyle.Cancel) { (action) -> Void in
			self.setupPlayer()
		}
		alertController.addAction(tryAction)
		alertController.addAction(cancelAction)
		self.presentViewController(alertController, animated: true, completion: nil)
	}

	override func remoteControlReceivedWithEvent(event: UIEvent?) {
		if (event!.type == UIEventType.RemoteControl)
		{
			switch event!.subtype {
			case UIEventSubtype.RemoteControlPlay:
				playing = true
				player?.play()

			case UIEventSubtype.RemoteControlPause:
				playing = false
				player?.pause()

			default: break
			}
		}
	}


	// MARK: - MFMailComposeDelegate -

	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
		controller.dismissViewControllerAnimated(true, completion: nil);
	}
}

