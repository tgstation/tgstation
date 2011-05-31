/proc/hex2num(hex)

	if (!( istext(hex) ))
		CRASH("hex2num not given a hexadecimal string argument (user error)")
		return
	var/num = 0
	var/power = 0
	var/i = null
	i = length(hex)
	while(i > 0)
		var/char = copytext(hex, i, i + 1)
		switch(char)
			if("0")
				//Apparently, switch works with empty statements, yay! If that doesn't work, blame me, though. -- Urist
			if("9", "8", "7", "6", "5", "4", "3", "2", "1")
				num += text2num(char) * 16 ** power
			if("a", "A")
				num += 16 ** power * 10
			if("b", "B")
				num += 16 ** power * 11
			if("c", "C")
				num += 16 ** power * 12
			if("d", "D")
				num += 16 ** power * 13
			if("e", "E")
				num += 16 ** power * 14
			if("f", "F")
				num += 16 ** power * 15
			else
				CRASH("hex2num given non-hexadecimal string (user error)")
				return
		power++
		i--
	return num

/proc/num2hex(num, placeholder)

	if (placeholder == null)
		placeholder = 2
	if (!( isnum(num) ))
		CRASH("num2hex not given a numeric argument (user error)")
		return
	if (!( num ))
		return "0"
	var/hex = ""
	var/i = 0
	while(16 ** i < num)
		i++
	var/power = null
	power = i - 1
	while(power >= 0)
		var/val = round(num / 16 ** power)
		num -= val * 16 ** power
		switch(val)
			if(9.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 0.0)
				hex += text("[]", val)
			if(10.0)
				hex += "A"
			if(11.0)
				hex += "B"
			if(12.0)
				hex += "C"
			if(13.0)
				hex += "D"
			if(14.0)
				hex += "E"
			if(15.0)
				hex += "F"
			else
		power--
	while(length(hex) < placeholder)
		hex = text("0[]", hex)
	return hex

/proc/invertHTML(HTMLstring)

	if (!( istext(HTMLstring) ))
		CRASH("Given non-text argument!")
		return
	else
		if (length(HTMLstring) != 7)
			CRASH("Given non-HTML argument!")
			return
	var/textr = copytext(HTMLstring, 2, 4)
	var/textg = copytext(HTMLstring, 4, 6)
	var/textb = copytext(HTMLstring, 6, 8)
	var/r = hex2num(textr)
	var/g = hex2num(textg)
	var/b = hex2num(textb)
	textr = num2hex(255 - r)
	textg = num2hex(255 - g)
	textb = num2hex(255 - b)
	if (length(textr) < 2)
		textr = text("0[]", textr)
	if (length(textg) < 2)
		textr = text("0[]", textg)
	if (length(textb) < 2)
		textr = text("0[]", textb)
	return text("#[][][]", textr, textg, textb)
	return

/proc/shuffle(var/list/shufflelist)
	if(!shufflelist)
		return
	var/list/new_list = list()
	var/list/old_list = shufflelist.Copy()
	while(old_list.len)
		var/item = pick(old_list)
		new_list += item
		old_list -= item
	return new_list

/proc/uniquelist(var/list/L)
	var/list/K = list()
	for(var/item in L)
		if(!(item in K))
			K += item
	return K

/proc/sanitize(var/t)
	var/index = findtext(t, "\n")
	while(index)
		t = copytext(t, 1, index) + "#" + copytext(t, index+1)
		index = findtext(t, "\n")

	index = findtext(t, "\t")
	while(index)
		t = copytext(t, 1, index) + "#" + copytext(t, index+1)
		index = findtext(t, "\t")

	index = findtext(t, "ÿ")
	while(index)
		t = copytext(t, 1, index) + "ß" + copytext(t, index+1)
		index = findtext(t, "ÿ")

	return html_encode(t)

