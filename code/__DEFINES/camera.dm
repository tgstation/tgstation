///Converts camera half dimension aperture into full meters
///We first do size = value - 1 which is the picture size & then 2 * size + 1 to give us meters
#define APERTURE_TO_METERS(value)(2 * value - 1)
///Max size of an photograph in square dimensions
#define CAMERA_PICTURE_SIZE_HARD_LIMIT 4
