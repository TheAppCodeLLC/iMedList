//
//  Med.h
//  iMedList
//
//  Created by kent franks on 12/2/14.
//  Copyright (c) 2014 TheAppCodeLLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Med : NSManagedObject

@property (nonatomic, retain) NSString * dose;
@property (nonatomic, retain) NSString * frequency;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;

@end
