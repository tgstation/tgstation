/// Helper macro for creating a matrix at the given offsets.
/// Works at compile time.
#define TRANSLATE_MATRIX(offset_x, offset_y) matrix(1, 0, (offset_x), 0, 1, (offset_y))
/// The color matrix of an image which colors haven't been altered. Does nothing.
#define COLOR_MATRIX_IDENTITY list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)
/// Color inversion
#define COLOR_MATRIX_INVERT list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0)
///Sepiatone
#define COLOR_MATRIX_SEPIATONE list(0.393,0.349,0.272,0, 0.769,0.686,0.534,0, 0.189,0.168,0.131,0, 0,0,0,1, 0,0,0,0)
///Grayscale
#define COLOR_MATRIX_GRAYSCALE list(0.33,0.33,0.33,0, 0.59,0.59,0.59,0, 0.11,0.11,0.11,0, 0,0,0,1, 0,0,0,0)
///Polaroid colors
#define COLOR_MATRIX_POLAROID list(1.438,-0.062,-0.062,0, -0.122,1.378,-0.122,0, -0.016,-0.016,1.483,0, 0,0,0,1, 0,0,0,0)
/// Converts reds to blue, green to red and blue to green.
#define COLOR_MATRIX_BRG list(0,0,1,0, 0,1,0,0, 1,0,0,0, 0,0,0,1, 0,0,0,0)
/// Black & White
#define COLOR_MATRIX_BLACK_WHITE list(1.5,1.5,1.5,0, 1.5,1.5,1.5,0, 1.5,1.5,1.5,0, 0,0,0,1, -1,-1,-1,0)
/**
 * Adds/subtracts overall lightness
 * 0 is identity, 1 makes everything white, -1 makes everything black
 */
#define COLOR_MATRIX_LIGHTNESS(power) list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, power,power,power,0)
/**
 * Changes distance colors have from rgb(127,127,127) grey
 * 1 is identity. 0 makes everything grey >1 blows out colors and greys
 */
#define COLOR_MATRIX_CONTRAST(val) list(val,0,0,0, 0,val,0,0, 0,0,val,0, 0,0,0,1, (1-val)*0.5,(1-val)*0.5,(1-val)*0.5,0)
