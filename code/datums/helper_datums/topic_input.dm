/datum/topic_input
	var/href
	var/list/href_list

/datum/topic_input/New(thref,list/thref_list)
	href = thref
	href_list = thref_list.Copy()
	return

/datum/topic_input/proc/get(i)
	return listgetindex(href_list,i)

/datum/topic_input/proc/getAndLocate(i)
	var/t = get(i)
	if(t)
		t = locate(t)
	return t || null

/datum/topic_input/proc/getNum(i)
	var/t = get(i)
	if(t)
		t = text2num(t)
	return isnum(t) ? t : null

/datum/topic_input/proc/getObj(i)
	var/t = getAndLocate(i)
	return isobj(t) ? t : null

/datum/topic_input/proc/getMob(i)
	var/t = getAndLocate(i)
	return ismob(t) ? t : null

/datum/topic_input/proc/getTurf(i)
	var/t = getAndLocate(i)
	return isturf(t) ? t : null

/datum/topic_input/proc/getAtom(i)
	return getType(i,/atom)

/datum/topic_input/proc/getArea(i)
	var/t = getAndLocate(i)
	return isarea(t) ? t : null

/datum/topic_input/proc/getStr(i)//params should always be text, but...
	var/t = get(i)
	return istext(t) ? t : null

/datum/topic_input/proc/getType(i,type)
	var/t = getAndLocate(i)
	return istype(t,type) ? t : null

/datum/topic_input/proc/getPath(i)
	var/t = get(i)
	if(t)
		t = text2path(t)
	return ispath(t) ? t : null

/datum/topic_input/proc/getList(i)
	var/t = getAndLocate(i)
	return islist(t) ? t : null
