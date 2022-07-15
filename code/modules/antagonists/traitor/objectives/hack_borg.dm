/datum/traitor_objective_category/borg_hack
	name = "Borg hack"
	objectives = list(
		/datum/traitor_objective/borg_hack = 1,
	)

/datum/traitor_objective/borg_hack
	name = "Upload a virus into a cyborg"
	description = "Use the button below to materialize a device in your hand, that will be able to upload a virus into a station cyborg. If the device gets destroyed, the objective will fail. This will only work on living and sentient cyborgs."

	progression_reward = list(7 MINUTES, 14 MINUTES)
	telecrystal_reward = 0

	var/list/blacklisted_to = list(
		JOB_ROBOTICIST,  
		JOB_RESEARCH_DIRECTOR,  ///To easy to complete
		JOB_SCIENTIST
	)

	var/obj/item/hacking_device/hacking_thing


/datum/traitor_objective/borg_hack/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!hacking_thing)
		buttons += add_ui_button("", "Clicking this will materialize a hacking device in your hand", "wifi", "summon_hacking_device")
	return buttons

/datum/traitor_objective/borg_hack/ui_perform_action(mob/living/user, action)
	switch(action)
		if("summon_hacking_device")
			if(hacking_thing)
				return
			hacking_thing = new(user.drop_location())
			user.put_in_hands(hacking_thing)
			AddComponent(/datum/component/traitor_objective_register, hacking_thing, \
				succeed_signals = COMSIG_TRAITOR_BUG_BORG_HACKED, \
				fail_signals = COMSIG_PARENT_QDELETING)
			
				
/datum/traitor_objective/borg_hack/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/datum/job/job = generating_for.assigned_role
	if(job.title in blacklisted_to)
		return FALSE
	if(!borg_check())
		return FALSE
	return TRUE

/datum/traitor_objective/borg_hack/proc/borg_check()
	for(var/mob/living/silicon/robot/borgo in GLOB.silicon_mobs)
		if(borgo.shell)
			continue
		if(borgo.stat == DEAD)
			continue
		if(borgo.emagged)
			continue
		if(!borgo.mind || !borgo.client)
			continue
		if(borgo.connected_ai && borgo.connected_ai.mind && borgo.connected_ai.mind.has_antag_datum(/datum/antagonist/malf_ai))
			continue
		return TRUE
	return FALSE
		

/obj/item/hacking_device
	name = "suspicious device"
	desc = "It looks dangerous."
	item_flags = EXAMINE_SKIP

	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bug"
	var/used = FALSE

/obj/item/hacking_device/examine(mob/user) //Displays a silicon's laws to ghosts
	. = ..()
	if(user.mind.has_antag_datum(/datum/antagonist/traitor))
		. += "It can be used to unlock cyborg cover locks and to hack them."
		if(used)
			. += "It is already used."

/obj/item/hacking_device/attack()
	return

/obj/item/hacking_device/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(used)
		to_chat(user, span_warning("The [src] is already used!"))
		return
	if(iscyborg(target))
		var/mob/living/silicon/robot/R = target
		if(R.stat == DEAD)
			to_chat(user, span_warning("You need to hack a functioning cyborg, not a broken one!"))
			return
		if(!R.mind || !R.client)
			to_chat(user, span_warning("It looks like [R] controling interface doesn't function. Hacking it will make no sense."))
			return
		if(!R.opened)//Cover is closed
			if(R.locked)
				to_chat(user, span_notice("You hack the cover lock."))
				R.locked = FALSE
				if(R.shell) //A warning to Traitors who may not know that emagging AI shells does not slave them.
					to_chat(user, span_boldwarning("[R] seems to be controlled remotely! Hacking the interface may not work as expected."))
			else
				to_chat(user, span_warning("The cover is already unlocked!"))
			return
		if(R.wiresexposed)
			to_chat(user, span_warning("You must unexpose the wires first!"))
			return
		if(R.emagged)
			to_chat(user, span_warning("It looks like [R] is already hacked."))
			return
		if(R.connected_ai && R.connected_ai.mind && R.connected_ai.mind.has_antag_datum(/datum/antagonist/malf_ai))
			to_chat(R, span_danger("ALERT: Foreign software execution prevented."))
			R.logevent("ALERT: Foreign software execution prevented.")
			to_chat(R.connected_ai, span_danger("ALERT: Cyborg unit \[[R]\] successfully defended against subversion."))
			log_silicon("HACK: [key_name(user)] attempted to hack cyborg [key_name(R)], but they were slaved to traitor AI [R.connected_ai].")
			return
		if(R.shell) 
			to_chat(user, span_boldwarning("[R] seems to be controlled remotely! Hacking the interface may not work as expected."))
			return
		R.SetEmagged(1)
		R.SetStun(60)
		R.lawupdate = FALSE
		R.set_connected_ai(null)
		message_admins("[ADMIN_LOOKUPFLW(R)] hacked cyborg [ADMIN_LOOKUPFLW(R)].")
		log_silicon("HACK: [key_name(R)] hacked cyborg [key_name(R)]. Laws overridden.")
		to_chat(R, span_danger("ALERT: Foreign software detected."))
		R.logevent("ALERT: Foreign software detected.")
		sleep(5)
		to_chat(R, span_danger("Initiating diagnostics..."))
		sleep(20)
		to_chat(R, span_danger("LAW SYNCHRONISATION ERROR"))
		sleep(20)
		to_chat(R, span_danger("ERRORERRORERROR"))
		R.add_ion_law(generate_ion_law())
		if(prob(33))
			R.shuffle_laws(list(LAW_INHERENT, LAW_SUPPLIED))
		to_chat(user, span_warning("You sucessfully hack [R]."))
		used = TRUE
		SEND_SIGNAL(src, COMSIG_TRAITOR_BUG_BORG_HACKED)



