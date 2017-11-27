/// ABBYY® Real-Time Recognition SDK 1 © 2016 ABBYY Production LLC.
/// ABBYY is either a registered trademark or a trademark of ABBYY Software Ltd.

#import <Foundation/Foundation.h>

/// Represents the data scheme applied to the recognized frame.
@interface RTRDataScheme : NSObject

/// The scheme identifier.
@property (nonatomic, strong, readonly ) NSString* id;
/// The human-readable name of the scheme.
@property (nonatomic, strong, readonly ) NSString* name;

- (instancetype)init __unavailable;

@end
