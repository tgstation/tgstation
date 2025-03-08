/// Field of vision defines.
#define FOV_90_DEGREES 90
#define FOV_180_DEGREES 180
#define FOV_270_DEGREES 270
#define FOV_REVERSE_90_DEGRESS -90
#define FOV_REVERSE_180_DEGRESS -180
#define FOV_REVERSE_270_DEGRESS -270

/// Base mask dimensions. They're like a client's view, only change them if you modify the mask to different dimensions.
#define BASE_FOV_MASK_X_DIMENSION 15
#define BASE_FOV_MASK_Y_DIMENSION 15

/// Range at which FOV effects treat nearsightness as blind and play
#define NEARSIGHTNESS_FOV_BLINDNESS 2

//Fullscreen overlay resolution in tiles for the clients view.
/// The fullscreen overlay in tiles for x axis
#define FULLSCREEN_OVERLAY_RESOLUTION_X 15
/// The fullscreen overlay in tiles for y axis
#define FULLSCREEN_OVERLAY_RESOLUTION_Y 15
