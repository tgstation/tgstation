
/obj
	var/crit_fail = FALSE
	animate_movement = 2
	var/obj_flags = CAN_BE_HIT
	var/set_obj_flags // ONLY FOR MAPPING: Sets flags from a string list, handled in Initialize. Usage: set_obj_flags = "EMAGGED;!CAN_BE_HIT" to set EMAGGED and clear CAN_BE_HIT.

	var/damtype = BRUTE
	var/force = 0

	var/datum/armor/armor
	var/obj_integrity	//defaults to max_integrity
	var/max_integrity = 500
	var/integrity_failure = 0 //0 if we have no special broken behavior

	var/resistance_flags = NONE // INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ON_FIRE | UNACIDABLE | ACID_PROOF

	var/acid_level = 0 //how much acid is on that obj

	var/persistence_replacement //have something WAY too amazing to live to the next round? Set a new path here. Overuse of this var will make me upset.
	var/current_skin //Has the item been reskinned?
	var/list/unique_reskin //List of options to reskin.

	// Access levels, used in modules\jobs\access.dm
	var/list/req_access
	var/req_access_txt = "0"
	var/list/req_one_access
	var/req_one_access_txt = "0"

	var/renamedByPlayer = FALSE //set when a player uses a pen on a renamable object

/obj/vv_edit_var(vname, vval)
	switch(vname)
		if("anchored")
			setAnchored(vval)
			return TRUE
		if("obj_flags")
			if ((obj_flags & DANGEROUS_POSSESSION) && !(vval & DANGEROUS_POSSESSION))
				return FALSE
		if("control_object")
			var/obj/O = vval
			if(istype(O) && (O.obj_flags & DANGEROUS_POSSESSION))
				return FALSE
	return ..()

/obj/Initialize()
	. = ..()
	if (islist(armor))
		armor = getArmor(arglist(armor))
	else if (!armor)
		armor = getArmor()
	else if (!istype(armor, /datum/armor))
		stack_trace("Invalid type [armor.type] found in .armor during /obj Initialize()")

	if(obj_integrity == null)
		obj_integrity = max_integrity
	if (set_obj_flags)
		var/flagslist = splittext(set_obj_flags,";")
		var/list/string_to_objflag = GLOB.bitfields["obj_flags"]
		for (var/flag in flagslist)
			if (findtext(flag,"!",1,2))
				flag = copytext(flag,1-(length(flag))) // Get all but the initial !
				obj_flags &= ~string_to_objflag[flag]
			else
				obj_flags |= string_to_objflag[flag]
	if((obj_flags & ON_BLUEPRINTS) && isturf(loc))
		var/turf/T = loc
		T.add_blueprints_preround(src)


/obj/Destroy(force=FALSE)
	if(!ismachinery(src))
		STOP_PROCESSING(SSobj, src) // TODO: Have a processing bitflag to reduce on unnecessary loops through the processing lists
	SStgui.close_uis(src)
	. = ..()

/obj/proc/setAnchored(anchorvalue)
	SEND_SIGNAL(src, COMSIG_OBJ_SETANCHORED, anchorvalue)
	anchored = anchorvalue

/obj/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	..()
	if(obj_flags & FROZEN)
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
	if((obj_flags & IN_USE) && !(obj_flags & USES_TGUI))
		var/is_in_use = FALSE
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = TRUE
				ui_interact(M)
		if(isAI(usr) || iscyborg(usr) || IsAdminGhost(usr))
			if (!(usr in nearby))
				if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = TRUE
					ui_interact(usr)

		// check for TK users

		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			if(!(usr in nearby))
				if(usr.client && usr.machine==src)
					if(H.dna.check_mutation(TK))
						is_in_use = TRUE
						ui_interact(usr)
		if (is_in_use)
			obj_flags |= IN_USE
		else
			obj_flags &= ~IN_USE

/obj/proc/updateDialog(update_viewers = TRUE,update_ais = TRUE)
	// Check that people are actually using the machine. If not, don't update anymore.
	if(obj_flags & IN_USE)
		var/is_in_use = FALSE
		if(update_viewers)
			for(var/mob/M in viewers(1, src))
				if ((M.client && M.machine == src))
					is_in_use = TRUE
					src.interact(M)
		var/ai_in_use = FALSE
		if(update_ais)
			ai_in_use = AutoUpdateAI(src)

		if(update_viewers && update_ais) //State change is sure only if we check both
			if(!ai_in_use && !is_in_use)
				obj_flags &= ~IN_USE


/obj/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	ui_interact(user)

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
		O.obj_flags |= IN_USE

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)

/obj/proc/hide(h)
	return

/obj/singularity_pull(S, current_size)
	..()
	if(!anchored || current_size >= STAGE_FIVE)
		step_towards(src,S)

/obj/get_spans()
	return ..() | SPAN_ROBOT

/obj/get_dumping_location(datum/component/storage/source,mob/user)
	return get_turf(src)

/obj/proc/CanAStarPass()
	. = !density

/obj/proc/check_uplink_validity()
	return 1

/obj/proc/intercept_user_move(dir, mob, newLoc, oldLoc)
	return

/obj/vv_get_dropdown()
	. = ..()
	.["Delete all of type"] = "?_src_=vars;[HrefToken()];delall=[REF(src)]"
	.["Osay"] = "?_src_=vars;[HrefToken()];osay[REF(src)]"
	.["Modify armor values"] = "?_src_=vars;[HrefToken()];modarmor=[REF(src)]"

/obj/examine(mob/user)
	..()
	if(obj_flags & UNIQUE_RENAME)
		to_chat(user, "<span class='notice'>Use a pen on it to rename it or change its description.</span>")
	if(unique_reskin && !current_skin)
		to_chat(user, "<span class='notice'>Alt-click it to reskin it.</span>")

/obj/AltClick(mob/user)
	. = ..()
	if(unique_reskin && !current_skin && user.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		reskin_obj(user)

/obj/proc/reskin_obj(mob/M)
	if(!LAZYLEN(unique_reskin))
		return
	to_chat(M, "<b>Reskin options for [name]:</b>")
	for(var/V in unique_reskin)
		var/output = icon2html(src, M, unique_reskin[V])
		to_chat(M, "[V]: <span class='reallybig'>[output]</span>")

	var/choice = input(M,"Warning, you can only reskin [src] once!","Reskin Object") as null|anything in unique_reskin
	if(!QDELETED(src) && choice && !current_skin && !M.incapacitated() && in_range(M,src))
		if(!unique_reskin[choice])
			return
		current_skin = choice
		icon_state = unique_reskin[choice]
		to_chat(M, "[src] is now skinned as '[choice].'")