/proc/strip_html(var/t,var/limit=MAX_MESSAGE_LEN)
	t = copytext(t,1,limit)
	var/index = findtext(t, "<")
	while(index)
		t = copytext(t, 1, index) + copytext(t, index+1)
		index = findtext(t, "<")
	index = findtext(t, ">")
	while(index)
		t = copytext(t, 1, index) + copytext(t, index+1)
		index = findtext(t, ">")
	return sanitize(t)

/proc/adminscrub(var/t,var/limit=MAX_MESSAGE_LEN)
	t = copytext(t,1,limit)
	var/index = findtext(t, "<")
	while(index)
		t = copytext(t, 1, index) + copytext(t, index+1)
		index = findtext(t, "<")
	index = findtext(t, ">")
	while(index)
		t = copytext(t, 1, index) + copytext(t, index+1)
		index = findtext(t, ">")
	return html_encode(t)

/proc/add_zero(t, u)
	while (length(t) < u)
		t = "0[t]"
	return t

/proc/add_lspace(t, u)
	while(length(t) < u)
		t = " [t]"
	return t

/proc/add_tspace(t, u)
	while(length(t) < u)
		t = "[t] "
	return t

/proc/trim_left(text)
	for (var/i = 1 to length(text))
		if (text2ascii(text, i) > 32)
			return copytext(text, i)
	return ""

/proc/trim_right(text)
	for (var/i = length(text), i > 0, i--)
		if (text2ascii(text, i) > 32)
			return copytext(text, 1, i + 1)

	return ""

/proc/trim(text)
	return trim_left(trim_right(text))

/proc/capitalize(var/t as text)
	return uppertext(copytext(t, 1, 2)) + copytext(t, 2)

/proc/sortList(var/list/L)
	if(L.len < 2)
		return L
	var/middle = L.len / 2 + 1 // Copy is first,second-1
	return mergeLists(sortList(L.Copy(0,middle)), sortList(L.Copy(middle))) //second parameter null = to end of list

/proc/sortNames(var/list/L)
	var/list/Q = new()
	for(var/atom/x in L)
		Q[x.name] = x
	return sortList(Q)

/proc/mergeLists(var/list/L, var/list/R)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	while(Li <= L.len && Ri <= R.len)
		if(sorttext(L[Li], R[Ri]) < 1)
			result += R[Ri++]
		else
			result += L[Li++]

	if(Li <= L.len)
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

/proc/dd_file2list(file_path, separator)
	var/file
	if(separator == null)
		separator = "\n"
	if(isfile(file_path))
		file = file_path
	else
		file = file(file_path)
	return dd_text2list(file2text(file), separator)

/proc/dd_range(var/low, var/high, var/num)
	return max(low,min(high,num))

/proc/dd_replacetext(text, search_string, replacement_string)
	var/textList = dd_text2list(text, search_string)
	return dd_list2text(textList, replacement_string)

/proc/dd_replaceText(text, search_string, replacement_string)
	var/textList = dd_text2List(text, search_string)
	return dd_list2text(textList, replacement_string)

/proc/dd_hasprefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtext(text, prefix, start, end)

/proc/dd_hasPrefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtext(text, prefix, start, end) //was findtextEx

/proc/dd_hassuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtext(text, suffix, start, null)
	return

/proc/dd_hasSuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtext(text, suffix, start, null) //was findtextEx

/proc/dd_text2list(text, separator, var/list/withinList)
	var/textlength = length(text)
	var/separatorlength = length(separator)
	if(withinList && !withinList.len) withinList = null
	var/list/textList = new()
	var/searchPosition = 1
	var/findPosition = 1
	while(1)
		findPosition = findtext(text, separator, searchPosition, 0)
		var/buggyText = copytext(text, searchPosition, findPosition)
		if(!withinList || (buggyText in withinList)) textList += "[buggyText]"
		if(!findPosition) return textList
		searchPosition = findPosition + separatorlength
		if(searchPosition > textlength)
			textList += ""
			return textList
	return

