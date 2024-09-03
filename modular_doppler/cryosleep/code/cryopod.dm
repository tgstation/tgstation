#define AHELP_FIRST_MESSAGE "Please adminhelp before leaving the round, even if there are no administrators online!"

/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */
GLOBAL_LIST_EMPTY(cryopod_computers)

GLOBAL_LIST_EMPTY(ghost_records)

/// A list of all cryopods that aren't quiet, to be used by the "Send to Cryogenic Storage" VV action.
GLOBAL_LIST_EMPTY(valid_cryopods)

//Main cryopod console.

/obj/machinery/computer/cryopod
	name = "cryogenic oversight console"
	desc = "An interface between crew and the cryogenic storage oversight systems."
	icon = 'modular_doppler/cryosleep/icons/cryogenics.dmi'
	icon_state = "cellconsole_1"
	icon_keyboard = null
	icon_screen = null
	use_power = FALSE
	density = FALSE
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE
	req_one_access = list(ACCESS_COMMAND, ACCESS_ARMORY) // Heads of staff or the warden can go here to claim recover items from their department that people went were cryodormed with.
	verb_say = "coldly states"
	verb_ask = "queries"
	verb_exclaim = "alarms"

	/// Used for logging people entering cryosleep and important items they are carrying.
	var/list/frozen_crew = list()
	/// The items currently stored in the cryopod control panel.
	var/list/frozen_item = list()

	/// This is what the announcement system uses to make announcements. Make sure to set a radio that has the channel you want to broadcast on.
	var/obj/item/radio/headset/radio = /obj/item/radio/headset/silicon/ai
	/// The channel to be broadcast on, valid values are the values of any of the "RADIO_CHANNEL_" defines.
	var/announcement_channel = null // RADIO_CHANNEL_COMMON doesn't work here.

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/cryopod, 32)

/obj/machinery/computer/cryopod/Initialize(mapload)
	. = ..()
	GLOB.cryopod_computers += src
	radio = new radio(src)

/obj/machinery/computer/cryopod/Destroy()
	GLOB.cryopod_computers -= src
	QDEL_NULL(radio)
	return ..()

/obj/machinery/computer/cryopod/update_icon_state()
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = "cellconsole"
		return ..()
	icon_state = "cellconsole_1"
	return ..()

/obj/machinery/computer/cryopod/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	add_fingerprint(user)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CryopodConsole", name)
		ui.open()

/obj/machinery/computer/cryopod/ui_data(mob/user)
	var/list/data = list()
	data["frozen_crew"] = frozen_crew

	/// The list of references to the stored items.
	var/list/item_ref_list = list()
	/// The associative list of the reference to an item and its name.
	var/list/item_ref_name = list()

	for(var/obj/item/item in frozen_item)
		var/ref = REF(item)
		item_ref_list += ref
		item_ref_name[ref] = item.name

	data["item_ref_list"] = item_ref_list
	data["item_ref_name"] = item_ref_name

	// Check Access for item dropping.
	var/item_retrieval_allowed = allowed(user)
	data["item_retrieval_allowed"] = item_retrieval_allowed

	var/obj/item/card/id/id_card
	if(isliving(user))
		var/mob/living/person = user
		id_card = person.get_idcard()
	if(id_card?.registered_name)
		data["account_name"] = id_card.registered_name

	return data

/obj/machinery/computer/cryopod/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("item_get")
			// This is using references, kinda clever, not gonna lie. Good work Zephyr
			var/item_get = params["item_get"]
			var/obj/item/item = locate(item_get)
			if(item in frozen_item)
				item.forceMove(drop_location())
				frozen_item.Remove(item_get, item)
				visible_message("[src] dispenses \the [item].")
				message_admins("[item] was retrieved from cryostorage at [ADMIN_COORDJMP(src)]")
			else
				CRASH("Invalid REF# for ui_act. Not inside internal list!")
			return TRUE

		else
			CRASH("Illegal action for ui_act: '[action]'")

