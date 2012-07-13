//
//  ETWRequest.h
//  Drafty
//
//  Created by Steve Streza on 7/11/12.
//  Copyright (c) 2012 Mustacheware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ETWTwitterApp;
@class ETWAccount;

typedef enum {
    ETWRequestMethodGET,
    ETWRequestMethodPOST
} ETWRequestMethod;

typedef enum {
    ETWRequestTypeREST,
    ETWRequestTypeOAuth
} ETWRequestType;

@interface ETWRequest : NSObject

@property (nonatomic, retain) ETWTwitterApp *app;
@property (nonatomic, retain) ETWAccount *account;

@property (nonatomic, assign, getter=isSecure) BOOL secure;
@property (nonatomic, assign) ETWRequestType type; // defaults to REST
@property (nonatomic, assign) ETWRequestMethod method; // defaults to GET

@property (nonatomic, readonly, retain) NSString *nonce;
@property (nonatomic, readonly, retain) NSDate *timestamp;

@property (nonatomic, retain) NSString *APIMethod;
@property (nonatomic, retain) NSDictionary *parameters;

-(void)performOnQueue:(NSOperationQueue *)queue handler:(void (^)(NSDictionary *response, NSError *error, ETWRequest *request))handler;

+(NSString *)newNonce;
+(NSString *)encodeValue:(NSString *)value;

@end