/proc/dd_text2List(text, separator, var/list/withinList)
	var/textlength = length(text)
	var/separatorlength = length(separator)
	if(withinList && !withinList.len) withinList = null
	var/list/textList = new()
	var/searchPosition = 1
	var/findPosition = 1
	while(1)
		findPosition = findtext(text, separator, searchPosition, 0) //was findtextEx
		var/buggyText = copytext(text, searchPosition, findPosition)
		if(!withinList || (buggyText in withinList)) textList += "[buggyText]"
		if(!findPosition) return textList
		searchPosition = findPosition + separatorlength
		if(searchPosition > textlength)
			textList += ""
			return textList
	return

/proc/dd_list2text(var/list/the_list, separator)
	var/total = the_list.len
	if(!total)
		return
	var/count = 2
	var/newText = "[the_list[1]]"
	while(count <= total)
		if(separator)
			newText += separator
		newText += "[the_list[count]]"
		count++
	return newText

/proc/english_list(var/list/input, nothing_text = "nothing", and_text = " and ", comma_text = ", ", final_comma_text = "," )
	var/total = input.len
	if (!total)
		return "[nothing_text]"
	else if (total == 1)
		return "[input[1]]"
	else if (total == 2)
		return "[input[1]][and_text][input[2]]"
	else
		var/output = ""
		var/index = 1
		while (index < total)
			if (index == total - 1)
				comma_text = final_comma_text

			output += "[input[index]][comma_text]"
			index++

		return "[output][and_text][input[index]]"

/proc/dd_centertext(message, length)
	var/new_message = message
	var/size = length(message)
	var/delta = length - size
	if(size == length)
		return new_message
	if(size > length)
		return copytext(new_message, 1, length + 1)
	if(delta == 1)
		return new_message + " "
	if(delta % 2)
		new_message = " " + new_message
		delta--
	var/spaces = add_lspace("",delta/2-1)
	return spaces + new_message + spaces

/proc/dd_limittext(message, length)
	var/size = length(message)
	if(size <= length)
		return message
	return copytext(message, 1, length + 1)

/proc/angle2dir(var/degree)
	degree = ((degree+22.5)%365)
	if(degree < 45)		return NORTH
	if(degree < 90)		return NORTH|EAST
	if(degree < 135)	return EAST
	if(degree < 180)	return SOUTH|EAST
	if(degree < 225)	return SOUTH
	if(degree < 270)	return SOUTH|WEST
	if(degree < 315)	return WEST
	return NORTH|WEST

//Returns direction that the mob or whomever should be facing in relation to the target.
//This proc does not grant absolute direction and is mostly useful for 8dir sprite positioning.
//I personally used it with getline() to great effect.
/proc/get_dir_to(turf/start,turf/end)//N
	var/xdiff = start.x - end.x//The sign is important.
	var/ydiff = start.y - end.y

	var/direction_x = xdiff<1 ? 4:8//East - west
	var/direction_y = ydiff<1 ? 1:2//North - south
	var/direction_xy = xdiff==0 ? -4:0//If x is the same, subtract 4.
	var/direction_yx = ydiff==0 ? -1:0//If y is the same, subtract 1.
	var/direction_f = direction_x+direction_y+direction_xy+direction_yx//Finally direction tally.
	direction_f = direction_f==0 ? 1:direction_f//If direction is 0(same spot), return north. Otherwise, direction.

	return direction_f

