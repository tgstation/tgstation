// Datum antag mind procs
/datum/mind/proc/add_antag_datum(datum_type_or_instance, team)
	if(!datum_type_or_instance)
		return
	var/datum/antagonist/A
	if(!ispath(datum_type_or_instance))
		A = datum_type_or_instance
		if(!istype(A))
			return
	else
		A = new datum_type_or_instance()
	//Choose snowflake variation if antagonist handles it
	var/datum/antagonist/S = A.specialization(src)
	if(S && S != A)
		qdel(A)
		A = S
	if(!A.can_be_owned(src))
		qdel(A)
		return
	A.owner = src
	LAZYADD(antag_datums, A)
	A.create_team(team)
	var/datum/team/antag_team = A.get_team()
	if(antag_team)
		antag_team.add_member(src)
	INVOKE_ASYNC(A, TYPE_PROC_REF(/datum/antagonist, on_gain))
	log_game("[key_name(src)] has gained antag datum [A.name]([A.type]).")
	return A

/datum/mind/proc/remove_antag_datum(datum_type)
	if(!datum_type)
		return
	var/datum/antagonist/A = has_antag_datum(datum_type)
	if(A)
		A.on_removal()
		current.log_message("has lost antag datum [A.name]([A.type]).", LOG_GAME)
		return TRUE

/datum/mind/proc/remove_all_antag_datums() //For the Lazy amongst us.
	for(var/a in antag_datums)
		var/datum/antagonist/A = a
		A.on_removal()
	current.log_message("has lost all antag datums.", LOG_GAME)

/datum/mind/proc/has_antag_datum(datum_type, check_subtypes = TRUE)
	if(!datum_type)
		return
	for(var/a in antag_datums)
		var/datum/antagonist/A = a
		if(check_subtypes && istype(A, datum_type))
			return A
		else if(A.type == datum_type)
			return A

/*
	Removes antag type's references from a mind.
	objectives, uplinks, powers etc are all handled.
*/

/datum/mind/proc/remove_changeling()
	var/datum/antagonist/changeling/C = has_antag_datum(/datum/antagonist/changeling)
	if(C)
		remove_antag_datum(/datum/antagonist/changeling)
		special_role = null

/datum/mind/proc/remove_traitor()
	remove_antag_datum(/datum/antagonist/traitor)

/datum/mind/proc/remove_nukeop()
	var/datum/antagonist/nukeop/nuke = has_antag_datum(/datum/antagonist/nukeop,TRUE)
	if(nuke)
		remove_antag_datum(nuke.type)
		special_role = null

/datum/mind/proc/remove_wizard()
	remove_antag_datum(/datum/antagonist/wizard)
	special_role = null

/datum/mind/proc/remove_rev()
	var/datum/antagonist/rev/rev = has_antag_datum(/datum/antagonist/rev)
	if(rev)
		remove_antag_datum(rev.type)
		special_role = null


/datum/mind/proc/remove_antag_equip()
	var/list/Mob_Contents = current.get_contents()
	for(var/obj/item/I in Mob_Contents)
		var/datum/component/uplink/O = I.GetComponent(/datum/component/uplink) //Todo make this reset signal
		if(O)
			O.unlock_code = null

/// Remove the antagonists that should not persist when being borged
/datum/mind/proc/remove_antags_for_borging()
	remove_antag_datum(/datum/antagonist/cult)

	var/datum/antagonist/rev/revolutionary = has_antag_datum(/datum/antagonist/rev)
	revolutionary?.remove_revolutionary(borged = TRUE)

/**
 * ## give_uplink
 *
 * A mind proc for giving anyone an uplink.
 * arguments:
 * * silent: if this should send a message to the mind getting the uplink. traitors do not use this silence, but the silence var on their antag datum.
 * * antag_datum: the antag datum of the uplink owner, for storing it in antag memory. optional!
 */
