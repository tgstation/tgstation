// Script -> BYOND code procs
#define SCRIPT_MAX_REPLACEMENTS_ALLOWED 200


// --- List operations (lists known as vectors in n_script) ---

// Creates a list out of all the arguments
/proc/n_list()
	var/list/returnlist = list()
	for(var/e in args)
		returnlist.Add(e)
	return returnlist

// Picks one random item from the list
/proc/n_pick()
	var/list/finalpick = list()
	for(var/e in args)
		if(isobject(e))
			if(istype(e, /list))
				var/list/sublist = e
				for(var/sube in sublist)
					finalpick.Add(sube)
				continue
		finalpick.Add(e)

	return pick(finalpick)

// Gets/Sets a value at a key in the list
/proc/n_listpos(var/list/L, var/pos, var/value)
	if(!istype(L, /list)) return
	if(isnum(pos))
		if(!value)
			if(L.len >= pos)
				return L[pos]
		else
			if(L.len >= pos)
				L[pos] = value
	else if(istext(pos))
		if(!value)
			return L[pos]
		else
			L[pos] = value

// Copies the list into a new one
/proc/n_listcopy(var/list/L, var/start, var/end)
	if(!istype(L, /list)) return
	return L.Copy(start, end)

// Adds arg 2,3,4,5... to the end of list at arg 1
/proc/n_listadd()
	var/list/chosenlist
	var/i = 1
	for(var/e in args)
		if(i == 1)
			if(isobject(e))
				if(istype(e, /list))
					chosenlist = e
			i = 2
		else
			if(chosenlist)
				chosenlist.Add(e)

// Removes arg 2,3,4,5... from list at arg 1
/proc/n_listremove()
	var/list/chosenlist
	var/i = 1
	for(var/e in args)
		if(i == 1)
			if(isobject(e))
				if(istype(e, /list))
					chosenlist = e
			i = 2
		else
			if(chosenlist)
				chosenlist.Remove(e)

// Cuts out a copy of a list
/proc/n_listcut(var/list/L, var/start, var/end)
	if(!istype(L, /list)) return
	return L.Cut(start, end)

// Swaps two values in the list
/proc/n_listswap(var/list/L, var/firstindex, var/secondindex)
	if(!istype(L, /list)) return
	if(L.len >= secondindex && L.len >= firstindex)
		return L.Swap(firstindex, secondindex)

// Inserts a value into the list
/proc/n_listinsert(var/list/L, var/index, var/element)
	if(!istype(L, /list)) return
	return L.Insert(index, element)

// --- String methods ---

//If list, finds a value in it, if text, finds a substring in it
/proc/n_smartfind(var/haystack, var/needle, var/start = 1, var/end = 0)
	if(haystack && needle)
		if(isobject(haystack))
			if(istype(haystack, /list))
				if(length(haystack) >= end && start > 0)
					var/list/listhaystack = haystack
					return listhaystack.Find(needle, start, end)

		else
			if(istext(haystack))
				if(length(haystack) >= end && start > 0)
					return findtext(haystack, needle, start, end)

//Returns a substring of the string
/proc/n_substr(var/string, var/start = 1, var/end = 0)
	if(istext(string) && isnum(start) && isnum(end))
		if(start > 0)
			return copytext(string, start, end)

//Returns the length of the string or list
/proc/n_smartlength(var/container)
	if(container)
		if(istype(container, /list) || istext(container))
			return length(container)
	return 0

//Lowercase all characters
/proc/n_lower(var/string)
	if(istext(string))
		return lowertext(string)

//Uppercase all characters
/proc/n_upper(var/string)
	if(istext(string))
		return uppertext(string)

//Converts a string to a list
/proc/n_explode(var/string, var/separator = "")
	if(istext(string) && (istext(separator) || isnull(separator)))
		return text2list(string, separator)

//Converts a list to a string
/proc/n_implode(var/list/li, var/separator)
	if(istype(li) && (istext(separator) || isnull(separator)))
		return list2text(li, separator)

