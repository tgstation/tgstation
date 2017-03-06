/obj
	languages_spoken = HUMAN
	languages_understood = HUMAN
	var/crit_fail = 0
	animate_movement = 2
	var/throwforce = 0
	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!

	var/damtype = "brute"
	var/force = 0

	var/list/armor
	var/obj_integrity = 500
	var/max_integrity = 500
	var/integrity_failure = 0 //0 if we have no special broken behavior

	var/resistance_flags = 0 // INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ON_FIRE | UNACIDABLE | ACID_PROOF

	var/acid_level = 0 //how much acid is on that obj

	var/being_shocked = 0

	var/on_blueprints = FALSE //Are we visible on the station blueprints at roundstart?
	var/force_blueprints = FALSE //forces the obj to be on the blueprints, regardless of when it was created.

	var/persistence_replacement = null //have something WAY too amazing to live to the next round? Set a new path here. Overuse of this var will make me upset.
	var/unique_rename = 0 // can you customize the description/name of the thing?


/obj/Initialize()
	..()
	if (!armor)
		armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0)
	if(on_blueprints && isturf(loc))
		var/turf/T = loc
		if(force_blueprints)
			T.add_blueprints(src)
		else
			T.add_blueprints_preround(src)

/obj/Destroy(force=FALSE)
	var/inform_admins = HAS_SECONDARY_FLAG(src, INFORM_ADMINS_ON_RELOCATE)
	var/stationloving = HAS_SECONDARY_FLAG(src, STATIONLOVING)

	if(inform_admins && force)
		var/turf/T = get_turf(src)
		message_admins("[src] has been !!force deleted!! in [ADMIN_COORDJMP(T)].")
		log_game("[src] has been !!force deleted!! in [COORD(T)].")

	if(stationloving && !force)
		var/turf/currentturf = get_turf(src)
		var/turf/targetturf = relocate()
		log_game("[src] has been destroyed in [COORD(currentturf)]. Moving it to [COORD(targetturf)].")
		if(inform_admins)
			message_admins("[src] has been destroyed in [ADMIN_COORDJMP(currentturf)]. Moving it to [ADMIN_COORDJMP(targetturf)].")
		return QDEL_HINT_LETMELIVE

	if(stationloving && force)
		STOP_PROCESSING(SSinbounds, src)

	if(!istype(src, /obj/machinery))
		STOP_PROCESSING(SSobj, src) // TODO: Have a processing bitflag to reduce on unnecessary loops through the processing lists
	SStgui.close_uis(src)
	. = ..()

/obj/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	..()
	if(HAS_SECONDARY_FLAG(src, FROZEN))
		visible_message("<span class='danger'>[src] shatters into a million pieces!</span>")
		qdel(src)

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

/obj/proc/rewrite(mob/user)
	var/penchoice = alert("What would you like to edit?", "Rename or change description?", "Rename", "Change description", "Cancel")
	if(!QDELETED(src) && user.canUseTopic(src, BE_CLOSE))
		if(penchoice == "Rename")
			rename_obj(user)
		if(penchoice == "Change description")
			redesc_obj(user)

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

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = 1
				src.attack_hand(M)
		if(isAI(usr) || iscyborg(usr) || IsAdminGhost(usr))
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


/obj/attack_ghost(mob/user)
	if(ui_interact(user) != -1)
		return
	..()

/obj/proc/container_resist(mob/living/user)
	return

/obj/proc/update_icon()
	return

/mob/proc/unset_machine()
	if(machine)
		machine.on_unset_machine(src)
		machine = null

//called when the user unsets the machine.
/atom/movable/proc/on_unset_machine(mob/user)
	return

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

/obj/proc/hide(h)
	return

//If a mob logouts/logins in side of an object you can use this proc
/obj/proc/on_log()
	..()
	if(isobj(loc))
		var/obj/Loc=loc
		Loc.on_log()


/obj/singularity_pull(S, current_size)
	if(!anchored || current_size >= STAGE_FIVE)
		step_towards(src,S)

/obj/get_spans()
	return ..() | SPAN_ROBOT

/obj/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	var/turf/T = get_turf(src)
	return T.storage_contents_dump_act(src_object, user)