/obj/machinery/computer/cryopod/proc/announce(message_type, user, rank, occupant_departments_bitflags, occupant_job_radio)
	switch(message_type)
		if("CRYO_JOIN")
			radio.talk_into(src, "[user][rank ? ", [rank]" : ""] has woken up from cryo storage.", announcement_channel)
		if("CRYO_LEAVE")
			if (occupant_job_radio)
				if (occupant_departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
					if (occupant_job_radio != RADIO_CHANNEL_COMMAND)
						radio.talk_into(src, "[user][rank ? ", [rank]" : ""] has been moved to cryo storage.", RADIO_CHANNEL_COMMAND)
					radio.use_command = TRUE
				radio.talk_into(src, "[user][rank ? ", [rank]" : ""] has been moved to cryo storage.", occupant_job_radio)
				radio.use_command = FALSE
			radio.talk_into(src, "[user][rank ? ", [rank]" : ""] has been moved to cryo storage.", announcement_channel)

// Cryopods themselves.
/obj/machinery/cryopod
	name = "cryogenic freezer"
	desc = "Suited for Cyborgs and Humanoids, the pod is a safe place for personnel affected by the Space Sleep Disorder to get some rest."
	icon = 'modular_doppler/cryosleep/icons/cryogenics.dmi'
	icon_state = "cryopod-open"
	base_icon_state = "cryopod"
	use_power = FALSE
	density = TRUE
	anchored = TRUE
	state_open = TRUE
	interaction_flags_mouse_drop = NEED_DEXTERITY

	var/open_icon_state = "cryopod-open"
	/// Whether the cryopod respects the minimum time someone has to be disconnected before they can be put into cryo by another player
	var/allow_timer_override = FALSE
	/// Minimum time for someone to be SSD before another player can cryo them. Customizable in "cryo_min_ssd_time" in config_doppler
	var/ssd_time = 15 MINUTES

	/// Time until despawn when a mob enters a cryopod. You cannot other people in pods unless they're catatonic.
	var/time_till_despawn = 30 SECONDS
	/// Cooldown for when it's now safe to try an despawn the player.
	COOLDOWN_DECLARE(despawn_world_time)

	///Weakref to our controller
	var/datum/weakref/control_computer_weakref
	COOLDOWN_DECLARE(last_no_computer_message)
	/// if false, plays announcement on cryo
	var/quiet = FALSE
	/// Has the occupant been tucked in?
	var/tucked = FALSE

/obj/machinery/cryopod/quiet
	quiet = TRUE

/obj/machinery/cryopod/Initialize(mapload)
	..()
	ssd_time = CONFIG_GET(number/cryo_min_ssd_time)
	if(!quiet)
		GLOB.valid_cryopods += src
	return INITIALIZE_HINT_LATELOAD //Gotta populate the cryopod computer GLOB first

/obj/machinery/cryopod/post_machine_initialize()
	. = ..()
	update_icon()
	find_control_computer()

// This is not a good situation
/obj/machinery/cryopod/Destroy()
	GLOB.valid_cryopods -= src
	control_computer_weakref = null
	return ..()

/obj/machinery/cryopod/proc/find_control_computer(urgent = FALSE)
	for(var/cryo_console as anything in GLOB.cryopod_computers)
		var/obj/machinery/computer/cryopod/console = cryo_console
		if(get_area(console) == get_area(src))
			control_computer_weakref = WEAKREF(console)
			break

	// Don't send messages unless we *need* the computer, and less than five minutes have passed since last time we messaged
	if(!control_computer_weakref && urgent && COOLDOWN_FINISHED(src, last_no_computer_message))
		COOLDOWN_START(src, last_no_computer_message, 5 MINUTES)
		log_admin("Cryopod in [get_area(src)] could not find control computer!")
		message_admins("Cryopod in [get_area(src)] could not find control computer!")
		last_no_computer_message = world.time

	return control_computer_weakref != null

/obj/machinery/cryopod/close_machine(atom/movable/target, density_to_set = TRUE)
	if(!control_computer_weakref)
		find_control_computer(TRUE)
	if((isnull(target) || isliving(target)) && state_open && !panel_open)
		..(target)
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(occupant, span_notice("<b>You feel cool air surround you. You go numb as your senses turn inward.</b>"))

		var/mob/living/carbon/human/human_occupant = occupant
		if(istype(human_occupant) && human_occupant.mind)
			human_occupant.save_individual_persistence(mob_occupant.ckey || mob_occupant.mind?.key)

		COOLDOWN_START(src, despawn_world_time, time_till_despawn)

/obj/machinery/cryopod/open_machine(drop = TRUE, density_to_set = FALSE)
	..()
	set_density(TRUE)
	name = initial(name)
	tucked = FALSE

/obj/machinery/cryopod/container_resist_act(mob/living/user)
	visible_message(span_notice("[occupant] emerges from [src]!"),
		span_notice("You climb out of [src]!"))
	open_machine()

/obj/machinery/cryopod/relaymove(mob/user)
	container_resist_act(user)

/obj/machinery/cryopod/process()
	if(!occupant)
		return

	var/mob/living/mob_occupant = occupant
	if(mob_occupant.stat == DEAD)
		open_machine()

	if(!mob_occupant.client && COOLDOWN_FINISHED(src, despawn_world_time))
		if(!control_computer_weakref)
			find_control_computer(urgent = TRUE)

		despawn_occupant()

/obj/machinery/cryopod/proc/handle_objectives()
	var/mob/living/mob_occupant = occupant
	// Update any existing objectives involving this mob.
	for(var/datum/objective/objective in GLOB.objectives)
		// We don't want revs to get objectives that aren't for heads of staff. Letting
		// them win or lose based on cryo is silly so we remove the objective.
		if(istype(objective,/datum/objective/mutiny) && objective.target == mob_occupant.mind)
			objective.team.objectives -= objective
			qdel(objective)
			for(var/datum/mind/mind in objective.team.members)
				to_chat(mind.current, "<BR>[span_userdanger("Your target is no longer within reach. Objective removed!")]")
				mind.announce_objectives()
		else if(istype(objective.target) && objective.target == mob_occupant.mind)
			if(!istype(objective, /datum/objective/contract))
				return
		else if(istype(objective.target) && objective.target == mob_occupant.mind)
			var/old_target = objective.target
			objective.target = null
			if(!objective)
				return
			objective.find_target()
			if(!objective.target && objective.owner)
				to_chat(objective.owner.current, "<BR>[span_userdanger("Your target is no longer within reach. Objective removed!")]")
				for(var/datum/antagonist/antag in objective.owner.antag_datums)
					antag.objectives -= objective
			if (!objective.team)
				objective.update_explanation_text()
				objective.owner.announce_objectives()
				to_chat(objective.owner.current, "<BR>[span_userdanger("You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")]. Objectives updated!")]")
			else
				var/list/objectivestoupdate
				for(var/datum/mind/objective_owner in objective.get_owners())
					to_chat(objective_owner.current, "<BR>[span_userdanger("You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")]. Objectives updated!")]")
					for(var/datum/objective/update_target_objective in objective_owner.get_all_objectives())
						LAZYADD(objectivestoupdate, update_target_objective)
				objectivestoupdate += objective.team.objectives
				for(var/datum/objective/update_objective in objectivestoupdate)
					if(update_objective.target != old_target || !istype(update_objective,objective.type))
						continue
					update_objective.target = objective.target
					update_objective.update_explanation_text()
					to_chat(objective.owner.current, "<BR>[span_userdanger("You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")]. Objectives updated!")]")
					update_objective.owner.announce_objectives()
			qdel(objective)

