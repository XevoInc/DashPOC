/// ABBYY® Real-Time Recognition SDK 1 © 2016 ABBYY Production LLC.
/// ABBYY is either a registered trademark or a trademark of ABBYY Software Ltd.

#import "RTRConstants.h"

@class RTRTextLine;
@class RTRDataScheme;
@class RTRDataField;

#pragma mark - RTRRecognitionServiceDelegate

/**
 * A callback protocol to interact with the recognition service: input the data and obtain the results.
 */
@protocol RTRRecognitionServiceDelegate <NSObject>

@required
/**
 * Reports an error.
 *
 * @param error The description of the error that has occurred.
 */
- (void)onError:(NSError*)error;

@optional
/**
 * Reports a warning.
 *
 * @param warningCode The warning; for a list of possible values see the RTRCallbackWarningCode constant descriptions.
 */
- (void)onWarning:(RTRCallbackWarningCode)warningCode;

@end

#pragma mark - RTRTextCaptureServiceDelegate

/**
 * A specified callback protocol to obtain the text capture results.
 */
@protocol RTRTextCaptureServiceDelegate <RTRRecognitionServiceDelegate>

@required
/**
 * Delivers the result after recognizing the buffers that were supplied.
 * The result stability status is also provided and should be used to determine if the accuracy
 * is high enough for the result to be used for any practical purposes. We recommend not to use
 * the data in any way until stability level has reached RTRResultStabilityVerified.
 * When stability of the result has reached the desired level,
 * the service may be stopped by calling the -stopTasks method.
 *
 * @param textLines The result as an array with RTRTextLine objects that contain recognition results.
 * @param resultStatus The estimate of how stable the result is.
 *      It may go up and down. It is not guaranteed that it ever reaches desired levels for a particular scene.
 *      For a list of possible values see the RTRResultStabilityStatus constant descriptions.
 */
- (void)onBufferProcessedWithTextLines:(NSArray<RTRTextLine*>*)textLines resultStatus:(RTRResultStabilityStatus)resultStatus;

@end

#pragma mark - RTRDataCaptureServiceDelegate

/**
 * A specified callback protocol to obtain the data capture results.
 */
@protocol RTRDataCaptureServiceDelegate <RTRRecognitionServiceDelegate>

@required
/**
 * Delivers the result after recognizing the buffers that were supplied.
 * The result stability status is also provided and should be used to determine if the accuracy
 * is high enough for the result to be used for any practical purposes. We recommend not to use
 * the data in any way until stability level has reached RTRResultStabilityVerified.
 * When stability of the result has reached the desired level,
 * the service may be stopped by calling the -stopTasks method.
 *
 * @param dataScheme The scheme matching the recognized data, represented by an RTRDataScheme object.
 * @param dataFields The result as an array with RTRDataField objects that contain recognition results.
 * @param resultStatus The estimate of how stable the result is.
 *      It may go up and down. It is not guaranteed that it ever reaches desired levels for a particular scene.
 *      For a list of possible values see the RTRResultStabilityStatus constant descriptions.
 */
- (void)onBufferProcessedWithDataScheme:(RTRDataScheme*)dataScheme dataFields:(NSArray<RTRDataField*>*)dataFields resultStatus:(RTRResultStabilityStatus)resultStatus;

@end
