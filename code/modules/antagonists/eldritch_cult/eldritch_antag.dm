/datum/antagonist/heretic
	name = "Heretic"
	roundend_category = "Heretics"
	antagpanel_category = "Heretic"
	antag_moodlet = /datum/mood_event/e_cult
	job_rank = ROLE_HERETIC
	var/give_equipment = TRUE
	var/list/researched_knowledge = list()
	var/total_sacrifices = 0

/datum/antagonist/heretic/admin_add(datum/mind/new_owner,mob/admin)
	give_equipment = FALSE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has heresized [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has heresized [key_name(new_owner)].")

/datum/antagonist/heretic/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ecult_op.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	to_chat(owner, "<span class='boldannounce'>You are the Heretic!</span><br>\
	<B>The old ones gave you these tasks to fulfill:</B>")
	owner.announce_objectives()
	to_chat(owner, "<span class='cult'>The book whispers, the forbidden knowledge walks once again!<br>\
	Your book allows you to research abilities, read it very carefully! you cannot undo what has been done!<br>\
	You gain charges by either collecitng influences or sacrifcing people tracked by the living heart<br> \
	You can find a basic guide at :https://tgstation13.org/wiki/Heresy_101 </span>")

/datum/antagonist/heretic/on_gain()
	var/mob/living/current = owner.current
	if(ishuman(current))
		forge_primary_objectives()
		gain_knowledge(/datum/eldritch_knowledge/spell/basic)
		gain_knowledge(/datum/eldritch_knowledge/living_heart)
	current.log_message("has been converted to the cult of the forgotten ones!", LOG_ATTACK, color="#960000")
	if(!GLOB.reality_smash_track)
		new /datum/reality_smash_tracker()
		GLOB.reality_smash_track.Generate(1)
	GLOB.reality_smash_track.AddMind(owner)
	START_PROCESSING(SSprocessing,src)
	if(give_equipment)
		equip_cultist()
	return ..()

/datum/antagonist/heretic/on_removal()

	for(var/X in researched_knowledge)
		var/datum/eldritch_knowledge/EK = X
		EK.on_lose(owner.current)

	if(!silent)
		owner.current.visible_message("<span class='deconversion_message'>[owner.current] looks like [owner.current.p_theyve()] just reverted to [owner.current.p_their()] old faith!</span>", null, null, null, owner.current)
		to_chat(owner.current, "<span class='userdanger'>Your mind begins to flare as the otherwordly knowledge escapes your grasp!</span>")
		owner.current.log_message("has renounced the cult of the old ones!", LOG_ATTACK, color="#960000")
	GLOB.reality_smash_track.RemoveMind(owner)
	STOP_PROCESSING(SSprocessing,src)

	return ..()


/datum/antagonist/heretic/proc/equip_cultist()
	var/mob/living/carbon/H = owner.current
	if(!istype(H))
		return
	. += ecult_give_item(/obj/item/forbidden_book, H)
	. += ecult_give_item(/obj/item/living_heart, H)

/datum/antagonist/heretic/proc/ecult_give_item(obj/item/item_path, mob/living/carbon/human/H)
	var/list/slots = list(
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET
	)

	var/T = new item_path(H)
	var/item_name = initial(item_path.name)
	var/where = H.equip_in_one_of_slots(T, slots)
	if(!where)
		to_chat(H, "<span class='userdanger'>Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1).</span>")
		return FALSE
	else
		to_chat(H, "<span class='danger'>You have a [item_name] in your [where].</span>")
		if(where == "backpack")
			SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)
		return TRUE


/datum/antagonist/heretic/process()

	for(var/X in researched_knowledge)
		var/datum/eldritch_knowledge/EK = X
		EK.on_life(owner.current)

	for(var/X in objectives)
		if(!istype(X,/datum/objective/stalk))
			continue
		var/datum/objective/stalk/S = X
		if(S.target && S.target.current.stat == CONSCIOUS && (S.target in view(7,src)))
			S.timer -= 1 SECONDS

