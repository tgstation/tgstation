// Helpers for running 510 code on older versions of BYOND.
//	list of places with #if DM_VERSION defines for when we remove 509 support:
//		master controller and subsystems.dm
//		map loader (reader.dm)
//		defines/tick.dm
//		defines/misc.dm
//		unsorted.dm (bottom, in stoplag())
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

/proc/json_encode(value)
	return JSON.stringify(value)
	
/proc/json_decode(value)
	return JSON.parse(value)

//JSON PROCS

/var/datum/jsonHelper/JSON = new // A namespace for procs.

// ************************************ WRITER ************************************
/datum/jsonHelper/proc/stringify(value)
	return jointext(WriteValue(list(), value))

/datum/jsonHelper/proc/WriteValue(list/json, value)
	. = json
	if(isnum(value))
		json += value // Consider num2text(value, 20) for maximum accuracy.
	else if(isnull(value))
		json += "null"
	else if(istext(value))
		WriteString(json, value)
	else if(istype(value, /list))
		WriteList(json, value)
	else
		throw EXCEPTION("Datums cannot be converted to JSON.")

/datum/jsonHelper/proc/WriteString(list/json, str)
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

/datum/jsonHelper/proc/WriteList(list/json, list/listVal)
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
			WriteString(json, key)
			json += ":"
			WriteValue(json, listVal[key])
		json += "}"
	else
		json += "\["
		var/addComma
		for(var/key in listVal)
			if(addComma)
				json += ","
			else
				addComma = TRUE
			WriteValue(json, key)
		json += "]"
	#undef Either
	#undef CannotBeFlat
	#undef CannotBeAssoc
	#undef BadList
// ************************************ READER ************************************
#define aBackspace		0x08
#define aTab			0x09
#define aLineBreak		0x0A
#define aVertTab		0x0B
#define aFormFeed		0x0C
#define aCarriageReturn	0x0D
#define aSpace			0x20
#define aZero			0x30
#define aNonBreakSpace	0xA0
#define Advance			if(++readPos > jsonLen) { curAscii = 0; curChar = "" } else { curAscii = text2ascii(json, readPos); curChar = ascii2text(curAscii) } // Deal with it.
#define SkipWhitespace	while(curAscii in whitespace) Advance
#define AdvanceWS		Advance; SkipWhitespace
/datum/jsonHelper/var
	readPos
	jsonLen
	json
	curAscii
	curChar
	static/list/whitespace = list(aTab, aLineBreak, aVertTab, aFormFeed, aCarriageReturn, aSpace, aNonBreakSpace)
/datum/jsonHelper/proc/parse(json)
	readPos  = 0
	jsonLen  = length(json)
	src.json = json
	curAscii = 0
	curChar  = ""
	AdvanceWS
	var/value = ParseValue()
	if(readPos < jsonLen)
		throw EXCEPTION("Expected: End of JSON")
	return value
/datum/jsonHelper/proc/ParseValue()
	if(curChar == "\"")
		return ParseString()
	else if(curChar == "-" || (curAscii >= aZero && curAscii <= aZero + 9))
		return ParseNumber()
	else if(curChar == "{")
		return ParseObject()
	else if(curChar == "\[")
		return ParseArray()
	else if(curChar == "t")
		if(copytext(json, readPos, readPos+4) == "true")
			readPos += 3
			AdvanceWS
			return TRUE
		else
			throw EXCEPTION("Expected: 'true'")
	else if(curChar == "f")
		if(copytext(json, readPos, readPos+5) == "false")
			readPos += 4
			AdvanceWS
			return FALSE
		else
			throw EXCEPTION("Expected: 'false'")
	else if(curChar == "n")
		if(copytext(json, readPos, readPos+4) == "null")
			readPos += 3
			AdvanceWS
			return null
		else
			throw EXCEPTION("Expected: 'null'")
	else if(curChar == "")
		throw EXCEPTION("Unexpected: End of JSON")
	else
		throw EXCEPTION("Unexpected: '[curChar]'")



/datum/jsonHelper/proc/ParseString()
	ASSERT(curChar == "\"")
	Advance
	var/list/chars = list()
	while(readPos <= jsonLen)
		if(curChar == "\"")
			AdvanceWS
			return jointext(chars)
		else if(curChar == "\\")
			Advance
			switch(curChar)
				if("\"", "\\", "/")
					chars += ascii2text(curAscii)
				if("b")
					chars += ascii2text(aBackspace)
				if("f")
					chars += ascii2text(aFormFeed)
				if("n")
					chars += "\n"
				if("r")
					chars += ascii2text(aCarriageReturn) // Should we ignore these?
				if("t")
					chars += "\t"
				if("u")
					throw EXCEPTION("JSON \\uXXXX escape sequence not supported")
				else
					throw EXCEPTION("Invalid escape sequence")
			Advance
		else
			chars += ascii2text(curAscii)
			Advance
	throw EXCEPTION("Unterminated string")

/datum/jsonHelper/proc/ParseNumber()
	var/firstPos = readPos
	if(curChar == "-")
		Advance
	if(curAscii >= aZero + 1 && curAscii <= aZero + 9)
		do
			Advance
		while(curAscii >= aZero && curAscii <= aZero + 9)
	else if(curAscii == aZero)
		Advance
	else
		throw EXCEPTION("Expected: digit")

	if(curChar == ".")
		Advance
		var/found = FALSE
		while(curAscii >= aZero && curAscii <= aZero + 9)
			found = TRUE
			Advance
		if(!found)
			throw EXCEPTION("Expected: digit")

	if(curChar == "E" || curChar == "e")
		Advance
		var/found = FALSE
		if(curChar == "-")
			Advance
		else if(curChar == "+")
			Advance
		while(curAscii >= aZero && curAscii <= aZero + 9)
			found = TRUE
			Advance
		if(!found)
			throw EXCEPTION("Expected: digit")

	SkipWhitespace
	return text2num(copytext(json, firstPos, readPos))

/datum/jsonHelper/proc/ParseObject()
	ASSERT(curChar == "{")
	var/list/object = list()
	AdvanceWS
	while(curChar == "\"")
		var/key = ParseString()
		if(curChar != ":")
			throw EXCEPTION("Expected: ':'")
		AdvanceWS
		object[key] = ParseValue()
		if(curChar == ",")
			AdvanceWS
		else
			break
	if(curChar != "}")
		throw EXCEPTION("Expected: string or '}'")
	AdvanceWS
	return object

/datum/jsonHelper/proc/ParseArray()
	ASSERT(curChar == "\[")
	var/list/array = list()
	AdvanceWS
	while(curChar != "]")
		array += list(ParseValue()) // Wrapped in a list in case ParseValue() returns a list.
		if(curChar == ",")
			AdvanceWS
		else
			break
	if(curChar != "]")
		throw EXCEPTION("Expected: ']'")
	AdvanceWS
	return array

#undef aBackspace
#undef aTab
#undef aLineBreak
#undef aVertTab
#undef aFormFeed
#undef aCarriageReturn
#undef aSpace
#undef aZero
#undef aNonBreakSpace

#undef Advance
#undef SkipWhitespace
#undef AdvanceWS
#endif
