//
//  ClearisAppDelegate.m
//  Clearis
//
//  Created by 881 on 10-2-20.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "GameAppDelegate.h"
#import "cocos2d.h"
#import "GameMenuLayer.h"
#import "GamePlayingLayer.h"
#import "ReplaceLayerAction.h"
#import "GameOverLayer.h"
#import "GameHelpLayer.h"
#import "GameOptionsLayer.h"
#import "GameScoresLayer.h"
#import "GameNewLayer.h" 
#import "GamePauseLayer.h"
#import "SimpleAudioEngine.h"

@implementation GameAppDelegate

@synthesize window;

+ (GameAppDelegate*) instance
{
	UIApplication* app = [UIApplication sharedApplication];
	return (GameAppDelegate*)(app.delegate);
}


- (GameStateLayer*) getCurrentLayer
{
	return m_currentLayer;
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	
	m_dataManager = [[GameDataManager alloc] init];
	m_dataManager.mainWindow = window;
	[m_dataManager load];
	
	SimpleAudioEngine* engin = [SimpleAudioEngine sharedEngine];
	[engin preloadBackgroundMusic:@"MenuBkMusic.mp3"];
	[engin preloadEffect:@"ButtonClick.wav"];
	engin.backgroundMusicVolume = [m_dataManager realMusicVolume];
	engin.effectsVolume = [m_dataManager realSoundVolume];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use Threaded director
	if( ! [Director setDirectorType:CCDirectorTypeDisplayLink] )
		[Director setDirectorType:CCDirectorTypeDefault];
	
	// Use RGBA_8888 buffers
	// Default is: RGB_565 buffers
	[[Director sharedDirector] setPixelFormat:kPixelFormatRGBA8888];
	
	// Create a depth buffer of 16 bits
	// Enable it if you are going to use 3D transitions or 3d objects
//	[[Director sharedDirector] setDepthBufferFormat:kDepthBuffer16];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	// before creating any layer, set the landscape mode
	//[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	//[[Director sharedDirector] setDisplayFPS:YES];
	
	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		
		
	m_currentScene = [Scene node];
	m_currentLayer = [[[GameMenuLayer alloc] initWithDataManagerWithAnimate:m_dataManager] autorelease];
	[m_currentLayer enterLayer];
	
	Sprite *bg = [Sprite spriteWithFile:@"bg.png"];
	//Sprite* logo = [Sprite spriteWithFile:@"Menu_logo.png"];
	bg.anchorPoint = ccp(0.0, 0.0);
	//logo.position = ccp(320 * 0.5, 480 * 0.5);
	[m_currentScene addChild:bg];
	//[m_currentScene addChild:logo];
	
	//[logo runAction:[MoveTo actionWithDuration:1.0 position:ccp(320 * 0.5, 480 - 50)]];
	[m_currentScene addChild:m_currentLayer];
	
	[[Director sharedDirector] runWithScene:m_currentScene];
}




/*Sprite* logoImage = [Sprite spriteWithFile:@"Menu_logo.png"];
logoImage.position = ccp(contentSize.width * 0.5, contentSize.height - 50);
[self addChild:logoImage];*/
- (void)applicationWillResignActive:(UIApplication *)application {
	[[Director sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[Director sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeUnusedTextures];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[m_currentLayer levelLayer:m_dataManager];
	[m_dataManager save];
	[[Director sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[window release];
	[m_dataManager release];
	
	[[Director sharedDirector] release];
	[super dealloc];
}


#pragma mark Main menu actions

- (void) switchStateLayer:(Class) state reverse:(bool)flag
{
	[m_currentLayer levelLayer:m_dataManager];
	GameStateLayer* layer = [[[state alloc] initWithDataManager:m_dataManager] autorelease];
	ReplaceLayerAction *replaceScreen = 
	[[[ReplaceLayerAction alloc] initWithScene:m_currentScene layer:layer replaceLayer:m_currentLayer] autorelease];
	replaceScreen.reverse = flag;
	[m_currentScene runAction:replaceScreen];
	
	m_currentLayer = layer;
	
}

- (void) startGameScores:(bool)flag
{
	[self switchStateLayer:[GameScoresLayer class] reverse:flag];
}



- (void) startGameOptions:(bool)flag
{
	[self switchStateLayer:[GameOptionsLayer class] reverse:flag];
}


- (void) startGamePause:(bool)flag
{
	[self switchStateLayer:[GamePauseLayer class] reverse:flag];
}

- (void) startGameHelp:(bool)flag
{
	[self switchStateLayer:[GameHelpLayer class] reverse:flag];
}


- (void) startMainMenu:(bool)flag
{
	[self switchStateLayer:[GameMenuLayer class] reverse:flag];
}


- (void) startStartNewGame:(bool)flag
{
	[self switchStateLayer:[GamePlayingLayer class] reverse:flag];
}


- (void) startGameNew:(bool)flag
{
	[self switchStateLayer:[GameNewLayer class] reverse:flag];
}


- (void) startGameOver:(bool)flag
{
	[self switchStateLayer:[GameOverLayer class] reverse:flag];
}

@end
