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

/proc/SDQL_parse(list/query_list)
	var/datum/sdql_parser/parser = new()
	var/list/querys = list()
	var/list/query_tree = list()
	var/pos = 1
	var/querys_pos = 1
	var/do_parse = 0

	for(var/val in query_list)
		if(val == ";")
			do_parse = 1
		else if(pos >= query_list.len)
			query_tree += val
			do_parse = 1

		if(do_parse)
			parser.query = query_tree
			var/list/parsed_tree
			parsed_tree = parser.parse()
			if(parsed_tree.len > 0)
				querys.len = querys_pos
				querys[querys_pos] = parsed_tree
				querys_pos++
			else //There was an error so don't run anything, and tell the user which query has errored.
				to_chat(usr, span_danger("Parsing error on [querys_pos]\th query. Nothing was executed."), confidential = TRUE)
				return list()
			query_tree = list()
			do_parse = 0
		else
			query_tree += val
		pos++

	qdel(parser)
	return querys

/proc/SDQL_testout(list/query_tree, indent = 0)
	var/static/whitespace = "&nbsp;&nbsp;&nbsp; "
	var/spaces = ""
	if(indent > 0)
		for(var/i in 1 to indent)
			spaces += whitespace

	for(var/item in query_tree)
		if(istype(item, /list))
			to_chat(usr, "[spaces](", confidential = TRUE)
			SDQL_testout(item, indent + 1)
			to_chat(usr, "[spaces])", confidential = TRUE)

		else
			to_chat(usr, "[spaces][item]", confidential = TRUE)

		if(!isnum(item) && query_tree[item])

			if(istype(query_tree[item], /list))
				to_chat(usr, "[spaces][whitespace](", confidential = TRUE)
				SDQL_testout(query_tree[item], indent + 2)
				to_chat(usr, "[spaces][whitespace])", confidential = TRUE)

			else
				to_chat(usr, "[spaces][whitespace][query_tree[item]]", confidential = TRUE)

/proc/SDQL2_tokenize(query_text)

	var/list/whitespace = list(" ", "\n", "\t")
	var/list/single = list("(", ")", ",", "+", "-", ".", "\[", "]", "{", "}", ";", ":")
	var/list/multi = list(
					"=" = list("", "="),
					"<" = list("", "=", ">"),
					">" = list("", "="),
					"!" = list("", "="),
					"@" = list("\["))

	var/word = ""
	var/list/query_list = list()
	var/len = length(query_text)
	var/char = ""

	for(var/i = 1, i <= len, i += length(char))
		char = query_text[i]

		if(char in whitespace)
			if(word != "")
				query_list += word
				word = ""

		else if(char in single)
			if(word != "")
				query_list += word
				word = ""

			query_list += char

		else if(char in multi)
			if(word != "")
				query_list += word
				word = ""

			var/char2 = query_text[i + length(char)]

			if(char2 in multi[char])
				query_list += "[char][char2]"
				i++

			else
				query_list += char

		else if(char == "'")
			if(word != "")
				to_chat(usr, "\red SDQL2: You have an error in your SDQL syntax, unexpected ' in query: \"<font color=gray>[query_text]</font>\" following \"<font color=gray>[word]</font>\". Please check your syntax, and try again.", confidential = TRUE)
				return null

			word = "'"

			for(i += length(char), i <= len, i += length(char))
				char = query_text[i]

				if(char == "'")
					if(query_text[i + length(char)] == "'")
						word += "'"
						i += length(query_text[i + length(char)])

					else
						break

				else
					word += char

			if(i > len)
				to_chat(usr, "\red SDQL2: You have an error in your SDQL syntax, unmatched ' in query: \"<font color=gray>[query_text]</font>\". Please check your syntax, and try again.", confidential = TRUE)
				return null

			query_list += "[word]'"
			word = ""

		else if(char == "\"")
			if(word != "")
				to_chat(usr, "\red SDQL2: You have an error in your SDQL syntax, unexpected \" in query: \"<font color=gray>[query_text]</font>\" following \"<font color=gray>[word]</font>\". Please check your syntax, and try again.", confidential = TRUE)
				return null

			word = "\""

			for(i += length(char), i <= len, i += length(char))
				char = query_text[i]

				if(char == "\"")
					if((i + length(char) <= len) && query_text[i + length(char)] == "'")
						word += "\""
						i += length(query_text[i + length(char)])

					else
						break

				else
					word += char

			if(i > len)
				to_chat(usr, "\red SDQL2: You have an error in your SDQL syntax, unmatched \" in query: \"<font color=gray>[query_text]</font>\". Please check your syntax, and try again.", confidential = TRUE)
				return null

			query_list += "[word]\""
			word = ""

		else
			word += char

	if(word != "")
		query_list += word
	return query_list
