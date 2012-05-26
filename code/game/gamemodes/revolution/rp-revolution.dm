// To add a rev to the list of revolutionaries, make sure it's rev (with if(ticker.mode.name == "revolution)),
// then call ticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call ticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the rev icons start going wrong for some reason, ticker.mode:update_all_rev_icons() can be called to correct them.
// If the game somtimes isn't registering a win properly, then ticker.mode.check_win() isn't being called somewhere.
#define RPREV_REQUIRE_REVS_ALIVE 0
#define RPREV_REQUIRE_HEADS_ALIVE 0

/datum/game_mode/rp_revolution
	name = "rp-revolution"
	config_tag = "rp-revolution"

	var/finished = 0
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)
	var/all_brigged = 0
	var/brigged_time = 0

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10


/datum/game_mode/rp_revolution/announce()
	world << "<B>The current game mode is - Revolution RP!</B>"

/datum/game_mode/rp_revolution/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested staus information:</FONT><HR>"
	intercepttext += "<B> Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "traitor", "malf")
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))
	possible_modes.Insert(rand(possible_modes.len), "nuke")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, pick(head_revolutionaries))

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper - 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")

/datum/game_mode/rp_revolution/post_setup()

	var/list/revs_possible = list()
	revs_possible = get_possible_revolutionaries()
	var/list/heads = list()
	heads = get_living_heads()
	var/rev_number = 0

	if(!revs_possible || !heads)
		world << "<B> \red Not enough players for RP revolution game mode. Restarting world in 5 seconds."
		sleep(50)
		world.Reboot()
		return

	if(revs_possible.len >= 3)
		rev_number = 3
	else
		rev_number = revs_possible.len

	while(rev_number > 0)
		head_revolutionaries += pick(revs_possible - head_revolutionaries)
		rev_number--

	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/mind/head_mind in heads)
			var/datum/objective/capture/rev_obj = new
			rev_obj.owner = rev_mind
			rev_obj.find_target_by_role(head_mind.assigned_role)
			rev_mind.objectives += rev_obj
		equip_revolutionary(rev_mind.current)
		rev_mind.current.verbs += /mob/living/carbon/human/proc/RevConvert
		update_rev_icons_added(rev_mind)

	for(var/datum/mind/rev_mind in head_revolutionaries)
		var/obj_count = 1
		rev_mind.current << "\blue You are a member of the revolutionaries' leadership!"
		for(var/datum/objective/objective in rev_mind.objectives)
			rev_mind.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/rp_revolution/send_intercept()
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
			intercept.name = "paper - 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")

	spawn(54000)
		command_alert("Summary downloaded and printed out at all communications consoles.", "The revolution leaders have been determined.")
		intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested status information:</FONT><HR>"
		intercepttext += "We have determined the revolution leaders to be:"
		for(var/datum/mind/revmind in head_revolutionaries)
			intercepttext += "<br>[revmind.current.real_name]"
		intercepttext += "<br>Please arrest them at once."
		for (var/obj/machinery/computer/communications/comm in world)
			if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
				var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
				intercept.name = "paper - 'Cent. Com. Status Summary'"
				intercept.info = intercepttext

				comm.messagetitle.Add("Cent. Com. Status Summary")
				comm.messagetext.Add(intercepttext)
		spawn(12000)
			command_alert("Repeating the previous message over intercoms due to urgency. The station has enemy operatives onboard by the names of [reveal_rev_heads()], please arrest them at once.", "The revolution leaders have been determined.")


/datum/game_mode/rp_revolution/proc/reveal_rev_heads()
	. = ""
	for(var/i = 1, i <= head_revolutionaries.len,i++)
		var/datum/mind/revmind = head_revolutionaries[i]
		if(i < head_revolutionaries.len)
			. += "[revmind.current.real_name],"
		else
			. += "and [revmind.current.real_name]"

///datum/game_mode/rp_revolution/proc/equip_revolutionary(mob/living/carbon/human/rev_mob)
//	if(!istype(rev_mob))
//		return

//	spawn (100)
//		if (rev_mob.r_store)
//			rev_mob.equip_if_possible(new /obj/item/weapon/paper/communist_manifesto(rev_mob), rev_mob.slot_l_store)
//		if (rev_mob.l_store)
//			rev_mob.equip_if_possible(new /obj/item/weapon/paper/communist_manifesto(rev_mob), rev_mob.slot_r_store)


/datum/game_mode/rp_revolution/check_win()
	if(check_rev_victory())
		finished = 1
	else if(check_heads_victory())
		finished = 2
	return