//Returns location. Returns null if no location was found.
/proc/get_teleport_loc(turf/location,mob/target,distance = 1, density = 0, errorx = 0, errory = 0, eoffsetx = 0, eoffsety = 0)
//Location where the teleport begins, target that will teleport, distance to go, density checking 0/1(yes/no).
//Random error in tile placement x, error in tile placement y, and block offset.
//Block offset tells the proc how to place the box. Behind teleport location, relative to starting location, forward, etc.
//Negative values for offset are accepted, think of it in relation to North, -x is west, -y is south. Error defaults to positive.
//Turf and target are seperate in case you want to teleport some distance from a turf the target is not standing on or something.

	var/dirx = 0//Generic location finding variable.
	var/diry = 0

	var/xoffset = 0//Generic counter for offset location.
	var/yoffset = 0

	var/b1xerror = 0//Generic placing for point A in box. The lower left.
	var/b1yerror = 0
	var/b2xerror = 0//Generic placing for point B in box. The upper right.
	var/b2yerror = 0

	errorx = abs(errorx)//Error should never be negative.
	errory = abs(errory)
	//var/errorxy = round((errorx+errory)/2)//Used for diagonal boxes.

	switch(target.dir)//This can be done through equations but switch is the simpler method. And works fast to boot.
	//Directs on what values need modifying.
		if(1)//North
			diry+=distance
			yoffset+=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(2)//South
			diry-=distance
			yoffset-=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(4)//East
			dirx+=distance
			yoffset+=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx
		if(8)//West
			dirx-=distance
			yoffset-=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx

	var/turf/destination=locate(location.x+dirx,location.y+diry,location.z)

	if(destination)//If there is a destination.
		if(errorx||errory)//If errorx or y were specified.
			var/destination_list[] = list()//To add turfs to list.
			//destination_list = new()
			/*This will draw a block around the target turf, given what the error is.
			Specifying the values above will basically draw a different sort of block.
			If the values are the same, it will be a square. If they are different, it will be a rectengle.
			In either case, it will center based on offset. Offset is position from center.
			Offset always calculates in relation to direction faced. In other words, depending on the direction of the teleport,
			the offset should remain positioned in relation to destination.*/

			var/turf/center = locate((destination.x+xoffset),(destination.y+yoffset),location.z)//So now, find the new center.

			//Now to find a box from center location and make that our destination.
			for(var/turf/T in block(locate(center.x+b1xerror,center.y+b1yerror,location.z), locate(center.x+b2xerror,center.y+b2yerror,location.z) ))
				if(density&&T.density)	continue//If density was specified.
				if(T.x>world.maxx || T.x<1)	continue//Don't want them to teleport off the map.
				if(T.y>world.maxy || T.y<1)	continue
				destination_list += T
			if(destination_list.len)
				destination = pick(destination_list)
			else	return

		else//Same deal here.
			if(density&&destination.density)	return
			if(destination.x>world.maxx || destination.x<1)	return
			if(destination.y>world.maxy || destination.y<1)	return
	else	return

	return destination

/proc/angle2text(var/degree)
	return dir2text(angle2dir(degree))

/proc/text_input(var/Message, var/Title, var/Default, var/length=MAX_MESSAGE_LEN)
	return sanitize(input(Message, Title, Default) as text, length)

/proc/scrub_input(var/Message, var/Title, var/Default, var/length=MAX_MESSAGE_LEN)
	return strip_html(input(Message,Title,Default) as text, length)

/proc/InRange(var/A, var/lower, var/upper)
	if(A < lower) return 0
	if(A > upper) return 0
	return 1

/proc/LinkBlocked(turf/A, turf/B)
	if(A == null || B == null) return 1
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if((adir & (NORTH|SOUTH)) && (adir & (EAST|WEST)))	//	diagonal
		var/iStep = get_step(A,adir&(NORTH|SOUTH))
		if(!LinkBlocked(A,iStep) && !LinkBlocked(iStep,B)) return 0

		var/pStep = get_step(A,adir&(EAST|WEST))
		if(!LinkBlocked(A,pStep) && !LinkBlocked(pStep,B)) return 0
		return 1

	if(DirBlocked(A,adir)) return 1
	if(DirBlocked(B,rdir)) return 1
	return 0


/proc/DirBlocked(turf/loc,var/dir)
	for(var/obj/window/D in loc)
		if(!D.density)			continue
		if(D.dir == SOUTHWEST)	return 1
		if(D.dir == dir)		return 1

	for(var/obj/machinery/door/D in loc)
		if(!D.density)			continue
		if(istype(D, /obj/machinery/door/window))
			if((dir & SOUTH) && (D.dir & (EAST|WEST)))		return 1
			if((dir & EAST ) && (D.dir & (NORTH|SOUTH)))	return 1
		else return 1	// it's a real, air blocking door
	return 0

