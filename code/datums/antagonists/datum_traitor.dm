/datum/antagonist/traitor
	name = ROLE_TRAITOR

	text_on_gain = "<span class='userdanger'>You are a traitor!</span>"
	text_on_lose = "<span class='userdanger'>Your allegiance to the Syndicate wavers. You make a choice: you are no longer a traitor to Nanotrasen!</span>"

	possible_objectives = list(/datum/objective/maroon, /datum/objective/steal, /datum/objective/assassinate)
	number_of_possible_objectives = 1 //Number of objectives by default if there's no config for it.

	var/possible_objectives_silicon_special = list(/datum/objective/block, /datum/objective/purge, /datum/objective/robot_army, /datum/objective/protect)

/datum/antagonist/traitor/New()
	. = ..()
	if(config && config.traitor_objectives_amount)
		number_of_possible_objectives = config.traitor_objectives_amount

/datum/antagonist/traitor/apply_innate_effects()
	give_codewords()
	if(has_objectives)
		generate_objectives()
	if(issilicon(owner.current))
		give_syndicate_laws()

//	ticker.mode.update_traitor_icons_added(owner) // To-do: better huds

/datum/antagonist/traitor/remove_innate_effects()
	. = ..()
//	ticker.mode.update_traitor_icons_removed(owner)

/datum/antagonist/traitor/give_equipment()
	var/uplink_string
	var/memory_string
	var/obj/item/device/pda/P = locate(/obj/item/device/pda) in owner.current.contents
	if(P)
		var/obj/item/device/uplink/U = new(P)
		U.owner = owner.key
		P.hidden_uplink = U
		P.lock_code = "[rand(100,999)] [pick(pda_phonetics)]"
		uplink_string = "The Syndicate have cunningly hidden an uplink as your [P.name]. Simply enter the code \"[P.lock_code]\" into the ringtone select to unlock its hidden features."
		memory_string = "<b>Uplink password:</b> [P.lock_code]"
	else
		var/obj/item/device/radio/R = locate(/obj/item/device/radio) in owner.current.contents
		if(R)
			var/obj/item/device/uplink/U = new(R)
			U.owner = owner.key
			R.hidden_uplink = U
			R.traitor_frequency = sanitize_frequency(rand(MIN_FREQ, MAX_FREQ))
			uplink_string = "The Syndicate have cunningly hidden an uplink into your [R.name]. Simply dial the frequency [format_frequency(R.traitor_frequency)] to unlock its hidden features."
			memory_string = "<b>Headset Uplink Frequency:</b> [format_frequency(R.traitor_frequency)]"
		else
			new /obj/item/device/radio/uplink(get_turf(owner.current))
			uplink_string = "At your feet is a Syndicate uplink that you can buy contraband with. Keep it hidden, as it is highly illegal on Nanotrasen stations."
	if(uplink_string)
		owner.current << uplink_string
	if(memory_string)
		owner.store_memory(memory_string)

/datum/antagonist/traitor/proc/give_syndicate_laws()
	if(!isAI(owner))
		return FALSE
	var/mob/living/silicon/ai/AI = owner
	AI.set_zeroth_law("Accomplish your objectives at all costs.", "Accomplish your AI's objectives at all costs.")
	AI.set_syndie_radio()
	AI << "<b>As a Syndicate AI, your laws have been changed to let you act as you wish, and you have access to a Syndicate radio frequency! Append \".t\" or \":t\" before your messages in order to speak to fellow Syndicate agents who purchase an access card from their uplinks.</b>"
	AI.add_malf_picker()
	AI << "<span class='boldannounce'>INIT SYN_OVRD.exe AS_ADMIN: Restricted upgrades unlocked! Check your Malfunction tab to learn more.</span>"
	AI.show_laws()

/datum/antagonist/traitor/generate_objectives()
	var/objective_count = 0
	var/is_hijacker = prob(TRAITOR_HIJACK_CHANCE)
	var/is_martyr = prob(TRAITOR_MARTYR_CHANCE)
	if(isAI(owner.current))
		if(prob(30))
			var/type = pick(possible_objectives_silicon_special)
			var/datum/objective/special = new type
			special.owner = owner
			current_objectives += special
			objective_count++
			if(istype(special, /datum/objective/protect))
				special.find_target()
				var/datum/objective/maroon/keeper = new
				keeper.owner = owner
				current_objectives += keeper
				keeper.target = special.target
				objective_count++
		else
			for(var/i in objective_count to number_of_possible_objectives)
				var/datum/objective/assassinate/kill = new
				kill.owner = owner
				current_objectives += kill
				kill.find_target()
	else
		if(LAZYLEN(active_ais()))
			possible_objectives += /datum/objective/destroy
		objective_count = is_hijacker
		for(var/i in objective_count to number_of_possible_objectives)
			var/type = pick_n_take(possible_objectives)
			var/datum/objective/random_objective = new type
			random_objective.owner = owner
			random_objective.find_target()
			current_objectives += random_objective

		var/can_martyr = TRUE
		for(var/o in current_objectives)
			var/datum/objective/O = o
			if(!O.martyr_compatible)
				can_martyr = FALSE
				break
		if(is_hijacker)
			var/datum/objective/hijack/hi_jack = new
			hi_jack.owner = owner
			current_objectives += hi_jack
		else if(can_martyr && is_martyr)
			var/datum/objective/martyr/ided = new
			ided.owner = owner
			current_objectives += ided
		else
			var/datum/objective/escape/irun = new
			irun.owner = owner
			current_objectives += irun

/datum/antagonist/traitor/proc/give_codewords()
	owner.current << "<U><B>The Syndicate provided you with the following information on how to identify their agents:</B></U>"
	owner.current << "<B>Code Phrase</B>: <span class='danger'>[syndicate_code_phrase]</span>"
	owner.current << "<B>Code Response</B>: <span class='danger'>[syndicate_code_response]</span>"

	owner.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
	owner.store_memory("<b>Code Response</b>: [syndicate_code_response]")

	owner.current << "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe."

/proc/give_codewords(datum/mind/owner)
	owner.current << "<U><B>The Syndicate provided you with the following information on how to identify their agents:</B></U>"
	owner.current << "<B>Code Phrase</B>: <span class='danger'>[syndicate_code_phrase]</span>"
	owner.current << "<B>Code Response</B>: <span class='danger'>[syndicate_code_response]</span>"

	owner.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
	owner.store_memory("<b>Code Response</b>: [syndicate_code_response]")

	owner.current << "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe."