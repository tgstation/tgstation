// To add a rev to the list of revolutionaries, make sure it's rev (with if(ticker.mode.name == "revolution)),
// then call ticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call ticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the rev icons start going wrong for some reason, ticker.mode:update_all_rev_icons() can be called to correct them.
// If the game somtimes isn't registering a win properly, then ticker.mode.check_win() isn't being called somewhere.

/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"

	var/list/datum/mind/head_revolutionaries = list()
	var/list/datum/mind/revolutionaries = list()
	var/finished = 0
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)


/datum/game_mode/revolution/announce()
	world << "<B>The current game mode is - Revolution!</B>"
	world << "<B>Some crewmembers are attempting to start a revolution!<BR>\nRevolutionaries - Kill the Captain, HoP, and HoS. Convert other crewmembers (excluding the Captain, HoP, HoR, and security officers) to your cause by flashing them. Protect your leaders.<BR>\nPersonnel - Protect the Captain, HoP, and HoR. Kill the leaders of the revolution, and brainwash the other revolutionaries (by beating them in the head).</B>"

/datum/game_mode/revolution/post_setup()

	var/list/revs_possible = list()
	revs_possible = get_possible_revolutionaries()
	var/list/heads = list()
	heads = get_living_heads()
	var/rev_number = 0

	if(!revs_possible || !heads)
		world << "<B> \red Not enough players for revolution game mode. Restarting world in 5 seconds."
		sleep(50)
		world.Reboot()
		return

	if(revs_possible.len >= 3)
		rev_number = 3
	else
		rev_number = revs_possible.len

	while(rev_number > 0)
		head_revolutionaries += pick(revs_possible)
		rev_number--

	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/mind/head_mind in heads)
			var/datum/objective/assassinate/rev_obj = new
			rev_obj.owner = rev_mind
			rev_obj.find_target_by_role(head_mind.assigned_role)
			rev_mind.objectives += rev_obj

		equip_revolutionary(rev_mind.current)
		update_rev_icons_added(rev_mind)

	for(var/datum/mind/rev_mind in head_revolutionaries)
		var/obj_count = 1
		rev_mind.current << "\blue You are a member of the revolutionaries' leadership!"
		for(var/datum/objective/objective in rev_mind.objectives)
			rev_mind.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/revolution/proc/equip_revolutionary(mob/living/carbon/human/rev_mob)
	if(!istype(rev_mob))
		return
	if (rev_mob.mind.assigned_role == "Clown")
		rev_mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
		rev_mob.mutations &= ~16
	spawn (100)
		var/freq = 1441
		var/list/freqlist = list()
		while (freq <= 1489)
			if (freq < 1451 || freq > 1459)
				freqlist += freq
			freq += 2
			if ((freq % 2) == 0)
				freq += 1
		freq = freqlist[rand(1, freqlist.len)]
		var/obj/item/device/R = null //Hide the uplink in a PDA if available, otherwise radio
		var/pda_pass = "[rand(100,999)] [pick("Freedom","Revolution","Alpha","Theta")]"

	if (!R && istype(rev_mob.belt, /obj/item/device/pda))
		R = rev_mob.belt
		loc = "on your belt"
		var/obj/item/device/radio/R = null
		if (!R && istype(rev_mob.l_hand, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = rev_mob.l_hand
			var/list/L = S.return_inv()
			for (var/obj/item/device/radio/foo in L)
				R = foo
				loc = "in the [S.name] in your left hand"
				break
		if (!R && istype(rev_mob.r_hand, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = rev_mob.r_hand
			var/list/L = S.return_inv()
			for (var/obj/item/device/radio/foo in L)
				R = foo
				loc = "in the [S.name] in your right hand"
				break
		if (!R && istype(rev_mob.back, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = rev_mob.back
			var/list/L = S.return_inv()
			for (var/obj/item/device/radio/foo in L)
				R = foo
				loc = "in the [S.name] on your back"
				break
		if (!R && rev_mob.w_uniform && istype(rev_mob.belt, /obj/item/device/radio))
			R = rev_mob.belt
			loc = "on your belt"
		if (!R && istype(rev_mob.ears, /obj/item/device/radio))
			R = rev_mob.ears
			loc = "on your head"
		if (!R)
			rev_mob << "Unfortunately, the Syndicate wasn't able to get you a radio."
		else
			if (istype(R, /obj/item/device/radio))
				var/obj/item/weapon/syndicate_uplink/T = new /obj/item/weapon/syndicate_uplink(R)
				R.traitorradio = T
				R.traitor_frequency = freq
				T.name = R.name
				T.icon_state = R.icon_state
				T.origradio = R
				rev_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock it's hidden features."
				rev_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc]).", 0, 0)
			if (rev_mob.r_store)
				rev_mob.equip_if_possible(new /obj/item/device/flash(rev_mob), rev_mob.slot_l_store)
			if (rev_mob.l_store)
				rev_mob.equip_if_possible(new /obj/item/device/flash(rev_mob), rev_mob.slot_r_store)
			else if (istype(R, /obj/item/device/pda))
			var/obj/item/weapon/integrated_uplink/SWF/T = new /obj/item/weapon/integrated_uplink/SWF(R)
			R:uplink = T
			T.lock_code = pda_pass
			T.hostpda = R
			rev_mob << "The Syndicate have cunningly hidden a Syndicate Uplink in your PDA [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features."
			rev_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [loc]).")

/datum/game_mode/revolution/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested staus information:</FONT><HR>"
	intercepttext += "<B> Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))
	possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, pick(head_revolutionaries))

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")


/datum/game_mode/revolution/check_win()
	if(check_rev_victory())
		finished = 1
	else if(check_heads_victory())
		finished = 2
	return

/datum/game_mode/revolution/check_finished()
	if(finished != 0)
		return 1
	else
		return 0

/datum/game_mode/revolution/proc/add_revolutionary(datum/mind/rev_mind)
	var/list/uncons = get_unconvertables()
	if(!(rev_mind in revolutionaries) && !(rev_mind in head_revolutionaries) && !(rev_mind in uncons))
		revolutionaries += rev_mind
		rev_mind.current << "\red <FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the game!</FONT>"
		update_rev_icons_added(rev_mind)

/datum/game_mode/revolution/proc/remove_revolutionary(datum/mind/rev_mind)
	if(rev_mind in revolutionaries)
		revolutionaries -= rev_mind
		rev_mind.current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a revolutionary!</B></FONT>"
		update_rev_icons_removed(rev_mind)
		for(var/mob/living/M in view(rev_mind.current))
			M << "[rev_mind.current] looks like they just remembered their real allegiance!"

/datum/game_mode/revolution/proc/update_all_rev_icons()
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					for(var/image/I in head_rev_mind.current.client.images)
						if(I.icon_state == "rev" || I.icon_state == "rev_head")
							del(I)

		for(var/datum/mind/rev_mind in revolutionaries)
			if(rev_mind.current)
				if(rev_mind.current.client)
					for(var/image/I in rev_mind.current.client.images)
						if(I.icon_state == "rev" || I.icon_state == "rev_head")
							del(I)

		for(var/datum/mind/head_rev in head_revolutionaries)
			if(head_rev.current)
				if(head_rev.current.client)
					for(var/datum/mind/rev in revolutionaries)
						if(rev.current)
							var/I = image('mob.dmi', loc = rev.current, icon_state = "rev")
							head_rev.current.client.images += I
					for(var/datum/mind/head_rev_1 in head_revolutionaries)
						if(head_rev_1.current)
							var/I = image('mob.dmi', loc = head_rev_1.current, icon_state = "rev_head")
							head_rev.current.client.images += I

		for(var/datum/mind/rev in revolutionaries)
			if(rev.current)
				if(rev.current.client)
					for(var/datum/mind/head_rev in head_revolutionaries)
						if(head_rev.current)
							var/I = image('mob.dmi', loc = head_rev.current, icon_state = "rev")
							rev.current.client.images += I
					for(var/datum/mind/rev_1 in revolutionaries)
						if(rev_1.current)
							var/I = image('mob.dmi', loc = rev_1.current, icon_state = "rev_head")
							rev.current.client.images += I

/datum/game_mode/revolution/proc/update_rev_icons_added(datum/mind/rev_mind)
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					var/I = image('mob.dmi', loc = rev_mind.current, icon_state = "rev")
					head_rev_mind.current.client.images += I
			if(rev_mind.current)
				if(rev_mind.current.client)
					var/image/J = image('mob.dmi', loc = head_rev_mind.current, icon_state = "rev_head")
					rev_mind.current.client.images += J

		for(var/datum/mind/rev_mind_1 in revolutionaries)
			if(rev_mind_1.current)
				if(rev_mind_1.current.client)
					var/I = image('mob.dmi', loc = rev_mind.current, icon_state = "rev")
					rev_mind_1.current.client.images += I
			if(rev_mind.current)
				if(rev_mind.current.client)
					var/image/J = image('mob.dmi', loc = rev_mind_1.current, icon_state = "rev")
					rev_mind.current.client.images += J

/datum/game_mode/revolution/proc/update_rev_icons_removed(datum/mind/rev_mind)
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					for(var/image/I in head_rev_mind.current.client.images)
						if(I.loc == rev_mind.current)
							del(I)

		for(var/datum/mind/rev_mind_1 in revolutionaries)
			if(rev_mind_1.current)
				if(rev_mind_1.current.client)
					for(var/image/I in rev_mind_1.current.client.images)
						if(I.loc == rev_mind.current)
							del(I)
		if(rev_mind.current)
			if(rev_mind.current.client)
				for(var/image/I in rev_mind.current.client.images)
					if(I.icon_state == "rev" || I.icon_state == "rev_head")
						del(I)

/datum/game_mode/revolution/proc/get_possible_revolutionaries()
	var/list/candidates = list()

	for(var/mob/living/carbon/human/player in world)
		if(player.client)
			if(player.be_syndicate)
				candidates += player.mind

	if(candidates.len < 1)
		for(var/mob/living/carbon/human/player in world)
			if(player.client)
				candidates += player.mind

	var/list/uncons = get_unconvertables()
	for(var/datum/mind/mind in uncons)
		candidates -= mind

	if(candidates.len < 1)
		return null
	else
		return candidates

/datum/game_mode/revolution/proc/get_living_heads()
	var/list/heads = list()

	for(var/mob/living/carbon/human/player in world)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
				heads += player.mind

	return heads


/datum/game_mode/revolution/proc/get_all_heads()
	var/list/heads = list()

	for(var/mob/player in world)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
				heads += player.mind

	return heads

/datum/game_mode/revolution/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in world)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director", "Security Officer", "Detective", "AI"))
				ucs += player.mind

	return ucs

/datum/game_mode/revolution/proc/check_rev_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/objective/objective in rev_mind.objectives)
			if(!(objective.check_completion()))
				return 0

		return 1

