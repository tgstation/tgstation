// wrapper for update_appearance that lets me capture it in debug mode
// Does not work for callbacks unfortunately, not sure how to feel about that
// This only works if definitions of the proc get changed to _update_appearance with REGEX
// See the _compile_options comment for the regexes to use for that
#ifdef APPEARANCE_SUCCESS_TRACKING
#define update_appearance(arguments...) wrap_update_appearance(__FILE__, __LINE__, ##arguments)
#endif
