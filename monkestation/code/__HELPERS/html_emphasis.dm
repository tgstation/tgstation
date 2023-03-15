#define ENCODE_HTML_EMPHASIS(input, char, html, varname) \
    var/static/regex/##varname = regex("(?<!\\\\)[char](.+?)(?<!\\\\)[char]", "g");\
    input = varname.Replace_char(input, "<[html]>$1</[html]>")



/**
  * Allows you to bold, underline, and italicize things using HTML encoding
  *
  * Takes one argument, input, which is the text you wish to emphasize
  *
  * Returns the emphasized input
  */
/proc/say_emphasis(input)
    ENCODE_HTML_EMPHASIS(input, "\\|", "i", italics)
    ENCODE_HTML_EMPHASIS(input, "\\+", "b", bold)
    ENCODE_HTML_EMPHASIS(input, "_", "u", underline)
    var/static/regex/remove_escape_backlashes = regex("\\\\(_|\\+|\\|)", "g") // Removes backslashes used to escape text modification.
    input = remove_escape_backlashes.Replace_char(input, "$1")
    return input
