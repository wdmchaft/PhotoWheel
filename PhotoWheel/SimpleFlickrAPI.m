//
//  SimpleFlickrAPI.m
//  PhotoWheel
//
//  Created by Kirby Turner on 10/2/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "SimpleFlickrAPI.h"
#import <Foundation/NSJSONSerialization.h>

#define flickrBaseURL @"http://api.flickr.com/services/rest/?format=json&"

#define flickrParamMethod @"method"
#define flickrParamAppKey @"api_key"
#define flickrParamUsername @"username"
#define flickrParamUserid @"user_id"
#define flickrParamPhotoSetId @"photoset_id"
#define flickrParamExtras @"extras"
#define flickrParamText @"text"

#define flickrMethodFindByUsername @"flickr.people.findByUsername"
#define flickrMethodGetPhotoSetList @"flickr.photosets.getList"
#define flickrMethodGetPhotosWithPhotoSetId @"flickr.photosets.getPhotos"
#define flickrMethodSearchPhotos @"flickr.photos.search"


@interface SimpleFlickrAPI ()
- (id)flickrJSONSWithParameters:(NSDictionary *)parameters;
@end

@implementation SimpleFlickrAPI

- (NSArray *)photosWithSearchString:(NSString *)string
{
   NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                               flickrMethodSearchPhotos, flickrParamMethod, 
                               flickrAPIKey, flickrParamAppKey, 
                               string, flickrParamText, 
                               @"url_t, url_s, url_m, url_sq", flickrParamExtras, 
                               nil];
   NSDictionary *json = [self flickrJSONSWithParameters:parameters];
   NSDictionary *photoset = [json objectForKey:@"photos"];
   NSArray *photos = [photoset objectForKey:@"photo"];
   return photos;
}

- (NSString *)userIdForUsername:(NSString *)username
{
   NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                               flickrMethodFindByUsername, flickrParamMethod, 
                               flickrAPIKey, flickrParamAppKey, 
                               username, flickrParamUsername, 
                               nil];
   NSDictionary *json = [self flickrJSONSWithParameters:parameters];
   NSDictionary *userDict = [json objectForKey:@"user"];
   NSString *nsid = [userDict objectForKey:@"nsid"];
   
   return nsid;
}

- (NSArray *)photoSetListWithUserId:(NSString *)userId
{
   NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                               flickrMethodGetPhotoSetList, flickrParamMethod, 
                               flickrAPIKey, flickrParamAppKey, 
                               userId, flickrParamUserid, 
                               nil];
   NSDictionary *json = [self flickrJSONSWithParameters:parameters];
   NSDictionary *photosets = [json objectForKey:@"photosets"];
   NSArray *photoSet = [photosets objectForKey:@"photoset"];
   return photoSet;
}

- (NSArray *)photosWithPhotoSetId:(NSString *)photoSetId
{
   NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                         flickrMethodGetPhotosWithPhotoSetId, flickrParamMethod, 
                         flickrAPIKey, flickrParamAppKey, 
                         photoSetId, flickrParamPhotoSetId, 
                         @"url_t, url_s, url_m, url_sq", flickrParamExtras, 
                         nil];
   NSDictionary *json = [self flickrJSONSWithParameters:parameters];
   NSDictionary *photoset = [json objectForKey:@"photoset"];
   NSArray *photos = [photoset objectForKey:@"photo"];
   return photos;
}

#pragma mark - Helper methods

- (NSData *)fetchResponseWithURL:(NSURL *)URL
{
   NSURLRequest *request = [NSURLRequest requestWithURL:URL];
   NSURLResponse *response = nil;
   NSError *error = nil;
   NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
   ZAssert(data, @"NSURLConnection error: %@\n%@", [error localizedDescription], [error userInfo]);
   return data;
}

- (NSURL *)buildFlickrURLWithParameters:(NSDictionary *)parameters
{
   NSMutableString *URLString = [[NSMutableString alloc] initWithString:flickrBaseURL];
   for (id key in parameters) {
      NSString *value = [parameters objectForKey:key];
      [URLString appendFormat:@"%@=%@&", key, [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   }
   NSURL *URL = [NSURL URLWithString:URLString];
   return URL;
}

- (NSString *)stringWithData:(NSData *)data
{
   NSString *result = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
   return result;
}

- (NSString *)stringByRemovingFlickrJavaScript:(NSData *)data
{
   // Flickr returns a JavaScript function containing the JSON data.
   // We need to strip out the JavaScript part before we can parse
   // the JSON data. Ex: jsonFlickrApi(JSON-DATA-HERE).
   
   NSMutableString *string = [[self stringWithData:data] mutableCopy];
   NSRange range = NSMakeRange(0, [@"jsonFlickrApi(" length]);
   [string deleteCharactersInRange:range];
   range = NSMakeRange([string length] - 1, 1);
   [string deleteCharactersInRange:range];
   
   return string;
}

- (id)flickrJSONSWithParameters:(NSDictionary *)parameters
{
   NSURL *URL = [self buildFlickrURLWithParameters:parameters];
   NSData *data = [self fetchResponseWithURL:URL];
   NSString *string = [self stringByRemovingFlickrJavaScript:data];
   NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
   
   DLog(@"flickr json: %@", string);
   
   NSError *error = nil;
   id json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
   ZAssert(json, @"json error: %@\n%@", [error localizedDescription], [error userInfo]);
   return json;
}

@end
