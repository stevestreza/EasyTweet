//
//  ETWAccount.m
//  Drafty
//
//  Created by Steve Streza on 7/11/12.
//  Copyright (c) 2012 Mustacheware. All rights reserved.
//

#import "ETWAccount.h"

@implementation ETWAccount

-(id)initWithTokenData:(NSDictionary *)dict{
    if(self = [self init]){
        _userID = [dict[@"user_id"] integerValue];
        _username = dict[@"screen_name"];
        _accessTokenKey = dict[@"oauth_token"];
        _accessTokenSecret = dict[@"oauth_token_secret"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInteger:_userID forKey:@"userID"];
    [aCoder encodeObject:_username forKey:@"username"];
    [aCoder encodeObject:_accessTokenKey forKey:@"accessTokenKey"];
    [aCoder encodeObject:_accessTokenSecret forKey:@"accessTokenSecret"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [self init]){
        _userID = [aDecoder decodeIntegerForKey:@"userID"];
        _username = [aDecoder decodeObjectForKey:@"username"];
        _accessTokenKey = [aDecoder decodeObjectForKey:@"accessTokenKey"];
        _accessTokenSecret = [aDecoder decodeObjectForKey:@"accessTokenSecret"];
    }
    return self;
}

@end
