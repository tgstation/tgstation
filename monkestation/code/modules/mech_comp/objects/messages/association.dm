#define ASSOC_MUTABLE "Mutable"
#define ASSOC_IMMUTABLE "Immutable"
#define ASSOC_LIST "List"

#define ISWHITESPACE(val) (isnull(val) || val == "")

/obj/item/mcobject/messaging/association
	name = "array component"
	base_icon_state = "comp_ass"
	icon_state = "comp_ass"

	var/mode = ASSOC_MUTABLE
	var/static/list/modes = list(
		ASSOC_MUTABLE,
		ASSOC_IMMUTABLE,
		ASSOC_LIST
	)
	var/list/mylist = list()

/obj/item/mcobject/messaging/association/Initialize(mapload)
	. = ..()
	configs -= MC_CFG_OUTPUT_MESSAGE
	MC_ADD_INPUT("add association(s)", add_elements)
	MC_ADD_INPUT("remove association", remove_element)
	MC_ADD_INPUT("push value", push)
	MC_ADD_CONFIG("Set Mode", set_mode)
	MC_ADD_CONFIG("Add Association", add_element_config)
	MC_ADD_CONFIG("Remove Association", remove_element_config)
	MC_ADD_CONFIG("View Associations", send2chat)
	MC_ADD_CONFIG("Clear Associations", clear)

/obj/item/mcobject/messaging/association/proc/add_elements(datum/mcmessage/input)
	var/list/L = params2list(input.cmd)
	var/animate = FALSE

	for(var/key in L)
		var/list/value = L[key]
		if(ISWHITESPACE(value) || (islist(value) && L[value][1] == ""))
			continue
		value = islist(value) ? value : list(value)

		switch(mode)
			if(ASSOC_MUTABLE)
				mylist[key] = value[1]
				animate = TRUE

			if(ASSOC_IMMUTABLE)
				if(!isnull(mylist[key]))
					continue
				mylist[key] = value
				animate = TRUE

			if(ASSOC_LIST)
				if(isnull(mylist[key]))
					mylist[key] = jointext(value, ",")
				else
					mylist[key] = "[mylist[key]],[jointext(value, ",")]"
				animate = TRUE

	if(animate)
		flash()

/obj/item/mcobject/messaging/association/proc/remove_element(datum/mcmessage/input)
	if(isnull(mylist[input.cmd]))
		return
	mylist -= input.cmd
	flash()

/obj/item/mcobject/messaging/association/proc/push(datum/mcmessage/input)
	var/value = mylist[input.cmd]
	if(isnull(value))
		return

	fire(value, input)

/obj/item/mcobject/messaging/association/proc/set_mode(mob/user, obj/item/tool)
	var/_mode = input(user, "Set mode", "Configure Component", mode) as null|anything in modes
	if(isnull(_mode))
		return
	mode = _mode
	to_chat(user, span_notice("You set the mode of [src] to [mode]."))
	return TRUE

/obj/item/mcobject/messaging/association/proc/add_element_config(mob/user, obj/item/tool)
	var/ikey = input(user, "Add key", "Configure Component") as null|text
	if(isnull(ikey))
		return
	var/ivalue = input(user, "Associated value", "Configure Component") as null|text
	if(isnull(ikey))
		return

	switch(mode)
		if(ASSOC_MUTABLE)
			mylist[ikey] = ivalue

		if(ASSOC_IMMUTABLE)
			if(!isnull(mylist[ikey]))
				to_chat(user, span_warning("You cannot change an immutable value!"))
				return
			mylist[ikey] = ivalue

		if(ASSOC_LIST)
			if(isnull(mylist[ikey]))
				mylist[ikey] = jointext(ivalue, ",")
			else
				mylist[ikey] = "[mylist[ikey]],[jointext(ivalue, ",")]"

	to_chat(user, span_notice("You set the value of [src]'s [ikey] to [ivalue]"))
	return TRUE

/obj/item/mcobject/messaging/association/proc/remove_element_config(mob/user, obj/item/tool)
	if(!length(mylist))
		to_chat(user, span_warning("[src] has no associations to remove!"))
		return

	var/removal = input(user, "Remove association", "Configure Component") as null|anything in mylist
	if(isnull(removal))
		return

	to_chat(user, span_notice("You remove [src]'s [removal]:[mylist[removal]] pair."))
	mylist -= removal
	return TRUE

/obj/item/mcobject/messaging/association/proc/send2chat(mob/user, obj/item/tool)
	var/list/formatted = list()
	for(var/key in mylist)
		formatted += html_encode("[key] : [mylist[key]]")

	to_chat(user, length(formatted) ? span_notice(jointext(formatted, "<br>")) : span_warning("[src]'s array is empty!"))
	return TRUE

/obj/item/mcobject/messaging/association/proc/clear(mob/user, obj/item/tool)
	mylist.Cut()
	return TRUE

#undef ISWHITESPACE
#undef ASSOC_MUTABLE
#undef ASSOC_IMMUTABLE
#undef ASSOC_LIST
