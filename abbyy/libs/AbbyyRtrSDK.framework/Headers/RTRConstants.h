/// ABBYY® Real-Time Recognition SDK 1 © 2016 ABBYY Production LLC.
/// ABBYY is either a registered trademark or a trademark of ABBYY Software Ltd.

#pragma mark - Real-Time Recognition constants

/// Result stability status: the estimate of how stable the result is,
/// and whether it is likely to be improved by adding new frames.
typedef NS_ENUM(NSInteger, RTRResultStabilityStatus) {
	/// No content available.
	RTRResultStabilityNotReady,
	/// Tentative Content Detected.
	RTRResultStabilityTentative,
	/// Content Verified (matching content found in at least two frames).
	RTRResultStabilityVerified,
	/// Result Available (matching content found in three or more frames,
	/// the result varies with the addition of new frames).
	RTRResultStabilityAvailable,
	/// Result Tentatively Stable (the result has been stable in the last two frames).
	RTRResultStabilityTentativelyStable,
	/// Result Stable (the result has been stable in the last three or more frames).
	RTRResultStabilityStable,
};

/// Codes of warnings returned through callback.
typedef NS_ENUM(NSInteger, RTRCallbackWarningCode) {
	/// Выделенное значение. Нет предупреждения.
	RTRCallbackWarningNoWarning,
	/// The image is being recognized too slowly, perhaps something is going wrong.
	RTRCallbackWarningRecognitionIsSlow,
	/// The image probably has low quality.
	RTRCallbackWarningProbablyLowQualityImage,
	/// The chosen recognition language is probably wrong.
	RTRCallbackWarningProbablyWrongLanguage,
	/// The chosen recognition language is wrong.
	RTRCallbackWarningWrongLanguage,
	/// The text is too small. Zoom in or move camera closer.
	RTRCallbackWarningTextTooSmall,
};
