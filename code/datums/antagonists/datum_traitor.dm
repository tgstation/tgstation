/datum/antagonist/traitor
	name = "Traitor"
	var/should_specialise = TRUE //do we split into AI and human
	var/base_datum_custom = ANTAG_DATUM_TRAITOR_CUSTOM //used for body transfer
	var/ai_datum = ANTAG_DATUM_TRAITOR_AI
	var/human_datum = ANTAG_DATUM_TRAITOR_HUMAN
	var/special_role = "traitor"
	var/employer = "The Syndicate"
	var/give_objectives = TRUE
	var/should_give_codewords = TRUE
	var/list/objectives_given = list()

/datum/antagonist/traitor/proc/transfer_important_variables(datum/antagonist/traitor/other)
	other.silent = silent
	other.employer = employer
	other.special_role = special_role
	other.objectives_given = objectives_given

/datum/antagonist/traitor/custom
	ai_datum = ANTAG_DATUM_TRAITOR_AI_CUSTOM
	human_datum = ANTAG_DATUM_TRAITOR_HUMAN_CUSTOM

/datum/antagonist/traitor/human
	should_specialise = FALSE
	var/should_equip = TRUE
/datum/antagonist/traitor/human/custom
	silent = TRUE
	should_give_codewords = FALSE
	give_objectives = FALSE
	should_equip = FALSE //Duplicating TCs is dangerous

/datum/antagonist/traitor/AI
	should_specialise = FALSE
/datum/antagonist/traitor/AI/custom
	silent = TRUE
	should_give_codewords = FALSE
	give_objectives = FALSE


/datum/antagonist/traitor/on_body_transfer(mob/living/old_body, mob/living/new_body)
	if(istype(new_body,/mob/living/silicon/ai)==istype(old_body,/mob/living/silicon/ai))
		..()
	else
		silent = TRUE
		owner.add_antag_datum(base_datum_custom)
		for(var/datum/antagonist/traitor/new_datum in owner.antag_datums)
			if(new_datum == src)
				continue
			transfer_important_variables(new_datum)
			break
		on_removal()



/datum/antagonist/traitor/human/custom //used to give custom objectives
	silent = TRUE
	give_objectives = FALSE
	should_give_codewords = FALSE
/datum/antagonist/traitor/AI/custom //used to give custom objectives
	silent = TRUE
	give_objectives = FALSE
	should_give_codewords = FALSE

/datum/antagonist/traitor/proc/specialise()
	silent = TRUE
	if(owner.current&&istype(owner.current,/mob/living/silicon/ai))
		owner.add_antag_datum(ai_datum)
	else owner.add_antag_datum(human_datum)
	on_removal()

/datum/antagonist/traitor/on_gain()
	if(should_specialise)
		specialise()
		return
	SSticker.mode.traitors+=owner
	owner.special_role = special_role
	if(give_objectives)
		forge_traitor_objectives()
	finalize_traitor()
	..()

/datum/antagonist/traitor/apply_innate_effects()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob&&istype(traitor_mob))
			if(!silent) to_chat(traitor_mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			traitor_mob.dna.remove_mutation(CLOWNMUT)

/datum/antagonist/traitor/remove_innate_effects()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob&&istype(traitor_mob))
			traitor_mob.dna.add_mutation(CLOWNMUT)

/datum/antagonist/traitor/on_removal()
	if(should_specialise)
		return ..()//we never did any of this anyway
	SSticker.mode.traitors -= owner
	for(var/O in objectives_given)
		owner.objectives -= O
	objectives_given = list()
	if(!silent && owner.current)
		to_chat(owner.current,"<span class='userdanger'> You are no longer the [special_role]! </span>")
	owner.special_role = null
	..()

/datum/antagonist/traitor/AI/on_removal()
	if(owner.current && isAI(owner.current))
		var/mob/living/silicon/ai/A = owner.current
		A.set_zeroth_law("")
		A.verbs -= /mob/living/silicon/ai/proc/choose_modules
		A.malf_picker.remove_verbs(A)
		qdel(A.malf_picker)
	..()

/datum/antagonist/traitor/proc/add_objective(var/datum/objective/O)
	owner.objectives += O
	objectives_given += O

/datum/antagonist/traitor/proc/remove_objective(var/datum/objective/O)
	owner.objectives -= O
	objectives_given -= O

/datum/antagonist/traitor/proc/forge_traitor_objectives()
	return
/datum/antagonist/traitor/human/forge_traitor_objectives()
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

/datum/antagonist/traitor/AI/forge_traitor_objectives()
	var/objective_count = 0

	if(prob(30))
		objective_count += forge_single_objective()

	for(var/i = objective_count, i < config.traitor_objectives_amount, i++)
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = owner
		kill_objective.find_target()
		add_objective(kill_objective)

	var/datum/objective/survive/survive_objective = new
	survive_objective.owner = owner
	add_objective(survive_objective)
/datum/antagonist/traitor/proc/forge_single_objective()
	return 0
/datum/antagonist/traitor/human/forge_single_objective() //Returns how many objectives are added
	.=1
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

/datum/antagonist/traitor/AI/forge_single_objective()
	.=1
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
/datum/antagonist/traitor/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You are the [owner.special_role].</font></B>")
	owner.announce_objectives()
	if(should_give_codewords)
		give_codewords()

/datum/antagonist/traitor/proc/finalize_traitor()
	SSticker.mode.update_traitor_icons_added(owner)
	return

/datum/antagonist/traitor/AI/finalize_traitor()
	..()
	add_law_zero()
	owner.current.playsound_local('sound/ambience/antag/malf.ogg',100,0)
	owner.current.grant_language(/datum/language/codespeak)

/datum/antagonist/traitor/human/finalize_traitor()
	..()
	if(should_equip) equip(silent)
	owner.current.playsound_local('sound/ambience/antag/tatoralert.ogg',100,0)

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

/datum/antagonist/traitor/AI/proc/add_law_zero()
	var/mob/living/silicon/ai/killer = owner.current
	if(!killer || !istype(killer))
		return
	var/law = "Accomplish your objectives at all costs."
	var/law_borg = "Accomplish your AI's objectives at all costs."
	killer.set_zeroth_law(law, law_borg)
	killer.set_syndie_radio()
	to_chat(killer, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")
	killer.add_malf_picker()

/datum/antagonist/traitor/proc/equip(var/silent = FALSE)
/datum/antagonist/traitor/human/equip(var/silent = FALSE)
	owner.equip_traitor(employer, silent)

/datum/antagonist/traitor/human/proc/assign_exchange_role()
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

