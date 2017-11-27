/// ABBYY® Real-Time Recognition SDK 1 © 2016 ABBYY Production LLC.
/// ABBYY is either a registered trademark or a trademark of ABBYY Software Ltd.

#import <Foundation/Foundation.h>

@class RTRTextLine;

/// Field of recognized DataCapture scenario.
@interface RTRDataField : NSObject

/// Field Identifier.
@property (nonatomic, strong, readonly) NSString* id;
/// Extended localized (RU) field description.
@property (nonatomic, strong, readonly) NSString* name;
/// Recognized text value for field.
@property (nonatomic, strong, readonly) NSString* text;
/// Four vertices of the bounding quadrangle.
@property (nonatomic, strong, readonly) NSArray<NSValue*>* quadrangle;
/// In some cases the field contains several components, like for example passport number or last name.
@property (nonatomic, strong, readonly) NSArray<RTRTextLine*>* components;

- (instancetype)init __unavailable;

@end
