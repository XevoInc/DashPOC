//
//  DemoWebSocket.m
//  RNXreComm
//
//  Created by Glenn Harter on 12/13/17.
//

#import "DemoWebSocket.h"

@implementation DemoWebSocket

@synthesize socket;

-(void)beginSession
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ip = [defaults objectForKey:@"CLUSTER_DEMO_IPPORT"];
    //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://52.11.183.81:8001"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:ip]];
    socket = [[SRWebSocket alloc] initWithURLRequest:request];
    socket.delegate = self;
    [socket open];
}

-(void)changeValue:(NSString *)setting value:(NSString *)value
{
    NSString *message = [NSString stringWithFormat:@"{\"method\" : \"setProperty\", \"params\" : {\"property\" : \"%@\", \"value\" : \"%@\"}}", setting, value];
    [socket send:message];
}

#pragma mark SRWebSocketDelegate
-(void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"webSocketDidOpen");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *demoIdentifier = [defaults objectForKey:@"CLUSTER_DEMO_ID"];
    NSString *message = [NSString stringWithFormat:@"{\"method\" : \"setConnectionProperties\", \"params\" : {\"vehicleID\" : \"%@\"}}", demoIdentifier];
    [socket send:message];
    
    [self getAllProperties];
    //message = @"{\"method\" : \"getAllProperties\", \"params\" : {}}";
    //[socket send:message];
}

-(void)getAllProperties
{
    if (socket != nil)
    {
        NSString *message = @"{\"method\" : \"getAllProperties\", \"params\" : {}}";
        [socket send:message];
    }
}

-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"WebSocket connection error %@", error);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self beginSession];
    });
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ( [message isKindOfClass:[NSString class]] ) {
        NSString *theMessage = message;
        NSError *error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:[theMessage dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if ( object && [object isKindOfClass:[NSDictionary class]] ) {
            NSDictionary *result = object;
            NSString *method =result[@"method"];
            NSDictionary *params = result[@"params"];
            if ( [method isEqualToString:@"setProperty"] && [params isKindOfClass:[NSDictionary class]] ) {
                NSString *property = params[@"property"];
                NSString *value = params[@"value"];
                if ( [value isKindOfClass:[NSNumber class]]) {
                    NSNumber *temp = (NSNumber *)value;
                    value = temp.stringValue;
                }
                if ( [property isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]] && property.length && value.length ) {
                    [_delegate valueChanged:property value:value];
                }
            }
        }
    }
}


@end