/datum/antagonist/heretic/proc/forge_primary_objectives()
	var/list/assasination = list()
	var/list/protection = list()
	for(var/i in 1 to 2)
		var/pck = pick("assasinate","stalk","protect")
		switch(pck)
			if("assasinate")
				var/datum/objective/assassinate/A = new
				A.owner = owner
				var/list/owners = A.get_owners()
				A.find_target(owners,protection)
				assasination += A.target
				objectives += A
			if("stalk")
				var/datum/objective/stalk/S = new
				S.owner = owner
				S.find_target()
				objectives += S
			if("protect")
				var/datum/objective/protect/P = new
				P.owner = owner
				var/list/owners = P.get_owners()
				P.find_target(owners,assasination)
				protection += P.target
				objectives += P

	var/datum/objective/sacrifice_ecult/SE = new
	SE.update_explanation_text()
	objectives += SE

/datum/antagonist/heretic/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	handle_clown_mutation(current, mob_override ? null : "Knowledge described in the book allowed you to overcome your clownish nature, allowing you to use complex items effectively.")
	current.faction |= "e_cult"

/datum/antagonist/heretic/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	handle_clown_mutation(current, removing = FALSE)
	current.faction -= "e_cult"

/datum/antagonist/heretic/get_admin_commands()
	. = ..()
	.["Equip"] = CALLBACK(src,.proc/equip_cultist)

/datum/antagonist/heretic/roundend_report()
	var/list/parts = list()

	var/cultiewin = TRUE

	parts += printplayer(owner)

	//Removed sanity if(changeling) because we -want- a runtime to inform us that the changelings list is incorrect and needs to be fixed.
	parts += "<b>Sacrifices Made:</b> [total_sacrifices]"

	if(objectives.len)
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='greentext'>Success!</b></span>"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				cultiewin = FALSE
			count++

	if(cultiewin)
		parts += "<span class='greentext'>The heretic was successful!</span>"
	else
		parts += "<span class='redtext'>The heretic has failed.</span>"

	parts += "<b>Knowledge Researched:</b> "

	var/list/knowledge_message = list()
	for(var/X in get_all_knowledge())
		var/datum/eldritch_knowledge/EK = X
		knowledge_message += "[EK.name]"
	parts += knowledge_message.Join(", ")

	return parts.Join("<br>")
////////////////
// Knowledge //
////////////////

/datum/antagonist/heretic/proc/gain_knowledge(datum/eldritch_knowledge/EK)
	if(has_knowledge(EK))
		return FALSE
	var/datum/eldritch_knowledge/initialized_knowledge = new EK
	researched_knowledge += initialized_knowledge
	researched_knowledge[initialized_knowledge] = initialized_knowledge.name
	initialized_knowledge.on_gain(owner.current)
	return TRUE

/datum/antagonist/heretic/proc/get_researchable_knowledge()
	var/list/researchable_knowledge = list()
	var/list/banned_knowledge = list()
	for(var/X in researched_knowledge)
		var/datum/eldritch_knowledge/EK = X
		researchable_knowledge |= EK.next_knowledge
		banned_knowledge |= EK.banned_knowledge
		banned_knowledge |= EK.type
	researchable_knowledge -= banned_knowledge
	return researchable_knowledge

/datum/antagonist/heretic/proc/has_knowledge(datum/eldritch_knowledge/wanted)
	if(researched_knowledge[initial(wanted.name)])
		return TRUE
	return FALSE

/datum/antagonist/heretic/proc/get_knowledge(datum/eldritch_knowledge/wanted)
	return researched_knowledge[initial(wanted.name)] || FALSE

/datum/antagonist/heretic/proc/get_all_knowledge()
	return researched_knowledge

////////////////
// Objectives //
////////////////

/datum/objective/stalk
	name = "spendtime"
	var/timer = 5 MINUTES


/datum/objective/stalk/update_explanation_text()
	if(timer == initial(timer))//just so admins can mess with it
		timer += pick(-3 MINUTES, 3 MINUTES)
	if(target?.current)
		explanation_text = "Stalk [target.name] for at least [DisplayTimeText(timer)] while they're alive."
	else
		explanation_text = "Free Objective"

/datum/objective/stalk/check_completion()
	return timer <= 0 || explanation_text == "Free Objective"

/datum/objective/sacrifice_ecult
	name = "sacrifice"

/datum/objective/sacrifice_ecult/update_explanation_text()
	. = ..()
	target_amount = rand(4,6)
	explanation_text = "Sacrifice at least [target_amount] people."

/datum/objective/sacrifice_ecult/check_completion()
	if(!owner)
		return FALSE
	var/datum/antagonist/heretic/cultie = owner.has_antag_datum(/datum/antagonist/heretic)
	if(!cultie)
		return FALSE
	return cultie.total_sacrifices >= target_amount
