// Script -> BYOND code procs

// --- List operations (lists known as vectors in n_script) ---

// Clone of list()
/proc/n_list()
	var/list/returnlist = list()
	for(var/e in args)
		returnlist.Add(e)
	return returnlist

// Clone of pick()
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

// Clone of list[]
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

// Clone of list.Copy()
/proc/n_listcopy(var/list/L, var/start, var/end)
	if(!istype(L, /list)) return
	return L.Copy(start, end)

// Clone of list.Add()
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

// Clone of list.Remove()
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

// Clone of list.Cut()
/proc/n_listcut(var/list/L, var/start, var/end)
	if(!istype(L, /list)) return
	return L.Cut(start, end)

// Clone of list.Swap()
/proc/n_listswap(var/list/L, var/firstindex, var/secondindex)
	if(!istype(L, /list)) return
	if(L.len >= secondindex && L.len >= firstindex)
		return L.Swap(firstindex, secondindex)

// Clone of list.Insert()
/proc/n_listinsert(var/list/L, var/index, var/element)
	if(!istype(L, /list)) return
	return L.Insert(index, element)

// --- Miscellaneous functions ---

// Clone of sleep()
/proc/delay(var/time)
	sleep(time)

// Clone of prob()
/proc/prob_chance(var/chance)
	return prob(chance)

// Merge of list.Find() and findtext()
/proc/smartfind(var/haystack, var/needle, var/start = 1, var/end = 0)
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

// Clone of copytext()
/proc/docopytext(var/string, var/start = 1, var/end = 0)
	if(istext(string) && isnum(start) && isnum(end))
		if(start > 0)
			return copytext(string, start, end)

// Clone of length()
/proc/smartlength(var/container)
	if(container)
		if(istype(container, /list) || istext(container))
			return length(container)

// BY DONKIE~
// String stuff
/proc/n_lower(var/string)
	if(istext(string))
		return lowertext(string)

/proc/n_upper(var/string)
	if(istext(string))
		return uppertext(string)


//Makes a list where all indicies in a string is a seperate index in the list
// JUST A HELPER DON'T ADD TO NTSCRIPT
proc/string_tolist(var/string)
	var/list/L = new/list()

	var/i
	for(i=1, i<=lentext(string), i++)
		L.Add(copytext(string, i, i))

	return L

proc/string_explode(var/string, var/separator)
	if(istext(string))
		if(istext(separator) && separator == "")
			return string_tolist(string)

		var/i
		var/lasti = 1
		var/list/L = new/list()

		for(i=1, i<=lentext(string)+1, i++)
			if(copytext(string, i, i+1) == separator) // We found a separator
				L.Add(copytext(string, lasti, i))
				lasti = i+1

		L.Add(copytext(string, lasti, lentext(string)+1)) // Adds the last segment

		return L

proc/n_repeat(var/string, var/amount)
	if(istext(string) && isnum(amount))
		var/i
		var/newstring = ""
		for(i=0, i<=amount, i++)
			newstring = newstring + string

		return newstring

proc/n_reverse(var/string)
	if(istext(string))
		var/newstring = ""
		var/i
		for(i=lentext(string), i>0, i--)
			world << copytext(string, i, i+1)
			newstring = newstring + copytext(string, i, i+1)

		return newstring

// I don't know if it's neccesary to make my own proc, but I think I have to to be able to check for istext.
proc/n_str2num(var/string)
	if(istext(string))
		return text2num(string)

// Number shit
proc/n_num2str(var/num)
	if(isnum(num))
		return num2text(num)

// Squareroot
proc/n_sqrt(var/num)
	if(isnum(num))
		return sqrt(num)

// Magnitude of num
proc/n_abs(var/num)
	if(isnum(num))
		return abs(num)

// Round down
proc/n_floor(var/num)
	if(isnum(num))
		return round(num)

// Round up
proc/n_ceil(var/num)
	if(isnum(num))
		return round(num)+1

// Round to nearest integer
proc/n_round(var/num)
	if(isnum(num))
		if(num-round(num)<0.5)
			return round(num)
		return n_ceil(num)

// Clamps N between min and max
proc/n_clamp(var/num, var/min=-1, var/max=1)
	if(isnum(num)&&isnum(min)&&isnum(max))
		if(num<=min)
			return min
		if(num>=max)
			return max
		return num

// Returns 1 if N is inbetween Min and Max
proc/n_inrange(var/num, var/min=-1, var/max=1)
	if(isnum(num)&&isnum(min)&&isnum(max))
		return ((min <= num) && (num <= max))
// END OF BY DONKIE :(
