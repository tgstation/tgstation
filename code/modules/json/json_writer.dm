#define LIST_FLAT 0
#define LIST_NESTED 1
#define LIST_OBJECT 2 //object in this case means json object, orther wise known as an associative list

json_writer/var/use_cache = 0
json_writer/proc/WriteObject(list/L)
	if(use_cache && L["__json_cache"])
		return L["__json_cache"]
	. = list()
	for(var/k in L)
		. += "\"[k]\":[write(L[k])]"
	
	. = "{[list2text(., ",")]}"
	

json_writer/proc/write(val)
	if(isnum(val))
		. = num2text(val)
	else if(isnull(val))
		. =  "null"
	else if(istype(val, /list))
		switch (listtype(val))
			if (LIST_FLAT)
				. = write_flat_array(val)
			if (LIST_NESTED)
				. = write_array(val)
			if (LIST_OBJECT)
				. = WriteObject(val)
	else
		. = write_string("[val]")

json_writer/proc/write_flat_array(list/L)
	. = "\[[list2text(L, ",")]]"

json_writer/proc/write_array(list/L)
	. = list()
	for(var/item in L)
		. += write(item)
	. = "\[[list2text(., ",")]]"

json_writer/proc/write_string(txt)
	var/static/list/json_escape = list("\\" = "\\\\", "\"" = "\\\"", "\n" = "\\n")
	for(var/targ in json_escape)
		var/start = 1
		while(start <= lentext(txt))
			var/i = findtext(txt, targ, start)
			if(!i)
				break
			var/lrep = length(json_escape[targ])
			txt = "[copytext(txt, 1, i)][json_escape[targ]][copytext(txt, i + length(targ))]"
			start = i + lrep

	return {""[txt]""}

json_writer/proc/listtype(list/L)
	. = LIST_FLAT	
	for(var/key in L)
		if (. == LIST_FLAT && istype(key, /list))
			. = LIST_NESTED
		if (!isnum(key) && !isnull(L[key]) && !istype(key, /list))
			. = LIST_OBJECT
			break // if it's an object, we can just stop now
			
		
#undef LIST_FLAT
#undef LIST_NESTED
#undef LIST_OBJECT 
