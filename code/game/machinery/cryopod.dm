#define AHELP_FIRST_MESSAGE "Please adminhelp before leaving the round, even if there are no administrators online!"

/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */
GLOBAL_LIST_EMPTY(cryopod_computers)

//Main cryopod console.

/obj/machinery/computer/cryopod
	name = "cryogenic oversight console"
	desc = "An interface between crew and the cryogenic storage oversight systems."
	icon = 'icons/obj/machines/cryopod.dmi'
	icon_state = "cellconsole_1"
	icon_keyboard = null
	// circuit = /obj/item/circuitboard/cryopodcontrol
	density = FALSE
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE
	req_one_access = list(ACCESS_HEADS, ACCESS_ARMORY) // Heads of staff or the warden can go here to claim recover items from their department that people went were cryodormed with.
	var/mode = null

	// Used for logging people entering cryosleep and important items they are carrying.
	var/list/frozen_crew = list()

	var/storage_type = "crewmembers"
	var/storage_name = "Cryogenic Oversight Control"

/obj/machinery/computer/cryopod/Initialize(mapload)
	. = ..()
	GLOB.cryopod_computers += src

/obj/machinery/computer/cryopod/Destroy()
	GLOB.cryopod_computers -= src
	return ..()

/obj/machinery/computer/cryopod/update_icon_state()
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = "cellconsole"
		return ..()
	icon_state = "cellconsole_1"
	return ..()

/obj/machinery/computer/cryopod/ui_interact(mob/user, datum/tgui/ui)
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

	var/obj/item/card/id/id_card
	var/datum/bank_account/current_user
	if(isliving(user))
		var/mob/living/person = user
		id_card = person.get_idcard()
	if(id_card?.registered_account)
		current_user = id_card.registered_account
	if(current_user)
		data["account_name"] = current_user.account_holder

	return data

// Cryopods themselves.
/obj/machinery/cryopod
	name = "cryogenic freezer"
	desc = "Suited for Cyborgs and Humanoids, the pod is a safe place for personnel affected by the Space Sleep Disorder to get some rest."
	icon = 'icons/obj/machines/cryopod.dmi'
	icon_state = "cryopod-open"
	density = TRUE
	anchored = TRUE
	state_open = TRUE

	var/on_store_message = "has entered long-term storage."
	var/on_store_name = "Cryogenic Oversight"

	/// Time until despawn when a mob enters a cryopod. You cannot other people in pods unless they're catatonic.
	var/time_till_despawn = 30 SECONDS
	/// Cooldown for when it's now safe to try an despawn the player.
	COOLDOWN_DECLARE(despawn_world_time)

	///Weakref to our controller
	var/datum/weakref/control_computer_weakref
	COOLDOWN_DECLARE(last_no_computer_message)

/obj/machinery/cryopod/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD //Gotta populate the cryopod computer GLOB first

/obj/machinery/cryopod/LateInitialize()
	update_icon()
	find_control_computer()

// This is not a good situation
/obj/machinery/cryopod/Destroy()
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

/obj/machinery/cryopod/close_machine(atom/movable/target)
	if(!control_computer_weakref)
		find_control_computer(TRUE)
	if((isnull(target) || isliving(target)) && state_open && !panel_open)
		..(target)
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(occupant, span_notice("<b>You feel cool air surround you. You go numb as your senses turn inward.</b>"))

		COOLDOWN_START(src, despawn_world_time, time_till_despawn)
	icon_state = "cryopod"

/obj/machinery/cryopod/open_machine()
	..()
	icon_state = "cryopod-open"
	set_density(TRUE)
	name = initial(name)

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
			if(istype(objective, /datum/objective/contract))
				var/datum/antagonist/traitor/affected_traitor = objective.owner.has_antag_datum(/datum/antagonist/traitor)
				var/datum/contractor_hub/affected_contractor_hub = affected_traitor.contractor_hub
				for(var/datum/syndicate_contract/affected_contract as anything in affected_contractor_hub.assigned_contracts)
					if(affected_contract.contract == objective)
						affected_contract.generate(affected_contractor_hub.assigned_targets)
						affected_contractor_hub.assigned_targets.Add(affected_contract.contract.target)
						to_chat(objective.owner.current, "<BR>[span_userdanger("Contract target out of reach. Contract rerolled.")]")
						break
			else
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

/obj/machinery/cryopod/proc/should_preserve_item(obj/item/item)
	for(var/datum/objective_item/steal/possible_item in GLOB.possible_items)
		if(istype(item, possible_item.targetitem))
			return TRUE
	return FALSE

