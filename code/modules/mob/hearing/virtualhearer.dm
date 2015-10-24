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
	flags = INVULNERABLE
	status_flags = GODMODE

	alpha = 0
	animate_movement = 0
	ignoreinvert = 1
	//This can be expanded with vision flags to make a device to hear through walls for example

/mob/virtualhearer/New(attachedto)
	AddToProfiler()
	virtualhearers += src
	loc = get_turf(attachedto)
	attached = attachedto
	if(istype(attached,/obj/item/device/radio/intercom) || istype(attached,/obj/machinery/camera))
		virtualhearers -= src

/mob/virtualhearer/Destroy()
	virtualhearers -= src
	attached = null

/mob/virtualhearer/resetVariables()
	return

/mob/virtualhearer/Hear(var/datum/speech/speech, var/rendered_speech="")
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