/proc/TurfBlockedNonWindow(turf/loc)
	for(var/obj/O in loc)
		if(O.density && !istype(O, /obj/window))
			return 1
	return 0

/proc/sign(x) //Should get bonus points for being the most compact code in the world!
	return x!=0?x/abs(x):0 //((x<0)?-1:((x>0)?1:0))

/*	//Kelson's version (doesn't work)
/proc/getline(atom/M,atom/N)
	if(!M || !M.loc) return
	if(!N || !N.loc) return
	if(M.z != N.z) return
	var/line = new/list()

	var/dx = abs(M.x - N.x)
	var/dy = abs(M.y - N.y)
	var/cx = M.x < N.x ? 1 : -1
	var/cy = M.y < N.y ? 1 : -1
	var/slope = dy ? dx/dy : INFINITY

	var/tslope = slope
	var/turf/tloc = M.loc

	while(tloc != N.loc)
		if(tslope>0)
			--tslope
			tloc = locate(tloc.x+cx,tloc.y,tloc.z)
		else
			tslope += slope
			tloc = locate(tloc.x,tloc.y+cy,tloc.z)
		line += tloc
	return line
*/

/proc/getline(atom/M,atom/N)//Ultra-Fast Bresenham Line-Drawing Algorithm
	var/px=M.x		//starting x
	var/py=M.y
	var/line[] = list(locate(px,py,M.z))
	var/dx=N.x-px	//x distance
	var/dy=N.y-py
	var/dxabs=abs(dx)//Absolute value of x distance
	var/dyabs=abs(dy)
	var/sdx=sign(dx)	//Sign of x distance (+ or -)
	var/sdy=sign(dy)
	var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
	var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
	var/j			//Generic integer for counting
	if(dxabs>=dyabs)	//x distance is greater than y
		for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
			y+=dyabs
			if(y>=dxabs)	//Every dyabs steps, step once in y direction
				y-=dxabs
				py+=sdy
			px+=sdx		//Step on in x direction
			line+=locate(px,py,M.z)//Add the turf to the list
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
			py+=sdy
			line+=locate(px,py,M.z)
	return line

/proc/IsGuestKey(key)
	if (findtext(key, "Guest-", 1, 7) != 1) //was findtextEx
		return 0

	var/i, ch, len = length(key)

	for (i = 7, i <= len, ++i)
		ch = text2ascii(key, i)
		if (ch < 48 || ch > 57)
			return 0

	return 1

/proc/pickweight(list/L)
	var/total = 0
	var/item
	for (item in L)
		if (!L[item])
			L[item] = 1
		total += L[item]

	total = rand(1, total)
	for (item in L)
		total -=L [item]
		if (total <= 0)
			return item

	return null

/proc/sanitize_frequency(var/f)
	f = round(f)
	f = max(1441, f) // 144.1
	f = min(1489, f) // 148.9
	if ((f % 2) == 0)
		f += 1
	return f

/proc/format_frequency(var/f)
	return "[round(f / 10)].[f % 10]"

/proc/ainame(var/mob/M as mob)
	var/randomname = M.name
	var/time_passed = world.time//Pretty basic but it'll do. It's still possible to bypass this by return ainame().
	var/newname = input(M,"You are the AI. Would you like to change your name to something else?", "Name change",randomname)
	if((world.time-time_passed)>200)//If more than 20 game seconds passed.
		M << "You took too long to decide. Default name selected."
		return

	if (length(newname) == 0)
		newname = randomname

	if (newname)
		if (newname == "Inactive AI")//Keeping this here to prevent dumb.
			M << "That name is reserved."
			return ainame(M)
		for (var/mob/living/silicon/ai/A in world)
			if (A.real_name == newname&&newname!=randomname)
				M << "There's already an AI with that name."
				return ainame(M)
		if (length(newname) >= 26)
			newname = copytext(newname, 1, 26)
		newname = dd_replacetext(newname, ">", "'")
		M.real_name = newname
		M.name = newname

