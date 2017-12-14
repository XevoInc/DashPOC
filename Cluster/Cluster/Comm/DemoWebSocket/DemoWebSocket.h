//
//  DemoWebSocket.h
//  RNXreComm
//
//  Created by Glenn Harter on 12/13/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>

@protocol DemoWebSocketDelegate
-(void)valueChanged:(NSString *)setting value:(NSString *)value;
@end

@interface DemoWebSocket : NSObject <SRWebSocketDelegate>

@property (strong, nonatomic) SRWebSocket *socket;
@property (weak, nonatomic) id<DemoWebSocketDelegate> delegate;

-(void)beginSession;
-(void)changeValue:(NSString *)setting value:(NSString *)value;

@end
