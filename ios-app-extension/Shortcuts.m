#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"
#import "React/RCTConvert.h"

@interface RCT_EXTERN_MODULE(Shortcuts, RCTEventEmitter)
RCT_EXTERN_METHOD(clearAllShortcuts:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(clearShortcutsWithIdentifiers: (NSArray *)persistentIdentifiers resolver:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(donateShortcut: (NSString *)type options: (NSDictionary *) options)
RCT_EXTERN_METHOD(suggestShortcuts)
RCT_EXTERN_METHOD(presentShortcut: (NSDictionary *) options callback: (RCTResponseSenderBlock) callback)
RCT_EXTERN_METHOD(presentIntentShortcut: (NSString *)type callback: (RCTResponseSenderBlock) callback)
RCT_EXTERN_METHOD(getShortcuts:(RCTPromiseResolveBlock)resolve rejecter: (RCTPromiseRejectBlock)reject)
@end
