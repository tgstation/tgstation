/// Helper macro for creating a matrix at the given offsets.
/// Works at compile time.
#define TRANSLATE_MATRIX(offset_x, offset_y) matrix(1, 0, (offset_x), 0, 1, (offset_y))
/// The color matrix of an image which colors haven't been altered. Does nothing.
#define COLOR_MATRIX_IDENTITY list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0,0,0,0)
/// Color inversion
#define COLOR_MATRIX_INVERT list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0)
///Grayscale
#define COLOR_MATRIX_GRAYSCALE list(0.33,0.33,0.33,0, 0.59,0.59,0.59,0, 0.11,0.11,0.11,0, 0,0,0,1, 0,0,0,0)
