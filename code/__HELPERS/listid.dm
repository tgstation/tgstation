#define VAR_TO_TXT_ID(variable, output) do{\
	if(isnull(variable)){\
		output += "#null#"}\
	else if(isnum(variable)){\
		output += "#num_[thing]#"}\
	else if(istext(variable)){\
		output += "#txt_[thing]#"}\
	else if(islist(variable)){\
		output += get_shallow_list_id(variable)}\
	else{\
		output += "#ref_[REF(variable)]#"}\
}\
while(FALSE)

/proc/get_shallow_list_id(list/input)
	var/list/output = list()
	for(var/thing in input)
		if(istext(thing))
			output += "#txt_key_[thing]_open#"
			VAR_TO_TXT_ID(input[thing], output)
			output += "#txt_key_[thing]_close#"
		else if(ispath(thing))
			output += "#path_key_[thing]_open#"
			VAR_TO_TXT_ID(input[thing], output)
			output += "#path_key_[thing]_close#"
		else if(islist(thing) || isatom(thing))
			output += "#ref_key_[REF(thing)]_open#"
			VAR_TO_TXT_ID(input[thing], output)
			output += "#ref_key_[REF(thing)]_close#"
		else
			VAR_TO_TXT_ID(thing, output)
	return output.Join("#separator#")
