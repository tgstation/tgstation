// Used to stringify message targets before sending the signal datum.
#define STRINGIFY_PDA_TARGET(name, job) "[name] ([job])"

// Health scan modes
/// Healthscan prints health of the target
#define SCANNER_CONDENSED 0
/// Healthscan prints health of each bodypart of the target in addition to broad health
#define SCANNER_VERBOSE 1
/// Used to prevent health analyzers from switching modes when they shouldn't.
/// Functions the same as [SCANNER_CONDENSED]
#define SCANNER_NO_MODE -1
