/// Helper macro for creating a matrix at the given offsets.
/// Works at compile time.
#define TRANSLATE_MATRIX(offset_x, offset_y) matrix(1, 0, (offset_x), 0, 1, (offset_y))
