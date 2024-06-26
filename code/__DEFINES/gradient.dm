// spacemandmm doesn't really implement gradient() right, so let's just handle that here yeah?
#define rgb_gradient(_index, args...) gradient(args, index = _index)
#define hsl_gradient(_index, args...) gradient(args, space = COLORSPACE_HSL, index = _index)
#define hsv_gradient(_index, args...) gradient(args, space = COLORSPACE_HSV, index = _index)
