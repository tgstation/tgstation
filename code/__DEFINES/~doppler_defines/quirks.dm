/// the minimum percentage of RGB darkness reduction that Nova's NV will always give. for base reference, the old NV quirk was equal to 4.5. note: some wide variance in min/max is needed to ensure hue has some chance to linear convert across
#define DOPPLER_NIGHT_VISION_POWER_MIN 4.5
/// the maximum percentage. for reference, low-light adapted eyes (icecats and ashwalkers) have 30.
#define DOPPLER_NIGHT_VISION_POWER_MAX 9
/// percentage of the NIGHT_VISION_POWER_MAX increase that is applied for eyes with low innate flash protection (photophobia quirk/moth eyes). At 0.75, this raises NV to 22.5 at hypersensitive flash_protect.
#define DOPPLER_NIGHT_VISION_SENSITIVITY_MULT 0.75
