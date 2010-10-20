// To add a rev to the list of revolutionaries, make sure it's rev (with if(ticker.mode.name == "revolution)),
// then call ticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call ticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the rev icons start going wrong for some reason, ticker.mode:update_all_rev_icons() can be called to correct them.
// If the game somtimes isn't registering a win properly, then ticker.mode.check_win() isn't being called somewhere.

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"

	var/list/datum/mind/cult = list()
	var/finished = 0
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)


/datum/game_mode/cult/announce()
	world << "<B>The current game mode is - Cult!</B>"
	world << "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - Kill the Captain, HoP, RD, CE and HoS. Convert other crewmembers (excluding the heads, security officers and chaplain) to your cause by using the convert rune. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Protect the heads. Destroy the cult either via killing the cultists or brainwashing them with the chaplain's bible.</B>"

/datum/game_mode/cult/post_setup()

	var/list/cultists_possible = list()
	cultists_possible = get_possible_cultists()
	var/list/heads = list()
	heads = get_living_heads()
	var/cultists_number = 0

	if(!cultists_possible || !heads)
		world << "<B> \red Not enough players for cult game mode. Restarting world in 5 seconds."
		sleep(50)
		world.Reboot()
		return

	if(cultists_possible.len >= 3)
		cultists_number = 3
	else
		cultists_number = cultists_possible.len

	while(cultists_number > 0)
		cult += pick(cultists_possible)
		cultists_possible -= cult
		cultists_number--

	for(var/datum/mind/cult_mind in cult)
		for(var/datum/mind/head_mind in heads)
			var/datum/objective/assassinate/cult_obj = new
			cult_obj.owner = cult_mind
			cult_obj.find_target_by_role(head_mind.assigned_role)
			cult_mind.objectives += cult_obj

		equip_cultist(cult_mind.current)
		update_cult_icons_added(cult_mind)

	for(var/datum/mind/cult_mind in cult)
		var/obj_count = 1
		cult_mind.current << "\blue You are a member of the cult!"
		for(var/datum/objective/objective in cult_mind.objectives)
			cult_mind.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/cult/proc/equip_cultist(mob/living/carbon/human/cult_mob)
	if(!istype(cult_mob))
		return
	spawn (0)
		var/obj/item/weapon/paper/talisman/supply/T = null
		cult_mob.equip_if_possible(new /obj/item/weapon/paper/talisman/supply(cult_mob), cult_mob.slot_l_store)
		if (!T && istype(cult_mob.l_store, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = cult_mob.l_store
			var/list/L = S.return_inv()
			for (var/obj/item/weapon/paper/talisman/supply/foo in L)
				T = foo
				break
		if (!T)
			cult_mob << "Unfortunately, you weren't able to get a talisman. This is very bad and you should adminhelp immediately."
		else
			cult_mob << "You have a talisman in your backpack, one that will help you start the cult on this station. Use it well and remember - there are others."
		if(!wordtravel)
			runerandom()
		var/word=pick("1","2","3","4","5","6","7","8")
		switch(word)
			if("1")
				cult_mob << "\red You remembered one thing from the dark teachings of your master... [wordtravel] is travel..."
			if("2")
				cult_mob << "\red You remembered one thing from the dark teachings of your master... [wordblood] is blood..."
			if("3")
				cult_mob << "\red You remembered one thing from the dark teachings of your master... [wordjoin] is join..."
			if("4")
				cult_mob << "\red You remembered one thing from the dark teachings of your master... [wordhell] is Hell..."
			if("5")
				cult_mob << "\red You remembered one thing from the dark teachings of your master... [worddestr] is destroy..."
			if("6")
				cult_mob << "\red You remembered one thing from the dark teachings of your master... [wordtech] is technology..."
			if("7")
				cult_mob << "\red You remembered one thing from the dark teachings of your master... [wordself] is self..."
			if("8")
				cult_mob << "\red You remembered one thing from the dark teachings of your master... [wordsee] is see..."

/datum/game_mode/cult/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested staus information:</FONT><HR>"
	intercepttext += "<B> Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "cult", "wizard", "nuke", "traitor", "malf", "changeling")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))
	possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, pick(cult))

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")
	world << sound('intercept.ogg')


/datum/game_mode/cult/check_win()
	if(check_cult_victory())
		finished = 1
	else if(check_heads_victory())
		finished = 2
	return

/datum/game_mode/cult/check_finished()
	if(finished != 0)
		return 1
	else
		return 0

/datum/game_mode/cult/proc/add_cultist(datum/mind/cult_mind)
	var/list/uncons = get_unconvertables()
	if(!(cult_mind in cult) && !(cult_mind in uncons))
		cult += cult_mind
		update_cult_icons_added(cult_mind)

/datum/game_mode/cult/proc/remove_cultist(datum/mind/cult_mind)
	if(cult_mind in cult)
		cult -= cult_mind
		cult_mind.current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a cultist!</B></FONT>"
		update_cult_icons_removed(cult_mind)
		for(var/mob/living/M in view(cult_mind.current))
			M << "<FONT size = 3>[cult_mind.current] looks like they just reverted to their old faith!</FONT>"

/datum/game_mode/cult/proc/update_all_cult_icons()
	spawn(0)
		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					for(var/image/I in cultist.current.client.images)
						if(I.icon_state == "cult")
							del(I)

		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					for(var/datum/mind/cultist_1 in cult)
						if(cultist_1.current)
							var/I = image('mob.dmi', loc = cultist_1.current, icon_state = "cult")
							cultist.current.client.images += I

/datum/game_mode/cult/proc/update_cult_icons_added(datum/mind/cult_mind)
	spawn(0)
		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					var/I = image('mob.dmi', loc = cult_mind.current, icon_state = "cult")
					cultist.current.client.images += I
			if(cult_mind.current)
				if(cult_mind.current.client)
					var/image/J = image('mob.dmi', loc = cultist.current, icon_state = "cult")
					cult_mind.current.client.images += J

/datum/game_mode/cult/proc/update_cult_icons_removed(datum/mind/cult_mind)
	spawn(0)
		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					for(var/image/I in cultist.current.client.images)
						if(I.loc == cult_mind.current)
							del(I)

		if(cult_mind.current)
			if(cult_mind.current.client)
				for(var/image/I in cult_mind.current.client.images)
					if(I.icon_state == "cult")
						del(I)

/datum/game_mode/cult/proc/get_possible_cultists()
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

/datum/game_mode/cult/proc/get_living_heads()
	var/list/heads = list()

	for(var/mob/living/carbon/human/player in world)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
				heads += player.mind

	return heads


/datum/game_mode/cult/proc/get_all_heads()
	var/list/heads = list()

	for(var/mob/player in world)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
				heads += player.mind

	return heads

/datum/game_mode/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in world)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director", "Security Officer", "Detective", "AI", "Chaplain"))
				ucs += player.mind

	return ucs

/datum/game_mode/cult/proc/check_cult_victory()
	for(var/datum/mind/cult_mind in cult)
		for(var/datum/objective/objective in cult_mind.objectives)
			if(!(objective.check_completion()))
				return 0

		return 1

/datum/game_mode/cult/proc/check_heads_victory()
	for(var/datum/mind/cult_mind in cult)
		if(cult_mind.current.stat != 2)
			return 0
	return 1

/datum/game_mode/cult/declare_completion()

	var/text = ""
	if(finished == 1)
		world << "\red <FONT size = 3><B> The heads of staff were killed! The cult win!</B></FONT>"
	else if(finished == 2)
		world << "\red <FONT size = 3><B> The heads of staff managed to stop the cult!</B></FONT>"

	world << "<FONT size = 2><B>The cultists were: </B></FONT>"
	for(var/datum/mind/cult_nh_mind in cultists)
		if(cult_nh_mind.current)
			text += "[cult_nh_mind.current.real_name]"
			if(cult_nh_mind.current.stat == 2)
				text += " (Dead)"
			else
				text += " (Survived!)"
		else
			text += "[cult_nh_mind.key] (character destroyed)"
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