/datum/game_mode/rp_revolution/check_finished()
	if(finished != 0)
		return 1
	else
		return 0

/datum/game_mode/rp_revolution/proc/get_possible_revolutionaries()
	var/list/candidates = list()

	for(var/mob/living/carbon/human/player in world)
		if(player.client)
			if(player.client.be_syndicate & BE_REV)
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

/datum/game_mode/rp_revolution/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in world)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director", "Security Officer", "Forensic Technician", "AI"))
				ucs += player.mind

	return ucs

/datum/game_mode/rp_revolution/proc/check_rev_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/objective/objective in rev_mind.objectives)
			if(!(objective.check_completion()))
				return 0

		return 1

/datum/game_mode/rp_revolution/proc/check_heads_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		if(rev_mind.current.stat != 2)
			var/turf/revloc = rev_mind.current.loc
			if(!istype(revloc.loc,/area/security/brig) && !rev_mind.current.handcuffed)
				return 0
		else if(RPREV_REQUIRE_REVS_ALIVE) return 0
	return 1

/datum/game_mode/rp_revolution/declare_completion()

	var/text = ""
	if(finished == 1)
		world << "\red <FONT size = 3><B> The heads of staff were relieved of their posts! The revolutionaries win!</B></FONT>"
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


/*obj/item/weapon/paper/communist_manifesto
	name = "Communist Manifesto"
	icon = 'books.dmi'
	icon_state = "redcommunist"
	info = "Supporters of the Revolution:<br><br>"
	attack(mob/living/carbon/M as mob, mob/user as mob)
		if(user.mind in ticker.mode:head_revolutionaries)
			if(RevConvert(M,user))
				for(var/mob/O in viewers(user, null))
					O.show_message(text("\red [] converts [] with the Communist Manifesto!", user, M))
				info += "[M.real_name]<br>"
			else
				for(var/mob/O in viewers(user, null))
					O.show_message(text("\red [] fails to convert [] with the Communist Manifesto!", user, M))
		else
			usr << "\red You are completely confounded as to the operation of this tome."
		return

proc/RevConvert(mob/living/carbon/M,mob/user)
	if(!istype(M)) return 0
	if((M.mind in ticker.mode:head_revolutionaries) || (M.mind in ticker.mode:revolutionaries))
		user << "\red <b>[M] is already a revolutionary!</b>"
		return 0
	else if(M.mind in ticker.mode:get_unconvertables())
		user << "\red <b>[M] cannot be a revolutionary!</b>"
		return 0
	else
		if(world.time < M.mind.rev_cooldown)
			user << "\red Wait five seconds before reconversion attempt."
			return 0
		user << "\red Attempting to convert [M]..."
		var/choice = alert(M,"Asked by [user]: Do you want to join the revolution?","Align Thyself with the Revolution!","No!","Yes!")
		if(choice == "Yes!")
			ticker.mode:add_revolutionary(M.mind)
			user << "\blue <b>[M] joins the revolution!</b>"
			. = 1
		else if(choice == "No!")
			user << "\red <b>[M] does not support the revolution!</b>"
			. = 0
		M.mind.rev_cooldown = world.time+50*/

mob/living/carbon/human/proc
	RevConvert(mob/M as mob in oview(src))
		set name = "Rev-Convert"
		if(((src.mind in ticker.mode:head_revolutionaries) || (src.mind in ticker.mode:revolutionaries)))
			if((M.mind in ticker.mode:head_revolutionaries) || (M.mind in ticker.mode:revolutionaries))
				src << "\red <b>[M] is already be a revolutionary!</b>"
			else if(src.mind in ticker.mode:get_unconvertables())
				src << "\red <b>[M] cannot be a revolutionary!</b>"
			else
				if(world.time < M.mind.rev_cooldown)
					src << "\red Wait five seconds before reconversion attempt."
					return
				src << "\red Attempting to convert [M]..."
				log_admin("[src]([src.ckey]) attempted to convert [M].")
				message_admins("\red [src]([src.ckey]) attempted to convert [M].")
				var/choice = alert(M,"Asked by [src]: Do you want to join the revolution?","Align Thyself with the Revolution!","No!","Yes!")
				if(choice == "Yes!")
					ticker.mode:add_revolutionary(M.mind)
					M << "\blue You join the revolution!"
					src << "\blue <b>[M] joins the revolution!</b>"
				else if(choice == "No!")
					M << "\red You reject this traitorous cause!"
					src << "\red <b>[M] does not support the revolution!</b>"
				M.mind.rev_cooldown = world.time+50