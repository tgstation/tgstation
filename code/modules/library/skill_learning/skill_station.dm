#define SKILLCHIP_IMPLANT_TIME (15 SECONDS)
#define SKILLCHIP_REMOVAL_TIME (15 SECONDS)

/obj/machinery/skill_station
	name = "\improper Skillsoft station"
	desc = "Learn skills with only minimal chance for brain damage."

	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	occupant_typecache = list(/mob/living/carbon) //todo make occupant_typecache per type
	state_open = TRUE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND //Don't call ui_interac by default - we only want that when inside
	circuit = /obj/item/circuitboard/machine/skill_station
	/// Currently implanting/removing
	var/working = FALSE
	/// Timer until implanting/removing finishes.
	var/work_timer
	/// What we're implanting
	var/obj/item/skillchip/inserted_skillchip

/obj/machinery/skill_station/Initialize(mapload)
	. = ..()
	update_appearance()

//Only usable by the person inside
/obj/machinery/skill_station/ui_state(mob/user)
	return GLOB.contained_state

/obj/machinery/skill_station/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkillStation", name)
		ui.open()

/obj/machinery/skill_station/update_icon_state()
	icon_state = initial(icon_state)
	if(state_open)
		icon_state += "_open"
	if(occupant)
		icon_state += "_occupied"
	return ..()

/obj/machinery/skill_station/update_overlays()
	. = ..()
	if(working)
		. += "working"

/obj/machinery/skill_station/relaymove(mob/living/user, direction)
	open_machine()

/obj/machinery/skill_station/open_machine()
	. = ..()
	interrupt_operation()

/obj/machinery/skill_station/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == inserted_skillchip)
		inserted_skillchip = null
		interrupt_operation()

/obj/machinery/skill_station/power_change()
	. = ..()
	if(working)
		interrupt_operation()

/obj/machinery/skill_station/close_machine(atom/movable/target)
	. = ..()
	if(occupant)
		ui_interact(occupant)

/obj/machinery/skill_station/proc/interrupt_operation()
	working = FALSE
	if(work_timer)
		deltimer(work_timer)
		work_timer = null
	update_appearance()

/obj/machinery/skill_station/interact(mob/user)
	. = ..()
	if(user == occupant)
		ui_interact(user)
	else
		toggle_open()

/obj/machinery/skill_station/attackby(obj/item/I, mob/living/user, params)
	if(istype(I,/obj/item/skillchip))
		if(inserted_skillchip)
			to_chat(user,span_notice("There's already a skillchip inside."))
			return
		if(!user.transferItemToLoc(I, src))
			return
		inserted_skillchip = I
		return
	return ..()

/obj/machinery/skill_station/dump_contents()
	. = ..()
	inserted_skillchip = null

/obj/machinery/skill_station/dump_inventory_contents(list/subset = null)
	// Don't drop the skillchip, it's directly inserted into the machine.
	// dump_contents() will drop everything including the skillchip as an alternative to this.
	return ..(contents - inserted_skillchip)

/obj/machinery/skill_station/proc/toggle_open(mob/user)
	state_open ? close_machine() : open_machine()

// Functions below do not validate occupant exists - should be handled outer wrappers.
/// Start implanting.
/obj/machinery/skill_station/proc/start_implanting()
	var/mob/living/carbon/carbon_occupant = occupant

	if(inserted_skillchip.has_mob_incompatibility(carbon_occupant))
		CRASH("Unusual error - [usr] attempted to start implanting of [inserted_skillchip] when the interface state should not have allowed it.")

	working = TRUE
	work_timer = addtimer(CALLBACK(src, PROC_REF(implant)),SKILLCHIP_IMPLANT_TIME,TIMER_STOPPABLE)
	update_appearance()

