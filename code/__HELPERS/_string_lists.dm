#define pick_list(FILE, KEY) (pick(strings(FILE, KEY)))

var/global/list/string_cache

/proc/strings(filename as text, key as text)
	var/list/fileList
	if(!string_cache)
		string_cache = new
	if(!(filename in string_cache))
		if(fexists("strings/[filename]"))
			string_cache[filename] = list()
			var/list/stringsList = list()
			fileList = file2list("strings/[filename]")
			for(var/s in fileList)
				stringsList = text2list(s, "@=")
				if(stringsList.len != 2)
					CRASH("Invalid string list in strings/[filename]")
				if(findtext(stringsList[2], "@,"))
					string_cache[filename][stringsList[1]] = text2list(stringsList[2], "@,")
				else
					string_cache[filename][stringsList[1]] = stringsList[2] // Its a single string!
		else
			CRASH("file not found: strings/[filename]")
	if((filename in string_cache) && (key in string_cache[filename]))
		return string_cache[filename][key]
	else
		CRASH("strings list not found: strings/[filename], index=[key]")
