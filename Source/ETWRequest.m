    //
//  ETWRequest.m
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

#import "ETWRequest.h"

#import "ETWTwitterApp.h"
#import "ETWAccount.h"

#import <CommonCrypto/CommonCrypto.h>
#import "NSData+Base64.h"

@implementation ETWRequest

@synthesize nonce, timestamp;

-(NSString *)nonce{
    if(!nonce){
        nonce = [[self class] newNonce];
    }
    return nonce;
}

-(NSDate *)timestamp{
    if(!timestamp){
        timestamp = [NSDate date];
//        timestamp = [NSDate dateWithTimeIntervalSince1970:1342082682];
    }
    return timestamp;
}

-(void)performOnQueue:(NSOperationQueue *)queue handler:(void (^)(NSDictionary *response, NSError *error, ETWRequest *request))handler{
    __weak ETWRequest *this = self;
    NSMutableURLRequest *request = [self _URLRequest];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error){
            handler(nil, error, this);
            return;
        }
        
        NSMutableDictionary *responseDictionary = nil;
        
        NSString *contentType = [[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Content-Type"];
        if([contentType rangeOfString:@"text/html"].location != NSNotFound){
            responseDictionary = [NSMutableDictionary dictionary];

            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [[responseString componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSArray *componentPieces = [obj componentsSeparatedByString:@"="];
                NSString *key = componentPieces[0];
                NSString *value = componentPieces[1];
                responseDictionary[key] = value;
            }];
        }else if([contentType rangeOfString:@"application/json"].location != NSNotFound){
            responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        
        NSLog(@"Response! %@", responseDictionary);
        handler(responseDictionary, error, this);
    }];
}

#pragma mark Class Methods

+(NSString *)newNonce{
//    return @"21c7e0ebd8f33effb00bec7177ddcb56";
    return [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

+(NSString *)encodeValue:(NSString *)value{
    NSString *result = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)value,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
	return result;
}

+(NSString *)decodeValue:(NSString *)value{
    NSString *result = (__bridge NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						   (CFStringRef)value,
																						   CFSTR(""),
																						   kCFStringEncodingUTF8);
	return result;
}

#pragma mark Private Support APIs

-(NSMutableURLRequest *)_URLRequest{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self _fullURL]];
    request.HTTPMethod = [self _HTTPMethod];
    [request addValue:[self _OAuthHeader] forHTTPHeaderField:@"Authorization"];
    
    if(self.method == ETWRequestMethodPOST){
        NSMutableArray *postPieces = [NSMutableArray array];
        [self.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if([key isEqualToString:@"oauth_callback"]) return;
            
            [postPieces addObject:[NSString stringWithFormat:@"%@=%@", key, [[self class] encodeValue:obj]]];
        }];
        
        NSString *postBody = [postPieces componentsJoinedByString:@"&"];
        if(postBody && postBody.length > 0){
            [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    return request;
}

-(NSString *)_hostname{
    return @"api.twitter.com";
}

-(NSString *)_HTTPMethod{
    switch (self.method) {
        case ETWRequestMethodPOST:
            return @"POST";
            break;
        case ETWRequestMethodGET:
        default:
            return @"GET";
            break;
    }
}

-(NSURL *)_baseURL{
    NSURL *url = [NSURL URLWithString:[self _basePath]];
    return url;
}

-(NSString *)_basePath{
    return [@[
            (self.secure ? @"https://" : @"http://"),
            [self _hostname],
            (self.type == ETWRequestTypeOAuth ? @"/oauth/" : @"/1/"),
            self.APIMethod
            ] componentsJoinedByString:@""];
}

-(NSURL *)_fullURL{
    NSURL *baseURL = [self _baseURL];
    if(self.method == ETWRequestMethodPOST){
        return baseURL;
    }
    
    if(self.parameters.count){
        NSMutableArray *parameterComponents = [NSMutableArray array];
        [self.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [parameterComponents addObject:[NSString stringWithFormat:@"%@=%@", key, [[self class] encodeValue:obj]]];
        }];
        baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", baseURL.absoluteString, [parameterComponents componentsJoinedByString:@"&"]]];
    }
    
    return baseURL;
}