/// This function can not be undone; do not call this unless you are sure.
/// Handles despawning the player.
/obj/machinery/cryopod/proc/despawn_occupant()
	var/mob/living/mob_occupant = occupant

	var/occupant_ckey = mob_occupant.ckey || mob_occupant.mind?.key
	var/occupant_name = mob_occupant.name
	var/occupant_rank = mob_occupant.mind?.assigned_role.title
	var/occupant_departments_bitflags = mob_occupant.mind?.assigned_role.departments_bitflags
	var/occupant_job_radio = mob_occupant.mind?.assigned_role.default_radio_channel

	SSjob.FreeRole(occupant_rank)

	// Handle holy successor removal
	var/list/holy_successors = list_holy_successors()
	if(mob_occupant in holy_successors) // if this mob was a holy successor then remove them from the pool
		GLOB.holy_successors -= WEAKREF(mob_occupant)

	if(mob_occupant.mind)
		// Handle tater cleanup.
		if(LAZYLEN(mob_occupant.mind.objectives))
			mob_occupant.mind.objectives.Cut()
			mob_occupant.mind.special_role = null
		// Handle freeing the high priest role for the next chaplain in line
		if(mob_occupant.mind.holy_role == HOLY_ROLE_HIGHPRIEST)
			reset_religion()
	else
		// handle the case of the high priest no longer having a mind
		var/datum/weakref/current_highpriest = GLOB.current_highpriest
		if(current_highpriest?.resolve() == mob_occupant)
			reset_religion()

	// Delete them from datacore and ghost records.
	var/announce_rank = null

	for(var/list/record in GLOB.ghost_records)
		if(record["name"] == occupant_name)
			announce_rank = record["rank"]
			GLOB.ghost_records.Remove(list(record))
			break

	if(!announce_rank) // No need to loop over all of those if we already found it beforehand.
		for(var/datum/record/crew/possible_target_record as anything in GLOB.manifest.general)
			if(possible_target_record.name == occupant_name && (occupant_rank == "N/A" || possible_target_record.trim == occupant_rank))
				announce_rank = possible_target_record.rank
				qdel(possible_target_record)
				break

	var/obj/machinery/computer/cryopod/control_computer = control_computer_weakref?.resolve()
	if(!control_computer)
		control_computer_weakref = null
	else
		control_computer.frozen_crew += list(list("name" = occupant_name, "job" = occupant_rank))

		// Make an announcement and log the person entering storage. If set to quiet, does not make an announcement.
		if(!quiet)
			control_computer.announce("CRYO_LEAVE", mob_occupant.real_name, announce_rank, occupant_departments_bitflags, occupant_job_radio)

	visible_message(span_notice("[src] hums and hisses as it moves [mob_occupant.real_name] into storage."))

	for(var/obj/item/item_content as anything in mob_occupant)
		if(!istype(item_content) || HAS_TRAIT(item_content, TRAIT_NODROP))
			continue
		if (issilicon(mob_occupant) && istype(item_content, /obj/item/mmi))
			continue
		if(control_computer)
			if(istype(item_content, /obj/item/modular_computer))
				var/obj/item/modular_computer/computer = item_content
				for(var/datum/computer_file/program/messenger/message_app in computer.stored_files)
					message_app.invisible = TRUE
			mob_occupant.transferItemToLoc(item_content, control_computer, force = TRUE, silent = TRUE)
			item_content.dropped(mob_occupant)
			control_computer.frozen_item += item_content
		else
			mob_occupant.transferItemToLoc(item_content, drop_location(), force = TRUE, silent = TRUE)

	GLOB.joined_player_list -= occupant_ckey

	handle_objectives()
	mob_occupant.ghostize()
	QDEL_NULL(occupant)
	open_machine()
	name = initial(name)

