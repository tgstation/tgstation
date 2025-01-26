/datum/crafting_recipe/auto_implanter_board
	result = /obj/item/circuitboard/machine/automatic_implanter
	reqs = list(
        /obj/item/epic_loot/military_circuit = 1,
		/obj/item/epic_loot/processor = 1,
    )
	tool_behaviors = list(
		TOOL_SCREWDRIVER,
		TOOL_MULTITOOL,
	)
	time = 5 SECONDS
	category = CAT_EQUIPMENT

/datum/supply_pack/science/auto_ripper
	name = "Augment Auto-Ripper Board"
	desc = "A circuit board for the implant auto-ripper. See health and safety manual at HYPERLINK NOT FOUND."
	cost = CARGO_CRATE_VALUE * 8
	contains = list(
		/obj/item/circuitboard/machine/automatic_implanter,
		/obj/item/circuitboard/machine/smartfridge,
		/obj/item/screwdriver,
	)
	crate_type = /obj/structure/closet/crate/deforest
	crate_name = "robotics machinery crate"

/obj/machinery/automatic_implanter
	name = "augment auto-ripper"
	desc = "An advanced automatic ripper for augmentation and implantation alike. \
		You wonder why you don't see more of these things..."
	icon = 'modular_doppler/autoimplanter/icons/implanter.dmi'
	icon_state = "harvester"
	base_icon_state = "harvester"
	verb_say = "states"
	density = TRUE
	state_open = FALSE
	circuit = /obj/item/circuitboard/machine/automatic_implanter
	light_color = LIGHT_COLOR_BLUE
	/// How long each step of the process takes
	var/step_interval = 12 SECONDS
	/// Is the machine currently working
	var/working = FALSE

/obj/machinery/automatic_implanter/RefreshParts()
	. = ..()
	step_interval = initial(step_interval)
	for(var/datum/stock_part/micro_laser/micro_laser in component_parts)
		step_interval = step_interval - ((1 SECONDS) * micro_laser.tier)

/obj/item/circuitboard/machine/automatic_implanter
	name = "Augment Auto-Ripper"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/automatic_implanter
	req_components = list(/datum/stock_part/micro_laser = 1)

/obj/machinery/automatic_implanter/examine(mob/user)
	. = ..()
	. += span_notice("<b>To use:</b>")
	. += span_notice("<b>1.</b> Construct an <b>organ holding smart fridge</b> near the auto-ripper.")
	. += span_notice("<b>2.</b> Fill this smart fridge with all organs and limbs you intend to implant.")
	. += span_notice("<b>3.</b> Place your patient in the machine and close the hatch.")
	. += span_notice("<b>4.</b> <b>Alt-Click</b> the auto-ripper to start the process.")

/obj/machinery/automatic_implanter/update_icon_state()
	if(state_open)
		icon_state = "[base_icon_state]-open"
		return ..()
	if(working)
		icon_state = "[base_icon_state]-active"
		return ..()
	icon_state = base_icon_state
	return ..()

/obj/machinery/automatic_implanter/open_machine(drop = TRUE, density_to_set = FALSE)
	if(panel_open)
		return
	. = ..()
	working = FALSE

/obj/machinery/automatic_implanter/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(state_open)
		close_machine()
	else if(!working)
		open_machine()

/obj/machinery/automatic_implanter/click_alt(mob/user)
	if(working || state_open || !can_operate())
		return CLICK_ACTION_BLOCKING

	start_harvest()
	return CLICK_ACTION_SUCCESS

/// Can you actually use the machine on this guy
/obj/machinery/automatic_implanter/proc/can_operate()
	if(!powered() || state_open || !occupant || !iscarbon(occupant))
		return
	var/mob/living/carbon/carbon_occupant = occupant
	if(!(carbon_occupant.mob_biotypes & MOB_ORGANIC) && !(carbon_occupant.mob_biotypes & MOB_ROBOTIC))
		say("Cannot operate on patient biology. See user manual for support.")
		playsound(src, 'sound/machines/buzz/buzz-two.ogg', 30, TRUE)
		return
	return TRUE

/obj/machinery/automatic_implanter/proc/start_harvest()
	if(!occupant || !iscarbon(occupant))
		return

	/// A list of all organs we will be implanting today, associated to the fridge they are in for checking later
	var/list/organ_to_fridge_reference = list()
	for(var/obj/machinery/smartfridge/near_fridge in range(1, src))
		for(var/obj/item/fridge_organ in near_fridge.contents)
			if(isorgan(fridge_organ))
				organ_to_fridge_reference += fridge_organ
				organ_to_fridge_reference[fridge_organ] = near_fridge
			if(isbodypart(fridge_organ))
				organ_to_fridge_reference += fridge_organ
				organ_to_fridge_reference[fridge_organ] = near_fridge
	if(!length(organ_to_fridge_reference))
		say("No organs or body parts detected in nearby smart fridge. Aborting operation.")
		playsound(src, 'sound/machines/buzz/buzz-two.ogg', 30, TRUE)
		return
	working = TRUE
	visible_message(span_notice("[src] starts to buzz as it warms up."))
	say("Beginning operation.")
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(implant), organ_to_fridge_reference), step_interval)