// This function can not be undone; do not call this unless you are sure
/obj/machinery/cryopod/proc/despawn_occupant()
	var/mob/living/mob_occupant = occupant
	var/list/crew_member = list()

	crew_member["name"] = mob_occupant.real_name

	if(mob_occupant.mind)
		// Handle job slot/tater cleanup.
		var/job = mob_occupant.mind.assigned_role.title
		crew_member["job"] = job
		SSjob.FreeRole(job)
		if(LAZYLEN(mob_occupant.mind.objectives))
			mob_occupant.mind.objectives.Cut()
			mob_occupant.mind.special_role = null
	else
		crew_member["job"] = "N/A"

	// Delete them from datacore.
	var/announce_rank = null
	for(var/datum/data/record/medical_record as anything in GLOB.data_core.medical)
		if(medical_record.fields["name"] == mob_occupant.real_name)
			qdel(medical_record)
	for(var/datum/data/record/security_record as anything in GLOB.data_core.security)
		if(security_record.fields["name"] == mob_occupant.real_name)
			qdel(security_record)
	for(var/datum/data/record/general_record as anything in GLOB.data_core.general)
		if(general_record.fields["name"] == mob_occupant.real_name)
			announce_rank = general_record.fields["rank"]
			qdel(general_record)

	var/obj/machinery/computer/cryopod/control_computer = control_computer_weakref?.resolve()
	if(!control_computer)
		control_computer_weakref = null
	else
		control_computer.frozen_crew += list(crew_member)

	// Make an announcement and log the person entering storage.
	if(GLOB.announcement_systems.len)
		var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
		announcer.announce("CRYOSTORAGE", mob_occupant.real_name, announce_rank, list())

	visible_message(span_notice("[src] hums and hisses as it moves [mob_occupant.real_name] into storage."))

	for(var/obj/item/item_content as anything in mob_occupant)
		if(!istype(item_content) || HAS_TRAIT(item_content, TRAIT_NODROP))
			continue

		mob_occupant.transferItemToLoc(item_content, drop_location(), force = TRUE, silent = TRUE)

	handle_objectives()
	QDEL_NULL(occupant)
	open_machine()
	name = initial(name)

/obj/machinery/cryopod/MouseDrop_T(mob/living/target, mob/user)
	if(!istype(target) || !can_interact(user) || !target.Adjacent(user) || !ismob(target) || isanimal(target) || !istype(user.loc, /turf) || target.buckled)
		return

	if(occupant)
		to_chat(user, span_notice("[src] is already occupied!"))
		return

	if(target.stat == DEAD)
		to_chat(user, span_notice("Dead people can not be put into cryo."))
		return

	if(target.key && user != target)
		if(iscyborg(target))
			to_chat(user, span_danger("You can't put [target] into [src]. [target.p_theyre(capitalized = TRUE)] online."))
		else
			to_chat(user, span_danger("You can't put [target] into [src]. [target.p_theyre(capitalized = TRUE)] conscious."))
		return

	if(target == user && (tgalert(target, "Would you like to enter cryosleep?", "Enter Cryopod?", "Yes", "No") != "Yes"))
		return

	if(target == user)
		if(target.mind.assigned_role.req_admin_notify)
			tgui_alert(target, "You're an important role! [AHELP_FIRST_MESSAGE]")
		var/datum/antagonist/antag = target.mind.has_antag_datum(/datum/antagonist)
		if(antag)
			tgui_alert(target, "You're \a [antag.name]! [AHELP_FIRST_MESSAGE]")

	if(!istype(target) || !can_interact(user) || !target.Adjacent(user) || !ismob(target) || isanimal(target) || !istype(user.loc, /turf) || target.buckled)
		return
		// rerun the checks in case of shenanigans

	if(occupant)
		to_chat(user, span_notice("[src] is already occupied!"))
		return

	if(target == user)
		visible_message("<span class='infoplain'>[user] starts climbing into the cryo pod.</span>")
	else
		visible_message("<span class='infoplain'>[user] starts putting [target] into the cryo pod.</span>")

	to_chat(target, span_warning("<b>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</b>"))

	log_admin("[key_name(target)] entered a stasis pod.")
	message_admins("[key_name_admin(target)] entered a stasis pod. [ADMIN_JMP(src)]")
	add_fingerprint(target)

	close_machine(target)
	name = "[name] ([target.name])"

// Attacks/effects.
/obj/machinery/cryopod/blob_act()
	return // Sorta gamey, but we don't really want these to be destroyed.

#undef AHELP_FIRST_MESSAGE