/obj/machinery/cryopod/mouse_drop_receive(mob/living/target, mob/user, params)
	if(!istype(target) || !ismob(target) || isanimal(target) || !istype(user.loc, /turf) || target.buckled)
		return

	if(occupant)
		to_chat(user, span_notice("[src] is already occupied!"))
		return

	if(target.stat == DEAD)
		to_chat(user, span_notice("Dead people can not be put into cryo."))
		return

// Allows admins to enable players to override SSD Time check.
	if(allow_timer_override)
		if(tgui_alert(user, "Would you like to place [target] into [src]?", "Place into Cryopod?", list("Yes", "No")) != "No")
			to_chat(user, span_danger("You put [target] into [src]. [target.p_Theyre()] in the cryopod."))
			log_admin("[key_name(user)] has put [key_name(target)] into a overridden stasis pod.")
			message_admins("[key_name(user)] has put [key_name(target)] into a overridden stasis pod. [ADMIN_JMP(src)]")

			add_fingerprint(target)

			close_machine(target)
			name = "[name] ([target.name])"

// Allows players to cryo others. Checks if they have been AFK for 30 minutes.
	if(target.key && user != target)
		if (target.get_organ_by_type(/obj/item/organ/internal/brain) ) //Target the Brain
			if(!target.mind || target.ssd_indicator ) // Is the character empty / AI Controlled
				if(target.lastclienttime + ssd_time >= world.time)
					to_chat(user, span_notice("You can't put [target] into [src] for another [round(((ssd_time - (world.time - target.lastclienttime)) / (1 MINUTES)), 1)] minutes."))
					log_admin("[key_name(user)] has attempted to put [key_name(target)] into a stasis pod, but they were only disconnected for [round(((world.time - target.lastclienttime) / (1 MINUTES)), 1)] minutes.")
					message_admins("[key_name(user)] has attempted to put [key_name(target)] into a stasis pod. [ADMIN_JMP(src)]")
					return
				else if(tgui_alert(user, "Would you like to place [target] into [src]?", "Place into Cryopod?", list("Yes", "No")) == "Yes")
					if(target.mind.assigned_role.req_admin_notify)
						tgui_alert(user, "They are an important role! [AHELP_FIRST_MESSAGE]")
					to_chat(user, span_danger("You put [target] into [src]. [target.p_Theyre()] in the cryopod."))
					log_admin("[key_name(user)] has put [key_name(target)] into a stasis pod.")
					message_admins("[key_name(user)] has put [key_name(target)] into a stasis pod. [ADMIN_JMP(src)]")

					add_fingerprint(target)

					close_machine(target)
					name = "[name] ([target.name])"

		else if(iscyborg(target))
			to_chat(user, span_danger("You can't put [target] into [src]. [target.p_Theyre()] online."))
		else
			to_chat(user, span_danger("You can't put [target] into [src]. [target.p_Theyre()] conscious."))
		return

	if(target == user && (tgui_alert(target, "Would you like to enter cryosleep?", "Enter Cryopod?", list("Yes", "No")) != "Yes"))
		return

	if(target == user)
		if(target.mind.assigned_role.req_admin_notify)
			tgui_alert(target, "You're an important role! [AHELP_FIRST_MESSAGE]")
		var/datum/antagonist/antag = target.mind.has_antag_datum(/datum/antagonist)
		if(antag)
			tgui_alert(target, "You're \a [antag.name]! [AHELP_FIRST_MESSAGE]")

	if(LAZYLEN(target.buckled_mobs) > 0)
		if(target == user)
			to_chat(user, span_danger("You can't fit into the cryopod while someone is buckled to you."))
		else
			to_chat(user, span_danger("You can't fit [target] into the cryopod while someone is buckled to them."))
		return

	if(!istype(target) || !can_interact(user) || !target.Adjacent(user) || !ismob(target) || isanimal(target) || !istype(user.loc, /turf) || target.buckled)
		return
		// rerun the checks in case of shenanigans

	if(occupant)
		to_chat(user, span_notice("[src] is already occupied!"))
		return

	if(target == user)
		visible_message(span_infoplain("[user] starts climbing into the cryo pod."))
	else
		visible_message(span_infoplain("[user] starts putting [target] into the cryo pod."))

	to_chat(target, span_warning("<b>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</b>"))

	log_admin("[key_name(target)] entered a stasis pod.")
	message_admins("[key_name_admin(target)] entered a stasis pod. [ADMIN_JMP(src)]")
	add_fingerprint(target)

	close_machine(target)
	name = "[name] ([target.name])"

