/// Regex.Replace does not allow calling procs by name, but as of 515 these will always call the top level proc instead of overrides
#define REGEX_REPLACE_HANDLER SHOULD_NOT_OVERRIDE(TRUE)
