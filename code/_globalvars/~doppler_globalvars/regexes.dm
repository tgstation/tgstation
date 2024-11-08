//Does the line end in any EOL char that isn't appropriate punctuation OR does it end in a chat-formatted markdown sequence (+bold+, etc) without a period?
GLOBAL_DATUM_INIT(needs_eol_autopunctuation, /regex, regex(@"([a-zA-Z\d]|[^.?!~-][+|_])$"))

//All non-capitalized 'i' surrounded with whitespace (aka, 'hello >i< am a cat')
GLOBAL_DATUM_INIT(noncapital_i, /regex, regex(@"\b[i]\b", "g"))
