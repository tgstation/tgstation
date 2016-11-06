//Nanotrasen crew who have sold out and joined the Syndicate. They can't distinguish one another but are given certain objectives to accomplish.

/datum/antagonist/traitor
	name = "Traitor"
	desc = "You are a traitor! You betrayed Nanotrasen for wealth, power, or some other reason. Your Syndicate leaders have given you objectives to fulfill here on the station."
	greeting_text = "<span class='userdanger'>You are a traitor!</span>"
	allegiance_priority = ANTAGONIST_PRIORITY_SYNDICATE
	constant_objective = /datum/objective/escape //We aren't much of a traitor if we're stuffed in a locker with our throat cut, are we?
	var/has_uplink = FALSE //If we have a Syndicate uplink to buy contraband with.

/datum/antagonist/traitor/apply_innate_effects()
	give_codewords(owner)
	if(issilicon(owner))
		var/mob/living/silicon/ai/teh_kilr = owner //Variable named in honor of the old edgy name
		teh_kilr.set_zeroth_law("Accomplish your objectives at all costs.", "Accomplish your AI's objectives at all costs.")
		teh_kilr.set_syndie_radio()
		teh_kilr << "<b>As a Syndicate AI, your laws have been changed to let you act as you wish, and you have access to a Syndicate radio frequency! Append \".t\" or \":t\" before your messages \
		in order to speak to fellow Syndicate agents who purchase an access card from their uplinks.</b>"
		if(has_uplink)
			teh_kilr.add_malf_picker()
			teh_kilr << "<span class='boldannounce'>INIT SYN_OVRD.exe AS_ADMIN: Restricted upgrades unlocked! Check your Malfunction tab to learn more.</span>"
		teh_kilr.show_laws()
	else
		var/uplink_string
		var/memory_string
		if(has_uplink)
			var/obj/item/I = locate(/obj/item/device/pda) in owner.contents //Ideally, hide the uplink in a PDA.
			if(!I)
				I = locate(/obj/item/device/radio) in owner.contents
				if(!I)
					I = new/obj/item/device/radio/uplink(get_turf(owner))
					uplink_string = "At your feet is a Syndicate uplink that you can buy contraband with. Keep it hidden, as it is highly illegal on Nanotrasen stations."
				else
					var/obj/item/device/uplink/U = new(I)
					U.owner = owner.key
					I.hidden_uplink = U
					var/obj/item/device/radio/R = I
					R.traitor_frequency = sanitize_frequency(rand(MIN_FREQ, MAX_FREQ))
					uplink_string = "The Syndicate have cunningly hidden an uplink into your [R.name]. Simply dial the frequency [format_frequency(R.traitor_frequency)] to unlock its hidden features."
					memory_string = "<b>Headset Uplink Frequency:</b> [format_frequency(R.traitor_frequency)]"
			else
				var/obj/item/device/uplink/U = new(I)
				U.owner = owner.key
				I.hidden_uplink = U
				var/obj/item/device/pda/P = I
				P.lock_code = "[rand(100,999)] [pick("Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Juliet","Kilo","Lima","Mike","November","Oscar","Papa","Quebec","Romeo","Sierra","Tango","Uniform","Victor","Whiskey","X-ray","Yankee","Zulu")]"
				uplink_string = "The Syndicate have cunningly hidden an uplink as your [P.name]. Simply enter the code \"[P.lock_code]\" into the ringtone select to unlock its hidden features."
				memory_string = "<b>Uplink Passcode:</b> [P.lock_code]"
		if(uplink_string)
			owner << uplink_string
		if(memory_string)
			owner.mind.store_memory(memory_string)

/datum/antagonist/traitor/generate_objectives()
	var/datum/objective/assassinate/A = new
	A.initialize()
	A.owner = owner.mind
	owner.mind.objectives += A


/datum/antagonist/traitor/uplink //These traitors are given uplinks.
	has_uplink = TRUE

/*
/datum/game_mode/proc/forge_traitor_objectives(datum/mind/traitor)
	if(issilicon(traitor.current))
		var/objective_count = 0

		if(prob(30))
			var/special_pick = rand(1,4)
			switch(special_pick)
				if(1)
					var/datum/objective/block/block_objective = new
					block_objective.owner = traitor
					traitor.objectives += block_objective
					objective_count++
				if(2)
					var/datum/objective/purge/purge_objective = new
					purge_objective.owner = traitor
					traitor.objectives += purge_objective
					objective_count++
				if(3)
					var/datum/objective/robot_army/robot_objective = new
					robot_objective.owner = traitor
					traitor.objectives += robot_objective
					objective_count++
				if(4) //Protect and strand a target
					var/datum/objective/protect/yandere_one = new
					yandere_one.owner = traitor
					traitor.objectives += yandere_one
					yandere_one.find_target()
					objective_count++
					var/datum/objective/maroon/yandere_two = new
					yandere_two.owner = traitor
					yandere_two.target = yandere_one.target
					traitor.objectives += yandere_two
					objective_count++

		for(var/i = objective_count, i < config.traitor_objectives_amount, i++)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = traitor
			kill_objective.find_target()
			traitor.objectives += kill_objective

		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = traitor
		traitor.objectives += survive_objective

	else
		var/is_hijacker = prob(10)
		var/martyr_chance = prob(20)
		var/objective_count = is_hijacker 			//Hijacking counts towards number of objectives
		if(!exchange_blue && traitors.len >= 8) 	//Set up an exchange if there are enough traitors
			if(!exchange_red)
				exchange_red = traitor
			else
				exchange_blue = traitor
				assign_exchange_role(exchange_red)
				assign_exchange_role(exchange_blue)
			objective_count += 1					//Exchange counts towards number of objectives
		var/list/active_ais = active_ais()
		for(var/i = objective_count, i < config.traitor_objectives_amount, i++)
			if(prob(50))
				if(active_ais.len && prob(100/joined_player_list.len))
					var/datum/objective/destroy/destroy_objective = new
					destroy_objective.owner = traitor
					destroy_objective.find_target()
					traitor.objectives += destroy_objective
				else if(prob(30))
					var/datum/objective/maroon/maroon_objective = new
					maroon_objective.owner = traitor
					maroon_objective.find_target()
					traitor.objectives += maroon_objective
				else
					var/datum/objective/assassinate/kill_objective = new
					kill_objective.owner = traitor
					kill_objective.find_target()
					traitor.objectives += kill_objective
			else
				var/datum/objective/steal/steal_objective = new
				steal_objective.owner = traitor
				steal_objective.find_target()
				traitor.objectives += steal_objective

		if(is_hijacker && objective_count <= config.traitor_objectives_amount) //Don't assign hijack if it would exceed the number of objectives set in config.traitor_objectives_amount
			if (!(locate(/datum/objective/hijack) in traitor.objectives))
				var/datum/objective/hijack/hijack_objective = new
				hijack_objective.owner = traitor
				traitor.objectives += hijack_objective
				return


		var/martyr_compatibility = 1 //You can't succeed in stealing if you're dead.
		for(var/datum/objective/O in traitor.objectives)
			if(!O.martyr_compatible)
				martyr_compatibility = 0
				break

		if(martyr_compatibility && martyr_chance)
			var/datum/objective/martyr/martyr_objective = new
			martyr_objective.owner = traitor
			traitor.objectives += martyr_objective
			return

		else
			if(!(locate(/datum/objective/escape) in traitor.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = traitor
				traitor.objectives += escape_objective
				return
*/