//Repeats the string x times
/proc/n_repeat(var/string, var/amount)
	if(istext(string) && isnum(amount))
		var/i
		var/newstring = ""
		if(length(newstring)*amount >=1000)
			return
		for(i=0, i<=amount, i++)
			if(i>=1000)
				break
			newstring = newstring + string

		return newstring

//Reverses the order of the string. "Clown" becomes "nwolC"
/proc/n_reverse(var/string)
	if(istext(string))
		var/newstring = ""
		var/i
		for(i=lentext(string), i>0, i--)
			if(i>=1000)
				break
			newstring = newstring + copytext(string, i, i+1)

		return newstring

// String -> Number
/proc/n_str2num(var/string)
	if(istext(string))
		return text2num(string)

/proc/n_proper(var/string)
	if(!istext(string))
		return ""

	return text("[][]", uppertext(copytext(string, 1, 2)), lowertext(copytext(string, 2)))

// --- Number methods ---

//Returns the highest value of the arguments
//Need custom functions here cause byond's min and max runtimes if you give them a string or list.
/proc/n_max()
	if(args.len == 0)
		return 0

	var/max = args[1]
	for(var/e in args)
		if(isnum(e) && e > max)
			max = e

	return max

//Returns the lowest value of the arguments
/proc/n_min()
	if(args.len == 0)
		return 0

	var/min = args[1]
	for(var/e in args)
		if(isnum(e) && e < min)
			min = e

	return min

/proc/n_prob(var/chance)
	return prob(chance)

/proc/n_randseed(var/seed)
	rand_seed(seed)
	return 0

/proc/n_rand(var/low, var/high)
	if(isnull(low) && isnull(high))
		return rand()

	return rand(low, high)

// Number -> String
/proc/n_num2str(var/num)
	if(isnum(num))
		return num2text(num)

// Squareroot
/proc/n_sqrt(var/num)
	if(isnum(num))
		return sqrt(num)

// Magnitude of num
/proc/n_abs(var/num)
	if(isnum(num))
		return abs(num)

// Round down
/proc/n_floor(var/num)
	if(isnum(num))
		return round(num)

// Round up
/proc/n_ceil(var/num)
	if(isnum(num))
		return round(num)+1

// Round to nearest integer
/proc/n_round(var/num)
	if(isnum(num))
		if(num-round(num)<0.5)
			return round(num)
		return n_ceil(num)

// Clamps N between min and max
/proc/n_clamp(var/num, var/min=-1, var/max=1)
	if(isnum(num)&&isnum(min)&&isnum(max))
		if(num<=min)
			return min
		if(num>=max)
			return max
		return num

// Returns 1 if N is inbetween Min and Max
/proc/n_inrange(var/num, var/min=-1, var/max=1)
	if(isnum(num)&&isnum(min)&&isnum(max))
		return ((min <= num) && (num <= max))

// Returns the sine of num
/proc/n_sin(var/num)
	if(isnum(num))
		return sin(num)

// Returns the cosine of num
/proc/n_cos(var/num)
	if(isnum(num))
		return cos(num)

// Returns the arcsine of num
/proc/n_asin(var/num)
	if(isnum(num)&&-1<=num&&num<=1)
		return arcsin(num)

// Returns the arccosine of num
/proc/n_acos(var/num)
	if(isnum(num)&&-1<=num&&num<=1)
		return arccos(num)

// Returns the natural log of num
/proc/n_log(var/num)
	if(isnum(num)&&0<num)
		return log(num)

// Replace text
/proc/n_replace(text, find, replacement)
	if(istext(text) && istext(find) && istext(replacement))
		var/find_len = length(find)
		if(find_len < 1)	return text
		. = ""
		var/last_found = 1
		var/count = 0
		while(1)
			count += 1
			if(count >  SCRIPT_MAX_REPLACEMENTS_ALLOWED)
				break
			var/found = findtext(text, find, last_found, 0)
			. += copytext(text, last_found, found)
			if(found)
				. += replacement
				last_found = found + find_len
				continue
			return

#undef SCRIPT_MAX_REPLACEMENTS_ALLOWED

// --- Miscellaneous functions ---

/proc/n_time()
	return world.timeofday

// Clone of sleep()
/proc/n_delay(var/time)
	sleep(time)
