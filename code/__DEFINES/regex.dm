/// Use this for every proc passed in as second argument in regex.Replace. regex.Replace does not allow calling procs by name but as of 515 using proc refs will always call the top level proc instead of overrides
#define REGEX_REPLACE_HANDLER SHOULD_NOT_OVERRIDE(TRUE)

/// The maximum number of characters that a regular expression made by a player can have. Used in [validate_regex_user_input()]
#define MAX_REGEX_INPUT_LEN 64
