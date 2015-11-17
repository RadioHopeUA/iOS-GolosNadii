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
import AFNetworking
import MediaPlayer

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {

	// MARK: - Properties -
	@IBOutlet var playButton: UIButton?
	@IBOutlet var playTextLabel: UILabel?
	@IBOutlet var volumeSlider: MPVolumeView?

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
		setupReachabilityObserving()

		try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)


		let shareItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Reply, target: self, action: Selector("share:"));
		self.navigationItem.rightBarButtonItem = shareItem;

		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerDidEnded:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: player)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerDidFailed:"), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: player)

		self.view.layoutIfNeeded()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		self.volumeSlider?.layer.removeAllAnimations();
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


	func setupUI()
	{
		volumeSlider?.tintColor = UIColor.r_lightColor();
		volumeSlider?.setVolumeThumbImage(UIImage(named: "thumb"), forState: .Normal);
		volumeSlider?.showsRouteButton = false;
	}

	func setupReachabilityObserving()
	{
		AFNetworkReachabilityManager.sharedManager().startMonitoring()
		AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (status:AFNetworkReachabilityStatus) -> Void in
			switch status {
			case .NotReachable:
					self.stopPlaying()
					self.showError()
			case .ReachableViaWiFi, .ReachableViaWWAN:
				if self.playing {
					self.startPlaying()
				}
			default:
				 break
			}
		}
	}

	// MARK: - Actions -

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
			mailVC.setToRecipients(["support@hope.ua"])
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
				UIApplication.sharedApplication().openURL(url!);
			}
		}
	}

	@IBAction func playOrPause(sender:UIButton) -> ()
	{
		if(playing)
		{
			stopPlaying()
		}
		else
		{
			startPlaying()
		}
	}

	@IBAction func updateVolume(sender:UISlider)
	{
		player?.volume = sender.value;
	}

	func playerDidEnded(not:NSNotification)
	{
		stopPlaying()
	}

	func playerDidFailed(not:NSNotification)
	{
		stopPlaying()
		showError();
	}

	func startPlaying()
	{
		if (player != nil)
		{
			player?.pause();
			player = nil;
		}

		if(AFNetworkReachabilityManager.sharedManager().reachable)
		{
			let url = NSURL(string: settings.streamLink())
			player = AVPlayer(URL: url!)
			player?.play()
			playing = true
			beginRecurciveUpdateTitleUpdate()
		}
		else
		{
			showError()
		}
	}

	func stopPlaying()
	{
		if (player != nil)
		{
			player?.pause();
			player = nil;
		}
		playing = false;
	}

	func beginRecurciveUpdateTitleUpdate()
	{
		let manager = AFURLSessionManager();
		let responseSerializer = AFHTTPResponseSerializer()
		var types = responseSerializer.acceptableContentTypes
		types?.insert("text/plain")
		responseSerializer.acceptableContentTypes = types
		manager.responseSerializer = responseSerializer
		let url = NSURL(string: "http://stream.hope.ua:7777/currentsong?sid=11")
		let request = NSURLRequest(URL: url!);
		let task = manager.dataTaskWithRequest(request) { (response, data, error) -> Void in
			if ((data as? NSData) != nil)
			{
				let text = NSString(data: data as! NSData, encoding: NSUTF8StringEncoding)!
				let components = text.componentsSeparatedByString("-")
				if (components.count > 1)
				{
					self.updateTextLabel(components[0], detail: components[1]);
				}
			}

			let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
			dispatch_after(delayTime, dispatch_get_main_queue()) {
				if self.playing
				{
					self.beginRecurciveUpdateTitleUpdate()
				}
			}
		}
		task.resume()
	}

	func updateTextLabel(title:String?, var detail:String?)
	{
		let string = NSMutableAttributedString();
		if (title != nil)
		{
			let atributes = [
				NSFontAttributeName : UIFont(name: "HelveticaNeue-Medium", size: 17.0)!,
				NSForegroundColorAttributeName : UIColor.r_lightColor()
			]

			let titleString = NSAttributedString(string: title!, attributes: atributes );
			string.appendAttributedString(titleString)
		}

		if (detail != nil)
		{
			if (title != nil)
			{
				detail = "\n\(detail)"
			}
			let atributes = [
				NSFontAttributeName : UIFont(name: "HelveticaNeue-Light", size: 17.0)!,
				NSForegroundColorAttributeName : UIColor.r_lightColor()
			]

			let detailString = NSAttributedString(string: detail!, attributes: atributes)
			string.appendAttributedString(detailString)
		}

		self.playTextLabel?.attributedText = string
	}

	func showError()
	{
		let alertController = UIAlertController(title: NSLocalizedString("alert.title.error", comment: ""), message: NSLocalizedString("alert.message.error", comment: ""), preferredStyle: .Alert)
		let tryAction = UIAlertAction(title: NSLocalizedString("alert.button.retry", comment: ""), style: UIAlertActionStyle.Default) { (action) -> Void in
			 self.stopPlaying()

		}
		let cancelAction = UIAlertAction(title: NSLocalizedString("alert.button.cancel", comment: ""), style: UIAlertActionStyle.Cancel) { (action) -> Void in
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
				startPlaying()

			case UIEventSubtype.RemoteControlPause:
				stopPlaying()
			default: break
			}
		}
	}

	// MARK: - MFMailComposeDelegate -

	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
		controller.dismissViewControllerAnimated(true, completion: nil);
	}
}

