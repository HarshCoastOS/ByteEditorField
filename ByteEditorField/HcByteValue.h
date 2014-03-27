//
//  HcByteSize.h
//
//  Copyright (c) 2014 Harsh Coast.
//


/// Represents a byte value with secondary values for the user interface
///
@interface HcByteValue : NSObject <NSCopying, NSSecureCoding>


/// The actual number of bytes
///
@property (assign, nonatomic) NSInteger bytes;

/// The maximum number of bytes
///
@property (assign, nonatomic) NSInteger maximumBytes;

/// The minimum number of bytes
///
@property (assign, nonatomic) NSInteger minimumBytes;

/// A relative value for a slider.
///
/// This value is always between 0.0 and 100.0
///
@property (assign, nonatomic) double relativeValue;

/// Initialize the object with default values
///
/// 0, in 0 - 10 GB.
///
- (id)init;

/// Create a default object.
///
+ (HcByteValue*)byteSize;

/// Get the observed paths for this object
///
+ (NSArray*)observedPaths:(NSString*)prefix;


@end
