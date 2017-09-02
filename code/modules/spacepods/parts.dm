/obj/item/pod_parts
	parent_type = /obj/item/mecha_parts
	icon = 'goon/icons/pods/pod_parts.dmi'

/obj/item/pod_parts/core
	name="Space Pod Core"
	icon_state = "core"
	flags_2 = CONDUCT_1
	origin_tech = "programming=2;materials=2;biotech=2;engineering=2"

/obj/item/pod_parts/pod_frame
	name = "Space Pod Frame"
	desc = "The frames to make a spacepod. Align, wrench, and add rods."
	icon_state = ""
	flags_2 = CONDUCT_1
	density = FALSE
	anchored = FALSE
	var/link_to = null
	var/link_angle = 0

/obj/item/pod_parts/pod_frame/proc/find_square()
	/*
	each part, in essence, stores the relative position of another part
	you can find where this part should be by looking at the current direction of the current part and applying the link_angle
	the link_angle is the angle between the part's direction and its following part, which is the current part's link_to
	the code works by going in a loop - each part is capable of starting a loop by checking for the part after it, and that part checking, and so on
	this 4-part loop, starting from any part of the frame, can determine if all the parts are properly in place and aligned
	it also checks that each part is unique, and that all the parts are there for the spacepod itself
	*/
	var/neededparts = list(/obj/item/pod_parts/pod_frame/aft_port, /obj/item/pod_parts/pod_frame/aft_starboard, /obj/item/pod_parts/pod_frame/fore_port, /obj/item/pod_parts/pod_frame/fore_starboard)
	var/turf/T
	var/obj/item/pod_parts/pod_frame/linked
	var/obj/item/pod_parts/pod_frame/pointer
	var/list/connectedparts =  list()
	neededparts -= src
	linked = src
	for(var/i in 1 to 4)
		T = get_turf(get_step(linked, turn(linked.dir, -linked.link_angle))) //get the next place that we want to look at
		var/link_to_in_t = locate(linked.link_to) in T
		if(link_to_in_t)
			pointer = link_to_in_t
		if(istype(pointer, linked.link_to) && pointer.dir == linked.dir && pointer.anchored)
			if(!(pointer in connectedparts))
				connectedparts += pointer
			linked = pointer
			pointer = null
	if(connectedparts.len < 4)
		return
	for(var/i in 1 to 4)
		var/obj/item/pod_parts/pod_frame/F = connectedparts[i]
		if(F.type in neededparts) //if one of the items can be founded in neededparts
			neededparts -= F.type
		else //because neededparts has 4 distinct items, this must be called if theyre not all in place and wrenched
			return
	return connectedparts

/obj/item/pod_parts/pod_frame/attackby(var/obj/item/O, mob/user)
	. = ..()
	if(istype(O, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = O
		var/list/linkedparts = find_square()
		if(!linkedparts)
			to_chat(user, "<span class='rose'>You cannot assemble a pod frame because you do not have the necessary assembly. Did you ensure to align the frame properly and wrench all of it down?</span>")
			return
		var/obj/structure/spacepod_frame/pod = new /obj/structure/spacepod_frame(loc)
		pod.dir = dir
		to_chat(user, "<span class='notice'>You strut the pod frame together.</span>")
		R.use(10)
		for(var/obj/item/pod_parts/pod_frame/F in linkedparts)
			if(NORTH == turn(F.dir, -F.link_angle)) //if the part links north during construction, as the bottom left part always does
				pod.loc = F.loc
			qdel(F)
		playsound(get_turf(src), O.usesound, 50, 1)
	if(istype(O, /obj/item/wrench))
		to_chat(user, "<span class='notice'>You [!anchored ? "secure \the [src] in place."  : "remove the securing bolts."]</span>")
		anchored = !anchored
		density = anchored
		playsound(get_turf(src), O.usesound, 50, 1)

/obj/item/pod_parts/pod_frame/verb/rotate()
	set name = "Rotate Frame"
	set category = "Object"
	set src in oview(1)
	if(isobserver(usr))
		to_chat(usr, "<span class='notice'>No, you can't rotate [src]. You're a ghost!</span>")
	if(anchored)
		to_chat(usr, "\The [src] is securely bolted!")
		return FALSE
	dir = turn(dir, -90)
	return TRUE

/obj/item/pod_parts/pod_frame/verb/flip()
	set name = "Flip Frame"
	set category = "Object"
	set src in oview(1)
	if ( usr.stat || usr.restrained() || !usr.canmove )
		return FALSE
	if(isobserver(usr))
		to_chat(usr, "<span class='notice'>No, you can't flip [src]. You're a ghost!</span>")
		return FALSE
	if(anchored)
		to_chat(usr, "\The [src] is securely bolted!")
		return FALSE
	dir = turn(dir, -180)
	return TRUE

/obj/item/pod_parts/pod_frame/attack_hand()
	rotate()

/obj/item/pod_parts/pod_frame/fore_port
	name = "fore port pod frame"
	icon_state = "pod_fp"
	desc = "A space pod frame component. This is the fore port component."
	link_to = /obj/item/pod_parts/pod_frame/fore_starboard
	link_angle = 90

/obj/item/pod_parts/pod_frame/fore_starboard
	name = "fore starboard pod frame"
	icon_state = "pod_fs"
	desc = "A space pod frame component. This is the fore starboard component."
	link_to = /obj/item/pod_parts/pod_frame/aft_starboard
	link_angle = 180

/obj/item/pod_parts/pod_frame/aft_port
	name = "aft port pod frame"
	icon_state = "pod_ap"
	desc = "A space pod frame component. This is the aft port component."
	link_to = /obj/item/pod_parts/pod_frame/fore_port
	link_angle = 0

/obj/item/pod_parts/pod_frame/aft_starboard
	name = "aft starboard pod frame"
	icon_state = "pod_as"
	desc = "A space pod frame component. This is the aft starboard component."
	link_to = /obj/item/pod_parts/pod_frame/aft_port
	link_angle = 270

/obj/item/pod_parts/armor
	var/datum/pod_armor/armor_type = /datum/pod_armor/civ
	name = "civillian pod armor"
	icon = 'goon/icons/pods/pod_parts.dmi'
	icon_state = "pod_armor_civ"
	desc = "Spacepod armor. This is the civilian version. It looks rather flimsy."

/obj/item/pod_parts/armor/syndicate
	armor_type = /datum/pod_armor/syndicate
	name = "syndicate pod armor"
	icon_state = "pod_armor_synd"
	desc = "Tough-looking spacepod armor, with a bold \"FUCK NT\" stenciled directly into it."

/obj/item/pod_parts/armor/black
	armor_type = /datum/pod_armor/black
	name = "black pod armor"
	icon_state = "pod_armor_black"
	desc = "Plain black spacepod armor, with no logos or insignias anywhere on it."

/obj/item/pod_parts/armor/gold
	armor_type = /datum/pod_armor/gold
	name = "golden pod armor"
	icon_state = "pod_armor_gold"
	desc = "Golden spacepod armor. Looks like what a rich spessmen put on their spacepod."

/obj/item/pod_parts/armor/industrial
	armor_type = /datum/pod_armor/industrial
	name = "industrial pod armor"
	icon_state = "pod_armor_industrial"
	desc = "Tough industrial-grade spacepod armor. While meant for construction work, it is commonly used in spacepod battles, too."

/obj/item/pod_parts/armor/security
	armor_type = /datum/pod_armor/security
	name = "security pod armor"
	icon_state = "pod_armor_mil"
	desc = "Tough military-grade pod armor, meant for use by the NanoTrasen military and it's sub-divisons for space combat."