/// Finish implanting.
/obj/machinery/skill_station/proc/implant()
	working = FALSE
	work_timer = null
	var/mob/living/carbon/carbon_occupant = occupant
	var/implant_msg = carbon_occupant.implant_skillchip(inserted_skillchip, FALSE)
	if(implant_msg)
		to_chat(carbon_occupant,span_notice("Operation failed! [implant_msg]"))
	else
		to_chat(carbon_occupant,span_notice("Operation complete!"))
		inserted_skillchip = null

	update_appearance()

/// Start removal.
/obj/machinery/skill_station/proc/start_removal(obj/item/skillchip/to_be_removed)
	if(!to_be_removed)
		return

	if(to_be_removed.is_on_cooldown())
		to_chat(occupant, span_notice("DANGER! Operation cannot be completed, removal is unsafe."))
		CRASH("Unusual error - [usr] attempted to start removal of [to_be_removed] when the interface state should not have allowed it.")

	working = TRUE
	work_timer = addtimer(CALLBACK(src, PROC_REF(remove_skillchip),to_be_removed),SKILLCHIP_REMOVAL_TIME,TIMER_STOPPABLE)
	update_appearance()

/// Finish removal.
/obj/machinery/skill_station/proc/remove_skillchip(obj/item/skillchip/to_be_removed)
	working = FALSE
	work_timer = null
	update_appearance()

	var/mob/living/carbon/carbon_occupant = occupant

	if(to_be_removed.is_on_cooldown())
		to_chat(carbon_occupant,span_notice("Safety mechanisms activated! Skillchip cannot be safely removed."))
		return

	if(!istype(carbon_occupant))
		to_chat(carbon_occupant,span_notice("Occupant does not appear to be a carbon-based lifeform!"))
		return

	if(!carbon_occupant.remove_skillchip(to_be_removed))
		to_chat(carbon_occupant,span_notice("Failed to remove skillchip!"))
		return

	if(to_be_removed.removable)
		carbon_occupant.put_in_hands(to_be_removed)
	else
		qdel(to_be_removed)

	to_chat(carbon_occupant, span_notice("Operation complete!"))

/obj/machinery/skill_station/proc/toggle_chip_active(obj/item/skillchip/to_be_toggled)
	var/mob/living/carbon/carbon_occupant = occupant

	if(to_be_toggled.is_on_cooldown())
		to_chat(carbon_occupant,span_notice("Safety mechanisms activated! Skillchip cannot be safely modified."))
		return

	if(!istype(carbon_occupant))
		to_chat(carbon_occupant,span_notice("Occupant does not appear to be a carbon-based lifeform!"))
		return

	if(to_be_toggled.is_active())
		var/active_msg = to_be_toggled.try_deactivate_skillchip(FALSE, FALSE)
		if(active_msg)
			to_chat(carbon_occupant,span_notice("Failed to deactivate skillchip! [active_msg]"))
		return

	// This code will fire when to_be_toggled.active is FALSE
	var/active_msg = to_be_toggled.try_activate_skillchip(FALSE, FALSE)
	if(active_msg)
		to_chat(carbon_occupant,span_notice("Failed to activate skillchip! [active_msg]"))

