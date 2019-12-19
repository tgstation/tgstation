/obj/mecha/combat/nerchen
	desc = "This is a discontinued and highly experimental exosuit. Early on in the production in the durand, the idea of a second pilot was thrown around, resulting in this mecha."
	name = "\improper Nerchen"
	icon_state = "nerchen"
	step_in = 3
	dir_in = 2 //Facing South.
	max_integrity = 200 //breaks into two when destroyed, so this is actually more.
	deflect_chance = 30
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 30, "bio" = 0, "rad" = 50, "fire" = 100, "acid" = 100)
	max_temperature = 25000
	infra_luminosity = 3
	//wreckage
	melee_can_hit = FALSE
	add_req_access = 1
	internal_damage_threshold = 25
	var/obj/mecha/combat/chen/chen

/obj/mecha/combat/nerchen/Initialize()
	. = ..()
	chen = new(src, src)
	change_eyes()

/obj/mecha/combat/nerchen/obj_destruction()
	chen.Destroy()
	..()
/obj/mecha/combat/nerchen/Destroy()
	chen.Destroy()
	..()

/obj/mecha/combat/nerchen/mmi_move_inside(obj/item/mmi/mmi_as_oc, mob/user) //no cheese
	to_chat(user, "<span class='warning'>There doesn't seem to be any way to interface with the mech!</span>")
	return FALSE

/obj/mecha/combat/nerchen/proc/change_eyes() //icon proc
	var/newicon = initial(icon_state)
	newicon += "-"
	if(occupant)
		newicon += "closed"
	else
		newicon += "open"
	newicon += "-"
	if(chen.occupant)
		newicon += "closed"
	else
		newicon += "open"
	icon_state = newicon



/obj/mecha/combat/nerchen/moved_inside(mob/living/carbon/human/H)
	. = ..()
	change_eyes()

/obj/mecha/combat/nerchen/go_out(forced, atom/newloc = loc)
	..()
	change_eyes()

/obj/mecha/combat/nerchen/MouseDrop_T(mob/M, mob/user) //if chen exists, you can enter that instead.
	switch(alert("Which cockpit would you like to enter?","Mecha","Ner (Movement)","Chen (Weapons)", "Cancel"))
		if("Chen (Weapons)")
			chen.MouseDrop_T(M, user)
			return
		if("Cancel")
			return
	..()

/obj/mecha/combat/chen
	desc = "The second seat for the Nerchen."
	name = "\improper Nerchen"
	icon_state = "phazon"
	dir_in = 2 //Facing South. not sure if this one matters?
	max_integrity = 200 //breaks into two when destroyed, so this is actually more.
	deflect_chance = 30
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 30, "bio" = 0, "rad" = 50, "fire" = 100, "acid" = 100)
	max_temperature = 25000
	infra_luminosity = 3
	wreckage = /obj/structure/mecha_wreckage/durand
	add_req_access = 1
	internal_damage_threshold = 25
	force = 15
	max_equip = 3
	var/obj/mecha/combat/nerchen/ner

/obj/mecha/combat/chen/Initialize(mapload, _ner)
	. = ..()
	ner = _ner

/obj/mecha/combat/chen/GrantActions(mob/living/user, human_occupant = 0)
	if(human_occupant)
		eject_action.Grant(user, src)
	if(enclosed)
		internals_action.Grant(user, src)
	cycle_action.Grant(user, src)
	stats_action.Grant(user, src)

/obj/mecha/combat/chen/mmi_move_inside(obj/item/mmi/mmi_as_oc, mob/user) //no cheese
	to_chat(user, "<span class='warning'>There doesn't seem to be any way to interface with the mech!</span>")
	return FALSE

/obj/mecha/combat/chen/MouseDrop_T(mob/M, mob/user) //has some differences here and there, with progress bars too
	if((user != M) || user.incapacitated() || !ner.Adjacent(user))
		return
	if(!ishuman(user)) // no silicons or drones in mechas.
		return
	log_message("[user] tries to move in.", LOG_MECHA)
	if (occupant)
		to_chat(usr, "<span class='warning'>The [name] is already occupied!</span>")
		log_message("Permission denied (Occupied).", LOG_MECHA)
		return
	if(dna_lock)
		var/passed = FALSE
		if(user.has_dna())
			var/mob/living/carbon/C = user
			if(C.dna.unique_enzymes==dna_lock)
				passed = TRUE
		if (!passed)
			to_chat(user, "<span class='warning'>Access denied. [name] is secured with a DNA lock.</span>")
			log_message("Permission denied (DNA LOCK).", LOG_MECHA)
			return
	if(!operation_allowed(user))
		to_chat(user, "<span class='warning'>Access denied. Insufficient operation keycodes.</span>")
		log_message("Permission denied (No keycode).", LOG_MECHA)
		return
	if(user.buckled)
		to_chat(user, "<span class='warning'>You are currently buckled and cannot move.</span>")
		log_message("Permission denied (Buckled).", LOG_MECHA)
		return
	if(user.has_buckled_mobs()) //mob attached to us
		to_chat(user, "<span class='warning'>You can't enter the exosuit with other creatures attached to you!</span>")
		log_message("Permission denied (Attached mobs).", LOG_MECHA)
		return

	ner.visible_message("<span class='notice'>[user] starts to climb into [name].</span>")

	if(do_after(user, enter_delay, target = ner)) //chen will be where ner is, so this lets the progressbar be shown
		if(obj_integrity <= 0)
			to_chat(user, "<span class='warning'>You cannot get in the [name], it has been destroyed!</span>")
		else if(occupant)
			to_chat(user, "<span class='danger'>[occupant] was faster! Try better next time, loser.</span>")
		else if(user.buckled)
			to_chat(user, "<span class='warning'>You can't enter the exosuit while buckled.</span>")
		else if(user.has_buckled_mobs())
			to_chat(user, "<span class='warning'>You can't enter the exosuit with other creatures attached to you!</span>")
		else
			moved_inside(user)
	else
		to_chat(user, "<span class='warning'>You stop entering the exosuit!</span>")
	return

/obj/mecha/combat/chen/moved_inside(mob/living/carbon/human/H)
	. = ..()
	ner.change_eyes()

/obj/mecha/combat/chen/domove(direction)
	to_chat(occupant, "<span class='warning'>You need to be in the other cockpit to move!</span>")
	return FALSE

/obj/mecha/combat/chen/go_out(forced, atom/newloc = ner.loc)
	..()
	ner.change_eyes()

/* maybe add a punch animation
/obj/mecha/combat/chen/click_action(atom/target,mob/user,params)
	to_chat(occupant, "<span class='warning'>You need to be in the other cockpit to punch!</span>")
	return FALSE
*/
