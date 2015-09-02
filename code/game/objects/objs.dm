/obj
	languages = HUMAN
	var/crit_fail = 0
	var/unacidable = 0 //universal "unacidabliness" var, here so you can use it in any obj.
	animate_movement = 2
	var/throwforce = 0
	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!

	var/damtype = "brute"
	var/force = 0

	var/burn_state = -1 // -1=fireproof | 0=will burn in fires | 1=currently on fire
	var/burntime = 10 //How long it takes to burn to ashes, in seconds
	var/burn_world_time //What world time the object will burn up completely

/obj/Destroy()
	if(!istype(src, /obj/machinery))
		SSobj.processing.Remove(src) // TODO: Have a processing bitflag to reduce on unnecessary loops through the processing lists
	return ..()

/obj/assume_air(datum/gas_mixture/giver)
	if(loc)
		return loc.assume_air(giver)
	else
		return null

/obj/remove_air(amount)
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/obj/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/obj/proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
	//Return: (NONSTANDARD)
	//		null if object handles breathing logic for lifeform
	//		datum/air_group to tell lifeform to process using that breath return
	//DEFAULT: Take air from turf to give to have mob process

	if(breath_request>0)
		var/datum/gas_mixture/environment = return_air()
		var/breath_percentage = BREATH_VOLUME / environment.return_volume()
		return remove_air(environment.total_moles() * breath_percentage)
	else
		return null

/atom/movable/proc/initialize()
	return

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = 1
				src.attack_hand(M)
		if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
			if (!(usr in nearby))
				if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = 1
					src.attack_ai(usr)

		// check for TK users

		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			if(!(usr in nearby))
				if(usr.client && usr.machine==src)
					if(H.dna.check_mutation(TK))
						is_in_use = 1
						src.attack_hand(usr)
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = 1
				src.interact(M)
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = 0

/obj/proc/interact(mob/user)
	return

/obj/proc/container_resist()
	return

/obj/proc/update_icon()
	return

/mob/proc/unset_machine()
	src.machine = null

/mob/proc/set_machine(obj/O)
	if(src.machine)
		unset_machine()
	src.machine = O
	if(istype(O))
		O.in_use = 1

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)


/obj/proc/alter_health()
	return 1

/obj/proc/hide(h)
	return

/obj/ex_act(severity, target)
	if(severity == 1 || target == src)
		qdel(src)
	else if(severity == 2)
		if(prob(50))
			qdel(src)
	if(!gc_destroyed)
		..()

//If a mob logouts/logins in side of an object you can use this proc
/obj/proc/on_log()
	..()
	if(isobj(loc))
		var/obj/Loc=loc
		Loc.on_log()

/obj/singularity_act()
	ex_act(1.0)
	if(src && isnull(gc_destroyed))
		qdel(src)
	return 2

/obj/singularity_pull(S, current_size)
	if(!anchored || current_size >= STAGE_FIVE)
		step_towards(src,S)

/obj/proc/Deconstruct()
	qdel(src)

/obj/get_spans()
	return ..() | SPAN_ROBOT

/obj/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	var/turf/T = get_turf(src)
	return T.storage_contents_dump_act(src_object, user)

/obj/fire_act(global_overlay=1)
	if(!burn_state)
		burn_state = 1
		SSobj.burning += src
		burn_world_time = world.time + burntime*rand(10,20)
		if(global_overlay)
			overlays += fire_overlay
		return 1

/obj/proc/burn()
	for(var/obj/item/Item in contents) //Empty out the contents
		Item.loc = src.loc
		Item.fire_act() //Set them on fire, too
	var/obj/effect/decal/cleanable/ash/A = new(src.loc)
	A.desc = "Looks like this used to be a [name] some time ago."
	SSobj.burning -= src
	qdel(src)

/obj/proc/extinguish()
	if(burn_state == 1)
		burn_state = 0
		overlays -= fire_overlay
		SSobj.burning -= src