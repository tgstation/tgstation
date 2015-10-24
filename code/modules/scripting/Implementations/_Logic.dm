// Script -> BYOND code procs
#define SCRIPT_MAX_REPLACEMENTS_ALLOWED 200
// --- List operations (lists known as vectors in n_script) ---

// Clone of list()
/proc/n_list()
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/n_list() called tick#: [world.time]")
	var/list/returnlist = list()
	for(var/e in args)
		returnlist.Add(e)
	return returnlist

// Clone of pick()
/proc/n_pick()
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/n_pick() called tick#: [world.time]")
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
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/n_listpos() called tick#: [world.time]")
	if(!istype(L, /list)) return
	if(isnum(pos))
		if(!value)
			if(L.len >= pos && !(pos > L.len))
				return L[pos]
		else
			if(L.len >= pos && !(pos > L.len))
				L[pos] = value
	else if(istext(pos))
		if(!value)
			return L[pos]
		else
			L[pos] = value

// Clone of list.Copy()
/proc/n_listcopy(var/list/L, var/start, var/end)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/n_listcopy() called tick#: [world.time]")
	if(!istype(L, /list)) return
	return L.Copy(start, end)

// Clone of list.Add()
/proc/n_listadd()
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/n_listadd() called tick#: [world.time]")
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
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/n_listremove() called tick#: [world.time]")
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

// Clone of list.len = 0
/proc/n_listcut(var/list/L, var/start, var/end)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/n_listcut() called tick#: [world.time]")
	if(!istype(L, /list)) return
	return L.Cut(start, end)

// Clone of list.Swap()
/proc/n_listswap(var/list/L, var/firstindex, var/secondindex)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/n_listswap() called tick#: [world.time]")
	if(!istype(L, /list)) return
	if(L.len >= secondindex && L.len >= firstindex)
		return L.Swap(firstindex, secondindex)

// Clone of list.Insert()
/proc/n_listinsert(var/list/L, var/index, var/element)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/n_listinsert() called tick#: [world.time]")
	if(!istype(L, /list)) return
	return L.Insert(index, element)

// --- Miscellaneous functions ---

// Clone of sleep()
/proc/delay(var/time)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/delay() called tick#: [world.time]")
	sleep(time)

// Clone of rand()
/proc/rand_chance(var/low = 0, var/high)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/rand_chance() called tick#: [world.time]")
	return rand(low, high)

// Clone of prob()
/proc/prob_chance(var/chance)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/prob_chance() called tick#: [world.time]")
	return prob(chance)

// Merge of list.Find() and findtext()
/proc/smartfind(var/haystack, var/needle, var/start = 1, var/end = 0)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/smartfind() called tick#: [world.time]")
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
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/docopytext() called tick#: [world.time]")
	if(istext(string) && isnum(start) && isnum(end))
		if(start > 0)
			return copytext(string, start, end)

// Clone of length()
/proc/smartlength(var/container)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/smartlength() called tick#: [world.time]")
	if(container)
		if(istype(container, /list) || istext(container))
			return length(container)
	return 0

// BY DONKIE~
// String stuff
/proc/n_lower(var/string)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/n_lower() called tick#: [world.time]")
	if(istext(string))
		return lowertext(string)

/proc/n_upper(var/string)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/n_upper() called tick#: [world.time]")
	if(istext(string))
		return uppertext(string)

/proc/time()
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/time() called tick#: [world.time]")
	return world.time + (12 HOURS)

/proc/timestamp(var/format = "hh:mm:ss") // Get the game time in text
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/timestamp() called tick#: [world.time]")
	return time2text(world.time + (10 HOURS), format) // Yes, 10, not 12 hours, for some reason time2text() is being moronic (T-thanks BYOND), and it's adding 2 hours to this, I don't even know either.

proc/string_explode(var/string, var/separator = "")
	//writepanic("[__FILE__].[__LINE__] \\/proc/string_explode() called tick#: [world.time]")
	if(istext(string) && (istext(separator) || isnull(separator)))
		return text2list(string, separator)

proc/n_repeat(var/string, var/amount)
	//writepanic("[__FILE__].[__LINE__] \\/proc/n_repeat() called tick#: [world.time]")
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

// I don't know if it's neccesary to make my own proc, but I think I have to to be able to check for istext.
proc/n_str2num(var/string)
	//writepanic("[__FILE__].[__LINE__] \\/proc/n_str2num() called tick#: [world.time]")
	if(istext(string))
		return text2num(string)

// Clamps N between min and max
/proc/n_clamp(var/num, var/min = 0, var/max = 1)
	if(isnum(num) && isnum(min) && isnum(max))
		return Clamp(num, min, max)

// Number shit
proc/n_num2str(var/num)
	//writepanic("[__FILE__].[__LINE__] \\/proc/n_num2str() called tick#: [world.time]")
	if(isnum(num))
		return num2text(num)

// Squareroot
proc/n_sqrt(var/num)
	//writepanic("[__FILE__].[__LINE__] \\/proc/n_sqrt() called tick#: [world.time]")
	if(isnum(num))
		return sqrt(num)

// Magnitude of num
proc/n_abs(var/num)
	//writepanic("[__FILE__].[__LINE__] \\/proc/n_abs() called tick#: [world.time]")
	if(isnum(num))
		return abs(num)

// Round down
proc/n_floor(var/num)
	//writepanic("[__FILE__].[__LINE__] \\/proc/n_floor() called tick#: [world.time]")
	if(isnum(num))
		return round(num)

// Round up
proc/n_ceil(var/num)
	//writepanic("[__FILE__].[__LINE__] \\/proc/n_ceil() called tick#: [world.time]")
	if(isnum(num))
		return round(num)+1

// Round to nearest integer
proc/n_round(var/num)
	//writepanic("[__FILE__].[__LINE__] \\/proc/n_round() called tick#: [world.time]")
	if(isnum(num))
		if(num-round(num)<0.5)
			return round(num)
		return n_ceil(num)

// END OF BY DONKIE :(

/proc/n_sin(var/const/x)
	return sin(x)

/proc/n_cos(var/const/x)
	return cos(x)

/proc/n_asin(var/const/x)
	return arcsin(x)

/proc/n_acos(var/const/x)
	return arccos(x)


/proc/n_max(...)
	return max(arglist(args))

/proc/n_min(...)
	return min(arglist(args))