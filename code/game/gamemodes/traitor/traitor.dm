/datum/game_mode
	// this includes admin-appointed traitors and multitraitors. Easy!
	var/list/datum/mind/traitors = list()

/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	restricted_jobs = list("Cyborg", "AI")//Approved by headmins for a week test, if you see this it would be nice if you didn't spread it everywhere
	required_players = 0
	required_enemies = 1

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/traitors_possible = 4 //hard limit on traitors if scaling is turned off
	var/const/traitor_scaling_coeff = 10.0 //how much does the amount of players get divided by to determine traitors

	var/num_players = 0


/datum/game_mode/traitor/announce()
	world << "<B>The current game mode is - Traitor!</B>"
	world << "<B>There is a syndicate traitor on the station. Do not let the traitor succeed!</B>"


/datum/game_mode/traitor/pre_setup()
	var/list/possible_traitors = get_players_for_role(BE_TRAITOR)

	// stop setup if no possible traitors
	if(!possible_traitors.len)
		return 0

	var/num_traitors = 1

	if(config.traitor_scaling)
		num_traitors = max(1, round((num_players())/(traitor_scaling_coeff)) + 1)
	else
		num_traitors = max(1, min(num_players(), traitors_possible))

	for(var/datum/mind/player in possible_traitors)
		for(var/job in restricted_jobs)
			if(player.assigned_role == job)
				possible_traitors -= player

	for(var/j = 0, j < num_traitors, j++)
		if (!possible_traitors.len)
			break
		var/datum/mind/traitor = pick(possible_traitors)
		traitors += traitor
		traitor.special_role = "traitor"
		possible_traitors.Remove(traitor)

	if(!traitors.len)
		return 0
	return 1


/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in traitors)
		forge_traitor_objectives(traitor)
		spawn(rand(10,100))
			finalize_traitor(traitor)
			greet_traitor(traitor)
	modePlayer += traitors
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return 1


/datum/game_mode/proc/forge_traitor_objectives(var/datum/mind/traitor)
	if(istype(traitor.current, /mob/living/silicon))
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = traitor
		kill_objective.find_target()
		traitor.objectives += kill_objective

		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = traitor
		traitor.objectives += survive_objective

		if(prob(10))
			var/datum/objective/block/block_objective = new
			block_objective.owner = traitor
			traitor.objectives += block_objective

	else
		traitor.objectives = SelectObjectives(traitor.assigned_role, traitor)
	return


/datum/game_mode/proc/greet_traitor(var/datum/mind/traitor)
	traitor.current << "<B><font size=3 color=red>You are the traitor.</font></B>"
	traitor.current << "\red <B>REPEAT</B>"
	traitor.current << "\red <B>You are the traitor.</B>"
	spawn(rand(600,1800))			//Strumpetplaya - Just another friendly reminder so people don't forget they're the traitor.
		traitor.current << "\red <B>In case you missed it the first time - YOU ARE THE TRAITOR!</B>"
	var/obj_count = 1
	for(var/datum/objective/objective in traitor.objectives)
		traitor.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return


/datum/game_mode/proc/finalize_traitor(var/datum/mind/traitor)
	if (istype(traitor.current, /mob/living/silicon))
		add_law_zero(traitor.current)
	else
		equip_traitor(traitor.current)
	return


/datum/game_mode/traitor/declare_completion()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.


/datum/game_mode/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs."
	killer << "<b>Your laws have been changed!</b>"
	killer.set_zeroth_law(law)
	killer << "New law: 0. [law]"

	//Begin code phrase.
	killer << "The Syndicate provided you with the following information on how to identify their agents:"
	if(prob(80))
		killer << "\red Code Phrase: \black [syndicate_code_phrase]"
		killer.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
	else
		killer << "Unfortunately, the Syndicate did not provide you with a code phrase."
	if(prob(80))
		killer << "\red Code Response: \black [syndicate_code_response]"
		killer.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")
	else
		killer << "Unfortunately, the Syndicate did not provide you with a code response."
	killer << "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe."
	spawn(30)
		killer << sound('AISyndiHack.ogg',volume=50)
	//End code phrase.


