var/list/blackops_machine_list = list(/obj/machinery/power/emitter,
									/obj/machinery/announcement_system,
									/obj/machinery/field/generator,
									/obj/machinery/r_n_d/circuit_imprinter,
									/obj/machinery/r_n_d/protolathe,
									/obj/machinery/r_n_d/destructive_analyzer,
									/obj/machinery/r_n_d/server,
									/obj/machinery/clonepod,
									/obj/machinery/biogenerator,
									/obj/machinery/vending/boozeomat) // essential stuff

/datum/objective/extract_machine
	var/obj/machinery/steal_machine
	dangerrating = 10
	martyr_compatible = 1

/datum/objective/extract_machine/update_explanation_text()
	if(steal_machine)
		var/obj/machinery/M = new steal_machine
		explanation_text = "Extract all [M]s located on the station."
		qdel(M)
	else
		explanation_text = "Free Objective (Extract)"

/datum/objective/extract_machine/check_completion()
	var/total_machines
	var/stolen_machines
	for(var/obj/machinery/M in machines)
		if(istype(M, steal_machine))
			total_machines++
			var/area/location_area = get_area(M)
			if(istype(location_area, /area/shuttle/syndicate))
				stolen_machines++
	if(stolen_machines == total_machines)
		return 1
	else
		return 0
	return 0

/datum/objective/extract_machine/find_target()
	var/picked_machine = pick(blackops_machine_list)
	steal_machine = picked_machine
	blackops_machine_list -= picked_machine
	target = picked_machine
	return target

/datum/objective/destroy_machine
	var/obj/machinery/destroy_machine
	dangerrating = 10
	martyr_compatible = 1

/datum/objective/destroy_machine/update_explanation_text()
	if(destroy_machine)
		var/obj/machinery/M = new destroy_machine
		explanation_text = "Destroy all [M]s located on the station."
		qdel(M)
	else
		explanation_text = "Free Objective (Destroy)"

/datum/objective/destroy_machine/check_completion()
	var/total_machines
	for(var/obj/machinery/M in machines)
		if(istype(M, destroy_machine))
			total_machines++
	if(!total_machines)
		return 1
	else
		return 0
	return 0


/datum/objective/destroy_machine/find_target()
	var/picked_machine = pick(blackops_machine_list)
	destroy_machine = picked_machine
	blackops_machine_list -= picked_machine
	target = picked_machine
	return target


/datum/objective/ai_mag
	dangerrating = 10
	martyr_compatible = 1

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

/datum/objective/ai_mag/find_target()
	var/list/possible_targets = active_ais(1)
	var/mob/living/silicon/ai/target_ai = pick(possible_targets)
	target = target_ai.mind
	update_explanation_text()
	return target

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
