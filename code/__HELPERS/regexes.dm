//These are a bunch of regex datums for use /((any|every|no|some|head|foot)where(wolf)?\sand\s)+(\.[\.\s]+\s?where\?)?/i
/proc/regex_is_http_protocol(flags)
	. = regex("^https?://", flags)

/proc/regex_is_website(flags="i")
	. = regex("http|www.|\[a-z0-9_-]+.(com|org|net|mil|edu)+", flags)
/proc/regex_is_email(flags="i")
	. = regex("\[a-z0-9_-]+@\[a-z0-9_-]+.\[a-z0-9_-]+", flags)
/proc/regex_is_alphanumeric(flags="i")
	. = regex("\[a-z0-9]+", flags)
/proc/regex_is_punctuation(flags="i")
	. = regex("\[.!?]+", flags)
