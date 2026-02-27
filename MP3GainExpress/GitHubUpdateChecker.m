//
//  GitHubUpdateChecker.m
//  MP3Gain Express
//

#import "GitHubUpdateChecker.h"

static NSString * const kGitHubReleasesAPIURL = @"https://api.github.com/repos/perez987/MP3GainOSX-test/releases/latest";
static NSString * const kGitHubReleasesPageURL = @"https://github.com/perez987/MP3GainOSX-test/releases/latest";

@implementation GitHubUpdateChecker

+ (instancetype)sharedChecker {
    static GitHubUpdateChecker *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GitHubUpdateChecker alloc] init];
    });
    return instance;
}

- (void)checkForUpdatesWithUserInitiated:(BOOL)userInitiated {
    NSURL *url = [NSURL URLWithString:kGitHubReleasesAPIURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/vnd.github+json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"2022-11-28" forHTTPHeaderField:@"X-GitHub-Api-Version"];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (userInitiated) {
                    [self showErrorAlert:NSLocalizedString(@"UpdateCheckNetworkError", @"Unable to connect to the update server. Please check your internet connection.")];
                }
                return;
            }

            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode != 200) {
                if (userInitiated) {
                    [self showErrorAlert:NSLocalizedString(@"UpdateCheckFailed", @"Failed to parse update information.")];
                }
                return;
            }

            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError || ![json isKindOfClass:[NSDictionary class]]) {
                if (userInitiated) {
                    [self showErrorAlert:NSLocalizedString(@"UpdateCheckFailed", @"Failed to parse update information.")];
                }
                return;
            }

            NSString *latestTag = json[@"tag_name"];
            if (!latestTag) {
                if (userInitiated) {
                    [self showErrorAlert:NSLocalizedString(@"UpdateCheckFailed", @"Failed to parse update information.")];
                }
                return;
            }

            // Strip leading 'v' prefix if present (e.g. "v3.0.2" -> "3.0.2")
            NSString *latestVersion = [latestTag hasPrefix:@"v"] ? [latestTag substringFromIndex:1] : latestTag;
            NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];

            if ([self isVersion:latestVersion newerThan:currentVersion]) {
                [self showUpdateAvailableAlertWithVersion:latestVersion];
            } else if (userInitiated) {
                [self showUpToDateAlert:currentVersion];
            }
        });
    }];
    [task resume];
}

- (BOOL)isVersion:(NSString *)newVersion newerThan:(NSString *)currentVersion {
    NSArray<NSString *> *newComponents = [newVersion componentsSeparatedByString:@"."];
    NSArray<NSString *> *curComponents = [currentVersion componentsSeparatedByString:@"."];
    NSUInteger count = MAX(newComponents.count, curComponents.count);
    for (NSUInteger i = 0; i < count; i++) {
        NSInteger newVal = (i < newComponents.count) ? [newComponents[i] integerValue] : 0;
        NSInteger curVal = (i < curComponents.count) ? [curComponents[i] integerValue] : 0;
        if (newVal > curVal) return YES;
        if (newVal < curVal) return NO;
    }
    return NO;
}

- (void)showUpdateAvailableAlertWithVersion:(NSString *)version {
    NSAlert *alert = [NSAlert new];
    alert.messageText = NSLocalizedString(@"UpdateAvailable", @"Update Available");
    alert.informativeText = [NSString stringWithFormat:NSLocalizedString(@"UpdateAvailableInfo", @"MP3Gain Express %@ is now available. Would you like to download it?"), version];
    [alert addButtonWithTitle:NSLocalizedString(@"DownloadUpdate", @"Download Update")];
    [alert addButtonWithTitle:NSLocalizedString(@"UpdateLater", @"Later")];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kGitHubReleasesPageURL]];
    }
}

- (void)showUpToDateAlert:(NSString *)version {
    NSAlert *alert = [NSAlert new];
    alert.messageText = NSLocalizedString(@"UpToDate", @"You're up to date!");
    alert.informativeText = [NSString stringWithFormat:NSLocalizedString(@"UpToDateInfo", @"MP3Gain Express %@ is currently the latest version."), version];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
    [alert runModal];
}

- (void)showErrorAlert:(NSString *)message {
    NSAlert *alert = [NSAlert new];
    alert.messageText = NSLocalizedString(@"UpdateCheckError", @"Update Check Failed");
    alert.informativeText = message;
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
    [alert runModal];
}

@end
