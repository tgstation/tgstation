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
	return world.timeofday

/proc/timestamp(var/format = "hh:mm:ss") // Get the game time in text
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/timestamp() called tick#: [world.time]")
	return time2text(world.time + 432000, format)

/*
//Makes a list where all indicies in a string is a seperate index in the list
// JUST A HELPER DON'T ADD TO NTSCRIPT
proc/string_tolist(var/string)
	//writepanic("[__FILE__].[__LINE__] \\/proc/string_tolist() called tick#: [world.time]")
	var/list/L = new/list()

	var/i
	for(i=1, i<=length(string), i++)
		L.Add(copytext(string, i, i))

	return L

proc/string_explode(var/string, var/separator)
	//writepanic("[__FILE__].[__LINE__] \\/proc/string_explode() called tick#: [world.time]")
	if(istext(string))
		if(istext(separator) && separator == "")
			return string_tolist(string)
		var/i
		var/lasti = 1
		var/list/L = new/list()

		for(i=1, i<=length(string)+1, i++)
			if(copytext(string, i, i+1) == separator) // We found a separator
				L.Add(copytext(string, lasti, i))
				lasti = i+1

		L.Add(copytext(string, lasti, length(string)+1)) // Adds the last segment

		return L

Just found out there was already a string explode function, did some benchmarking, and that function were a bit faster, sticking to that.
*/


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

proc/n_reverse(var/string)
	//writepanic("[__FILE__].[__LINE__] \\/proc/n_reverse() called tick#: [world.time]")
	if(istext(string))
		var/newstring = ""
		var/i
		for(i=length(string), i>0, i--)
			if(i>=1000)
				break
			newstring = newstring + copytext(string, i, i+1)

		return newstring

// I don't know if it's neccesary to make my own proc, but I think I have to to be able to check for istext.
proc/n_str2num(var/string)
	//writepanic("[__FILE__].[__LINE__] \\/proc/n_str2num() called tick#: [world.time]")
	if(istext(string))
		return text2num(string)

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

// Clamps N between min and max
proc/n_clamp(var/num, var/min=-1, var/max=1)
	//writepanic("[__FILE__].[__LINE__] \\/proc/n_clamp() called tick#: [world.time]")
	if(isnum(num)&&isnum(min)&&isnum(max))
		if(num<=min)
			return min
		if(num>=max)
			return max
		return num

// Returns 1 if N is inbetween Min and Max
proc/n_inrange(var/num, var/min=-1, var/max=1)
	//writepanic("[__FILE__].[__LINE__] \\/proc/n_inrange() called tick#: [world.time]")
	if(isnum(num)&&isnum(min)&&isnum(max))
		return ((min <= num) && (num <= max))
// END OF BY DONKIE :(

// Non-recursive
// Imported from Mono string.ReplaceUnchecked
/*
/proc/string_replacetext(var/haystack,var/a,var/b)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/proc/string_replacetext() called tick#: [world.time]")
	if(istext(haystack)&&istext(a)&&istext(b))
		var/i = 1
		var/lenh=length(haystack)
		var/lena=length(a)
		//var/lenb=length(b)
		var/count = 0
		var/list/dat = list()
		while (i < lenh)
			var/found = findtext(haystack, a, i, 0)
			//diary << "findtext([haystack], [a], [i], 0)=[found]"
			if (found == 0) // Not found
				break
			else
				if (count < SCRIPT_MAX_REPLACEMENTS_ALLOWED)
					dat+=found
					count+=1
				else
					//diary << "Script found [a] [count] times, aborted"
					break
			//diary << "Found [a] at [found]! Moving up..."
			i = found + lena
		if (count == 0)
			return haystack
		//var/nlen = lenh + ((lenb - lena) * count)
		var/buf = copytext(haystack,1,dat[1]) // Prefill
		var/lastReadPos = 0
		for (i = 1, i <= count, i++)
			var/precopy = dat[i] - lastReadPos-1
			//internal static unsafe void CharCopy (String target, int targetIndex, String source, int sourceIndex, int count)
			//fixed (char* dest = target, src = source)
			//CharCopy (dest + targetIndex, src + sourceIndex, count);
			//CharCopy (dest + curPos, source + lastReadPos, precopy);
			buf+=copytext(haystack,lastReadPos,precopy)
			diary << "buf+=copytext([haystack],[lastReadPos],[precopy])"
			diary<<"[buf]"
			lastReadPos = dat[i] + lena
			//CharCopy (dest + curPos, replace, newValue.length);
			buf+=b
			diary<<"[buf]"
		buf+=copytext(haystack,lastReadPos, 0)
		return buf
*/

/proc/string_replacetext(text, find, replacement)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/string_replacetext() called tick#: [world.time]")
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