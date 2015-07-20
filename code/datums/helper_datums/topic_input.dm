/datum/topic_input
	var/href
	var/list/href_list

	New(thref,list/thref_list)
		href = thref
		href_list = thref_list.Copy()
		return

	proc/get(i)
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/get() called tick#: [world.time]")
		return listgetindex(href_list,i)

	proc/getAndLocate(i)
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/getAndLocate() called tick#: [world.time]")
		var/t = get(i)
		if(t)
			t = locate(t)
		return t || null

	proc/getNum(i)
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/getNum() called tick#: [world.time]")
		var/t = get(i)
		if(t)
			t = text2num(t)
		return isnum(t) ? t : null

	proc/getObj(i)
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/getObj() called tick#: [world.time]")
		var/t = getAndLocate(i)
		return isobj(t) ? t : null

	proc/getMob(i)
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/getMob() called tick#: [world.time]")
		var/t = getAndLocate(i)
		return ismob(t) ? t : null

	proc/getTurf(i)
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/getTurf() called tick#: [world.time]")
		var/t = getAndLocate(i)
		return isturf(t) ? t : null

	proc/getAtom(i)
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/getAtom() called tick#: [world.time]")
		return getType(i,/atom)

	proc/getArea(i)
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/getArea() called tick#: [world.time]")
		var/t = getAndLocate(i)
		return isarea(t) ? t : null

	proc/getStr(i)//params should always be text, but...
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/getStr() called tick#: [world.time]")
		var/t = get(i)
		return istext(t) ? t : null

	proc/getType(i,type)
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/getType() called tick#: [world.time]")
		var/t = getAndLocate(i)
		return istype(t,type) ? t : null

	proc/getPath(i)
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/getPath() called tick#: [world.time]")
		var/t = get(i)
		if(t)
			t = text2path(t)
		return ispath(t) ? t : null

	proc/getList(i)
		//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/getList() called tick#: [world.time]")
		var/t = getAndLocate(i)
		return islist(t) ? t : null