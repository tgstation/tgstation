/obj/machinery/harvester
	name = "organ harvester"
	desc = "An advanced machine used for harvesting organs and limbs from the deceased."
	density = TRUE
	icon = 'icons/obj/machines/harvester.dmi'
	icon_state = "harvester"
	base_icon_state = "harvester"
	verb_say = "states"
	state_open = FALSE
	circuit = /obj/item/circuitboard/machine/harvester
	light_color = LIGHT_COLOR_BLUE
	var/interval = 20
	var/harvesting = FALSE
	var/warming_up = FALSE
	var/list/operation_order = list() //Order of wich we harvest limbs.
	var/output_dir = SOUTH //Direction to drop the limbs in
	var/allow_clothing = FALSE
	var/allow_living = FALSE

/obj/machinery/harvester/Initialize(mapload)
	. = ..()
	if(prob(1))
		name = "auto-autopsy"

/obj/machinery/harvester/RefreshParts()
	. = ..()
	interval = 0
	var/max_time = 40
	for(var/datum/stock_part/micro_laser/micro_laser in component_parts)
		max_time -= micro_laser.tier
	interval = max(max_time,1)

/obj/machinery/harvester/update_icon_state()
	if(state_open)
		icon_state = "[base_icon_state]-open"
		return ..()
	if(warming_up)
		icon_state = "[base_icon_state]-charging"
		return ..()
	if(harvesting)
		icon_state = "[base_icon_state]-active"
		return ..()
	icon_state = base_icon_state
	return ..()

/obj/machinery/harvester/open_machine(drop = TRUE, density_to_set = FALSE)
	if(panel_open)
		return
	. = ..()
	warming_up = FALSE
	harvesting = FALSE

/obj/machinery/harvester/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(state_open)
		close_machine()
	else if(!harvesting)
		open_machine()

/obj/machinery/harvester/click_alt(mob/user)
	if(panel_open)
		output_dir = turn(output_dir, -90)
		to_chat(user, span_notice("You change [src]'s output settings, setting the output to [dir2text(output_dir)]."))
		return CLICK_ACTION_SUCCESS
	if(harvesting || state_open || !can_harvest())
		return CLICK_ACTION_BLOCKING

	start_harvest()
	return CLICK_ACTION_SUCCESS

/obj/machinery/harvester/proc/can_harvest()
	if(!powered() || state_open || !occupant || !iscarbon(occupant))
		return
	var/mob/living/carbon/carbon_occupant = occupant
	if(!allow_clothing)
		for(var/obj/item/abiotic_item in carbon_occupant.held_items + carbon_occupant.get_equipped_items())
			if(!(HAS_TRAIT(abiotic_item, TRAIT_NODROP)))
				say("Subject may not have abiotic items on.")
				playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
				return
	if(!(carbon_occupant.mob_biotypes & MOB_ORGANIC))
		say("Subject is not organic.")
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
		return
	if(!allow_living && !(carbon_occupant.stat == DEAD || HAS_TRAIT(carbon_occupant, TRAIT_FAKEDEATH)))     //I mean, the machines scanners arent advanced enough to tell you're alive
		say("Subject is still alive.")
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
		return
	return TRUE

/obj/machinery/harvester/proc/start_harvest()
	if(!occupant || !iscarbon(occupant))
		return

	var/mob/living/carbon/carbon_occupant = occupant

	if(carbon_occupant.stat < UNCONSCIOUS)
		notify_ghosts(
			"[occupant] is about to be ground up by a malfunctioning organ harvester!",
			source = src,
			header = "Gruesome!",
		)

	operation_order = reverseList(carbon_occupant.bodyparts)   //Chest and head are first in bodyparts, so we invert it to make them suffer more
	warming_up = TRUE
	harvesting = TRUE
	visible_message(span_notice("\The [src] begins warming up!"))
	say("Initializing harvest protocol.")
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(harvest)), interval)

/obj/machinery/harvester/proc/harvest()
	warming_up = FALSE
	update_appearance()
	if(!harvesting || state_open || !powered() || !occupant || !iscarbon(occupant))
		end_harvesting(success = FALSE)
		return
	playsound(src, 'sound/machines/juicer.ogg', 20, TRUE)
	var/mob/living/carbon/carbon_occupant = occupant
	if(!LAZYLEN(operation_order)) //The list is empty, so we're done here
		end_harvesting(success = TRUE)
		return
	var/turf/target = get_step(src, output_dir)
	for(var/obj/item/bodypart/limb_to_remove as anything in operation_order) //first we do non-essential limbs
		limb_to_remove.drop_limb()
		carbon_occupant.painful_scream() // DOPPLER EDIT: check for painkilling before screaming
		if(limb_to_remove.body_zone != "chest")
			limb_to_remove.forceMove(target)    //Move the limbs right next to it, except chest, that's a weird one
			limb_to_remove.drop_organs()
		else
			for(var/obj/item/organ/organ_to_remove in limb_to_remove.dismember())
				organ_to_remove.forceMove(target) //Some organs, like chest ones, are different so we need to manually move them
		operation_order.Remove(limb_to_remove)
		break
	use_energy(active_power_usage)
	addtimer(CALLBACK(src, PROC_REF(harvest)), interval)

/obj/machinery/harvester/proc/end_harvesting(success = TRUE)
	warming_up = FALSE
	harvesting = FALSE
	open_machine()
	if (!success)
		say("Protocol interrupted. Aborting harvest.")
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
	else
		say("Subject has been successfully harvested.")
		playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, FALSE)

/obj/machinery/harvester/screwdriver_act(mob/living/user, obj/item/tool)
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

/obj/machinery/harvester/crowbar_act(mob/living/user, obj/item/tool)
	if(default_pry_open(tool))
		return TRUE
	if(default_deconstruction_crowbar(tool))
		return TRUE

/obj/machinery/harvester/default_pry_open(obj/item/tool) //wew
	. = !(state_open || panel_open) && tool.tool_behaviour == TOOL_CROWBAR //We removed is_operational here
	if(.)
		tool.play_tool_sound(src, 50)
		visible_message(span_notice("[usr] pries open \the [src]."), span_notice("You pry open [src]."))
		open_machine()

/obj/machinery/harvester/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	allow_living = TRUE
	allow_clothing = TRUE
	balloon_alert(user, "lifesign scanners overloaded")
	return TRUE

/obj/machinery/harvester/container_resist_act(mob/living/user)
	if(!harvesting)
		visible_message(span_notice("[occupant] emerges from [src]!"),
			span_notice("You climb out of [src]!"))
		open_machine()
	else
		to_chat(user,span_warning("[src] is active and can't be opened!")) //rip

/obj/machinery/harvester/Exited(atom/movable/gone, direction)
	if (!state_open && gone == occupant)
		container_resist_act(gone)
	return ..()

/obj/machinery/harvester/relaymove(mob/living/user, direction)
	if (!state_open)
		container_resist_act(user)

/obj/machinery/harvester/examine(mob/user)
	. = ..()
	if(machine_stat & BROKEN)
		return
	if(state_open)
		. += span_notice("[src] must be closed before harvesting.")
	else if(!harvesting)
		. += span_notice("Alt-click [src] to start harvesting.")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Harvest speed at <b>[interval*0.1]</b> seconds per organ. Outputting to the <b>[dir2text(output_dir)]</b>.")