/datum/game_mode/revolution/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		if(rev_mind.current.stat != 2)
			return 0
	return 1

/datum/game_mode/revolution/declare_completion()

	var/text = ""
	if(finished == 1)
		world << "\red <FONT size = 3><B> The heads of staff were killed! The revolutionaries win!</B></FONT>"
	else if(finished == 2)
		world << "\red <FONT size = 3><B> The heads of staff managed to stop the revolution!</B></FONT>"

	world << "<FONT size = 2><B>The head revolutionaries were: </B></FONT>"
	for(var/datum/mind/rev_mind in head_revolutionaries)
		text = ""
		if(rev_mind.current)
			text += "[rev_mind.current.real_name]"
			if(rev_mind.current.stat == 2)
				text += " (Dead)"
			else
				text += " (Survived!)"
		else
			text += "[rev_mind.key] (character destroyed)"

		world << text

	text = ""
	world << "<FONT size = 2><B>The converted revolutionaries were: </B></FONT>"
	for(var/datum/mind/rev_nh_mind in revolutionaries)
		if(rev_nh_mind.current)
			text += "[rev_nh_mind.current.real_name]"
			if(rev_nh_mind.current.stat == 2)
				text += " (Dead)"
			else
				text += " (Survived!)"
		else
			text += "[rev_nh_mind.key] (character destroyed)"
		text += ", "

	world << text

	world << "<FONT size = 2><B>The heads of staff were: </B></FONT>"
	var/list/heads = list()
	heads = get_all_heads()
	for(var/datum/mind/head_mind in heads)
		text = ""
		if(head_mind.current)
			text += "[head_mind.current.real_name]"
			if(head_mind.current.stat == 2)
				text += " (Dead)"
			else
				text += " (Survived!)"
		else
			text += "[head_mind.key] (character destroyed)"

		world << text

	return 1