/datum/mind/proc/give_uplink(silent = FALSE, datum/antagonist/antag_datum)
	if(!current)
		return
	var/mob/living/carbon/human/traitor_mob = current
	if (!istype(traitor_mob))
		return

	var/list/all_contents = traitor_mob.get_all_contents()
	var/obj/item/modular_computer/pda/PDA = locate() in all_contents
	var/obj/item/radio/R = locate() in all_contents
	var/obj/item/pen/P

	if (PDA) // Prioritize PDA pen, otherwise the pocket protector pens will be chosen, which causes numerous ahelps about missing uplink
		P = locate() in PDA
	if (!P) // If we couldn't find a pen in the PDA, or we didn't even have a PDA, do it the old way
		P = locate() in all_contents

	var/obj/item/uplink_loc
	var/implant = FALSE

	var/uplink_spawn_location = traitor_mob.client?.prefs?.read_preference(/datum/preference/choiced/uplink_location)
	var/cant_speak = (HAS_TRAIT(traitor_mob, TRAIT_MUTE) || traitor_mob.mind?.assigned_role.title == JOB_MIME)
	if(uplink_spawn_location == UPLINK_RADIO && cant_speak)
		if(!silent)
			to_chat(traitor_mob, span_warning("You have been deemed ineligible for a radio uplink. Supplying standard uplink instead."))
		uplink_spawn_location = UPLINK_PDA
	switch (uplink_spawn_location)
		if(UPLINK_PDA)
			uplink_loc = PDA
			if(!uplink_loc)
				uplink_loc = R
			if(!uplink_loc)
				uplink_loc = P
		if(UPLINK_RADIO)
			uplink_loc = R
			if(!uplink_loc)
				uplink_loc = PDA
			if(!uplink_loc)
				uplink_loc = P
		if(UPLINK_PEN)
			uplink_loc = P
		if(UPLINK_IMPLANT)
			implant = TRUE

	if(!uplink_loc) // We've looked everywhere, let's just implant you
		implant = TRUE

	if(implant)
		var/obj/item/implant/uplink/starting/new_implant = new(traitor_mob)
		new_implant.implant(traitor_mob, null, silent = TRUE)
		if(!silent)
			to_chat(traitor_mob, span_boldnotice("Your Syndicate Uplink has been cunningly implanted in you, for a small TC fee. Simply trigger the uplink to access it."))
		add_memory(/datum/memory/key/traitor_uplink/implant, uplink_loc = "implant")
		return new_implant

	. = uplink_loc
	var/unlock_text
	var/datum/component/uplink/new_uplink = uplink_loc.AddComponent(/datum/component/uplink, traitor_mob.key)
	if(!new_uplink)
		CRASH("Uplink creation failed.")
	new_uplink.setup_unlock_code()
	new_uplink.uplink_handler.owner = traitor_mob.mind
	new_uplink.uplink_handler.assigned_role = traitor_mob.mind.assigned_role.title
	new_uplink.uplink_handler.assigned_species = traitor_mob.dna.species.id
	if(uplink_loc == R)
		unlock_text = "Your Uplink is cunningly disguised as your [R.name]. Simply speak \"[new_uplink.unlock_code]\" into frequency [RADIO_TOKEN_UPLINK] to unlock its hidden features."
		add_memory(/datum/memory/key/traitor_uplink, uplink_loc = R.name, uplink_code = new_uplink.unlock_code)
	else if(uplink_loc == PDA)
		unlock_text = "Your Uplink is cunningly disguised as your [PDA.name]. Simply enter the code \"[new_uplink.unlock_code]\" into the ring tone selection to unlock its hidden features."
		add_memory(/datum/memory/key/traitor_uplink, uplink_loc = "PDA", uplink_code = new_uplink.unlock_code)
	else if(uplink_loc == P)
		var/instructions = english_list(new_uplink.unlock_code)
		unlock_text = "Your Uplink is cunningly disguised as your [P.name]. Simply twist the top of the pen [instructions] from its starting position to unlock its hidden features."
		add_memory(/datum/memory/key/traitor_uplink, uplink_loc = "PDA pen", uplink_code = instructions)

	new_uplink.unlock_text = unlock_text
	if(!silent)
		to_chat(traitor_mob, span_boldnotice(unlock_text))
	if(antag_datum)
		antag_datum.antag_memory += new_uplink.unlock_note + "<br>"

