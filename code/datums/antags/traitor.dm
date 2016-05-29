/datum/antag/traitor
	name = "Traitor"
	antagtag = "traitor"

	var/obj/item/device/uplink/uplink
	var/starting_telecrystals = 20
	var/given_codewords = FALSE

/datum/antag/traitor/proc/inform_of_codewords(datum/mind/user)
	var/mob/mob = user.current
	mob << "<U><B>The Syndicate provided you with the following \
		information on how to identify their agents:</B></U>"
	mob << "<B>Code Phrase</B>: <span class='danger'>\
		[syndicate_code_phrase]</span>"
	mob << "<B>Code Response</B>: <span class='danger'>\
		[syndicate_code_response]</span>"

	user.store_memory("<b>Code Phrase</b>: \
		[syndicate_code_phrase]")
	user.store_memory("<b>Code Response</b>: \
		[syndicate_code_response]")

	mob << "Use the code words in the order provided, during \
		regular conversation, to identify other agents. Proceed with \
		caution, however, as everyone is a potential foe."

/datum/antag/traitor/equip(mob/living/carbon/human/mob)
	if(!ishuman(mob))
		mob << "<span class='warning'>The Syndicate do not provide equipment \
			for non-human agents.</span>"

	var/list/uplink_order = list("pda", "radio", "implant")
	var/randomise = FALSE
	if(randomise)
		uplink_order = shuffle(uplink_order)

	var/success = FALSE
	while(uplink_order.len && !success)
		var/item = popleft(uplink_order)
		switch(item)
			if("pda")
				var/P = locate(/obj/item/device/pda) in mob.contents
				success = equip_pda(mob, P)
			if("radio")
				var/R = locate(/obj/item/device/radio) in mob.contents
				success = equip_radio(mob, R)
			if("implant")
				success = equip_implant(mob)

	if(!success)
		mob << "<span class='warning'>The Syndicate were unable to provide \
			you with any equipment.</span>"
	else
		uplink.telecrystals = starting_telecrystals

/datum/antag/traitor/first_tick(datum/mind/user)
	. = ..()
	inform_of_codewords(user)

/datum/antag/traitor/proc/equip_pda(mob/living/mob, obj/item/device/pda/P)
	if(!P || !istype(P))
		return FALSE
	uplink = new(P)
	uplink.owner = "[mob.key]"

	P.hidden_uplink = uplink

	var/num = rand(100,999)
	var/greek = pick("Alpha","Bravo","Delta","Omega","Kappa","Tau")
	P.lock_code = "[num] [greek]"

	mob << "The Syndicate have cunningly disguised a Syndicate Uplink as \
		your [P.name]. Simply enter the code \
		\"[P.lock_code]\" into the ringtone select to unlock its hidden \
		features."
	mob.mind.store_memory("<B>Uplink Passcode:</B> [P.lock_code] \
		([P.name]).")
	return TRUE

/datum/antag/traitor/proc/equip_radio(mob/living/mob, obj/item/device/radio/R)
	if(!R || !istype(R))
		return FALSE
	uplink = new(R)
	uplink.owner = "[mob.key]"

	R.traitor_frequency = sanitize_frequency(rand(MIN_FREQ, MAX_FREQ))

	mob << "The Syndicate have cunningly disguised a Syndicate Uplink \
		as your [R.name]. Simply dial the frequency \
		[format_frequency(R.traitor_frequency)] to unlock its hidden features."
	mob.mind.store_memory("<B>Radio Frequency:</B> \
		[format_frequency(R.traitor_frequency)] ([R.name]).")
	return TRUE

/datum/antag/traitor/proc/equip_implant(mob/living/mob)
	var/obj/item/weapon/implant/uplink/imp = new(mob)
	. = imp.implant(mob)
	if(!.)
		return
	mob << "The Syndicate have cunningly supplied you with a Syndicate \
		Uplink implant."
	uplink = imp.hidden_uplink
	return TRUE

