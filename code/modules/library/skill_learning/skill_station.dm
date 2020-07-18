#define SKILLCHIP_IMPLANT_TIME 2 MINUTES
#define SKILLCHIP_REMOVAL_TIME 1 MINUTES

/obj/machinery/skill_station
	name = "Skill Station (name pending)"
	desc = "learn skills with only minimal chance for brain damage."

	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	occupant_typecache = list(/mob/living/carbon) //todo make occupant_typecache per type
	state_open = TRUE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND //Don't call ui_interac by default - we only want that when inside
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

/obj/machinery/skill_station/relaymove(mob/user as mob)
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
		else
			if(!user.transferItemToLoc(I, src))
				return
			inserted_skillchip = I
			SStgui.update_uis(src)
			return
	return ..()

/obj/machinery/skill_station/dropContents(list/subset)
	. = ..(contents - inserted_skillchip) //This is kinda annoying

/obj/machinery/skill_station/proc/toggle_open(mob/user)
	state_open ? close_machine() : open_machine()

// Functions below do not validate occupant exists - should be handled outer wrappers.
/// Start implanting.
/obj/machinery/skill_station/proc/start_implanting()
	if(!inserted_skillchip || !inserted_skillchip.can_be_implanted(occupant))
		return
	working = TRUE
	work_timer = addtimer(CALLBACK(src,.proc/implant),SKILLCHIP_IMPLANT_TIME,TIMER_STOPPABLE)
	update_icon()

/// Finish implanting.
/obj/machinery/skill_station/proc/implant()
	working = FALSE
	work_timer = null
	if(inserted_skillchip && inserted_skillchip.can_be_implanted(occupant))
		implant_skillchip(occupant,inserted_skillchip)
	update_icon()
	SStgui.update_uis(src)
	to_chat(occupant,"<span class='notice'>Operation complete!</span>")

/// Start removal.
/obj/machinery/skill_station/proc/start_removal(obj/item/skillchip/to_be_removed)
	if(!to_be_removed)
		return
	working = TRUE
	work_timer = addtimer(CALLBACK(src,.proc/remove_skillchip,to_be_removed),SKILLCHIP_REMOVAL_TIME,TIMER_STOPPABLE)
	update_icon()

/// Finish removal.
/obj/machinery/skill_station/proc/remove_skillchip(obj/item/skillchip/to_be_removed)
	working = FALSE
	work_timer = null
	var/mob/living/carbon/C = occupant
	var/obj/item/organ/brain/B = C.getorganslot(ORGAN_SLOT_BRAIN)
	if(!C || !B || !(to_be_removed in B.skillchips))
		return
	to_be_removed.on_removal(C,silent=FALSE)
	LAZYREMOVE(B.skillchips,to_be_removed)
	if(to_be_removed.removable)
		C.put_in_hands(to_be_removed)
	else
		qdel(to_be_removed)
	update_icon()
	SStgui.update_uis(src)
	to_chat(C,"<span class='notice'>Operation complete!</span>")

/obj/machinery/skill_station/proc/implant_skillchip(mob/living/carbon/target,obj/item/skillchip/chip)
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	chip.on_apply(target,silent=FALSE)
	chip.forceMove(B)
	LAZYADD(B.skillchips,chip)

/obj/machinery/skill_station/ui_data(mob/user)
	. = ..()
	.["working"] = working
	.["timeleft"] = work_timer ? timeleft(work_timer) : null
	var/mob/living/carbon/C = occupant
	var/obj/item/organ/brain/B = C.getorganslot(ORGAN_SLOT_BRAIN)
	if(!C || !B)
		.["error"] = "Brain not detected. Please consult nearest medical practitioner."
	else
		var/list/current_skills = list()
		for(var/obj/item/skillchip/S in B.skillchips)
			current_skills += list(list("name"=S.skill_name,"icon"=S.skill_icon))
		.["current"] = current_skills
		.["max_skills"] = C.get_max_skillchip_count()

	.["skillchip_ready"] = inserted_skillchip ? TRUE : FALSE
	if(inserted_skillchip)
		.["skill_name"] = inserted_skillchip.skill_name
		.["skill_desc"] = inserted_skillchip.skill_description
		.["skill_icon"] = inserted_skillchip.skill_icon

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
			var/skill_slot = text2num(params["slot"])
			var/mob/living/carbon/C = occupant
			var/obj/item/organ/brain/B = C.getorganslot(ORGAN_SLOT_BRAIN)
			if(!C || !B || !length(B.skillchips) || length(B.skillchips) < skill_slot)
				return TRUE
			var/obj/item/skillchip/to_be_removed = B.skillchips[skill_slot]
			start_removal(to_be_removed)
			return TRUE
		if("eject")
			if(inserted_skillchip)
				to_chat(occupant,"<span class='notice'>You eject the skillchip</span>")
				var/mob/living/carbon/human/H = occupant
				H.put_in_hands(inserted_skillchip)
				inserted_skillchip = null
				return TRUE
