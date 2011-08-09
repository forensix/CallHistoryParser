// -----------------------------------------------------------------------------
//  CallHistoryParser.h
//
//  Created by Manuel Gebele on 09.08.11.
// -----------------------------------------------------------------------------

#import "CallHistoryParser.h"

#import <sqlite3.h>

#define CALL_HISTORY_DB @"/private/var/wireless/Library/CallHistory/call_history.db"

@implementation CallHistoryParser


+ (sqlite3 *)callHistoryDatabase
{
    sqlite3 *database;
    
    if (sqlite3_open([CALL_HISTORY_DB UTF8String], &database)
        == SQLITE_OK)
    {
        return database;
    }
    
    return NULL;
}


+ (NSString *)formattedByteStringForValue:(double)value
{
    int multiplyFactor = 0;
    
    NSArray *unitTokens
    = [NSArray arrayWithObjects:@"KB", @"MB", @"GB", nil];
    
    while (value > 1024)
    {
        value /= 1024.0;
        multiplyFactor++;
    }
    
    return
    [NSString stringWithFormat:@"%d.0 %@",
     (int)value, /* round it down as it preferences.app does */
     [unitTokens objectAtIndex:multiplyFactor]];
}


+ (NSString *)formattedTimeStringForValue:(double)value
{
    NSDateComponents *components
    = [[[NSDateComponents alloc] init] autorelease];
    
    [components setSecond:value];
    
    NSCalendar *calendar
    = [[[NSCalendar alloc]
        initWithCalendarIdentifier:NSGregorianCalendar]
       autorelease];
    
    NSDate *date
    = [calendar dateFromComponents:components];
    
    NSDateComponents *resultComponents
    = [calendar components:NSHourCalendarUnit
       | NSMinuteCalendarUnit
       | NSSecondCalendarUnit
                  fromDate:date];
    
    return
    [NSString stringWithFormat:@"%02d:%02d:%02d",
     [resultComponents hour],
     [resultComponents minute],
     [resultComponents second]];    
}


+ (double)cellularDataBytesForStatement:(const char *)statement
{
    double bytes = -1.0;
    sqlite3 *database = [self callHistoryDatabase];
    
    if (!database)
    {
        return bytes;
    }
    
    sqlite3_stmt *sqlStatement;
    if (sqlite3_prepare_v2(
        database,statement,
        -1,
        &sqlStatement,
        NULL) == SQLITE_OK)
    {
        while(sqlite3_step(sqlStatement) == SQLITE_ROW)
        {
            bytes
            = sqlite3_column_double(sqlStatement, 0);
            
            if (bytes > .0)
            {
                bytes++;
            }
        }
    }
    
    return bytes;
}


+ (double)cellularDataBytesReceived
{
    return [self cellularDataBytesForStatement:
            "SELECT bytes_rcvd FROM data WHERE ROWID == 1"]; // pdp_ip0
}


+ (double)cellularDataBytesSent
{
    return [self cellularDataBytesForStatement:
            "SELECT bytes_sent FROM data WHERE ROWID == 1"]; // pdp_ip0
}


+ (NSString *)cellularDataBytesSentFormatted
{    
    double bytesSent = [self cellularDataBytesSent];
    
    if (bytesSent < .0)
    {
        return @"N/A";
    }
    else if (bytesSent == .0f)
    {
        // Make it as in preferences.app
        return @"0 Byte";
    }
    
    return [self formattedByteStringForValue:bytesSent];
}


+ (NSString *)cellularDataBytesReceivedFormatted
{    
    double bytesRcvd = [self cellularDataBytesReceived];
    
    if (bytesRcvd < .0)
    {
        return @"N/A";
    }
    else if (bytesRcvd == .0f)
    {
        // Make it as in preferences.app
        return @"0 Byte";
    }
    
    return [self formattedByteStringForValue:bytesRcvd];
}


+ (NSInteger)numberOfCallsForStatement:(const char *)statement
{
    NSInteger calls = 0;
    sqlite3 *database = [self callHistoryDatabase];
    
    if (!database)
    {
        return calls;
    }
    
    sqlite3_stmt *sqlStatement;
    if (sqlite3_prepare_v2(
        database,statement,
        -1,
        &sqlStatement,
        NULL) == SQLITE_OK)
    {
        while(sqlite3_step(sqlStatement) == SQLITE_ROW)
        {
            calls++;
        }
    }
    
    return calls;
}


+ (NSInteger)numberOfOutgoingCalls
{
    return
    [self numberOfCallsForStatement:
     "SELECT flags FROM call WHERE flags == 5"];
}


+ (NSInteger)numberOfIncomingCalls
{
    return
    [self numberOfCallsForStatement:
     "SELECT flags FROM call WHERE flags == 4"];
}


+ (NSInteger)callTimeForStatement:(const char *)statement
{
    NSInteger callTime = 0;
    sqlite3 *database = [self callHistoryDatabase];
    
    if (!database)
    {
        return callTime;
    }
    
    sqlite3_stmt *sqlStatement;
    if (sqlite3_prepare_v2(
        database,statement,
        -1,
        &sqlStatement,
        NULL) == SQLITE_OK)
    {
        while(sqlite3_step(sqlStatement) == SQLITE_ROW)
        {
            int tmpCallTime
            = sqlite3_column_int(sqlStatement, 0);
            callTime += tmpCallTime;
        }
    }
    
    return callTime;
}


+ (NSInteger)callTimeInSeconds
{
    return
    [self callTimeForStatement:
     "SELECT duration FROM call"];
}


+ (NSInteger)callTimeInSecondsForPhoneNumber:(NSString *)phoneNumber
{
    if (!phoneNumber)
    {
        return 0;
    }
    
    NSString *statement
    = [NSString stringWithFormat:@"SELECT duration FROM call WHERE address LIKE '%@'",
       phoneNumber];
    
    return
    [self callTimeForStatement:
     [statement UTF8String]];
}


+ (NSString *)callTimeFormattedForPhoneNumber:(NSString *)phoneNumber
{
    NSInteger callTimeInSeconds
    = [self callTimeInSecondsForPhoneNumber:phoneNumber];
    
    return [self formattedTimeStringForValue:callTimeInSeconds];
}


+ (NSString *)callTimeFormatted
{
    NSInteger callTimeInSeconds
    = [self callTimeInSeconds];

    return [self formattedTimeStringForValue:callTimeInSeconds];
}

@end