#pragma mark Private OAuth Methods

-(NSString *)_OAuthSigningString{
    NSString *httpMethod = [self _HTTPMethod];
    NSString *baseURLPath = [self _basePath];

    NSMutableDictionary *parameters = [(self.parameters ? self.parameters : [NSDictionary dictionary]) mutableCopy];
    
    // OAuth parameters
    [[self _OAuthParameters] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        parameters[key] = obj;
    }];
    
    // build the parameter string
    NSArray *sortedKeys = [parameters.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *parameterComponents = [@[] mutableCopy];
    [sortedKeys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
        NSString *value = parameters[key];
        [parameterComponents addObject:[[self class] encodeValue:[NSString stringWithFormat:@"%@=%@", key, value]]];
    }];
    NSString *parameterString = [parameterComponents componentsJoinedByString:@"%26"];
    
    NSString *baseString = [NSString stringWithFormat:@"%@&%@&%@", httpMethod.uppercaseString, [[self class] encodeValue:baseURLPath], parameterString];
    NSLog(@"OAuth signing string: %@",baseString);
    return baseString;
}

-(NSString *)_OAuthSignature{
    NSString *signatureBaseString = [self _OAuthSigningString];
    NSString *consumerSecret = (self.app.consumerSecret ? self.app.consumerSecret : @"");
    NSString *accessTokenSecret = (self.account.accessTokenSecret ? self.account.accessTokenSecret : @"");
    NSString *signingKey = [NSString stringWithFormat:@"%@&%@",[[self class] encodeValue:consumerSecret], [[self class] encodeValue:accessTokenSecret]];
    
    NSLog(@"OAuth signing key: %@",signingKey);
    
    const char *cSigningKey    = [signingKey          cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cSigningString = [signatureBaseString cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cSigningKey, strlen(cSigningKey), cSigningString, strlen(cSigningString), cHMAC);
    
    NSData *data = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *signature = [data base64EncodedString];
    
    NSLog(@"OAuth signature: %@", signature);
    return signature;
}

-(NSDictionary *)_OAuthParameters{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"oauth_nonce"] = self.nonce;
    parameters[@"oauth_signature_method"] = @"HMAC-SHA1";
    parameters[@"oauth_version"] = @"1.0";
    parameters[@"oauth_timestamp"] = [NSString stringWithFormat:@"%i", (int)([self.timestamp timeIntervalSince1970])];

    if(self.app && self.app.consumerKey){
        parameters[@"oauth_consumer_key"] = self.app.consumerKey;
    }
    
    if(self.account && self.account.accessTokenKey){
        parameters[@"oauth_token"] = self.account.accessTokenKey;
    }

    return parameters;
}

-(NSString *)_OAuthHeader{
    NSMutableDictionary *parameters = [[self _OAuthParameters] mutableCopy];
    parameters[@"oauth_signature"] = [self _OAuthSignature];
    if(self.parameters[@"oauth_callback"]){
        parameters[@"oauth_callback"] = self.parameters[@"oauth_callback"];
    }
    
    NSMutableArray *parameterPieces = [NSMutableArray array];
    [[parameters.allKeys sortedArrayUsingSelector:@selector(compare:)] enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
        NSString *obj = parameters[key];
        [parameterPieces addObject:[NSString stringWithFormat:@"%@=\"%@\"", key, [[self class] encodeValue:obj]]];
    }];
    
    NSString *header = [NSString stringWithFormat:@"OAuth %@", [parameterPieces componentsJoinedByString:@", "]];
    NSLog(@"OAuth header - Authorization: %@", header);
    return header;
}

@end
