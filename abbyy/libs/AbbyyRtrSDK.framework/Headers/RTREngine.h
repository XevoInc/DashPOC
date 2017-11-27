/// ABBYY® Real-Time Recognition SDK 1 © 2016 ABBYY Production LLC.
/// ABBYY is either a registered trademark or a trademark of ABBYY Software Ltd.

#if !defined ABBYY_RTR_ENGINE_H
#define ABBYY_RTR_ENGINE_H

#import <Foundation/Foundation.h>

@class RTRExtendedSettings;
@protocol RTREngineSettings;

@protocol RTRDataCaptureService;
@protocol RTRDataCaptureServiceDelegate;
@protocol RTRTextCaptureService;
@protocol RTRTextCaptureServiceDelegate;

@protocol RTRCoreAPI;

#pragma mark - RTREngine

/**
 * The main ABBYY Real-Time Recognition SDK class which serves to initialize the library
 * and create a background recognition service.
 */
@interface RTREngine : NSObject

/**
 * Additional engine settings.
 */
@property (nonatomic, readonly) id<RTREngineSettings> extendedSettings;

/**
 * Creates (or returns) the RTREngine object. Repeated calls to this method will result in the same object instance.
 *
 * @param licenseData The license data to initialize ABBYY RTR SDK.
 *
 * @return The RTREngine object or nil on failure.
 */
+ (instancetype)sharedEngineWithLicenseData:(NSData*)licenseData;

- (instancetype)init __unavailable;

/**
 * Creates a background recognition service configured with default settings.
 *
 * @param delegate The delegate object used to interact with the service.
 *
 * @return Recognition service that conforms to RTRRecognitionService protocol.
 */
- (id<RTRTextCaptureService>)createTextCaptureServiceWithDelegate:(id<RTRTextCaptureServiceDelegate>)delegate;

/**
 * Creates a background recognition service.
 *
 * @param delegate The delegate object used to interact with the service.
 * @param settings The settings used to configure background recognition service.
 *
 * @return Recognition service that conforms to RTRRecognitionService protocol.
 */
- (id<RTRTextCaptureService>)createTextCaptureServiceWithDelegate:(id<RTRTextCaptureServiceDelegate>)delegate settings:(RTRExtendedSettings*)settings;

/**
 * Creates a background recognition DataCapture service.
 *
 * @param delegate The delegate object used to interact with the service.
 * @param profile The selected profile for DataCapture service.
 *
 * @return Data capture service that conforms to RTRDataCaptureService protocol.
 */
- (id<RTRDataCaptureService>)createDataCaptureServiceWithDelegate:(id<RTRDataCaptureServiceDelegate>)delegate profile:(NSString*)profile;

/**
 * Creates a background recognition DataCapture service.
 *
 * @param delegate The delegate object used to interact with the service.
 * @param profile The selected profile for DataCapture service.
 * @param settings The settings used to configure background recognition service.
 *
 * @return Data capture service that conforms to RTRDataCaptureService protocol.
 */
- (id<RTRDataCaptureService>)createDataCaptureServiceWithDelegate:(id<RTRDataCaptureServiceDelegate>)delegate profile:(NSString*)profile settings:(RTRExtendedSettings*)settings;

#pragma mark - Core API

/**
 * Creates a core API object, which provides access to low-level single image processing functions for the current thread.
 *
 * @return An object that conforms to RTRCoreAPI protocol.
 */
- (id<RTRCoreAPI>)createCoreAPI;

/**
 * Examines bundle directories and returns the list of languages available for text recognition.
 *
 * @return A set of strings with internal language names.
 */
- (NSSet*)languagesAvailableForOCR;

@end

#endif