/proc/clname(var/mob/M as mob) //--All praise goes to NEO|Phyte, all blame goes to DH, and it was Cindi-Kate's idea
	var/randomname = pick(clown_names)
	var/newname = input(M,"You are the clown. Would you like to change your name to something else?", "Name change",randomname)
	var/oldname = M.real_name

	if (length(newname) == 0)
		newname = randomname

	if (newname)
		if (newname == "Unknown")
			M << "That name is reserved."
			return clname(M)
		for (var/mob/living/carbon/A in world)
			if (A.real_name == newname)
				M << "There's already a clown with that name."
				return clname(M)
		if (length(newname) >= 26)
			newname = copytext(newname, 1, 26)
		newname = dd_replacetext(newname, ">", "'")
		M.real_name = newname
		M.name = newname

	for (var/obj/item/device/pda/pda in M.contents)
		if (pda.owner == oldname)
			pda.owner = newname
			pda.name = "PDA-[newname] ([pda.ownjob])"
			break
	for(var/obj/item/weapon/card/id/id in M.contents)
		if(id.registered == oldname)
			id.registered = newname
			id.name = "[id.registered]'s ID Card ([id.assignment])"
			break

/proc/ionnum()
	return "[pick("!","@","#","$","%","^","&","*")][pick(pick("!","@","#","$","%","^","&","*"))][pick(pick("!","@","#","$","%","^","&","*"))][pick(pick("!","@","#","$","%","^","&","*"))]"

/proc/freeborg()
	var/select = null
	var/list/names = list()
	var/list/borgs = list()
	var/list/namecounts = list()
	for (var/mob/living/silicon/robot/A in world)
		var/name = A.real_name
		if (A.stat == 2)
			continue
		if (A.connected_ai)
			continue
		else
			if(A.module)
				name += " ([A.module.name])"
			names.Add(name)
			namecounts[name] = 1
		borgs[name] = A

	if (borgs.len)
		select = input("Unshackled borg signals detected:", "Borg selection", null, null) as null|anything in borgs
		return borgs[select]

/proc/activeais()
	var/select = null
	var/list/names = list()
	var/list/ais = list()
	var/list/namecounts = list()
	for (var/mob/living/silicon/ai/A in world)
		var/name = A.real_name
		if (A.stat == 2)
			continue
		if (A.control_disabled == 1)
			continue
		else
			names.Add(name)
			namecounts[name] = 1
		ais[name] = A

	if (ais.len)
		select = input("AI signals detected:", "AI selection") in ais
		return ais[select]