/obj/proc/CanAStarPass()
	. = !density

/obj/proc/check_uplink_validity()
	return 1

/obj/proc/on_mob_move(dir, mob)
	return

/obj/vv_get_dropdown()
	. = ..()
	.["Delete all of type"] = "?_src_=vars;delall=\ref[src]"

/obj/examine(mob/user)
	..()
	if(unique_rename)
		user << "<span class='notice'>Use a pen on it to rename it or change its description.</span>"

/obj/proc/rename_obj(mob/M)
	var/input = stripped_input(M,"What do you want to name \the [name]?", ,"", MAX_NAME_LEN)
	var/oldname = name

	if(!QDELETED(src) && M.canUseTopic(src, BE_CLOSE) && input != "")
		if(oldname == input)
			M << "You changed \the [name] to... well... \the [name]."
			return
		else
			name = input
			M << "\The [oldname] has been successfully been renamed to \the [input]."
			return
	else
		return

/obj/proc/redesc_obj(mob/M)
	var/input = stripped_input(M,"Describe \the [name] here", ,"", 100)

	if(!QDELETED(src) && M.canUseTopic(src, BE_CLOSE) && input != "")
		desc = input
		M << "You have successfully changed \the [name]'s description."
		return
	else
		return
<<<<<<< HEAD
=======

/* Stationloving
*
* An stationloving object will always teleport back to the station
* if it ever leaves the station z-levels or Centcom. It will also,
* when Destroy() is called, will teleport to a random turf on the
* station.
*
* The turf is guaranteed to be "safe" for normal humans, probably.
* If the station is SUPER SMASHED UP, it might not work.
*
* Here are some important procs:
* relocate()
* moves the object to a safe turf on the station
*
* check_in_bounds()
* regularly called and checks if `in_bounds()` returns true. If false, it
* triggers a `relocate()`.
*
* in_bounds()
* By default, checks that the object's z is the station z or centcom.
*/

/obj/proc/set_stationloving(state, inform_admins=FALSE)
	var/currently = HAS_SECONDARY_FLAG(src, STATIONLOVING)

	if(inform_admins)
		SET_SECONDARY_FLAG(src, INFORM_ADMINS_ON_RELOCATE)
	else
		CLEAR_SECONDARY_FLAG(src, INFORM_ADMINS_ON_RELOCATE)

	if(state == currently)
		return
	else if(!state)
		STOP_PROCESSING(SSinbounds, src)
		CLEAR_SECONDARY_FLAG(src, STATIONLOVING)
	else
		START_PROCESSING(SSinbounds, src)
		SET_SECONDARY_FLAG(src, STATIONLOVING)

/obj/proc/relocate()
	var/targetturf = find_safe_turf(ZLEVEL_STATION)
	if(!targetturf)
		if(blobstart.len > 0)
			targetturf = get_turf(pick(blobstart))
		else
			throw EXCEPTION("Unable to find a blobstart landmark")

	if(ismob(loc))
		var/mob/M = loc
		M.transferItemToLoc(src, targetturf, TRUE)	//nodrops disks when?
	else if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = loc
		S.remove_from_storage(src, targetturf)
	else
		forceMove(targetturf)
	// move the disc, so ghosts remain orbiting it even if it's "destroyed"
	return targetturf

/obj/check_in_bounds()
	if(in_bounds())
		return
	else
		var/turf/currentturf = get_turf(src)
		get(src, /mob) << "<span class='danger'>You can't help but feel that you just lost something back there...</span>"
		var/turf/targetturf = relocate()
		log_game("[src] has been moved out of bounds in [COORD(currentturf)]. Moving it to [COORD(targetturf)].")
		if(HAS_SECONDARY_FLAG(src, INFORM_ADMINS_ON_RELOCATE))
			message_admins("[src] has been moved out of bounds in [ADMIN_COORDJMP(currentturf)]. Moving it to [ADMIN_COORDJMP(targetturf)].")

/obj/proc/in_bounds()
	. = FALSE
	var/turf/currentturf = get_turf(src)
	if(currentturf && (currentturf.z == ZLEVEL_CENTCOM || currentturf.z == ZLEVEL_STATION))
		. = TRUE
>>>>>>> Objects can now be stationloving
