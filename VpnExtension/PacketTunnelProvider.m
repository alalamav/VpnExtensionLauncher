//
//  PacketTunnelProvider.m
//  VpnExtensionLauncher
//
//  Created by Alberto Lalama on 8/16/17.
//
//

#import <Foundation/Foundation.h>

@implementation PacketTunnelProvider

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler {
  NSLog(@"Starting tunnel");
  completionHandler(nil)
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason
           completionHandler:(void (^)(void))completionHandler {
  NSLog(@"Stopping tunnel");
  completionHandler();
}

@end
