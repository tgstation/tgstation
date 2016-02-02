// Helpers for running 510 code on older versions of BYOND.
#if DM_VERSION < 510
#define BYGEX "code/__HELPERS/bygex"
/proc/replacetext(text, replace, replacement)
	if(istype(replace, /regex))
		var/regex/R = replace
		return R.Replace(text, replacement)
	else
		return call(BYGEX, "regex_replaceallliteral")(text, replace, replacement)

/proc/replacetextEx(text, replace, replacement)
	return call(BYGEX, "regEx_replaceallliteral")(text, replace, replacement)

/proc/regex(pattern, flags)
	return new /regex(pattern, flags)

/regex
	var/pattern
	var/list/flags
	var/list/group

/regex/New(pattern, flags)
	src.pattern = pattern
	src.flags = splittext(flags, "")
	group = list()

/regex/proc/Find(text) // Does not support Start/End.
	var/method
	if("i" in flags)
		method = "regex_find"
	else
		method = "regEx_find"

	var/results = call(BYGEX, method)(text, pattern)
	var/list/L = params2list(results)
	var/list/M
	var/i
	var/j

	for(i in L)
		M = L[i]
		for(j = 2, j <= M.len, j += 2)
			var/pos = text2num(M[j-1])
			var/len = text2num(M[j])
			group += copytext(text, pos, pos + len)

/regex/proc/Replace(text, replacement)
	var/method
	if("g" in flags)
		if("i" in flags)
			method = "regex_replaceall"
		else
			method = "regEx_replaceall"
	else
		if("i" in flags)
			method = "regex_replace"
		else
			method = "regEx_replace"
	return call(BYGEX, method)(text, pattern, replacement)
#undef BYGEX

// Formerly list2text
/proc/jointext(list/ls, sep)
	if(ls.len <= 1) // Early-out code for empty or singleton lists.
		return ls.len ? ls[1] : ""

	var/l = ls.len // Made local for sanic speed.
	var/i = 0 // Incremented every time a list index is accessed.

	if(sep != null)
		// Macros expand to long argument lists like so: sep, ls[++i], sep, ls[++i], sep, ls[++i], etc...
		#define S1    sep, ls[++i]
		#define S4    S1,  S1,  S1,  S1
		#define S16   S4,  S4,  S4,  S4
		#define S64   S16, S16, S16, S16

		. = "[ls[++i]]" // Make sure the initial element is converted to text.

		// Having the small concatenations come before the large ones boosted speed by an average of at least 5%.
		if(l-1 & 0x01) // 'i' will always be 1 here.
			. = text("[][][]", ., S1) // Append 1 element if the remaining elements are not a multiple of 2.
		if(l-i & 0x02)
			. = text("[][][][][]", ., S1, S1) // Append 2 elements if the remaining elements are not a multiple of 4.
		if(l-i & 0x04)
			. = text("[][][][][][][][][]", ., S4) // And so on....
		if(l-i & 0x08)
			. = text("[][][][][][][][][][][][][][][][][]", ., S4, S4)
		if(l-i & 0x10)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16)
		if(l-i & 0x20)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, S16)
		if(l-i & 0x40)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		while(l > i) // Chomp through the rest of the list, 128 elements at a time.
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, S64)

		#undef S64
		#undef S16
		#undef S4
		#undef S1

	else
		// Macros expand to long argument lists like so: ls[++i], ls[++i], ls[++i], etc...
		#define S1    ls[++i]
		#define S4    S1,  S1,  S1,  S1
		#define S16   S4,  S4,  S4,  S4
		#define S64   S16, S16, S16, S16

		. = "[ls[++i]]" // Make sure the initial element is converted to text.

		if(l-1 & 0x01) // 'i' will always be 1 here.
			. += "[S1]" // Append 1 element if the remaining elements are not a multiple of 2.
		if(l-i & 0x02)
			. = text("[][][]", ., S1, S1) // Append 2 elements if the remaining elements are not a multiple of 4.
		if(l-i & 0x04)
			. = text("[][][][][]", ., S4) // And so on...
		if(l-i & 0x08)
			. = text("[][][][][][][][][]", ., S4, S4)
		if(l-i & 0x10)
			. = text("[][][][][][][][][][][][][][][][][]", ., S16)
		if(l-i & 0x20)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, S16)
		if(l-i & 0x40)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		while(l > i) // Chomp through the rest of the list, 128 elements at a time.
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, S64)

		#undef S64
		#undef S16
		#undef S4
		#undef S1

// Formerly text2list
/proc/splittext(text, delim = "\n")
	var/delim_len = length(delim)
	. = list()
	var/last_found = 1
	var/found = 1
	if(delim_len < 1)
		var/text_len = length(text)
		while(found++ <= text_len)
			. += copytext(text,found-1, found)
	else
		do
			found = findtext(text, delim, last_found, 0)
			. += copytext(text, last_found, found)
			last_found = found + delim_len
		while(found)

// Formerly JSON.stringify
/proc/json_encode(value)
	return jointext(json_encode_value(list(), value))

/proc/json_encode_value(list/json, value)
	. = json
	if(isnum(value))
		json += value // Consider num2text(value, 20) for maximum accuracy.
	else if(isnull(value))
		json += "null"
	else if(istext(value))
		json_encode_string(json, value)
	else if(istype(value, /list))
		json_encode_list(json, value)
	else
		json_encode_string(json, "[value]")
		// 510 just encodes the name of a datum.
		//throw EXCEPTION("Datums cannot be converted to JSON.")

/proc/json_encode_string(list/json, str)
	. = json
	var/quotePos = findtextEx(str, "\"")
	var/bsPos = findtextEx(str, "\\")
	if (quotePos == 0 && bsPos == 0)
		json.Add("\"", str, "\"")
	else
		json += "\""
		var/lastStop = 1
		while(quotePos != 0 || bsPos != 0)
			var/escPos
			if(quotePos < bsPos && quotePos != 0 || bsPos == 0)
				escPos = quotePos
			else
				escPos = bsPos
			json.Add(copytext(str, lastStop, escPos), "\\")
			lastStop = escPos
			if(escPos == quotePos)
				quotePos = findtextEx(str, "\"", escPos + 1)
			else if(escPos == bsPos)
				bsPos = findtextEx(str, "\\", escPos + 1)
		json.Add(copytext(str, lastStop), "\"")

/proc/json_encode_list(list/json, list/listVal)
	. = json
	#define Either			0
	#define CannotBeArray	1
	#define CannotBeObject	2
	#define BadList			(CannotBeArray | CannotBeObject)
	var/listType = Either
	for(var/key in listVal)
		if(istext(key))
			if(!isnull(listVal[key]))
				listType |= CannotBeArray
		else
			if(!isnum(key) && !isnull(listVal[key]))
				listType = BadList
			else
				listType |= CannotBeObject

		if(listType == BadList)
			throw EXCEPTION("The given list cannot be converted to JSON.")

	if(listType == CannotBeArray)
		json += "{"
		var/addComma
		for(var/key in listVal)
			if(addComma)
				json += ","
			else
				addComma = TRUE
			json_encode_string(json, key)
			json += ":"
			json_encode_value(json, listVal[key])
		json += "}"
	else
		json += "\["
		var/addComma
		for(var/key in listVal)
			if(addComma)
				json += ","
			else
				addComma = TRUE
			json_encode_value(json, key)
		json += "]"
	#undef Either
	#undef CannotBeFlat
	#undef CannotBeAssoc
	#undef BadList
#endif