/// Link a new mobs mind to the creator of said mob. They will join any team they are currently on, and will only switch teams when their creator does.
/datum/mind/proc/enslave_mind_to_creator(mob/living/creator)
	if(IS_CULTIST(creator))
		add_antag_datum(/datum/antagonist/cult)

	else if(IS_REVOLUTIONARY(creator))
		var/datum/antagonist/rev/converter = creator.mind.has_antag_datum(/datum/antagonist/rev,TRUE)
		converter.add_revolutionary(src,FALSE)

	else if(IS_NUKE_OP(creator))
		var/datum/antagonist/nukeop/converter = creator.mind.has_antag_datum(/datum/antagonist/nukeop,TRUE)
		var/datum/antagonist/nukeop/N = new()
		N.send_to_spawnpoint = FALSE
		N.nukeop_outfit = null
		add_antag_datum(N,converter.nuke_team)


	enslaved_to = creator

	current.faction |= creator.faction
	creator.faction |= current.faction

	if(creator.mind?.special_role)
		message_admins("[ADMIN_LOOKUPFLW(current)] has been created by [ADMIN_LOOKUPFLW(creator)], an antagonist.")
		to_chat(current, span_userdanger("Despite your creator's current allegiances, your true master remains [creator.real_name]. If their loyalties change, so do yours. This will never change unless your creator's body is destroyed."))

/datum/mind/proc/get_all_objectives()
	var/list/all_objectives = list()
	for(var/datum/antagonist/A in antag_datums)
		all_objectives |= A.objectives
	return all_objectives

/datum/mind/proc/announce_objectives()
	var/obj_count = 1
	to_chat(current, span_notice("Your current objectives:"))
	for(var/datum/objective/objective as anything in get_all_objectives())
		to_chat(current, "<B>[objective.objective_name] #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	// Objectives are often stored in the static data of antag uis, so we should update those as well
	for(var/datum/antagonist/antag as anything in antag_datums)
		antag.update_static_data(current)

/datum/mind/proc/find_syndicate_uplink(check_unlocked)
	var/list/L = current.get_all_contents()
	for (var/i in L)
		var/atom/movable/I = i
		var/datum/component/uplink/found_uplink = I.GetComponent(/datum/component/uplink)
		if(!found_uplink || (check_unlocked && found_uplink.locked))
			continue
		return found_uplink

/**
* Checks to see if the mind has an accessible uplink (their own, if they are a traitor; any unlocked uplink otherwise),
* and gives them a fallback spell if no uplink was found
*/
/datum/mind/proc/try_give_equipment_fallback()
	var/uplink_exists
	var/datum/antagonist/traitor/traitor_datum = has_antag_datum(/datum/antagonist/traitor)
	if(traitor_datum)
		uplink_exists = traitor_datum.uplink_ref
	if(!uplink_exists)
		uplink_exists = find_syndicate_uplink(check_unlocked = TRUE)
	if(!uplink_exists && !(locate(/datum/action/special_equipment_fallback) in current.actions))
		var/datum/action/special_equipment_fallback/fallback = new(src)
		fallback.Grant(current)

/datum/mind/proc/take_uplink()
	qdel(find_syndicate_uplink())

/datum/mind/proc/make_traitor()
	if(!(has_antag_datum(/datum/antagonist/traitor)))
		add_antag_datum(/datum/antagonist/traitor)

/datum/mind/proc/make_changeling()
	var/datum/antagonist/changeling/C = has_antag_datum(/datum/antagonist/changeling)
	if(!C)
		C = add_antag_datum(/datum/antagonist/changeling)
		special_role = ROLE_CHANGELING
	return C


/datum/mind/proc/make_wizard()
	if(has_antag_datum(/datum/antagonist/wizard))
		return
	set_assigned_role(SSjob.GetJobType(/datum/job/space_wizard))
	special_role = ROLE_WIZARD
	add_antag_datum(/datum/antagonist/wizard)


/datum/mind/proc/make_rev()
	var/datum/antagonist/rev/head/head = new()
	head.give_flash = TRUE
	head.give_hud = TRUE
	add_antag_datum(head)
	special_role = ROLE_REV_HEAD

/// Sets our can_hijack to the fastest speed our antag datums allow.
/datum/mind/proc/get_hijack_speed()
	. = 0
	for(var/datum/antagonist/A in antag_datums)
		. = max(., A.hijack_speed())

/datum/mind/proc/has_objective(objective_type)
	for(var/datum/antagonist/A in antag_datums)
		for(var/O in A.objectives)
			if(istype(O,objective_type))
				return TRUE
