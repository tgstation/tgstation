/* Usage:
	JSON.stringify(obj) - Converts lists and values into a JSON string.
	JSON.parse(json)    - Converts a JSON string into lists and values.
*/

/var/datum/jsonHelper/JSON = new // A namespace for procs.

// ************************************ WRITER ************************************
/datum/jsonHelper/proc/stringify(value)
	return list2text(WriteValue(list(), value))

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
			return list2text(chars)
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