/proc/getmobs()

	var/list/mobs = sortmobs()
	var/list/names = list()
	var/list/creatures = list()
	var/list/namecounts = list()
	for(var/mob/M in mobs)
		var/name = M.name
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if (M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
		if (M.stat == 2)
			if(istype(M, /mob/dead/observer/))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		creatures[name] = M

	return creatures

/proc/sortmobs()

	var/list/mob_list = list()
	for(var/mob/living/silicon/ai/M in world)
		mob_list.Add(M)
	for(var/mob/living/silicon/pai/M in world)
		mob_list.Add(M)
	for(var/mob/living/silicon/robot/M in world)
		mob_list.Add(M)
	for(var/mob/living/carbon/human/M in world)
		mob_list.Add(M)
	for(var/mob/living/carbon/alien/M in world)
		mob_list.Add(M)
	for(var/mob/dead/observer/M in world)
		mob_list.Add(M)
	for(var/mob/new_player/M in world)
		mob_list.Add(M)
	for(var/mob/living/carbon/monkey/M in world)
		mob_list.Add(M)
	for(var/mob/living/silicon/hivebot/M in world)
		mob_list.Add(M)
	for(var/mob/living/silicon/hive_mainframe/M in world)
		mob_list.Add(M)
	return mob_list

/proc/convert2energy(var/M)
	var/E = M*(SPEED_OF_LIGHT_SQ)
	return E

/proc/convert2mass(var/E)
	var/M = E/(SPEED_OF_LIGHT_SQ)
	return M

/proc/modulus(var/M)
	if(M >= 0)
		return M
	if(M < 0)
		return -M


/proc/key_name(var/whom, var/include_link = null, var/include_name = 1)
	var/mob/the_mob = null
	var/client/the_client = null
	var/the_key = ""

	if (isnull(whom))
		return "*null*"
	else if (istype(whom, /client))
		the_client = whom
		the_mob = the_client.mob
		the_key = the_client.key
	else if (ismob(whom))
		the_mob = whom
		the_client = the_mob.client
		the_key = the_mob.key
	else if (istype(whom, /datum))
		var/datum/the_datum = whom
		return "*invalid:[the_datum.type]*"
	else
		return "*invalid*"

	var/text = ""

	if (!the_key)
		text += "*no client*"
	else
		if (include_link && !isnull(the_mob))
			if (istext(include_link))
				text += "<a href=\"byond://?src=[include_link];priv_msg=\ref[the_mob]\">"
			else
				text += "<a href=\"byond://?src=\ref[include_link];priv_msg=\ref[the_mob]\">"

		if (the_client && the_client.holder && the_client.stealth && !include_name)
			text += "Administrator"
		else
			text += "[the_key]"

		if (!isnull(include_link) && !isnull(the_mob))
			text += "</a>"

	if (include_name && !isnull(the_mob))
		if (the_mob.real_name)
			text += "/([the_mob.real_name])"
		else if (the_mob.name)
			text += "/([the_mob.name])"

	return text

/proc/key_name_admin(var/whom, var/include_name = 1)
	return key_name(whom, "%admin_ref%", include_name)


// Registers the on-close verb for a browse window (client/verb/.windowclose)
// this will be called when the close-button of a window is pressed.
//
// This is usually only needed for devices that regularly update the browse window,
// e.g. canisters, timers, etc.
//
// windowid should be the specified window name
// e.g. code is	: user << browse(text, "window=fred")
// then use 	: onclose(user, "fred")
//
// Optionally, specify the "ref" parameter as the controlled atom (usually src)
// to pass a "close=1" parameter to the atom's Topic() proc for special handling.
// Otherwise, the user mob's machine var will be reset directly.
//
/proc/onclose(mob/user, windowid, var/atom/ref=null)
	if(!user.client) return
	var/param = "null"
	if(ref)
		param = "\ref[ref]"

	winset(user, windowid, "on-close=\".windowclose [param]\"")

	//world << "OnClose [user]: [windowid] : ["on-close=\".windowclose [param]\""]"


// the on-close client verb
// called when a browser popup window is closed after registering with proc/onclose()
// if a valid atom reference is supplied, call the atom's Topic() with "close=1"
// otherwise, just reset the client mob's machine var.
//
/client/verb/windowclose(var/atomref as text)
	set hidden = 1						// hide this verb from the user's panel
	set name = ".windowclose"			// no autocomplete on cmd line

	//world << "windowclose: [atomref]"
	if(atomref!="null")				// if passed a real atomref
		var/hsrc = locate(atomref)	// find the reffed atom
		var/href = "close=1"
		if(hsrc)
			//world << "[src] Topic [href] [hsrc]"
			usr = src.mob
			src.Topic(href, params2list(href), hsrc)	// this will direct to the atom's
			return										// Topic() proc via client.Topic()

	// no atomref specified (or not found)
	// so just reset the user mob's machine var
	if(src && src.mob)
		//world << "[src] was [src.mob.machine], setting to null"
		src.mob.machine = null
	return

/proc/reverselist(var/list/input)
	var/list/output = new/list()
	for(var/A in input)
		output += A
	return output

/proc/get_turf_loc(var/mob/M) //gets the location of the turf that the mob is on, or what the mob is in is on, etc
	//in case they're in a closet or sleeper or something
	var/atom/loc = M.loc
	while(!istype(loc, /turf/))
		loc = loc.loc
	return loc

// returns the turf located at the map edge in the specified direction relative to A
// used for mass driver
/proc/get_edge_target_turf(var/atom/A, var/direction)

	var/turf/target = locate(A.x, A.y, A.z)
		//since NORTHEAST == NORTH & EAST, etc, doing it this way allows for diagonal mass drivers in the future
		//and isn't really any more complicated

		// Note diagonal directions won't usually be accurate
	if(direction & NORTH)
		target = locate(target.x, world.maxy, target.z)
	if(direction & SOUTH)
		target = locate(target.x, 1, target.z)
	if(direction & EAST)
		target = locate(world.maxx, target.y, target.z)
	if(direction & WEST)
		target = locate(1, target.y, target.z)

	return target

// returns turf relative to A in given direction at set range
// result is bounded to map size
// note range is non-pythagorean
// used for disposal system
/proc/get_ranged_target_turf(var/atom/A, var/direction, var/range)

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	if(direction & WEST)
		x = max(1, x - range)

	return locate(x,y,A.z)


// returns turf relative to A offset in dx and dy tiles
// bound to map limits
/proc/get_offset_target_turf(var/atom/A, var/dx, var/dy)
	var/x = min(world.maxx, max(1, A.x + dx))
	var/y = min(world.maxy, max(1, A.y + dy))
	return locate(x,y,A.z)

/*
/proc/dir2text(var/d)
	var/dir
	switch(d)
		if(1)
			dir = "NORTH"
		if(2)
			dir = "SOUTH"
		if(4)
			dir = "EAST"
		if(8)
			dir = "WEST"
		if(5)
			dir = "NORTHEAST"
		if(6)
			dir = "SOUTHEAST"
		if(9)
			dir = "NORTHWEST"
		if(10)
			dir = "SOUTHWEST"
		else
			dir = null
	return dir
*/

//Makes sure MIDDLE is between LOW and HIGH. If not, it adjusts it. Returns the adjusted value.
/proc/between(var/low, var/middle, var/high)
	return max(min(middle, high), low)

//returns random gauss number
proc/GaussRand(var/sigma)
  var/x,y,rsq
  do
    x=2*rand()-1
    y=2*rand()-1
    rsq=x*x+y*y
  while(rsq>1 || !rsq)
  return sigma*y*sqrt(-2*log(rsq)/rsq)

//returns random gauss number, rounded to 'roundto'
proc/GaussRandRound(var/sigma,var/roundto)
	return round(GaussRand(sigma),roundto)

proc/anim(turf/location as turf,target as mob|obj,a_icon,a_icon_state as text,flick_anim as text,sleeptime = 0,direction as num)
//This proc throws up either an icon or an animation for a specified amount of time.
//The variables should be apparent enough.
	var/atom/movable/overlay/animation = new(location)
	if(direction)
		animation.dir = direction
	animation.icon = a_icon
	animation.layer = target:layer+1
	if(a_icon_state)
		animation.icon_state = a_icon_state
	else
		animation.icon_state = "blank"
		animation.master = target
		flick(flick_anim, animation)
	sleep(max(sleeptime, 15))
	del(animation)

//returns list element or null. Should prevent "index out of bounds" error.
proc/listgetindex(var/list/list,index)
	if(istype(list) && list.len)
		if(isnum(index))
			if(index>0 && index<=list.len)
				return list[index]
		else if(index in list)
			return list[index]
	return

proc/islist(list/list)
	if(istype(list))
		return 1
	return 0

proc/isemptylist(list/list)
	if(istype(list) && !list.len)
		return 1
	return 0

proc/clearlist(list/list)
	if(istype(list))
		list.len = 0
	return

/atom/proc/GetAllContents(searchDepth = 5)
	var/list/toReturn = list()

	for(var/atom/part in contents)
		toReturn += part
		if(part.contents.len && searchDepth)
			toReturn += part.GetAllContents(searchDepth - 1)

	return toReturn