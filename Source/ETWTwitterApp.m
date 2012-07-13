//
//  ETWTwitterApp.m
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

#import "ETWTwitterApp.h"
#import "ETWRequest.h"
#import "ETWAccount.h"

#define ETWAPIOAuthRoot @"http://api.twitter.com/oauth/"
#define ETWAPIRoot @"http://api.twitter.com/1/"
#define ETWAPI(path) ((NSString *)(ETWAPIRoot path))
#define ETWAPIOAuth(path) ((NSString *)(ETWAPIOAuthRoot path))

@interface ETWTwitterApp ()

@property (nonatomic, readwrite) NSSet *accounts;

@end

@implementation ETWTwitterApp

-(id)init{
    if(self = [super init]){
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(void)loginWithCallbackURL:(NSURL *)url handler:(void (^)(ETWAccount *))handler{
    ETWRequest *request = [[self.requestClass alloc] init];
    request.method = ETWRequestMethodPOST;
    request.type = ETWRequestTypeOAuth;
    request.APIMethod = @"request_token";
    request.app = self;
    request.parameters = @{ @"oauth_callback" : @"oob" };
    
    __weak NSOperationQueue *opQueue = self.operationQueue;
    
    [request performOnQueue:opQueue handler:^(NSDictionary *response, NSError *error, ETWRequest *request) {
        //        NSLog(@"Create account! %@", response);
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", response[@"oauth_token"]]];
        NSLog(@"Authorize: %@",url);
        
        int pin = 0;
        // break here and set pin
        
        ETWRequest *accessTokenRequest = [[self.requestClass alloc] init];
        accessTokenRequest.method = ETWRequestMethodPOST;
        accessTokenRequest.type = ETWRequestTypeOAuth;
        accessTokenRequest.APIMethod = @"access_token";
        accessTokenRequest.app = self;
        accessTokenRequest.parameters = @{ @"oauth_verifier" : [NSString stringWithFormat:@"%i", pin], @"oauth_token" : response[@"oauth_token"] };
        [accessTokenRequest performOnQueue:opQueue handler:^(NSDictionary *response, NSError *error, ETWRequest *request) {
            NSLog(@"Access token! %@", response);
            if(error){
                NSLog(@"Error obtaining access token: %@", error);
                handler(nil);
                return;
            }
            
            ETWAccount *account = [[self.accountClass alloc] initWithTokenData:response];
            [self addAccount:account];
            handler(account);
        }];
        
    }];
}

-(void)addAccount:(ETWAccount *)account{
    account.app = self;
    [self willChangeValueForKey:@"accounts"];
    if(!self.accounts){
        self.accounts = [NSMutableSet set];
    }
    
    [(NSMutableSet *)(self.accounts) addObject:account];
    [self  didChangeValueForKey:@"accounts"];    
}

-(Class)accountClass{
    if(!_accountClass){
        _accountClass = [ETWAccount class];
    }
    return _accountClass;
}

-(Class)requestClass{
    if(!_requestClass){
        _requestClass = [ETWRequest class];
    }
    return _requestClass;
}

@end
