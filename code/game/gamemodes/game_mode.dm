/datum/game_mode
	var/name = "invalid"
	var/config_tag = null
	var/intercept_hacked = 0
	var/list/datum/mind/modePlayer = null
	var/votable = 1
	var/probability = 1
	// this includes admin-appointed traitors and multitraitors. Easy!
	var/list/datum/mind/traitors = list()

/datum/game_mode/proc/announce()
	world << "<B>[src] did not define announce()</B>"

/datum/game_mode/proc/pre_setup()
	return 1

/datum/game_mode/proc/post_setup()

/datum/game_mode/proc/process()

/datum/game_mode/proc/check_finished()
	if(emergency_shuttle.location==2)
		return 1
	return 0

/datum/game_mode/proc/declare_completion()
	for(var/datum/mind/traitor in traitors)
		var/traitorwin = 1
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

		world << "<B>The syndicate traitor was [traitor_name]</B>"
		var/count = 1
		for(var/datum/objective/objective in traitor.objectives)
			if(objective.check_completion())
				world << "<B>Objective #[count]</B>: [objective.explanation_text] \green <B>Success</B>"
			else
				world << "<B>Objective #[count]</B>: [objective.explanation_text] \red Failed"
				traitorwin = 0
			count++

		if(traitorwin)
			world << "<B>The traitor was successful!<B>"
		else
			world << "<B>The traitor has failed!<B>"
	return 1

/datum/game_mode/proc/check_win()

/datum/game_mode/proc/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested staus information:</FONT><HR>"
	intercepttext += "<B> Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf", "changeling", "cult")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))

	if(!intercept_hacked)
		possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	shuffle(possible_modes)

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		if(modePlayer == null)
			intercepttext += i_text.build(A)
		else
			intercepttext += i_text.build(A, pick(modePlayer))

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")
	world << sound('intercept.ogg')

/*Added a safety check for traitor keywords.
Rev-heads won't get them. Can be expanded otherwise.*/
/datum/game_mode/proc/equip_traitor(mob/living/carbon/human/traitor_mob, var/safety = 0)
	if (!istype(traitor_mob))
		return
	if (traitor_mob.mind)
		if (traitor_mob.mind.assigned_role == "Clown")
			traitor_mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			traitor_mob.mutations &= ~CLOWN
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
	// generate a passcode if the uplink is hidden in a PDA
	var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

	// find a radio! toolbox(es), backpack, belt, headset
	var/loc = ""
	var/obj/item/device/R = null //Hide the uplink in a PDA if available, otherwise radio
	if (!R && istype(traitor_mob.belt, /obj/item/device/pda))
		R = traitor_mob.belt
		loc = "on your belt"
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
	if (!R && traitor_mob.w_uniform && istype(traitor_mob.belt, /obj/item/device/radio))
		R = traitor_mob.belt
		loc = "on your belt"
	if (!R && istype(traitor_mob.ears, /obj/item/device/radio))
		R = traitor_mob.ears
		loc = "on your head"
	if (!R)
		traitor_mob << "Unfortunately, the Syndicate wasn't able to get you a radio."
	else
		if (istype(R, /obj/item/device/radio))
			var/obj/item/weapon/syndicate_uplink/T = new /obj/item/weapon/syndicate_uplink(R)
			R:traitorradio = T
			R:traitor_frequency = freq
			T.name = R.name
			T.icon_state = R.icon_state
			T.origradio = R
			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc]).")
		else if (istype(R, /obj/item/device/pda))
			var/obj/item/weapon/integrated_uplink/T = new /obj/item/weapon/integrated_uplink(R)
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
			traitor_mob << "Unfortunetly, the Syndicate did not provide you with a code phrase."
		if(prob(80))
			traitor_mob << "\red Code Response: \black [syndicate_code_response]"
			traitor_mob.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")
		else
			traitor_mob << "Unfortunetly, the Syndicate did not provide you with a code response."
		traitor_mob << "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe."
	//End code phrase.