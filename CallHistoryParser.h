// -----------------------------------------------------------------------------
//  CallHistoryParser.h
//
//  Created by Manuel Gebele on 09.08.11.
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface CallHistoryParser : NSObject

+ (double)cellularDataBytesSent;
+ (double)cellularDataBytesReceived;

+ (NSString *)cellularDataBytesSentFormatted;
+ (NSString *)cellularDataBytesReceivedFormatted;

+ (NSInteger)numberOfOutgoingCalls;
+ (NSInteger)numberOfIncomingCalls;

+ (NSInteger)callTimeInSeconds;
+ (NSString *)callTimeFormatted;
+ (NSInteger)callTimeInSecondsForPhoneNumber:(NSString *)phoneNumber;
+ (NSString *)callTimeFormattedForPhoneNumber:(NSString *)phoneNumber;

@end
