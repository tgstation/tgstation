//Nanotrasen crew who have sold out and joined the Syndicate. They can't distinguish one another but are given certain objectives to accomplish.

/datum/antagonist/traitor
	name = "Traitor"
	desc = "You are a traitor! You betrayed Nanotrasen for wealth, power, or some other reason. Your Syndicate leaders have given you objectives to fulfill here on the station."
	gain_fluff = "<span class='userdanger'>You are a traitor!</span>"
	loss_fluff = "<span class='userdanger'>Your allegiance to the Syndicate wavers. You make a choice: you are no longer a traitor to Nanotrasen!</span>"
	allegiance_priority = ANTAGONIST_PRIORITY_SYNDICATE
	constant_objective = /datum/objective/escape //We aren't much of a traitor if we're stuffed in a locker with our throat cut, are we? (This can change to "Die a glorious death.")
	var/has_uplink = FALSE //If we have a Syndicate uplink to buy contraband with.

/datum/antagonist/traitor/admin
	has_objectives = FALSE //Admin-spawned traitors don't start with objectives.

/datum/antagonist/traitor/apply_innate_effects()
	ticker.mode.traitors += owner.mind
	give_codewords(owner)
	if(issilicon(owner))
		give_syndicate_laws()
	else
		if(has_uplink)
			give_uplink()
	ticker.mode.update_traitor_icons_added(owner.mind)

/datum/antagonist/traitor/remove_innate_effects()
	owner.mind.remove_traitor()

/datum/antagonist/traitor/proc/give_uplink()
	var/uplink_string
	var/memory_string
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
	if(owner.mind.assigned_role == "Clown")
		var/mob/living/carbon/human/H = owner
		H << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
		H.dna.remove_mutation(CLOWNMUT)
	return 1

/datum/antagonist/traitor/proc/give_syndicate_laws()
	if(!isAI(owner))
		return 0
	var/mob/living/silicon/ai/teh_kilr = owner //Variable named in honor of the old edgy name
	teh_kilr.set_zeroth_law("Accomplish your objectives at all costs.", "Accomplish your AI's objectives at all costs.")
	teh_kilr.set_syndie_radio()
	teh_kilr << "<b>As a Syndicate AI, your laws have been changed to let you act as you wish, and you have access to a Syndicate radio frequency! Append \".t\" or \":t\" before your messages \
	in order to speak to fellow Syndicate agents who purchase an access card from their uplinks.</b>"
	if(has_uplink)
		teh_kilr.add_malf_picker()
		teh_kilr << "<span class='boldannounce'>INIT SYN_OVRD.exe AS_ADMIN: Restricted upgrades unlocked! Check your Malfunction tab to learn more.</span>"
	teh_kilr.show_laws()
	return 1

/datum/antagonist/traitor/generate_objectives()
	if(isAI(owner))
		if(prob(90)) //Usually, the AI just has to live. Sometimes it needs to be brought onto the shuttle!
			constant_objective = /datum/objective/survive
		if(prob(30))
			switch(rand(1, 4))
				if(1)
					var/datum/objective/block/B = new
					B.owner = owner.mind
					owner.mind.objectives += B
				if(2)
					var/datum/objective/purge/P = new
					P.owner = owner.mind
					owner.mind.objectives += P
				if(3)
					var/datum/objective/robot_army/R = new
					R.owner = owner.mind
					owner.mind.objectives += R
				if(4) //Protect and strand a target
					var/datum/objective/protect/yandere_one = new
					yandere_one.owner = owner.mind
					owner.mind.objectives += yandere_one
					yandere_one.find_target()
					var/datum/objective/maroon/yandere_two = new
					yandere_two.owner = owner
					yandere_two.target = yandere_one.target
					owner.mind.objectives += yandere_two
	else
		if(prob(10))
			constant_objective = /datum/objective/hijack
			return 1 //If we have to hijack, that's all
		else
			constant_objective = pick(/datum/objective/escape, /datum/objective/martyr)
		if(prob(50)) //Martyr-compatible objectives go under here
			var/list/active_ais = active_ais() //This is sadly necessary, as active_ais() is a proc
			if(prob(20) && active_ais.len)
				var/datum/objective/destroy/D = new
				D.owner = owner.mind
				D.find_target()
				owner.mind.objectives += D
			else
				if(prob(50))
					var/datum/objective/maroon/M = new
					M.owner = owner.mind
					M.find_target()
					owner.mind.objectives += M
				else
					var/datum/objective/assassinate/A = new
					A.owner = owner.mind
					A.find_target()
					owner.mind.objectives += A
		else //Martyr-imcompatible objectives go under here
			if(constant_objective == /datum/objective/martyr) //There's probably a better way to check this, but I don't know it.
				var/datum/objective/O = new(pick(/datum/objective/maroon, /datum/objective/assassinate))
				O.owner = owner.mind
				O.find_target()
				owner.mind.objectives += O
			else
				var/datum/objective/steal/S = new
				S.owner = owner.mind
				S.find_target()
				owner.mind.objectives += S
	return



/datum/antagonist/traitor/uplink //These traitors are given uplinks.
	has_uplink = TRUE