// Attacks/effects.
/obj/machinery/cryopod/blob_act()
	return // Sorta gamey, but we don't really want these to be destroyed.

/obj/machinery/cryopod/attackby(obj/item/weapon, mob/living/carbon/human/user, params)
	. = ..()
	if(istype(weapon, /obj/item/bedsheet))
		if(!occupant || !istype(occupant, /mob/living))
			return
		if(tucked)
			to_chat(user, span_warning("[occupant.name] already looks pretty comfortable!"))
			return
		to_chat(user, span_notice("You tuck [occupant.name] into their pod!"))
		qdel(weapon)
		user.add_mood_event("tucked", /datum/mood_event/tucked_in, occupant)
		tucked = TRUE

/obj/machinery/cryopod/update_icon_state()
	icon_state = state_open ? open_icon_state : base_icon_state
	return ..()

/// Special wall mounted cryopod for the prison, making it easier to autospawn.
/obj/machinery/cryopod/prison
	icon_state = "prisonpod"
	base_icon_state = "prisonpod"
	open_icon_state = "prisonpod"
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/cryopod/prison, 18)

/obj/machinery/cryopod/prison/set_density(new_value)
	// Simple way to make it always non-dense.
	return ..(FALSE)

/obj/machinery/cryopod/prison/close_machine(atom/movable/target, density_to_set = TRUE)
	. = ..()
	// Flick the pod for a second when user enters
	flick("prisonpod-open", src)

// Wake-up notifications

/obj/effect/mob_spawn/ghost_role
	/// For figuring out where the local cryopod computer is. Must be set for cryo computer announcements.
	var/area/computer_area

/obj/effect/mob_spawn/ghost_role/create(mob/mob_possessor, newname)
	var/mob/living/spawned_mob = ..()
	var/obj/machinery/computer/cryopod/control_computer = find_control_computer()

	GLOB.ghost_records.Add(list(list("name" = spawned_mob.real_name, "rank" = name)))
	if(control_computer)
		control_computer.announce("CRYO_JOIN", spawned_mob.real_name, name)

	return spawned_mob

/obj/effect/mob_spawn/ghost_role/proc/find_control_computer()
	if(!computer_area)
		return
	for(var/cryo_console as anything in GLOB.cryopod_computers)
		var/obj/machinery/computer/cryopod/console = cryo_console
		var/area/area = get_area(cryo_console) // Define moment
		if(area.type == computer_area)
			return console

	return

#undef AHELP_FIRST_MESSAGE
