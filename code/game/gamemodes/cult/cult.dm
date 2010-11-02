/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"

	var/datum/mind/sacrifice_target = null
	var/list/datum/mind/cult = list()
	var/finished = 0
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	var/list/objectives = list()
	var/eldergod = 1 //for the summon god objective
	var/const/acolytes_needed = 5 //for the survive objective

/datum/game_mode/cult/announce()
	world << "<B>The current game mode is - Cult!</B>"
	world << "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - complete your objectives. Convert crewmembers to your cause by using the convert rune. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with the chaplain's bible reverts them to whatever CentCom-allowed faith they had.</B>"

/datum/game_mode/cult/pre_setup()
	if(prob(50))
		objectives += "survive"
		objectives += "sacrifice"
	else
		objectives += "eldergod"
		objectives += "sacrifice"
	return 1

/datum/game_mode/cult/post_setup()

	var/list/cultists_possible = list()
	cultists_possible = get_possible_cultists()
	var/cultists_number = 0

	if(!cultists_possible)
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

	if("sacrifice" in objectives)
		var/list/possible_targets = get_unconvertables()

		if(!possible_targets.len)
			for(var/mob/living/carbon/human/player in world)
				if(player.mind && !cult.Find(player.mind))
					possible_targets += player.mind

		if(possible_targets.len > 0)
			sacrifice_target = pick(possible_targets)

	for(var/datum/mind/cult_mind in cult)
		equip_cultist(cult_mind.current)
		update_cult_icons_added(cult_mind)
		cult_mind.current << "\blue You are a member of the cult!"
		for(var/obj_count = 1,obj_count <= objectives.len,obj_count++)
			var/explanation
			switch(objectives[obj_count])
				if("survive")
					explanation = "Our knowledge must live on. Make sure at least [acolytes_needed] acolytes escape on the shuttle to spread their work on an another station."
				if("sacrifice")
					if(sacrifice_target)
						explanation = "Sacrifice [sacrifice_target.current.real_name], the [sacrifice_target.assigned_role]. You will need the sacrifice rune (Hell join blood) and three acolytes to do so."
					else
						explanation = "Free objective."
				if("eldergod")
					explanation = "Summon Nar-Sie via the use of an appropriate rune. It will only work if nine cultists stand on and around it."
			cult_mind.current << "<B>Objective #[obj_count]</B>: [explanation]"
			cult_mind.memory += "<B>Objective #[obj_count]</B>: [explanation]<BR>"
		cult_mind.current << "The convert rune is join blood self"
		cult_mind.memory += "The convert rune is join blood self<BR>"

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/cult/proc/equip_cultist(mob/living/carbon/human/cult_mob)
	if(!istype(cult_mob))
		return
	spawn (0)
		var/obj/item/weapon/paper/talisman/supply/T = null
		cult_mob.equip_if_possible(new /obj/item/weapon/storage/backpack(cult_mob), cult_mob.slot_back)
		cult_mob.equip_if_possible(new /obj/item/weapon/paper/talisman/supply(cult_mob), cult_mob.slot_in_backpack)
		sleep(10)
		if (!T && istype(cult_mob.back, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = cult_mob.back
			var/list/L = S.return_inv()
			for (var/obj/item/weapon/paper/talisman/supply/foo in L)
				T = foo
				break
		if (!T)
			cult_mob << "Unfortunately, you weren't able to get a talisman. This is very bad and you should adminhelp immediately. (still, check your backpack. it may have been a mere bug. if you have a piece of bloody paper, all is well)"
		else
			cult_mob << "You have a talisman in your backpack, one that will help you start the cult on this station. Use it well and remember - there are others."
		if(!wordtravel)
			runerandom()
		var/word=pick("1","2","3","4","5","6","7","8")
		var/wordexp
		switch(word)
			if("1")
				wordexp = "[wordtravel] is travel..."
			if("2")
				wordexp = "[wordblood] is blood..."
			if("3")
				wordexp = "[wordjoin] is join..."
			if("4")
				wordexp = "[wordhell] is Hell..."
			if("5")
				wordexp = "[worddestr] is destroy..."
			if("6")
				wordexp = "[wordtech] is technology..."
			if("7")
				wordexp = "[wordself] is self..."
			if("8")
				wordexp = "[wordsee] is see..."
		cult_mob << "\red You remembered one thing from the dark teachings of your master... [wordexp]"
		cult_mob.mind.store_memory("<B>You remember one thing</B>: [wordexp]", 0, 0)
		cultists.Add(cult_mob)

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

/datum/game_mode/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in world)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director", "Security Officer", "Detective", "AI", "Chaplain"))
				ucs += player.mind

	return ucs

/datum/game_mode/cult/proc/check_cult_victory()
	var/cult_fail = 0
	if(objectives.Find("survive"))
		cult_fail += check_survive() //the proc returns 1 if there are not enough cultists on the shuttle, 0 otherwise
	if(objectives.Find("eldergod"))
		cult_fail += eldergod //1 by default, 0 if the elder god has been summoned at least once
	if(objectives.Find("sacrifice"))
		if(!sacrificed.Find(sacrifice_target)) //if the target has been sacrificed, ignore this step. otherwise, add 1 to cult_fail
			cult_fail++

	return cult_fail //if any objectives aren't met, failure

/datum/game_mode/cult/proc/check_survive()
	var/acolytes_survived = 0
	var/area/shuttle = locate(/area/shuttle/escape/centcom)
	for(var/mob/living/carbon/human/C in world)
		if(get_turf(C) in shuttle && C.stat!=2 && cult.Find(C.mind))
			acolytes_survived++
	if(acolytes_survived>=acolytes_needed)
		return 0
	else
		return 1

/datum/game_mode/cult/declare_completion()

	var/text = ""
	if(!check_cult_victory())
		world << "\red <FONT size = 3><B> The cult wins! It has succeeded in serving its dark masters!</B></FONT>"
	else
		world << "\red <FONT size = 3><B> The staff managed to stop the cult!</B></FONT>"

	world << "<FONT size = 2><B>The cultists were: </B></FONT>"
	for(var/datum/mind/cult_nh_mind in cult)
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

	world << "The cultists' objectives were:"

	for(var/obj_count=1,obj_count <= objectives.len,obj_count++)
		var/explanation
		switch(objectives[obj_count])
			if("survive")
				if(!check_survive())
					explanation = "Make sure at least [acolytes_needed] acolytes escape on the shuttle. \green <b>Success!</b>"
				else
					explanation = "Make sure at least [acolytes_needed] acolytes escape on the shuttle. \red Failed."
			if("sacrifice")
				if(!sacrifice_target)
					explanation = "Free objective"
				else
					if(sacrificed.Find(sacrifice_target))
						explanation = "Sacrifice [sacrifice_target.current.real_name], the [sacrifice_target.assigned_role]. \green <b>Success!</b>"
					else
						explanation = "Sacrifice [sacrifice_target.current.real_name], the [sacrifice_target.assigned_role]. \red Failed."
			if("eldergod")
				if(!eldergod)
					explanation = "Summon Nar-Sie. \green <b>Success!</b>"
				else
					explanation = "Summon Nar-Sie. \red Failed."
		world << "<B>Objective #[obj_count]</B>: [explanation]"

	return 1