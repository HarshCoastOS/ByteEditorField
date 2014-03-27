//
//  HcByteTextField.m
//
//  Copyright (c) 2014 Harsh Coast.
//
#import "HcByteTextField.h"


#import "HcByteValue.h"
#import "HcByteValueViewController.h"


@interface HcByteTextFieldFormatter : NSFormatter

@end


@implementation HcByteTextFieldFormatter {
    NSRegularExpression *_reByte;
}


- (id)init
{
    self = [super init];
    if (self) {
        _reByte = [NSRegularExpression regularExpressionWithPattern:@"^(?:\\d{0,16}|\\d{1,16}(?:\\.\\d*)? ?|\\d{1,16}(?:\\.\\d*)? ?(?:[kmg]b?)|\\d{1,16} ?(?:b|by|byt|bytes?))$"
                                                            options:NSRegularExpressionCaseInsensitive
                                                              error:nil];
    }
    return self;
}


- (NSString *)stringForObjectValue:(id)obj
{
    return obj;
}


- (BOOL)getObjectValue:(out __autoreleasing id *)obj forString:(NSString *)string errorDescription:(out NSString *__autoreleasing *)error
{
    *obj = string;
    return YES;
}


- (BOOL)isPartialStringValid:(NSString *__autoreleasing *)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString *__autoreleasing *)error
{
    NSString *text = *partialStringPtr;
    NSRange rangeOfFirstMatch = [_reByte rangeOfFirstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
    if (rangeOfFirstMatch.location == NSNotFound) {
        return NO;
    }
    
    return YES;
}


@end


@implementation HcByteTextField {
    NSByteCountFormatter *_byteCountFormatter;
    HcByteValueViewController *_byteValueViewController;
    NSPopover *_byteValuePopover;
    NSTimer *_hidePopoverTimer;
    NSRegularExpression *_reByteValue;
    BOOL _blockTextUpdate;
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initByteTextField];
    }
    return self;
}


- (void)awakeFromNib
{
    [self initByteTextField];
}


- (void)dealloc
{
    // Remove the all observers
    [self.window removeObserver:self forKeyPath:NSStringFromSelector(@selector(firstResponder))];
    [_editedByteValue removeObserver:self forKeyPath:NSStringFromSelector(@selector(bytes))];
}


- (void)initByteTextField
{
    // Make right aligned
    [self setAlignment:NSRightTextAlignment];
    
    // Create the formatter to limit the characters to enter in the text field.
    _byteCountFormatter = [[NSByteCountFormatter alloc] init];
    [self setFormatter:[[HcByteTextFieldFormatter alloc] init]];
    
    // Create the popup
    _byteValueViewController = [[HcByteValueViewController alloc] init];
    _byteValuePopover = [[NSPopover alloc] init];
    _byteValuePopover.contentViewController = _byteValueViewController;
    _byteValueViewController.owner = _byteValuePopover;
    
    // The regexp to convert the text into a byte value
    _reByteValue = [NSRegularExpression regularExpressionWithPattern:@"^(\\d{1,16}(?:\\.\\d*)?) ?([kmg]b|bytes?)?$" options:NSRegularExpressionCaseInsensitive error:nil];
}


- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    
    // Watch the current furst responder
    [self.window addObserver:self forKeyPath:NSStringFromSelector(@selector(firstResponder)) options:0 context:NULL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(firstResponder))]) {
        // Trigger the timer.
        [_hidePopoverTimer invalidate];
        _hidePopoverTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(onHidePopoverTimer:) userInfo:nil repeats:NO];
    } else if (object == _editedByteValue && [keyPath isEqualToString:NSStringFromSelector(@selector(bytes))]) {
        if (!_blockTextUpdate) {
            [self updateTextFromByteValue];
        }
    }
}


- (void)onHidePopoverTimer:(NSTimer*)timer
{
    // Check if we have to hide the popover
    NSResponder *firstResponder = self.window.firstResponder;
    if (_byteValuePopover.isShown && [firstResponder isKindOfClass:[NSView class]]) {
        NSView *view = (NSView*)firstResponder;
        if (![view isDescendantOf:_byteValueViewController.view] && ![view isDescendantOf:self]) {
            [_byteValuePopover performClose:nil];
        }
    }
}


- (void)setEditedByteValue:(HcByteValue *)editedByteValue
{
    if (_editedByteValue != editedByteValue) {
        [_editedByteValue removeObserver:self forKeyPath:NSStringFromSelector(@selector(bytes))];
        _editedByteValue = editedByteValue;
        _byteValueViewController.editedByteValue = editedByteValue;
        [self updateTextFromByteValue];
        [_editedByteValue addObserver:self forKeyPath:NSStringFromSelector(@selector(bytes)) options:0 context:NULL];
    }
}


- (void)updateTextFromByteValue
{
    [self setStringValue:[_byteCountFormatter stringFromByteCount:_editedByteValue.bytes]];
}


- (BOOL)becomeFirstResponder
{
    BOOL ok = [super becomeFirstResponder];
    if (!_byteValuePopover.isShown) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_byteValuePopover showRelativeToRect:self.bounds ofView:self preferredEdge:NSMinYEdge];
            [self.window makeFirstResponder:self];
            [self selectText:nil];
        });
    }
    return ok;
}


/// Converts a text into a byte value
///
/// @param text The formatted text
/// @return The byte value or -1 if the value makes no sense.
///
- (NSInteger)textToByteValue:(NSString*)text
{
    NSParameterAssert(text != nil);
    NSTextCheckingResult *match = [_reByteValue firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
    if (!match) {
        return -1;
    } else {
        double value = [[text substringWithRange:[match rangeAtIndex:1]] doubleValue];
        NSString *suffix = nil;
        if ([match rangeAtIndex:2].location != NSNotFound) {
            suffix = [[text substringWithRange:[match rangeAtIndex:2]] lowercaseString];
        }
        if ([suffix isEqualToString:@"kb"]) {
            value *= 1000.0;
        } else if ([suffix isEqualToString:@"mb"]) {
            value *= 1000000.0;
        } else if ([suffix isEqualToString:@"gb"]) {
            value *= 1000000000.0;
        }
        if (value > (double)NSIntegerMax) {
            return NSIntegerMax;
        }
        return (NSInteger)(floor(value));
    }
}


- (void)textDidChange:(NSNotification *)notification
{
    NSInteger bytes = [self textToByteValue:[self stringValue]];
    if (bytes >= 0) {
        _blockTextUpdate = YES;
        _editedByteValue.bytes = bytes;
        _blockTextUpdate = NO;
    }
    if (bytes > _editedByteValue.maximumBytes || bytes < _editedByteValue.minimumBytes) {
        [self setTextColor:[NSColor redColor]];
    } else {
        [self setTextColor:[NSColor textColor]];
    }
    [super textDidChange:notification];
}


- (void)textDidEndEditing:(NSNotification *)notification
{
    NSInteger bytes = [self textToByteValue:[self stringValue]];
    if (bytes >= 0) {
        _blockTextUpdate = YES;
        _editedByteValue.bytes = bytes;
        _blockTextUpdate = NO;
    }
    [self updateTextFromByteValue];
    [self setTextColor:[NSColor textColor]];
    [super textDidEndEditing:notification];
}


@end
