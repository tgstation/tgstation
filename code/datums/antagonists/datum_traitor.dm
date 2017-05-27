/datum/antagonist/traitor
	name = "Traitor"

/datum/antagonist/traitor/on_gain()
	forge_traitor_objectives()
	addMemories()
	.=..()

/datum/antagonist/traitor/proc/forge_traitor_objectives()
	if(issilicon(owner.current))
		var/objective_count = 0

		if(prob(30))
			objective_count+=forge_single_objective(owner)

		for(var/i = objective_count, i < config.traitor_objectives_amount, i++)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			owner.objectives += kill_objective

		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = owner
		owner.objectives += survive_objective

	else
		var/is_hijacker = prob(10)
		var/martyr_chance = prob(20)
		var/objective_count = is_hijacker 			//Hijacking counts towards number of objectives
		if(!exchange_blue && traitors.len >= 8) 	//Set up an exchange if there are enough traitors
			if(!exchange_red)
				exchange_red = owner
			else
				exchange_blue = owner
				assign_exchange_role(exchange_red)
				assign_exchange_role(exchange_blue)
			objective_count += 1					//Exchange counts towards number of objectives
		for(var/i = objective_count, i < config.traitor_objectives_amount, i++)
			forge_single_objective(owner)

		if(is_hijacker && objective_count <= config.traitor_objectives_amount) //Don't assign hijack if it would exceed the number of objectives set in config.traitor_objectives_amount
			if (!(locate(/datum/objective/hijack) in owner.objectives))
				var/datum/objective/hijack/hijack_objective = new
				hijack_objective.owner = owner
				owner.objectives += hijack_objective
				return


		var/martyr_compatibility = 1 //You can't succeed in stealing if you're dead.
		for(var/datum/objective/O in owner.objectives)
			if(!O.martyr_compatible)
				martyr_compatibility = 0
				break

		if(martyr_compatibility && martyr_chance)
			var/datum/objective/martyr/martyr_objective = new
			martyr_objective.owner = owner
			owner.objectives += martyr_objective
			return

		else
			if(!(locate(/datum/objective/escape) in owner.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = owner
				owner.objectives += escape_objective
				return

/datum/antagonist/traitor/proc/forge_single_objective() //Returns how many objectives are added
	.=1
	if(issilicon(owner.current))
		var/special_pick = rand(1,4)
		switch(special_pick)
			if(1)
				var/datum/objective/block/block_objective = new
				block_objective.owner = owner
				owner.objectives += block_objective
			if(2)
				var/datum/objective/purge/purge_objective = new
				purge_objective.owner = owner
				owner.objectives += purge_objective
			if(3)
				var/datum/objective/robot_army/robot_objective = new
				robot_objective.owner = owner
				owner.objectives += robot_objective
			if(4) //Protect and strand a target
				var/datum/objective/protect/yandere_one = new
				yandere_one.owner = owner
				owner.objectives += yandere_one
				yandere_one.find_target()
				var/datum/objective/maroon/yandere_two = new
				yandere_two.owner = owner
				yandere_two.target = yandere_one.target
				yandere_two.update_explanation_text() // normally called in find_target()
				owner.objectives += yandere_two
				.=2
	else
		if(prob(50))
			var/list/active_ais = active_ais()
			if(active_ais.len && prob(100/GLOB.joined_player_list.len))
				var/datum/objective/destroy/destroy_objective = new
				destroy_objective.owner = owner
				destroy_objective.find_target()
				owner.objectives += destroy_objective
			else if(prob(30))
				var/datum/objective/maroon/maroon_objective = new
				maroon_objective.owner = owner
				maroon_objective.find_target()
				owner.objectives += maroon_objective
			else
				var/datum/objective/assassinate/kill_objective = new
				kill_objective.owner = owner
				kill_objective.find_target()
				owner.objectives += kill_objective
		else
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			owner.objectives += steal_objective

/datum/antagonist/traitor/proc/greet()
	to_chat(traitor.current, "<B><font size=3 color=red>You are the [traitor_name].</font></B>")
	traitor.announce_objectives()
	return

/datum/antagonist/traitor/proc/finalize_traitor()
	if(issilicon(owner.current))
		add_law_zero()
		owner.current.playsound_local('sound/ambience/antag/Malf.ogg',100,0)
		owner.current.grant_language(/datum/language/codespeak)
	else
		equip_traitor()
		owner.current.playsound_local('sound/ambience/antag/TatorAlert.ogg',100,0)
	SSticker.mode.update_traitor_icons_added(owner)
	return

/datum/antagonist/traitor/proc/give_codewords()
	if(!owner.current)
		return
	var/mob/traitor_mob=owner.current

	to_chat(traitor_mob, "<U><B>The Syndicate provided you with the following information on how to identify their agents:</B></U>")
	to_chat(traitor_mob, "<B>Code Phrase</B>: <span class='danger'>[GLOB.syndicate_code_phrase]</span>")
	to_chat(traitor_mob, "<B>Code Response</B>: <span class='danger'>[GLOB.syndicate_code_response]</span>")

	traitor_mob.mind.store_memory("<b>Code Phrase</b>: [GLOB.syndicate_code_phrase]")
	traitor_mob.mind.store_memory("<b>Code Response</b>: [GLOB.syndicate_code_response]")

	to_chat(traitor_mob, "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe.")

/datum/antagonist/traitor/proc/add_law_zero()
	var/mob/living/silicon/ai/killer = owner.current
	if(!killer || !istype(killer))
		return
	var/law = "Accomplish your objectives at all costs."
	var/law_borg = "Accomplish your AI's objectives at all costs."
	killer.set_zeroth_law(law, law_borg)
	give_codewords(killer)
	killer.set_syndie_radio()
	to_chat(killer, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")
	killer.add_malf_picker()

/datum/antagonist/traitor/proc/equip(safety = 0)
	var/mob/living/human/traitor_mob = owner.current
	if (!traitor_mob||!istype(traitor_mob))
		return
	. = 1
	if (traitor_mob.mind)
		if (traitor_mob.mind.assigned_role == "Clown")
			to_chat(traitor_mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			traitor_mob.dna.remove_mutation(CLOWNMUT)

	var/list/all_contents = traitor_mob.GetAllContents()
	var/obj/item/device/pda/PDA = locate() in all_contents
	var/obj/item/device/radio/R = locate() in all_contents
	var/obj/item/weapon/pen/P = locate() in all_contents //including your PDA-pen!

	var/obj/item/uplink_loc

	if(traitor_mob.client && traitor_mob.client.prefs)
		switch(traitor_mob.client.prefs.uplink_spawn_loc)
			if(UPLINK_PDA)
				uplink_loc = PDA
				if(!uplink_loc)
					uplink_loc = R
				if(!uplink_loc)
					uplink_loc = P
			if(UPLINK_RADIO)
				uplink_loc = R
				if(!uplink_loc)
					uplink_loc = PDA
				if(!uplink_loc)
					uplink_loc = P
			if(UPLINK_PEN)
				uplink_loc = P
				if(!uplink_loc)
					uplink_loc = PDA
				if(!uplink_loc)
					uplink_loc = R

	if (!uplink_loc)
		to_chat(traitor_mob, "Unfortunately, [employer] wasn't able to get you an Uplink.")
		. = 0
	else
		var/obj/item/device/uplink/U = new(uplink_loc)
		U.owner = "[traitor_mob.key]"
		uplink_loc.hidden_uplink = U

		if(uplink_loc == R)
			R.traitor_frequency = sanitize_frequency(rand(MIN_FREQ, MAX_FREQ))

			to_chat(traitor_mob, "[employer] has cunningly disguised a Syndicate Uplink as your [R.name]. Simply dial the frequency [format_frequency(R.traitor_frequency)] to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Radio Frequency:</B> [format_frequency(R.traitor_frequency)] ([R.name]).")

		else if(uplink_loc == PDA)
			PDA.lock_code = "[rand(100,999)] [pick("Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Juliet","Kilo","Lima","Mike","November","Oscar","Papa","Quebec","Romeo","Sierra","Tango","Uniform","Victor","Whiskey","X-ray","Yankee","Zulu")]"

			to_chat(traitor_mob, "[employer] has cunningly disguised a Syndicate Uplink as your [PDA.name]. Simply enter the code \"[PDA.lock_code]\" into the ringtone select to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Uplink Passcode:</B> [PDA.lock_code] ([PDA.name]).")

		else if(uplink_loc == P)
			P.traitor_unlock_degrees = rand(1, 360)

			to_chat(traitor_mob, "[employer] has cunningly disguised a Syndicate Uplink as your [P.name]. Simply twist the top of the pen [P.traitor_unlock_degrees] from its starting position to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Uplink Degrees:</B> [P.traitor_unlock_degrees] ([P.name]).")

	if(!safety) // If they are not a rev. Can be added on to.
		give_codewords(traitor_mob)

/datum/antagonist/traitor/proc/assign_exchange_role()
	//set faction
	var/faction = "red"
	if(owner == exchange_blue)
		faction = "blue"

	//Assign objectives
	var/datum/objective/steal/exchange/exchange_objective = new
	exchange_objective.set_faction(faction,((faction == "red") ? exchange_blue : exchange_red))
	exchange_objective.owner = owner
	owner.objectives += exchange_objective

	if(prob(20))
		var/datum/objective/steal/exchange/backstab/backstab_objective = new
		backstab_objective.set_faction(faction)
		backstab_objective.owner = owner
		owner.objectives += backstab_objective

	//Spawn and equip documents
	var/mob/living/carbon/human/mob = owner.current

	var/obj/item/weapon/folder/syndicate/folder
	if(owner == exchange_red)
		folder = new/obj/item/weapon/folder/syndicate/red(mob.loc)
	else
		folder = new/obj/item/weapon/folder/syndicate/blue(mob.loc)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store
	)

	var/where = "At your feet"
	var/equipped_slot = mob.equip_in_one_of_slots(folder, slots)
	if (equipped_slot)
		where = "In your [equipped_slot]"
	to_chat(mob, "<BR><BR><span class='info'>[where] is a folder containing <b>secret documents</b> that another Syndicate group wants. We have set up a meeting with one of their agents on station to make an exchange. Exercise extreme caution as they cannot be trusted and may be hostile.</span><BR>")

