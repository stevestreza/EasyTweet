//
//  ETWTwitterApp.h
//  Drafty
//
//  Created by Steve Streza on 7/11/12.
//  Copyright (c) 2012 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ETWAccount;

@interface ETWTwitterApp : NSObject

@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *consumerSecret;

@property (nonatomic, readonly) NSSet *accounts;

@property (nonatomic, readonly) NSOperationQueue *operationQueue;

-(void)loginWithCallbackURL:(NSURL *)url handler:(void (^)(ETWAccount *))handler;

-(void)addAccount:(ETWAccount *)account;

// advanced use only
@property (nonatomic, strong) Class accountClass; // defaults to ETWAccount, override in subclasses if needed
@property (nonatomic, strong) Class requestClass; // defaults to ETWRequest, override in subclasses if needed

@end
