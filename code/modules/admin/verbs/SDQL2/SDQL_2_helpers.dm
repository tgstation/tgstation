/proc/recursive_list_print(list/output = list(), list/input, datum/callback/datum_handler, datum/callback/atom_handler)
	output += "\[ "
	for(var/i in 1 to input.len)
		var/final = i == input.len
		var/key = input[i]

		//print the key
		if(islist(key))
			recursive_list_print(output, key, datum_handler, atom_handler)
		else if(isdatum(key) && (datum_handler || (isatom(key) && atom_handler)))
			if(isatom(key) && atom_handler)
				output += atom_handler.Invoke(key)
			else
				output += datum_handler.Invoke(key)
		else
			output += "[key]"

		//print the value
		var/is_value = (!isnum(key) && !isnull(input[key]))
		if(is_value)
			var/value = input[key]
			if(islist(value))
				recursive_list_print(output, value, datum_handler, atom_handler)
			else if(isdatum(value) && (datum_handler || (isatom(value) && atom_handler)))
				if(isatom(value) && atom_handler)
					output += atom_handler.Invoke(value)
				else
					output += datum_handler.Invoke(value)
			else
				output += " = [value]"

		if(!final)
			output += " , "

	output += " \]"