/obj/machinery/automatic_implanter/proc/implant(list/organ_to_fridge_input, first_run = TRUE)
	update_appearance()
	if(!working || state_open || !powered() || !occupant || !iscarbon(occupant))
		end_harvesting(success = FALSE)
		return

	if(first_run) // The first time around it makes some noise
		playsound(src, 'sound/machines/mail_sort.ogg', 20, TRUE)
		first_run = FALSE
		addtimer(CALLBACK(src, PROC_REF(implant), organ_to_fridge_input, first_run), step_interval)
		return

	if(!length(organ_to_fridge_input)) //The list is empty, so we're done here or something is wrong
		end_harvesting(success = TRUE)
		return

	var/mob/living/carbon/carbon_occupant = occupant

	for(var/obj/item/bodypart/implant_bodypart in organ_to_fridge_input)
		var/obj/machinery/smartfridge/holding_fridge = organ_to_fridge_input[implant_bodypart]
		if(!holding_fridge || (get_dist(src, holding_fridge) > 1))
			organ_to_fridge_input -= implant_bodypart
			continue // The fridge isn't there anymore, abort
		if(!(implant_bodypart in holding_fridge.contents))
			organ_to_fridge_input -= implant_bodypart
			continue // It isn't in the fridge anymore, abort
		var/bodypart_body_zone = implant_bodypart.body_zone
		var/obj/item/bodypart/old_bodypart = carbon_occupant.get_bodypart(bodypart_body_zone)
		if((bodypart_body_zone != BODY_ZONE_CHEST) && (bodypart_body_zone != BODY_ZONE_HEAD) && old_bodypart)
			old_bodypart.dismember(silent = FALSE)
			implant_bodypart.try_attach_limb(carbon_occupant)
		else if(!old_bodypart)
			playsound(src, 'sound/items/handling/surgery/saw.ogg', 50, TRUE)
			implant_bodypart.try_attach_limb(carbon_occupant)
		else
			playsound(src, 'sound/items/handling/surgery/saw.ogg', 50, TRUE)
			implant_bodypart.replace_limb(carbon_occupant)
		organ_to_fridge_input -= implant_bodypart
		use_energy(active_power_usage)
		addtimer(CALLBACK(src, PROC_REF(implant), organ_to_fridge_input, first_run), step_interval)
		return

	for(var/obj/item/organ/implant_organ in organ_to_fridge_input)
		var/obj/machinery/smartfridge/holding_fridge = organ_to_fridge_input[implant_organ]
		if(!holding_fridge || (get_dist(src, holding_fridge) > 1))
			organ_to_fridge_input -= implant_organ
			continue // The fridge isn't there anymore, abort
		if(!(implant_organ in holding_fridge.contents))
			organ_to_fridge_input -= implant_organ
			continue // It isn't in the fridge anymore, abort
		var/organ_body_zone = deprecise_zone(implant_organ.zone)
		implant_organ.Insert(carbon_occupant)
		var/obj/item/bodypart/damaged_bodypart = carbon_occupant.get_bodypart(organ_body_zone)
		playsound(src, 'sound/items/handling/surgery/saw.ogg', 50, TRUE)
		if(damaged_bodypart.bodytype & BODYTYPE_ROBOTIC)
			var/datum/wound/slash/flesh/surgery_wound = new /datum/wound/electrical_damage/slash/moderate()
			surgery_wound.apply_wound(damaged_bodypart)
		else
			var/datum/wound/slash/flesh/surgery_wound = new /datum/wound/slash/flesh/severe()
			surgery_wound.apply_wound(damaged_bodypart)
		organ_to_fridge_input -= implant_organ
		use_energy(active_power_usage)
		addtimer(CALLBACK(src, PROC_REF(implant), organ_to_fridge_input, first_run), step_interval)
		return

/// Stops the harvesting process, making different sounds if it failed or not
/obj/machinery/automatic_implanter/proc/end_harvesting(success = TRUE)
	working = FALSE
	open_machine()
	if (!success)
		say("Operation interrupted, halting work.")
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
	else
		say("Operation successful. See user manual if issues due to implantation process arise.")
		playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, FALSE)

/obj/machinery/automatic_implanter/screwdriver_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(..())
		return
	if(occupant)
		to_chat(user, span_warning("[src] is currently occupied!"))
		return
	if(state_open)
		to_chat(user, span_warning("[src] must be closed to [panel_open ? "close" : "open"] its maintenance hatch!"))
		return
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), tool))
		return
	return FALSE

/obj/machinery/automatic_implanter/crowbar_act(mob/living/user, obj/item/tool)
	if(default_pry_open(tool))
		return TRUE
	if(default_deconstruction_crowbar(tool))
		return TRUE

/obj/machinery/automatic_implanter/default_pry_open(obj/item/tool) //wew
	. = !(state_open || panel_open) && tool.tool_behaviour == TOOL_CROWBAR //We removed is_operational here
	if(.)
		tool.play_tool_sound(src, 50)
		visible_message(span_notice("[usr] pries open \the [src]."), span_notice("You pry open [src]."))
		open_machine()

/obj/machinery/automatic_implanter/container_resist_act(mob/living/user)
	if(!working)
		visible_message(span_notice("[occupant] emerges from [src]!"),
			span_notice("You climb out of [src]!"))
		open_machine()
	else
		to_chat(user,span_warning("[src] is active and can't be opened!"))

/obj/machinery/automatic_implanter/Exited(atom/movable/gone, direction)
	if (!state_open && gone == occupant)
		container_resist_act(gone)
	return ..()

/obj/machinery/automatic_implanter/relaymove(mob/living/user, direction)
	if (!state_open)
		container_resist_act(user)
