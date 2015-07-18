var/global/list/mob/virtualhearer/virtualhearers = list()

/mob/virtualhearer
	name = ""
	see_in_dark = 8
	icon = null
	icon_state = null
	var/atom/movable/attached = null
	anchored = 1
	density = 0
	invisibility = INVISIBILITY_MAXIMUM
	alpha = 0
	animate_movement = 0
	//This can be expanded with vision flags to make a device to hear through walls for example

/mob/virtualhearer/New(attachedto)
	AddToProfiler()
	virtualhearers += src
	loc = get_turf(attachedto)
	attached = attachedto
	if(istype(attached,/obj/item/device/radio/intercom))
		virtualhearers -= src

/mob/virtualhearer/Destroy()
	virtualhearers -= src
	attached = null
/*
/mob/virtualhearer/proc/process()
	writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/virtualhearer/proc/process() called tick#: [world.time]")
	var/atom/A
	while(attached)
		for(A=attached.loc, A && !isturf(A), A=A.loc);
		loc = A
		sleep(10)
	returnToPool(src)*/

/mob/virtualhearer/resetVariables()
	return

/mob/virtualhearer/Hear(message, atom/movable/speaker, var/datum/language/speaking, raw_message, radio_freq)
	if(attached)
		attached.Hear(args)
	else
		returnToPool(src)

/mob/virtualhearer/ex_act()
	return

/mob/virtualhearer/singularity_act()
	return

/mob/virtualhearer/singularity_pull()
	return
