#ifdef USE_BYGEX
#define LIBREGEX_LIBRARY "bygex"

proc
	regEx_compare(str, exp)
		return new /datum/regex(str, exp, call(LIBREGEX_LIBRARY, "regEx_compare")(str, exp))

	regex_compare(str, exp)
		return new /datum/regex(str, exp, call(LIBREGEX_LIBRARY, "regex_compare")(str, exp))

	regEx_find(str, exp)
		return new /datum/regex(str, exp, call(LIBREGEX_LIBRARY, "regEx_find")(str, exp))

	regex_find(str, exp)
		return new /datum/regex(str, exp, call(LIBREGEX_LIBRARY, "regex_find")(str, exp))

	regEx_replaceall(str, exp, fmt)
		return call(LIBREGEX_LIBRARY, "regEx_replaceall")(str, exp, fmt)

	regex_replaceall(str, exp, fmt)
		return call(LIBREGEX_LIBRARY, "regex_replaceall")(str, exp, fmt)

	replacetextEx(str, exp, fmt)
		return call(LIBREGEX_LIBRARY, "regEx_replaceallliteral")(str, exp, fmt)

	replacetext(str, exp, fmt)
		return call(LIBREGEX_LIBRARY, "regex_replaceallliteral")(str, exp, fmt)

	regEx_replace(str, exp, fmt)
		return call(LIBREGEX_LIBRARY, "regEx_replace")(str, exp, fmt)

	regex_replace(str, exp, fmt)
		return call(LIBREGEX_LIBRARY, "regex_replace")(str, exp, fmt)

	regEx_findall(str, exp)
		return new /datum/regex(str, exp, call(LIBREGEX_LIBRARY, "regEx_findall")(str, exp))

	regex_findall(str, exp)
		return new /datum/regex(str, exp, call(LIBREGEX_LIBRARY, "regex_findall")(str, exp))

#undef LIBREGEX_LIBRARY

//upon calling a regex match or search, a /datum/regex object is created with str(haystack) and exp(needle) variables set
//it also contains a list(matches) of /datum/match objects, each of which holds the position and length of the match
//matched strings are not returned from the dll, in order to save on memory allocation for large numbers of strings
//instead, you can use regex.str(matchnum) to fetch this string as needed.
//likewise you can also use regex.pos(matchnum) and regex.len(matchnum) as shorthands
/datum/regex
	var/str
	var/exp
	var/error
	var/anchors = 0
	var/list/matches = list()

	New(str, exp, results)
		src.str = str
		src.exp = exp

		if(findtext(results, "Err", 1, 4))	//error message
			src.error = results
		else
			var/list/L = params2list(results)
			var/list/M
			var{i;j}
			for(i in L)
				M = L[i]
				for(j=2, j<=M.len, j+=2)
					matches += new /datum/match(text2num(M[j-1]),text2num(M[j]))
			anchors = (j-2)/2
		return matches

	proc
		str(i)
			if(!i)	return str
			var/datum/match/M = matches[i]
			return copytext(str, M.pos, M.pos+M.len)

		pos(i)
			if(!i)	return 1
			var/datum/match/M = matches[i]
			return M.pos

		len(i)
			if(!i)	return length(str)
			var/datum/match/M = matches[i]
			return M.len

		end(i)
			if(!i) return length(str)
			var/datum/match/M = matches[i]
			return M.pos + M.len

		report()	//debug tool
			. = ":: RESULTS ::\n:: str :: [html_encode(str)]\n:: exp :: [html_encode(exp)]\n:: anchors :: [anchors]"
			if(error)
				. += "\n<font color='red'>[error]</font>"
				return
			for(var/i=1, i<=matches.len, ++i)
				. += "\nMatch[i]\n\t[html_encode(str(i))]\n\tpos=[pos(i)] len=[len(i)]"

/datum/match
	var/pos
	var/len

	New(pos, len)
		src.pos = pos
		src.len = len

#endif