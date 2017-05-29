/datum/antagonist/traitor
	name = "Traitor"
	var/special_role = "traitor"
	var/employer = "The Syndicate" 
	var/give_objectives = TRUE
	var/should_give_codewords = TRUE
	var/list/objectives_given = list()

/datum/antagonist/traitor/custom //used to give custom objectives
	silent = TRUE
	give_objectives = FALSE
	should_give_codewords = FALSE

/datum/antagonist/traitor/on_gain()
	SSticker.mode.traitors+=owner
	owner.special_role = special_role
	if(give_objectives)
		forge_traitor_objectives()
	finalize_traitor()
	..()

/datum/antagonist/traitor/on_removal() //does not disable uplink, call remove_antag_equip() to remove uplink
	SSticker.mode.traitors -= owner
	if(owner.current && isAI(owner.current))
		var/mob/living/silicon/ai/A = owner.current
		A.set_zeroth_law("")
		A.verbs -= /mob/living/silicon/ai/proc/choose_modules
		A.malf_picker.remove_verbs(A)
		qdel(A.malf_picker)
	for(var/O in objectives_given)
		owner.objectives -= O
	objectives_given = list()
	if(owner.current)
		to_chat(owner.current,"<span class='userdanger'> You are no longer the [special_role]! </span>")
	owner.special_role = null
	..()

/datum/antagonist/traitor/proc/add_objective(var/datum/objective/O)
	owner.objectives += O
	objectives_given += O

/datum/antagonist/traitor/proc/remove_objective(var/datum/objective/O)
	owner.objectives -= O
	objectives_given -= O

/datum/antagonist/traitor/proc/forge_traitor_objectives()
	if(issilicon(owner.current))
		var/objective_count = 0

		if(prob(30))
			objective_count+=forge_single_objective()

		for(var/i = objective_count, i < config.traitor_objectives_amount, i++)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			add_objective(kill_objective)

		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = owner
		add_objective(survive_objective)

	else
		var/is_hijacker = prob(10)
		var/martyr_chance = prob(20)
		var/objective_count = is_hijacker 			//Hijacking counts towards number of objectives
		if(!SSticker.mode.exchange_blue && SSticker.mode.traitors.len >= 8) 	//Set up an exchange if there are enough traitors
			if(!SSticker.mode.exchange_red)
				SSticker.mode.exchange_red = owner
			else
				SSticker.mode.exchange_blue = owner
				assign_exchange_role(SSticker.mode.exchange_red)
				assign_exchange_role(SSticker.mode.exchange_blue)
			objective_count += 1					//Exchange counts towards number of objectives
		for(var/i = objective_count, i < config.traitor_objectives_amount, i++)
			forge_single_objective()

		if(is_hijacker && objective_count <= config.traitor_objectives_amount) //Don't assign hijack if it would exceed the number of objectives set in config.traitor_objectives_amount
			if (!(locate(/datum/objective/hijack) in owner.objectives))
				var/datum/objective/hijack/hijack_objective = new
				hijack_objective.owner = owner
				add_objective(hijack_objective)
				return


		var/martyr_compatibility = 1 //You can't succeed in stealing if you're dead.
		for(var/datum/objective/O in owner.objectives)
			if(!O.martyr_compatible)
				martyr_compatibility = 0
				break

		if(martyr_compatibility && martyr_chance)
			var/datum/objective/martyr/martyr_objective = new
			martyr_objective.owner = owner
			add_objective(martyr_objective)
			return

		else
			if(!(locate(/datum/objective/escape) in owner.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = owner
				add_objective(escape_objective)
				return

/datum/antagonist/traitor/proc/forge_single_objective() //Returns how many objectives are added
	.=1
	if(issilicon(owner.current))
		var/special_pick = rand(1,4)
		switch(special_pick)
			if(1)
				var/datum/objective/block/block_objective = new
				block_objective.owner = owner
				add_objective(block_objective)
			if(2)
				var/datum/objective/purge/purge_objective = new
				purge_objective.owner = owner
				add_objective(purge_objective)
			if(3)
				var/datum/objective/robot_army/robot_objective = new
				robot_objective.owner = owner
				add_objective(robot_objective)
			if(4) //Protect and strand a target
				var/datum/objective/protect/yandere_one = new
				yandere_one.owner = owner
				add_objective(yandere_one)
				yandere_one.find_target()
				var/datum/objective/maroon/yandere_two = new
				yandere_two.owner = owner
				yandere_two.target = yandere_one.target
				yandere_two.update_explanation_text() // normally called in find_target()
				add_objective(yandere_two)
				.=2
	else
		if(prob(50))
			var/list/active_ais = active_ais()
			if(active_ais.len && prob(100/GLOB.joined_player_list.len))
				var/datum/objective/destroy/destroy_objective = new
				destroy_objective.owner = owner
				destroy_objective.find_target()
				add_objective(destroy_objective)
			else if(prob(30))
				var/datum/objective/maroon/maroon_objective = new
				maroon_objective.owner = owner
				maroon_objective.find_target()
				add_objective(maroon_objective)
			else
				var/datum/objective/assassinate/kill_objective = new
				kill_objective.owner = owner
				kill_objective.find_target()
				add_objective(kill_objective)
		else
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			add_objective(steal_objective)

/datum/antagonist/traitor/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You are the [owner.special_role].</font></B>")
	owner.announce_objectives()
	if(should_give_codewords)
		give_codewords()

/datum/antagonist/traitor/proc/finalize_traitor()
	if(issilicon(owner.current))
		add_law_zero()
		owner.current.playsound_local('sound/ambience/antag/Malf.ogg',100,0)
		owner.current.grant_language(/datum/language/codespeak)
	else
		equip()
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
	killer.set_syndie_radio()
	to_chat(killer, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")
	killer.add_malf_picker()

/datum/antagonist/traitor/proc/equip(safety = 0, employer)
	SSticker.mode.equip_traitor(owner.current)

/datum/antagonist/traitor/proc/assign_exchange_role()
	//set faction
	var/faction = "red"
	if(owner == SSticker.mode.exchange_blue)
		faction = "blue"

	//Assign objectives
	var/datum/objective/steal/exchange/exchange_objective = new
	exchange_objective.set_faction(faction,((faction == "red") ? SSticker.mode.exchange_blue : SSticker.mode.exchange_red))
	exchange_objective.owner = owner
	add_objective(exchange_objective)

	if(prob(20))
		var/datum/objective/steal/exchange/backstab/backstab_objective = new
		backstab_objective.set_faction(faction)
		backstab_objective.owner = owner
		add_objective(backstab_objective)

	//Spawn and equip documents
	var/mob/living/carbon/human/mob = owner.current

	var/obj/item/weapon/folder/syndicate/folder
	if(owner == SSticker.mode.exchange_red)
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

