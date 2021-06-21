//
//  ECSignalingEvent.m
//  ErizoClientIOS
//
//  Created by Alvaro Gil on 5/18/17.
//
//

#import "ECSignalingEvent.h"

@implementation ECSignalingEvent

- (instancetype)initWithName:(NSString *)name message:(NSDictionary *)message {
    if (self = [super init]) {
        self.name = name;
        self.message = [[message mutableCopy] objectForKey:@"msg"];

        NSDictionary *dic = [[message mutableCopy] objectForKey:@"msg"];

        self.streamId = [NSString stringWithFormat:@"%@", [dic objectForKey:kEventKeyId]];
        self.peerSocketId = [dic objectForKey:kEventKeyPeerSocketId];
        self.attributes = [dic objectForKey:kEventKeyAttributes];
        self.updatedAttributes = [dic objectForKey:kEventKeyUpdatedAttributes];
        self.dataStream = [dic objectForKey:kEventKeyDataStream];
        self.audio = [(NSNumber *)[dic objectForKey:kEventKeyAudio] boolValue];
        self.video = [(NSNumber *)[dic objectForKey:kEventKeyVideo] boolValue];
        self.data = [(NSNumber *)[dic objectForKey:kEventKeyData] boolValue];

        // FIXME: Sometimes id is provided and sometimes streamId is provided.
        if ((!self.streamId || [self.streamId isEqualToString:@""]) && [dic valueForKey:kEventKeyStreamId]) {
            self.streamId = [NSString stringWithFormat:@"%@", [dic objectForKey:kEventKeyStreamId]];
        }
    }
    return self;
}

@end
