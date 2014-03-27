//
//  HcByteSize.m
//
//  Copyright (c) 2014 Harsh Coast.
//
#import "HcByteValue.h"


#define HC_BYTE_SLIDER_MIN 0.0
#define HC_BYTE_SLIDER_MAX 100.0


@implementation HcByteValue


- (id)init
{
    self = [super init];
    if (self) {
        _bytes = 0;
        _minimumBytes = 0;
        _maximumBytes = 10L * 1000L * 1000L * 1000L; // 10 GB
        [self setRelativeValueFromBytes];
    }
    return self;
}


- (id)initWith:(HcByteValue*)byteValue
{
    self = [super init];
    if (self) {
        _bytes = byteValue->_bytes;
        _minimumBytes = byteValue->_minimumBytes;
        _maximumBytes = byteValue->_maximumBytes;
        _relativeValue = byteValue->_relativeValue;
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _bytes = [aDecoder decodeIntegerForKey:@"bytes"];
        _minimumBytes = [aDecoder decodeIntegerForKey:@"minimumBytes"];
        _maximumBytes = [aDecoder decodeIntegerForKey:@"maximumBytes"];
        [self setRelativeValueFromBytes];
    }
    return self;
}


+ (NSArray*)observedPaths:(NSString*)prefix
{
    return @[[NSString stringWithFormat:@"%@.bytes", prefix]];
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_bytes forKey:@"bytes"];
    [aCoder encodeInteger:_minimumBytes forKey:@"minimumBytes"];
    [aCoder encodeInteger:_maximumBytes forKey:@"maximumBytes"];
}


+ (BOOL)supportsSecureCoding
{
    return YES;
}


- (id)copyWithZone:(NSZone *)zone
{
    return [[HcByteValue alloc] initWith:self];
}


+ (BOOL)automaticallyNotifiesObserversOfBytes
{
    return NO;
}


- (void)setBytes:(NSInteger)byteValue
{
    // Limit the value
    if (byteValue > _maximumBytes) {
        byteValue = _maximumBytes;
    }
    if (byteValue < _minimumBytes) {
        byteValue = _minimumBytes;
    }
    
    if (_bytes != byteValue) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(bytes))];
        _bytes = byteValue;
        [self setRelativeValueFromBytes];
        [self didChangeValueForKey:NSStringFromSelector(@selector(bytes))];
    }
}


+ (BOOL)automaticallyNotifiesObserversOfRelativeValue
{
    return NO;
}


- (void)setRelativeValue:(double)relativeValue
{
    if (relativeValue < HC_BYTE_SLIDER_MIN) {
        relativeValue = HC_BYTE_SLIDER_MIN;
    }
    if (relativeValue > HC_BYTE_SLIDER_MAX) {
        relativeValue = HC_BYTE_SLIDER_MAX;
    }
    if (_relativeValue != relativeValue) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(relativeValue))];
        _relativeValue = relativeValue;
        [self setBytesFromRelativeValue];
        [self didChangeValueForKey:NSStringFromSelector(@selector(relativeValue))];
    }
}


- (void)setRelativeValueFromBytes
{
    double newRelativeValue;
    if ((_maximumBytes - _minimumBytes) <= 0) {
        newRelativeValue = 0.0;
    } else {
        double rangeLog = log10((double)(_bytes - _minimumBytes));
        if (rangeLog < 0.0) {
            rangeLog = 0.0;
        }
        const double maxLog = log10(_maximumBytes);
        double minLog = log10(_minimumBytes);
        if (minLog < 0.0) { // Clip to zero.
            minLog = 0.0;
        }
        const double relative = ((rangeLog - minLog) / (maxLog - minLog) * (HC_BYTE_SLIDER_MAX - HC_BYTE_SLIDER_MIN)) + HC_BYTE_SLIDER_MIN;
        newRelativeValue = relative;
    }
    if (newRelativeValue != _relativeValue) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(relativeValue))];
        _relativeValue = newRelativeValue;
        [self didChangeValueForKey:NSStringFromSelector(@selector(relativeValue))];
    }
}


- (void)setBytesFromRelativeValue
{
    NSInteger newBytes = 0;
    if ((_maximumBytes - _minimumBytes) <= 0) {
        newBytes = _minimumBytes;
    } else {
        // handle the zero case
        if (_relativeValue == 0.0) {
            newBytes = _minimumBytes;
        } else {
            const double factor = (_relativeValue - HC_BYTE_SLIDER_MIN) / (HC_BYTE_SLIDER_MAX - HC_BYTE_SLIDER_MIN);
            const double maxLog = log10(_maximumBytes);
            double minLog = log10(_minimumBytes);
            if (minLog < 0.0) { // Clip to zero.
                minLog = 0.0;
            }
            newBytes = (NSInteger)(pow(10.0, (factor * (maxLog-minLog) + minLog)));
            // Make sure we don't leave the range on computing fuzziness.
            if (newBytes > _maximumBytes) {
                newBytes = _maximumBytes;
            }
        }
    }
    if (newBytes != _bytes) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(bytes))];
        _bytes = newBytes;
        [self didChangeValueForKey:NSStringFromSelector(@selector(bytes))];
    }
}


+ (HcByteValue*)byteSize
{
    return [[HcByteValue alloc] init];
}


@end
