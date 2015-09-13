var/list/blackops_steal_list = list(/obj/machinery/power/emitter,
									/obj/machinery/announcement_system,
									/obj/machinery/field/generator,
									/obj/structure/particle_accelerator,
									/obj/machinery/r_n_d/circuit_imprinter,
									/obj/machinery/r_n_d/protolathe,
									/obj/machinery/r_n_d/destructive_analyzer,
									/obj/machinery/r_n_d/server,
									/obj/machinery/autolathe,
									/obj/machinery/vending/boozeomat) // essential stuff
/datum/objective/kidnap // Kidnap X person and bring them to the black ops shuttle.
	var/steal_
	dangerrating = 10
	martyr_compatible = 1

/datum/objective/kidnap/find_target_by_role(role, role_type=0, invert=0)
	if(!invert)
		target_role_type = role_type
	..()
	return target

/datum/objective/kidnap/check_completion()
	if(!target)			//If it's a free objective.
		return 1
	if(target.current)
		if(target.current.stat) // syndicate cant use dead people
			return 0
		var/area/A = get_area(target.current)
		if(!istype(A, /area/shuttle/syndicate))
			return 0
		return 1
	return 0

/datum/objective/kidnap/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Extract [target.name], the [!target_role_type ? target.assigned_role : target.special_role] to the syndicate shuttle alive."
	else
		explanation_text = "Free Objective (Kidnap)"

/datum/objective/extract_machine
	var/obj/machinery/steal_machine
	dangerrating = 10
	martyr_compatible = 1

/datum/objective/ai_mag/find_target()
	var/list/possible_targets = active_ais(1)
	var/mob/living/silicon/ai/target_ai = pick(possible_targets)
	target = target_ai.mind
	update_explanation_text()
	return target

/datum/objective/kidnap/check_completion()
	if(!target)			//If it's a free objective.
		return 1
	for(var/obj/machinery/M in machines_list)
	return 0

/datum/objective/extract_machine/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Extract a [target.name]."
	else
		explanation_text = "Free Objective (Kidnap)"

/datum/objective/ai_mag // Kidnap X person and bring them to the black ops shuttle.
	dangerrating = 10
	martyr_compatible = 1

/datum/objective/ai_mag/find_target()
	var/list/possible_targets = active_ais(1)
	var/mob/living/silicon/ai/target_ai = pick(possible_targets)
	target = target_ai.mind
	update_explanation_text()
	return target

/datum/objective/ai_mag/check_completion()
	if(ticker && ticker.mode)
		if(istype(ticker.mode, /datum/game_mode/nuclear/blackops))
			var/datum/game_mode/nuclear/blackops/bops = ticker.mode
			if(bops.AI_magnet_applied)
				return 1
			return 0
		return 0
	return 0

/datum/objective/ai_mag/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Apply an cryptographic sequencer to an AI upload console."
	else
		explanation_text = "Free Objective"

/obj/machinery/computer/syndicate_blackops_console
	name = "syndicate black ops console"
	desc = "For heading home and finishing up your objectives on the station.."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key" // todo: make icons
/obj/machinery/computer/syndicate_blackops_console/attack_hand(var/mob/living/carbon/human/user)
	var/choice = alert(user, "Would you like to declare your objectives as complete and return to the Syndicate HQ? Only do this if you're certain all your objectives are complete!", "Objective Completion", "Authorize", "Abort")
	switch(choice)
		if("Abort")
			return
		if("Authorize")
			if(ticker && ticker.mode)
				if(istype(ticker.mode, /datum/game_mode/nuclear/blackops))
					var/datum/game_mode/nuclear/blackops/bops = ticker.mode
					bops.operatives_returned_to_home = 1
					return
	return