/obj/machinery/skill_station/ui_data(mob/user)
	. = ..()
	.["working"] = working
	.["timeleft"] = work_timer ? timeleft(work_timer) : null
	var/mob/living/carbon/carbon_occupant = occupant

	.["skillchip_ready"] = inserted_skillchip ? TRUE : FALSE
	if(inserted_skillchip)
		// This is safe, incompatibility check can accept a null or invalid mob.
		var/incompatibility_check = inserted_skillchip.has_mob_incompatibility(carbon_occupant)
		// Grab chip data. We do this because of special chips like Chameleon that may want to
		// spoof their information.
		var/list/inserted_chip_data = inserted_skillchip.get_chip_data()
		if(incompatibility_check)
			.["implantable"] = FALSE
			.["implantable_reason"] = incompatibility_check
		else
			.["implantable"] = TRUE
			.["implantable_reason"] = null
		.["skill_name"] = inserted_chip_data["name"]
		.["skill_desc"] = inserted_chip_data["desc"]
		.["skill_icon"] = inserted_chip_data["icon"]
		.["complexity"] = inserted_chip_data["complexity"]
		.["slot_use"] = inserted_chip_data["slot_use"]

	// If there's no occupant, we don't need to worry about what skillchips are in their brain.
	if(!carbon_occupant)
		.["error"] = "No valid occupant detected. Please consult nearest medical practitioner."
		.["current"] = null
		.["complexity_used"] = null
		.["complexity_max"] = null
		.["slots_used"] = null
		.["slots_max"] = null
		return

	var/obj/item/organ/internal/brain/occupant_brain = carbon_occupant.getorganslot(ORGAN_SLOT_BRAIN)

	// If there's no brain, we don't need to worry either.
	if(QDELETED(occupant_brain))
		.["error"] = "Brain not detected. Please consult nearest medical practitioner."
		.["current"] = null
		.["complexity_used"] = null
		.["complexity_max"] = null
		.["slots_used"] = null
		.["slots_max"] = null
		return

	.["complexity_used"] = occupant_brain.get_used_skillchip_complexity()
	.["complexity_max"] = occupant_brain.get_max_skillchip_complexity()
	.["slots_used"] = occupant_brain.get_used_skillchip_slots()
	.["slots_max"] = occupant_brain.get_max_skillchip_slots()

	// If we got here, we have both an occupant and it has a brain, so we can check for skillchips.
	var/list/current_skills = list()
	for(var/obj/item/skillchip/skill_chip in occupant_brain.skillchips)
		current_skills += list(skill_chip.get_chip_data())
	.["current"] = current_skills

/obj/machinery/skill_station/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(usr != occupant)
		return
	switch(action)
		if("implant")
			if(working)
				stack_trace("[usr] tried to start skillchip implanting when [src] was in an invalid state.")
				return TRUE
			if(occupant && inserted_skillchip)
				start_implanting()
			return TRUE
		if("remove")
			if(working)
				stack_trace("[usr] tried to start skillchip removal when [src] was in an invalid state.")
				return TRUE
			var/chipref = params["ref"]
			var/mob/living/carbon/carbon_occupant = occupant
			var/obj/item/organ/internal/brain/occupant_brain = carbon_occupant.getorganslot(ORGAN_SLOT_BRAIN)
			if(QDELETED(carbon_occupant) || QDELETED(occupant_brain))
				return TRUE
			var/obj/item/skillchip/to_be_removed = locate(chipref) in occupant_brain.skillchips
			if(!to_be_removed)
				return TRUE
			start_removal(to_be_removed)
			return TRUE
		if("eject")
			if(working)
				stack_trace("[usr] tried to toggle skillchip activation when [src] was in an invalid state.")
				return TRUE
			if(inserted_skillchip)
				to_chat(occupant,span_notice("You eject the skillchip."))
				var/mob/living/carbon/human/H = occupant
				H.put_in_hands(inserted_skillchip)
				inserted_skillchip = null
				return TRUE
		if("toggle_activate")
			var/chipref = params["ref"]
			// Check if the machine is already working. If it is, this act should not have sent.
			if(working)
				stack_trace("[usr] tried to toggle skillchip activation when [src] was in an invalid state.")
				return TRUE
			var/mob/living/carbon/carbon_occupant = occupant
			var/obj/item/organ/internal/brain/occupant_brain = carbon_occupant.getorganslot(ORGAN_SLOT_BRAIN)
			if(QDELETED(carbon_occupant) || QDELETED(occupant_brain))
				return TRUE
			var/obj/item/skillchip/to_be_removed = locate(chipref) in occupant_brain.skillchips
			if(!to_be_removed)
				return TRUE
			toggle_chip_active(to_be_removed)
			return TRUE

