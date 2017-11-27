/// ABBYY® Real-Time Recognition SDK 1 © 2016 ABBYY Production LLC.
/// ABBYY is either a registered trademark or a trademark of ABBYY Software Ltd.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// Extended information about the character's formatting.
@interface RTRCharInfo : NSObject

/// The bounding rectangle.
@property (nonatomic, assign, readonly) CGRect rect;
/// Four vertices of the bounding quadrangle.
@property (nonatomic, strong, readonly) NSArray* quadrangle;
/// The color of the symbol.
@property (nonatomic, assign, readonly) NSInteger foregroundColor;
/// The color of the background.
@property (nonatomic, assign, readonly) NSInteger backgroundColor;

@property (nonatomic, assign, readonly) BOOL isItalic;
@property (nonatomic, assign, readonly) BOOL isBold;
@property (nonatomic, assign, readonly) BOOL isUnderlined;
@property (nonatomic, assign, readonly) BOOL isStrikethrough;
@property (nonatomic, assign, readonly) BOOL isSmallcaps;
@property (nonatomic, assign, readonly) BOOL isSuperscript;
@property (nonatomic, assign, readonly) BOOL isUncertain;

- (instancetype)init __unavailable;

@end

#pragma mark - RTRTextLine

/// A line of recognized (translated) text; the location and additional information are also available.
@interface RTRTextLine : NSObject

/// The recognized (translated) text.
@property (nonatomic, strong, readonly) NSString* text;
/// The bounding rectangle.
@property (nonatomic, assign, readonly) CGRect rect;
/// Four vertices of the bounding quadrangle.
@property (nonatomic, strong, readonly) NSArray* quadrangle;
/// Additional information about the characters (may be nil).
@property (nonatomic, strong, readonly) NSArray* charsInfo;

- (instancetype)init __unavailable;

@end

#pragma mark - RTRTextBlock

/// The RTRTextBlock is a collection of lines of recognized text.
@interface RTRTextBlock : NSObject

/// Lines of recognized text.
@property (nonatomic, strong, readonly) NSArray<RTRTextLine*>* textLines;

- (instancetype)init __unavailable;

@end