/datum/game_mode/proc/auto_declare_completion_traitor()
	for(var/datum/mind/traitor in traitors)
		var/traitor_name

		if(traitor.current)
			if(traitor.current == traitor.original)
				traitor_name = "[traitor.current.real_name] (played by [traitor.key])"
			else if (traitor.original)
				traitor_name = "[traitor.current.real_name] (originally [traitor.original.real_name]) (played by [traitor.key])"
			else
				traitor_name = "[traitor.current.real_name] (original character destroyed) (played by [traitor.key])"
		else
			traitor_name = "[traitor.key] (character destroyed)"
		var/special_role_text = traitor.special_role?(lowertext(traitor.special_role)):"antagonist"
		world << "<B>The [special_role_text] was [traitor_name]</B>"
		if(traitor.objectives.len)//If the traitor had no objectives, don't need to process this.
			var/traitorwin = 1
			var/count = 1
			for(var/datum/objective/objective in traitor.objectives)
				if(objective.check_completion())
					world << "<B>Objective #[count]</B>: [objective.explanation_text] \green <B>Success</B>"
				else
					world << "<B>Objective #[count]</B>: [objective.explanation_text] \red Failed"
					traitorwin = 0
				count++

			if(traitorwin)
				world << "<B>The [special_role_text] was successful!<B>"
			else
				world << "<B>The [special_role_text] has failed!<B>"
	return 1


/datum/game_mode/proc/equip_traitor(mob/living/carbon/human/traitor_mob, var/safety = 0)
	if (!istype(traitor_mob))
		return
	. = 1
	if (traitor_mob.mind)
		if (traitor_mob.mind.assigned_role == "Clown")
			traitor_mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			traitor_mob.mutations &= ~CLUMSY

	// find a radio! toolbox(es), backpack, belt, headset, pockets
	var/loc = ""
	var/obj/item/device/R = null //Hide the uplink in a PDA if available, otherwise radio
	if (!R && istype(traitor_mob.belt, /obj/item/device/pda))
		R = traitor_mob.belt
		loc = "on your belt"
	if (!R && istype(traitor_mob.wear_id, /obj/item/device/pda))
		R = traitor_mob.wear_id
		loc = "on your jumpsuit"
	if (!R && istype(traitor_mob.wear_id, /obj/item/device/pda))
		R = traitor_mob.wear_id
		loc = "on your jumpsuit"
	if (!R && istype(traitor_mob.l_hand, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.l_hand
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your left hand"
			break
	if (!R && istype(traitor_mob.r_hand, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.r_hand
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your right hand"
			break
	if (!R && istype(traitor_mob.back, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.back
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] on your back"
			break
	if (!R && istype(traitor_mob.l_store, /obj/item/device/pda))
		R = traitor_mob.l_store
		loc = "in your pocket"
	if (!R && istype(traitor_mob.r_store, /obj/item/device/pda))
		R = traitor_mob.r_store
		loc = "in your pocket"
	if (!R && traitor_mob.w_uniform && istype(traitor_mob.belt, /obj/item/device/radio))
		R = traitor_mob.belt
		loc = "on your belt"
	if (!R && istype(traitor_mob.l_ear, /obj/item/device/radio) || prob(10))
		R = traitor_mob.l_ear
		loc = "on your head"
	if (!R && istype(traitor_mob.r_ear, /obj/item/device/radio))
		R = traitor_mob.r_ear
		loc = "on your head"
	if (!R)
		traitor_mob << "Unfortunately, the Syndicate wasn't able to get you an uplink."
		traitor_mob << "\red <b>ADMINHELP THIS AT ONCE.</b>"
		. = 0
	else
		if (istype(R, /obj/item/device/radio))
			// generate list of radio freqs
			var/freq = 1441
			var/list/freqlist = list()
			while (freq <= 1489)
				if (freq < 1451 || freq > 1459)
					freqlist += freq
				freq += 2
				if ((freq % 2) == 0)
					freq += 1
			freq = freqlist[rand(1, freqlist.len)]

			var/obj/item/device/uplink/radio/T = new /obj/item/device/uplink/radio(R)
			R:traitorradio = T
			R:traitor_frequency = freq
			T.name = R.name
			T.icon = R.icon
			T.w_class = R.w_class
			T.icon_state = R.icon_state
			T.item_state = R.item_state
			T.origradio = R
			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc]).")
		else if (istype(R, /obj/item/device/pda))
			// generate a passcode if the uplink is hidden in a PDA
			var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

			var/obj/item/device/uplink/pda/T = new /obj/item/device/uplink/pda(R)
			R:uplink = T
			T.lock_code = pda_pass
			T.hostpda = R
			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [loc]).")
	//Begin code phrase.
	if(!safety)//If they are not a rev. Can be added on to.
		traitor_mob << "The Syndicate provided you with the following information on how to identify other agents:"
		if(prob(80))
			traitor_mob << "\red Code Phrase: \black [syndicate_code_phrase]"
			traitor_mob.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
		else
			traitor_mob << "Unfortunately, the Syndicate did not provide you with a code phrase."
		if(prob(80))
			traitor_mob << "\red Code Response: \black [syndicate_code_response]"
			traitor_mob.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")
		else
			traitor_mob << "Unfortunately, the Syndicate did not provide you with a code response."
		traitor_mob << "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe."
		spawn(30)
			traitor_mob << sound('syndicate intro.ogg',volume=50)
	//End code phrase.
