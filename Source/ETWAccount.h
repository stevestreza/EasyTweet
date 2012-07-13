//
//  ETWAccount.h
//  Drafty
//
//  Created by Steve Streza on 7/11/12.
//  Copyright (c) 2012 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ETWTwitterApp;

@interface ETWAccount : NSObject <NSCoding>

@property (nonatomic, weak) ETWTwitterApp *app;

@property (nonatomic, readonly) NSUInteger userID;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *accessTokenKey;
@property (nonatomic, readonly) NSString *accessTokenSecret;

-(id)initWithTokenData:(NSDictionary *)dict;

@end
