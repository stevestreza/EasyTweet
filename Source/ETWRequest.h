//
//  ETWRequest.h
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
