/// ABBYY® Real-Time Recognition SDK 1 © 2016 ABBYY Production LLC.
/// ABBYY is either a registered trademark or a trademark of ABBYY Software Ltd.

#import <AVFoundation/AVFoundation.h>

#pragma mark - RTRRecognitionService

/**
 * A background recognition service.
 */
@protocol RTRRecognitionService
@required

/**
 * Adds sample buffer for processing.
 *
 * @param sampleBuffer
 *      The buffer received from the camera in -captureOutput:didOutputSampleBuffer:fromConnection: callback method
 *      of AVCaptureVideoDataOutputSampleBufferDelegate object.
 *      Only kCVPixelFormatType_32BGRA pixel format is currently supported.
 *      Preferred session preset is AVCaptureSessionPreset1280x720.
 */
- (void)addSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 * Stops processing tasks, clears internal buffer container.
 */
- (void)stopTasks;

/**
 * Sets the area on the frame where the text is to be found.
 *
 * By default, no area of interest is selected.
 * The size of the area of interest affects performance and the speed of
 * convergence of the result. The best result is achieved when the area of interest does not
 * touch the boundaries of the frame but has a margin of at least half the size of a typical
 * printed character.
 *
 * @param areaOfInterest The rectangle specifying the area of interest in image coordinates. Pass CGRectZero for default value.
 */
- (void)setAreaOfInterest:(CGRect)areaOfInterest;

@end

#pragma mark - RTRTextCaptureService

/**
 * A background text recognition service.
 */
@protocol RTRTextCaptureService <RTRRecognitionService>

/**
 * Sets the languages to be used for recognition.
 *
 * Setting the correct languages for your text will improve
 * recognition accuracy. However, setting too many languages may slow down performance.
 *
 * @param recognitionLanguages The set of languages to be used for recognition.
 */
- (void)setRecognitionLanguages:(NSSet*)recognitionLanguages;

/**
 * Sets the name of the translation dictionary.
 *
 * By default, no translation dictionary is used. Translation dictionaries should be
 * put in the 'Translation' subfolder of the app bundle.
 *
 * @param dictionaryName The name of the translation dictionary. Set nil for default value.
 */
- (void)setTranslationDictionary:(NSString*)dictionaryName;

@end

#pragma mark - RTRDataCaptureService

/**
 * Signature for a callback field validation block.
 */
typedef BOOL (^RTRFieldPredicateBlock)(NSString* value);

/**
 * Describes a field which should be extracted by the data capture service.
 */
@protocol RTRDataFieldBuilder

/**
 * The field name.
 * Field name will be returned by the callback delegate methods.
 */
- (id<RTRDataFieldBuilder>)setName:(NSString*)name;

/**
 * A regular expression against which the field should be validated in the custom data capture scenario.
 */
- (id<RTRDataFieldBuilder>)setRegEx:(NSString*)regEx;

/**
 * Sets a user-defined validation block which will be used to verify the recognized field data.
 *
 * The validation block is called only after the data passes the regular expression check.
 * If no validation block is specified, the field is captured on the basis of the regular
 * expression only.
 */
- (id<RTRDataFieldBuilder>)setPredicateBlock:(RTRFieldPredicateBlock)predicateBlock;

@end

/**
 * A protocol for the scheme builder object. Using the scheme builder you will be able to add the data field 
 * and define the rules to which it should conform.
 */
@protocol RTRDataSchemeBuilder

/**
 * Sets the scheme name.
 *
 * @return self
 */
- (id<RTRDataSchemeBuilder>)setName:(NSString*)name;

/**
 * Creates a new data field in the scheme.
 * @param id Field identifier.
 * 
 * @return Field builder object.
 */
- (id<RTRDataFieldBuilder>)addField:(NSString*)id;

@end

/**
 * Profile builder. Allows you to create a custom profile for data capture scenarios.
 */
@protocol RTRDataCaptureProfileBuilder

/**
 * Sets the languages to be used for recognition.
 *
 * Setting the correct languages for your text will improve
 * recognition accuracy. However, setting too many languages may slow down performance.
 *
 * @param languages The set of languages to be used for recognition.
 * 
 * @return self
 */
- (id<RTRDataCaptureProfileBuilder>)setRecognitionLanguages:(NSSet*)languages;

/**
 * Create a new scheme in the profile.
 *
 * @param id The scheme identifier.
 *
 * @return Scheme builder object.
 */
- (id<RTRDataSchemeBuilder>)addScheme:(NSString*)id;

/**
 * Submit the created profile for use in the data capture service.
 *
 * @return Error object in case an error occurs while submitting profile, otherwise - nil.
 */
- (NSError*)checkAndApply;

@end

/**
 * A background data capture recognition service.
 */
@protocol RTRDataCaptureService <RTRRecognitionService>

/**
 * Creates a profile builder object with which you will be able to configure the data capture service
 * to recognize a custom field.
 *
 * @return Profile builder object or nil in unsupported scenarios.
 */
- (id<RTRDataCaptureProfileBuilder>)configureDataCaptureProfile;

@end
