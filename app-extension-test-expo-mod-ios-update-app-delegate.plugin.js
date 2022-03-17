const { withAppDelegate } = require('@expo/config-plugins');

module.exports = function appExtensionTestExpoModIosUpdateAppDelegate(config) {
  return withAppDelegate(config, async (config) => {
    config.modResults.contents = config.modResults.contents.replace(
      '@implementation AppDelegate',
      '#import "ExpoEasAppExtensionTest-Swift.h"\n\n@implementation AppDelegate',
    );
    let didFinishLaunchingIndex = config.modResults.contents.indexOf(
      'didFinishLaunchingWithOptions',
    );
    didFinishLaunchingIndex += config.modResults.contents
      .slice(didFinishLaunchingIndex)
      .indexOf('return YES');

    config.modResults.contents = `${config.modResults.contents.slice(0, didFinishLaunchingIndex)}
  BOOL launchedFromShortcut = [launchOptions objectForKey:@"UIApplicationLaunchOptionsUserActivityDictionaryKey"] != nil;
  Shortcuts.launchedFromShortcut = launchedFromShortcut;
  if (launchedFromShortcut) {
    [Shortcuts requestPermissions];
  }
${config.modResults.contents.slice(didFinishLaunchingIndex)}`;

    config.modResults.contents = config.modResults.contents.replace(
      /restorationHandler \{[^}]+\}/,
      `
restorationHandler {
  if (Shortcuts.launchedFromShortcut) {
    Shortcuts.initialUserActivity = userActivity;
    Shortcuts.launchedFromShortcut = false;
  }

   [Shortcuts onShortcutReceivedWithUserActivity:userActivity];

  return YES;
}
`,
    );

    return config;
  });
};
