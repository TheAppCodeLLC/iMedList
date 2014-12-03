//
//  Reminder.h
//  iMedList
//
//  Created by kent franks on 12/2/14.
//  Copyright (c) 2014 TheAppCodeLLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Reminder : NSManagedObject

@property (nonatomic, retain) NSString * customMessage;
@property (nonatomic, retain) NSDate * fireDate;
@property (nonatomic, retain) NSString * frequency;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * notes;

@end
