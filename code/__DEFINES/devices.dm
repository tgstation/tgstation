// Used to stringify message targets before sending the signal datum.
#define STRINGIFY_PDA_TARGET(name, job) "[name] ([job])"

//N-spect scanner defines
#define INSPECTOR_PRINT_SOUND_MODE_NORMAL 1
#define INSPECTOR_PRINT_SOUND_MODE_CLASSIC 2
#define INSPECTOR_PRINT_SOUND_MODE_HONK 3
#define INSPECTOR_PRINT_SOUND_MODE_FAFAFOGGY 4
#define BANANIUM_CLOWN_INSPECTOR_PRINT_SOUND_MODE_LAST 4
#define CLOWN_INSPECTOR_PRINT_SOUND_MODE_LAST 4
#define INSPECTOR_ENERGY_USAGE_HONK (0.015 * STANDARD_CELL_CHARGE)
#define INSPECTOR_ENERGY_USAGE_NORMAL (0.005 * STANDARD_CELL_CHARGE)
#define INSPECTOR_ENERGY_USAGE_LOW (0.001 * STANDARD_CELL_CHARGE)
#define INSPECTOR_TIME_MODE_SLOW 1
#define INSPECTOR_TIME_MODE_FAST 2
#define INSPECTOR_TIME_MODE_HONK 3

// Health scan modes
/// Healthscan prints health of the target
#define SCANNER_CONDENSED 0
/// Healthscan prints health of each bodypart of the target in addition to broad health
#define SCANNER_VERBOSE 1
/// Used to prevent health analyzers from switching modes when they shouldn't.
/// Functions the same as [SCANNER_CONDENSED]
#define SCANNER_NO_MODE -1
