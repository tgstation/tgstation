#define SKILLCHIP_IMPLANT_TIME 1 MINUTES
#define SKILLCHIP_REMOVAL_TIME 30 SECONDS

/obj/machinery/skill_station
	name = "Skillsoft Station"
	desc = "learn skills with only minimal chance for brain damage."

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

/obj/machinery/skill_station/Initialize()
	. = ..()
	update_icon()

//Only usable by the person inside
/obj/machinery/skill_station/ui_state(mob/user)
	return GLOB.contained_state

/obj/machinery/skill_station/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkillStation", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/skill_station/update_icon_state()
	icon_state = initial(icon_state)
	if(state_open)
		icon_state += "_open"
	if(occupant)
		icon_state += "_occupied"

/obj/machinery/skill_station/update_overlays()
	. = ..()
	if(working)
		. += "working"

/obj/machinery/skill_station/relaymove(mob/user)
	open_machine()

/obj/machinery/skill_station/open_machine()
	. = ..()
	interrupt_operation()

/obj/machinery/skill_station/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if(AM == inserted_skillchip)
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
	update_icon()

/obj/machinery/skill_station/interact(mob/user)
	. = ..()
	if(user == occupant)
		ui_interact(user)
	else
		toggle_open()

/obj/machinery/skill_station/attackby(obj/item/I, mob/living/user, params)
	if(istype(I,/obj/item/skillchip))
		if(inserted_skillchip)
			to_chat(user,"<span class='notice'>There's already a skillchip inside.</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		inserted_skillchip = I
		SStgui.update_uis(src)
		return
	return ..()

/obj/machinery/skill_station/dropContents(list/subset)
	subset = contents - inserted_skillchip
	return ..() //This is kinda annoying

/obj/machinery/skill_station/proc/toggle_open(mob/user)
	state_open ? close_machine() : open_machine()

// Functions below do not validate occupant exists - should be handled outer wrappers.
/// Start implanting.
/obj/machinery/skill_station/proc/start_implanting()
	var/mob/living/carbon/carbon_occupant = occupant

	if(inserted_skillchip.has_mob_incompatibility(carbon_occupant))
		CRASH("Unusual error - [usr] attempted to start implanting of [inserted_skillchip] when the interface state should not have allowed it.")

	working = TRUE
	work_timer = addtimer(CALLBACK(src,.proc/implant),SKILLCHIP_IMPLANT_TIME,TIMER_STOPPABLE)
	update_icon()

/// Finish implanting.
/obj/machinery/skill_station/proc/implant()
	working = FALSE
	work_timer = null
	var/mob/living/carbon/carbon_occupant = occupant
	if(carbon_occupant.implant_skillchip(inserted_skillchip))
		inserted_skillchip = null
		to_chat(occupant,"<span class='notice'>Operation complete!</span>")
	else
		to_chat(occupant,"<span class='notice'>Operation failed!</span>")
	update_icon()
	SStgui.update_uis(src)

/// Start removal.
/obj/machinery/skill_station/proc/start_removal(obj/item/skillchip/to_be_removed)
	if(!to_be_removed)
		return

	if(!to_be_removed.can_remove_safely())
		to_chat(occupant, "<span class='notice'>DANGER! Operation cannot be completed, removal is unsafe.</span>")
		CRASH("Unusual error - [usr] attempted to start removal of [to_be_removed] when the interface state should not have allowed it.")

	working = TRUE
	work_timer = addtimer(CALLBACK(src,.proc/remove_skillchip,to_be_removed),SKILLCHIP_REMOVAL_TIME,TIMER_STOPPABLE)
	update_icon()

/// Finish removal.
/obj/machinery/skill_station/proc/remove_skillchip(obj/item/skillchip/to_be_removed)
	working = FALSE
	work_timer = null
	update_icon()

	var/mob/living/carbon/carbon_occupant = occupant

	if(!to_be_removed.can_remove_safely())
		to_chat(carbon_occupant,"<span class='notice'>Safety mechanisms activated! Skillchip cannot be safely removed.</span>")
		SStgui.update_uis(src)
		return

	if(!istype(carbon_occupant))
		to_chat(carbon_occupant,"<span class='notice'>Occupant does not appear to be a carbon-based lifeform!</span>")
		SStgui.update_uis(src)
		return

	if(!carbon_occupant.remove_skillchip(to_be_removed))
		to_chat(carbon_occupant,"<span class='notice'>Failed to remove skillchip!</span>")
		SStgui.update_uis(src)
		return

	if(to_be_removed.removable)
		carbon_occupant.put_in_hands(to_be_removed)
	else
		qdel(to_be_removed)

	to_chat(carbon_occupant, "<span class='notice'>Operation complete!</span>")

	SStgui.update_uis(src)

/obj/machinery/skill_station/ui_data(mob/user)
	. = ..()
	.["working"] = working
	.["timeleft"] = work_timer ? timeleft(work_timer) : null
	var/mob/living/carbon/carbon_occupant = occupant

	.["skillchip_ready"] = inserted_skillchip ? TRUE : FALSE
	if(inserted_skillchip)
		// This is safe, incompatibility check can accept a null or invalid mob.
		var/incompatibility_check = inserted_skillchip.has_mob_incompatibility(carbon_occupant)
		if(incompatibility_check)
			.["implantable"] = FALSE
			.["implantable_reason"] = incompatibility_check
		else
			.["implantable"] = TRUE
			.["implantable_reason"] = null
		.["skill_name"] = inserted_skillchip.skill_name
		.["skill_desc"] = inserted_skillchip.skill_description
		.["skill_icon"] = inserted_skillchip.skill_icon
		.["skill_cost"] = inserted_skillchip.slot_cost

	// If there's no occupant, we don't need to worry about what skillchips are in their brain.
	if(!carbon_occupant)
		.["error"] = "No valid occupant detected. Please consult nearest medical practitioner."
		.["current"] = null
		.["slots_used"] = null
		.["slots_max"] = null
		return

	var/obj/item/organ/brain/occupant_brain = carbon_occupant?.getorganslot(ORGAN_SLOT_BRAIN)

	// If there's no brain, we don't need to worry about what skillchips are in it but can still process
	// any info about the skillslot capacity of the body, even though the info is useless without a brain.
	if(QDELETED(occupant_brain))
		.["error"] = "Brain not detected. Please consult nearest medical practitioner."
		.["current"] = null
		.["slots_used"] = carbon_occupant.used_skillchip_slots
		.["slots_max"] = carbon_occupant.max_skillchip_slots
		return

	// If we got here, we have both an occupant and it has a brain, so we can check for skillchips.
	var/list/current_skills = list()
	for(var/obj/item/skillchip/skill_chip in occupant_brain)
		current_skills += list(skill_chip.get_chip_data())
	.["current"] = current_skills
	.["slots_used"] = carbon_occupant.used_skillchip_slots
	.["slots_max"] = carbon_occupant.max_skillchip_slots



/obj/machinery/skill_station/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(usr != occupant)
		return
	switch(action)
		if("implant")
			if(occupant && inserted_skillchip)
				start_implanting()
			return TRUE
		if("remove")
			var/chipref = params["ref"]
			var/mob/living/carbon/carbon_occupant = occupant
			var/obj/item/organ/brain/occupant_brain = carbon_occupant.getorganslot(ORGAN_SLOT_BRAIN)
			if(QDELETED(carbon_occupant) || QDELETED(occupant_brain))
				return TRUE
			var/obj/item/skillchip/to_be_removed = locate(chipref) in occupant_brain
			if(!to_be_removed)
				return TRUE
			start_removal(to_be_removed)
			return TRUE
		if("eject")
			if(inserted_skillchip)
				to_chat(occupant,"<span class='notice'>You eject the skillchip.</span>")
				var/mob/living/carbon/human/H = occupant
				H.put_in_hands(inserted_skillchip)
				inserted_skillchip = null
				return TRUE
