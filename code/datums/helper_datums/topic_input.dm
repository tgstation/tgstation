/datum/topic_input
	var/href
	var/list/href_list

	New(thref,list/thref_list)
		href = thref
		href_list = thref_list.Copy()
		return

	proc/get(i)
		return listgetindex(href_list,i)

	proc/getAndLocate(i)
		var/t = get(i)
		if(t)
			t = locate(t)
		return t || null

	proc/getNum(i)
		var/t = get(i)
		if(t)
			t = text2num(t)
		return isnum(t) ? t : null

	proc/getObj(i)
		var/t = getAndLocate(i)
		return isobj(t) ? t : null

	proc/getMob(i)
		var/t = getAndLocate(i)
		return ismob(t) ? t : null

	proc/getTurf(i)
		var/t = getAndLocate(i)
		return isturf(t) ? t : null

	proc/getAtom(i)
		return getType(i,/atom)

	proc/getArea(i)
		var/t = getAndLocate(i)
		return isarea(t) ? t : null

	proc/getStr(i)//params should always be text, but...
		var/t = get(i)
		return istext(t) ? t : null

	proc/getType(i,type)
		var/t = getAndLocate(i)
		return istype(t,type) ? t : null

	proc/getPath(i)
		var/t = get(i)
		if(t)
			t = text2path(t)
		return ispath(t) ? t : null

	proc/getList(i)
		var/t = getAndLocate(i)
		return islist(t) ? t : null