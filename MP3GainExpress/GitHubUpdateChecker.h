//
//  GitHubUpdateChecker.h
//  MP3Gain Express
//

#import <Cocoa/Cocoa.h>

@interface GitHubUpdateChecker : NSObject

+ (instancetype)sharedChecker;
- (void)checkForUpdatesWithUserInitiated:(BOOL)userInitiated;

@end
