/datum/ntcode/module/string
	module_name = "string"

/datum/ntcode/module/string/New()
	. = ..()

	add_byond_proc("replace", TYPE_PROC_REF(/datum/ntcode/module/string, replace), list("string", "sub_string", "replace_string"))
	add_byond_proc("find", TYPE_PROC_REF(/datum/ntcode/module/string, find), list("string", "needle", "start", "end"))
	add_byond_proc("length", TYPE_PROC_REF(/datum/ntcode/module/string, string_length), list("string"))
	add_byond_proc("to_string", TYPE_PROC_REF(/datum/ntcode/module/string, to_string), list("value"))
	add_byond_proc("lower", TYPE_PROC_REF(/datum/ntcode/module/string, lower), list("string"))
	add_byond_proc("upper", TYPE_PROC_REF(/datum/ntcode/module/string, upper), list("string"))
	add_byond_proc("split", TYPE_PROC_REF(/datum/ntcode/module/string, split), list("string", "delimiter"))
	add_byond_proc("repeat", TYPE_PROC_REF(/datum/ntcode/module/string, repeat), list("string", "amount"))
	add_byond_proc("reverse", TYPE_PROC_REF(/datum/ntcode/module/string, reverse), list("string"))

/datum/ntcode/module/string/proc/replace(string, sub_string, replace_string)
	if(!istext(string) || !istext(sub_string) || !istext(replace_string))
		return
	return replacetext(string, sub_string, replace_string)

/datum/ntcode/module/string/proc/find(string, needle, start, end)
	if(!istext(string) || !istext(needle) || !isnum(start) || !isnum(end))
		return
	// Indexing from 0
	return findtext(string, needle, start + 1, end + 1)

/datum/ntcode/module/string/proc/string_length(string)
	if(!istext(string))
		return
	return length(string)

/datum/ntcode/module/string/proc/to_string(value)
	if(istext(value))
		return value

	if(isnum(value))
		return num2text(value)

	if(islist(value))
		var/result = "\["
		var/list/list = value
		if(list.len > 0)
			result += " "
			for(var/item in list)
				result += "[to_string(value)], "
			result = copytext(result, 1, length(result) - 1)
			result += " "
		return result + "]"
	return ""

/datum/ntcode/module/string/proc/lower(string)
	if(!istext(string))
		return
	return lowertext(string)

/datum/ntcode/module/string/proc/upper(string)
	if(!istext(string))
		return
	return uppertext(string)

/datum/ntcode/module/string/proc/split(string, delimiter)
	if(!istext(string) || !istext(delimiter))
		return
	return splittext(string, delimiter)

/datum/ntcode/module/string/proc/repeat(string, amount)
	if(!istext(string) || !isnum(amount))
		return
	if(amount >= 32)
		return
	var/result = ""
	for(var/i = 0; i < amount; i++)
		result += string
	return result

/datum/ntcode/module/string/proc/reverse(string)
	if(!istext(string))
		return
	if(length(string) >= 256)
		return string

	var/result = ""
	for(var/i = length(string); i >= 1; i--)
		result += string[i]
	return result
