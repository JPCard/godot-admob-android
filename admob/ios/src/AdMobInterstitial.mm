#import "AdMobInterstitial.h"
#include "reference.h"

@implementation AdMobInterstitial

- (void)dealloc 
{
	interstitial.delegate = nil;
	[interstitial release];
	[super dealloc];
}

- (void)initialize :(int)instance_id :(NSString*)test_device_id 
{
	initialized = true;
	instanceId = instance_id;
	testDeviceId = test_device_id;
	rootController = [AppDelegate getViewController];
}


- (void) load_interstitial :(NSString*)ad_unit_id 
{
	NSLog(@"Calling load_interstitial");
	
	if ((!initialized) || (!ad_unit_id.length)) 
	{
		return;
	}
	interstitial = [[GADInterstitial alloc] initWithAdUnitID :ad_unit_id];
	NSLog(@"interstitial created with the id");
	NSLog(ad_unit_id);

	interstitial.delegate = self;

	GADRequest *request = [GADRequest request];
	if (testDeviceId.length){
		request.testDevices = @[testDeviceId];
		NSLog(@"Using test device with id");
		NSLog(testDeviceId);
	}
	[interstitial loadRequest :request];
	
}

- (void) show_interstitial 
{
	if (!initialized) 
	{
		return;
	}

	if (interstitial.isReady) 
	{
		[interstitial presentFromRootViewController :rootController];
	}
	else 
	{
		NSLog(@"Interstitial ad wasn't ready");
	}
}


/// Tells the delegate an ad request succeeded.
- (void)interstitialDidReceiveAd :(GADInterstitial *)ad 
{
	NSLog(@"interstitialDidReceiveAd");
	Object *obj = ObjectDB::get_instance(instanceId);
	obj->call_deferred("_on_AdMob_interstitial_loaded");
}

/// Tells the delegate an ad request failed.
- (void)interstitial :(GADInterstitial *)ad
didFailToReceiveAdWithError :(GADRequestError *)error {
	NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
	Object *obj = ObjectDB::get_instance(instanceId);
	obj->call_deferred("_on_AdMob_interstitial_failed_to_load", error.code);
}

/// Tells the delegate that an interstitial will be presented.
- (void)interstitialWillPresentScreen :(GADInterstitial *)ad 
{
	NSLog(@"interstitialWillPresentScreen");
	Object *obj = ObjectDB::get_instance(instanceId);
	obj->call_deferred("_on_AdMob_interstitial_opened");
}

/// Tells the delegate the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen :(GADInterstitial *)ad 
{
	NSLog(@"interstitialWillDismissScreen");
}

/// Tells the delegate the interstitial had been animated off the screen.
- (void)interstitialDidDismissScreen :(GADInterstitial *)ad 
{
	NSLog(@"interstitialDidDismissScreen");
	Object *obj = ObjectDB::get_instance(instanceId);
	obj->call_deferred("_on_AdMob_interstitial_closed");
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication :(GADInterstitial *)ad 
{
	NSLog(@"interstitialWillLeaveApplication");
	Object *obj = ObjectDB::get_instance(instanceId);
	obj->call_deferred("_on_AdMob_interstitial_left_application");
}

@end