/*
 Copyright (c) 2011, OpenEmu Team
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     * Neither the name of the OpenEmu Team nor the
       names of its contributors may be used to endorse or promote products
       derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY OpenEmu Team ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL OpenEmu Team BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "AppDelegate.h"

// Load Plugins
#import "OECorePlugin.h"
#import "OESystemPlugin.h"
#import "OEShaderPlugin.h"

#import <OpenEmuSystem/OEBindingsController.h>

#import "OEGameCoreManager.h"
#import "OEXPCGameCoreManager.h"
#import "OEDOGameCoreManager.h"
#import "OEThreadGameCoreManager.h"

NSString * const OECoreLauncherLastROMPath = @"OECoreLauncherLastROMPath";

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (strong) OEGameCoreManager *gameCoreManager;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self loadPlugins];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString    *lastRomPath = [defaults objectForKey:OECoreLauncherLastROMPath];
    NSURL       *lastRomURL  = [NSURL URLWithString:lastRomPath];

    // Prompt user for rom path if alt-key is held down or the last rom can't be found

    if(([NSEvent modifierFlags] & NSAlternateKeyMask)
       || (lastRomPath != nil)
       || ![[NSFileManager defaultManager] fileExistsAtPath:lastRomPath])
    {
        [self openDocument:nil];
    }
    else
    {
        [self _launchRomWithURL:lastRomURL error:nil];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{

}

- (void)loadPlugins
{
    [OEPlugin registerPluginClass:[OECorePlugin class]];
    [OEPlugin registerPluginClass:[OESystemPlugin class]];
    [OEPlugin registerPluginClass:[OECGShaderPlugin class]];
    [OEPlugin registerPluginClass:[OEGLSLShaderPlugin class]];
    [OEPlugin registerPluginClass:[OEMultipassShaderPlugin class]];

    // Register all system controllers with the bindings controller
    for(OESystemPlugin *plugin in [OESystemPlugin allPlugins])
        [OEBindingsController registerSystemController:[plugin controller]];
}

#pragma mark - 
- (void)_launchRomWithURL:(NSURL*)url error:(NSError**)outError
{
    NSLog(@"Launch ROM URL: %@", url);
    NSString *extension = [url pathExtension];
    NSSet *validExtensions = [self _validFileExtensions];
    if(![validExtensions containsObject:extension])
    {
        NSLog(@"Invalid Extension (%@ not in %@)", extension, validExtensions);
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:OECoreLauncherLastROMPath];
        return;
    }

    NSArray *systemPlugins = [OESystemPlugin allPlugins];
    NSAssert([systemPlugins count] == 1, @"Can only handle one system plugin!");

    OESystemPlugin *systemPlugin = [systemPlugins lastObject];
    NSString   *systemIdentifier = [systemPlugin systemIdentifier];
    NSArray *corePlugins = [OECorePlugin corePluginsForSystemIdentifier:systemIdentifier];
    NSAssert([corePlugins count] == 1, @"Can only handle one core plugin!");

    NSString *romPath = [url path];
    NSString *crc32 = nil, *md5 = nil, *romHeader = nil, *romSerial = nil, *systemRegion = nil;
    OECorePlugin *corePlugin = [corePlugins lastObject];
    OESystemController *systemController = [systemPlugin controller];
    id<OEGameCoreDisplayHelper> displayHelper = [self gameViewController];

    Class gameCoreClass = [self _pickGameCoreManagerClass];
    OEGameCoreManager *manager = [[gameCoreClass alloc] initWithROMPath:romPath
                                                               romCRC32:crc32
                                                                 romMD5:md5
                                                              romHeader:romHeader
                                                              romSerial:romSerial
                                                           systemRegion:systemRegion
                                                             corePlugin:corePlugin
                                                       systemController:systemController
                                                          displayHelper:displayHelper];
    [self setGameCoreManager:manager];

    [[NSUserDefaults standardUserDefaults] setObject:romPath forKey:OECoreLauncherLastROMPath];

    [manager loadROMWithCompletionHandler:^(id systemClient)
    {
        [manager setupEmulationWithCompletionHandler:^(IOSurfaceID surfaceID, OEIntSize screenSize, OEIntSize aspectSize)
         {
             [displayHelper setScreenSize:screenSize aspectSize:aspectSize withIOSurfaceID:surfaceID];
             [manager startEmulationWithCompletionHandler:^{ }];
         }];
    } errorHandler:^(NSError *error) {
    }];
}

- (NSSet*)_validFileExtensions
{
    NSMutableSet *set = [NSMutableSet set];
    for(OESystemPlugin *system in [OESystemPlugin allPlugins])
    {
        [set addObjectsFromArray:[system supportedTypeExtensions]];
    }
    return set;
}

- (Class)_pickGameCoreManagerClass
{
    if([OEXPCGameCoreManager canUseXPCGameCoreManager])
        return [OEXPCGameCoreManager class];
    else if(YES)
        return [OEDOGameCoreManager class];
    else
        return [OEThreadGameCoreManager class];
}

#pragma mark - Menu Actions
- (IBAction)openDocument:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    NSSet *validExtensions = [self _validFileExtensions];
    [panel setAllowedFileTypes:[validExtensions allObjects]];

    [panel beginWithCompletionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelOKButton)
        {
            NSURL *romURL = [panel URL];
            [[NSUserDefaults standardUserDefaults] setObject:[romURL path] forKey:OECoreLauncherLastROMPath];
            [self _launchRomWithURL:romURL error:nil];
        }
    }];
}
@end
