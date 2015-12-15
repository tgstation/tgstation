/var/datum/jsonHelper/_jsonHelper = new // Solely as a namespace for procs.

// ************************************ WRITER ************************************
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