#define AHELP_KEYWORDS_FILE "config/bandastation/ahelp_keywords.json"

/proc/get_ahelp_keywords()
	var/static/initialized
	var/static/regex/keywords

	if(initialized)
		return keywords

	initialized = TRUE
	keywords = null

	if(!fexists(AHELP_KEYWORDS_FILE))
		return null

	var/raw_filter = file2text(AHELP_KEYWORDS_FILE)
	var/list/parsed_filter = safe_json_decode(raw_filter)
	if(isnull(parsed_filter))
		log_config("JSON parsing failure for [AHELP_KEYWORDS_FILE]")
		return null

	var/list/filters = parsed_filter["ahelp_keywords"]
	if(!length(filters))
		return null

	var/list/unique_filters = list()
	unique_filters |= filters
	var/combined_regex = unique_filters.Join("|")
	keywords = new /regex(combined_regex, "i")
	return keywords

/// TRUE if ahelp message matches any configured keyword.
/proc/ahelp_message_matches_keyword(message)
	if(!message)
		return FALSE

	var/regex/keywords = get_ahelp_keywords()
	if(!keywords)
		return FALSE

	return !!keywords.Find("[message]")

#undef AHELP_KEYWORDS_FILE
