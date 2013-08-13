class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    HTBHatenaBookmarkManager.sharedManager.setConsumerKey(
      "...",
      consumerSecret: "..."
    )

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    controller = UINavigationController.alloc.initWithRootViewController(MainViewController.new)
    @window.rootViewController = controller
    @window.makeKeyAndVisible
    true
  end
end

class MainViewController < UIViewController
  def viewDidLoad
    super
    NSNotificationCenter.defaultCenter.addObserver(self, selector:'showOAuthLoginView:', name:KHTBLoginStartNotification, object:nil)
    self.view.backgroundColor = UIColor.whiteColor

    self.view << @loginButton = UIButton.rounded_rect.tap do |btn|
      btn.setTitle('login', forState:UIControlStateNormal)
      btn.addTarget(self, action:'on_login', forControlEvents:UIControlEventTouchUpInside)
    end

    self.view << @bookmarkButton = UIButton.rounded_rect.tap do |btn|
      btn.setTitle('bookmark', forState:UIControlStateNormal)
      btn.addTarget(self, action:'on_bookmark', forControlEvents:UIControlEventTouchUpInside)
    end

    if HTBHatenaBookmarkManager.sharedManager.authorized
      HTBHatenaBookmarkManager.sharedManager.getMyEntryWithSuccess(
        lambda { |entry| },
        failure: lambda { |error| }
      )

      HTBHatenaBookmarkManager.sharedManager.getMyTagsWithSuccess(
        lambda { |tags| },
        failure: lambda { |error| }
      )
    end
  end

  def viewWillAppear(animated)
    @loginButton.frame = [[0, 0], [200, 42]]
    @loginButton.center = self.view.center
    @bookmarkButton.frame = [[10, 10], [200, 42]]
    super
  end

  def on_login
    HTBHatenaBookmarkManager.sharedManager.logout
    HTBHatenaBookmarkManager.sharedManager.authorizeWithSuccess(
      lambda {},
      failure: lambda {|error| NSLog(error.localizedDescription) }
    )
  end

  def on_bookmark
    controller = HTBHatenaBookmarkViewController.alloc.init
    controller.URL = 'http://hbfav.bloghackers.net/'.nsurl
    self.presentViewController(controller, animated:true, completion:nil)
  end

  def showOAuthLoginView(notification)
    req = notification.object
    navigationController = UINavigationController.alloc.initWithNavigationBarClass(HTBNavigationBar, toolbarClass:nil)
    viewController = HTBLoginWebViewController.alloc.initWithAuthorizationRequest(req)
    navigationController.viewControllers = [viewController]
    self.presentViewController(navigationController, animated:true, completion:nil)
  end
end