/datum/antag/traitor/on_loss(datum/mind/user, hard=FALSE)
	// Work out if anyone else's objectives are affected
	// Wipe their uplink if carried
	. = ..()
	var/mob/M = user.current
	if(uplink in M.GetAllContents() || hard)
		uplink.telecrystals = 0
		if(istype(uplink.loc, /obj/item/weapon/implant/uplink))
			qdel(uplink.loc) // the implant self destructs
		else if(istype(uplink.loc, /obj/item/device/radio))
			var/obj/item/device/radio/R = uplink.loc
			R.traitor_frequency = 0
		else if(istype(uplink.loc, /obj/item/device/pda))
			var/obj/item/device/pda/P = uplink.loc
			P.lock_code = ""
		qdel(uplink)
	// Remove codewords and any other information from their notes
	// is this even possible to selectively edit the memory?
	// TODO make memory editable in this way

/datum/antag/traitor/proc/make_silicon_objectives(datum/mind/user)
	if(!issilicon(user.current))
		throw EXCEPTION("[user.current] is not a silicon!")

	var/objective_count = 0

	if(prob(30))
		var/special_pick = rand(1,4)
		switch(special_pick)
			if(1)
				var/datum/objective/block/block_objective = new
				block_objective.owner = user
				objectives += block_objective
				objective_count++
			if(2)
				var/datum/objective/purge/purge_objective = new
				purge_objective.owner = user
				objectives += purge_objective
				objective_count++
			if(3)
				var/datum/objective/robot_army/robot_objective = new
				robot_objective.owner = user
				objectives += robot_objective
				objective_count++
			if(4) //Protect and strand a target
				var/datum/objective/protect/yandere_one = new
				yandere_one.owner = user
				objectives += yandere_one
				yandere_one.find_target()
				objective_count++
				var/datum/objective/maroon/yandere_two = new
				yandere_two.owner = user
				yandere_two.target = yandere_one.target
				objectives += yandere_two
				objective_count++

	for(var/i = objective_count, i < config.traitor_objectives_amount, i++)
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = user
		kill_objective.find_target()
		objectives += kill_objective

	var/datum/objective/survive/survive_objective = new
	survive_objective.owner = user
	objectives += survive_objective

/datum/antag/traitor/proc/make_objectives(datum/mind/user, exchanging=FALSE)
	if(issilicon(user.current))
		throw EXCEPTION("[user.current] is a silicon!")

	var/is_hijacker = prob(10)
	var/martyr_chance = prob(20)
	var/objective_count = 0

	if(is_hijacker)
		objective_count++

	// The exchanging objective is created later, so for now just take
	// up a slot
	if(exchanging)
		objective_count++

	var/list/active_ais = active_ais()
	for(var/i = objective_count, i < config.traitor_objectives_amount, i++)
		if(prob(50))
			if(active_ais.len && prob(100/joined_player_list.len))
				var/datum/objective/destroy/destroy_objective = new
				destroy_objective.owner = user
				destroy_objective.find_target()
				objectives += destroy_objective
			else if(prob(30))
				var/datum/objective/maroon/maroon_objective = new
				maroon_objective.owner = user
				maroon_objective.find_target()
				objectives += maroon_objective
			else
				var/datum/objective/assassinate/kill_objective = new
				kill_objective.owner = user
				kill_objective.find_target()
				objectives += kill_objective
		else
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = user
			steal_objective.find_target()
			objectives += steal_objective

	if(is_hijacker && objective_count <= config.traitor_objectives_amount)
		var/datum/objective/hijack/hijack_objective = new
		hijack_objective.owner = user
		objectives += hijack_objective
		return
	// You can't succeed in stealing if you're dead.
	var/martyr_compatibility = TRUE
	for(var/datum/objective/O in objectives)
		if(!O.martyr_compatible)
			martyr_compatibility = FALSE
			break

	if(martyr_compatibility && martyr_chance)
		var/datum/objective/martyr/martyr_objective = new
		martyr_objective.owner = user
		objectives += martyr_objective

	else
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = user
		objectives += escape_objective
