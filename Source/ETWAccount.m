//
//  ETWAccount.m
//  EasyTweet
//
//  Created by Steve Streza on 7/11/12.
//  Copyright (c) 2012 Steve Streza
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in 
//  the Software without restriction, including without limitation the rights to 
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
//  SOFTWARE.
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
