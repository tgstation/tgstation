// BS12's less violent revolution mode

/datum/game_mode/revolution/rp_revolution
	name = "rp-revolution"
	config_tag = "rp-revolution"
	required_players = 4
	required_players_secret = 12
	required_enemies = 3
	recommended_enemies = 3

	uplink_welcome = "Revolutionary Uplink Console:"
	uplink_uses = 5

	newscaster_announcements = /datum/news_announcement/revolution_inciting_event

	var/last_command_report = 0
	var/list/heads = list()
	var/tried_to_add_revheads = 0

///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/rp_revolution/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/num_players = num_players()
	max_headrevs = max(num_players / 4, 3)
	recommended_enemies = max_headrevs

	var/list/datum/mind/possible_headrevs = get_players_for_role(BE_REV)

	var/head_check = 0
	for(var/mob/new_player/player in player_list)
		if(player.mind.assigned_role in command_positions)
			head_check = 1
			break

	for(var/datum/mind/player in possible_headrevs)
		for(var/job in restricted_jobs)//Removing heads and such from the list
			if(player.assigned_role == job)
				possible_headrevs -= player

	for (var/i=1 to max_headrevs)
		if (possible_headrevs.len==0)
			break
		var/datum/mind/lenin = pick(possible_headrevs)
		possible_headrevs -= lenin
		head_revolutionaries += lenin

	if((head_revolutionaries.len==0)||(!head_check))
		return 0

	return 1


/datum/game_mode/revolution/rp_revolution/post_setup()
	heads = get_living_heads()

	for(var/datum/mind/rev_mind in head_revolutionaries)
		for(var/datum/mind/head_mind in heads)
			var/datum/objective/mutiny/rp/rev_obj = new
			rev_obj.owner = rev_mind
			rev_obj.target = head_mind
			rev_obj.explanation_text = "Assassinate, convert or capture [head_mind.name], the [head_mind.assigned_role]."
			rev_mind.objectives += rev_obj

		update_rev_icons_added(rev_mind)

	for(var/datum/mind/rev_mind in head_revolutionaries)
		greet_revolutionary(rev_mind)
		rev_mind.current.verbs += /mob/living/carbon/human/proc/RevConvert
		equip_traitor(rev_mind.current, 1) //changing how revs get assigned their uplink so they can get PDA uplinks. --NEO

	modePlayer += head_revolutionaries
	spawn (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/revolution/rp_revolution/greet_revolutionary(var/datum/mind/rev_mind, var/you_are=1)
	var/obj_count = 1
	if (you_are)
		to_chat(rev_mind.current, "<span class='notice'>You are a member of the revolutionaries' leadership!</span>")
	for(var/datum/objective/objective in rev_mind.objectives)
		to_chat(rev_mind.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		rev_mind.special_role = "Head Revolutionary"
		obj_count++

	// Show each head revolutionary up to 3 candidates
	var/list/already_considered = list()
	for(var/i = 0, i < 2, i++)
		var/mob/rev_mob = rev_mind.current
		already_considered += rev_mob
		// Tell them about people they might want to contact.
		var/mob/living/carbon/human/M = get_nt_opposed()
		if(M && !(M.mind in head_revolutionaries) && !(M in already_considered))
			to_chat(rev_mob, "We have received credible reports that [M.real_name] might be willing to help our cause. If you need assistance, consider contacting them.")
			rev_mob.mind.store_memory("<b>Potential Collaborator</b>: [M.real_name]")

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////
/datum/game_mode/revolution/rp_revolution/add_revolutionary(datum/mind/rev_mind)
	// overwrite this func to make it so even heads can be converted
	var/mob/living/carbon/human/H = rev_mind.current//Check to see if the potential rev is implanted
	if(!is_convertible(H))
		return 0
	if((rev_mind in revolutionaries) || (rev_mind in head_revolutionaries))
		return 0
	revolutionaries += rev_mind
	to_chat(rev_mind.current, "<span class='warning'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill, capture or convert the heads to win the revolution!</FONT></span>")
	rev_mind.special_role = "Revolutionary"
	update_rev_icons_added(rev_mind)
	return 1

/////////////////////////////
//Checks for a head victory//
/////////////////////////////
/datum/game_mode/revolution/rp_revolution/check_heads_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		var/turf/T = get_turf(rev_mind.current)
		if(rev_mind.current.stat != 2)
			// TODO: add a similar check that also checks whether they're without ID in the brig..
			//       probably wanna export this stuff into a separate function for use by both
			//       revs and heads
			//assume that only carbon mobs can become rev heads for now
			if(!rev_mind.current:handcuffed && T && T.z == 1)
				return 0
	return 1

///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/rp_revolution/announce()
	to_chat(world, "<B>The current game mode is - Revolution!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a revolution!</B>")


//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/rp_revolution/declare_completion()
	if(finished == 1)
		feedback_set_details("round_end_result","win - heads overthrown")
		to_chat(world, "<span class='danger'><FONT size = 3> The heads of staff were overthrown! The revolutionaries win!</FONT></span>")
	else if(finished == 2)
		feedback_set_details("round_end_result","loss - revolution stopped")
		to_chat(world, "<span class='danger'><FONT size = 3> The heads of staff managed to stop the revolution!</FONT></span>")
	..()
	return 1

/datum/game_mode/revolution/proc/is_convertible(mob/M)
	for(var/obj/item/weapon/implant/loyalty/L in M)//Checking that there is a loyalty implant in the contents
		if(L.imp_in == M)//Checking that it's actually implanted
			return 0

	return 1

/mob/living/carbon/human/proc/RevConvert(mob/M as mob in oview(src))
	set name = "Rev-Convert"
	set category = "IC"
	if(((src.mind in ticker.mode:head_revolutionaries) || (src.mind in ticker.mode:revolutionaries)))
		if((M.mind in ticker.mode:head_revolutionaries) || (M.mind in ticker.mode:revolutionaries))
			to_chat(src, "<span class='danger'>[M] is already be a revolutionary!</span>")
		else if(!ticker.mode:is_convertible(M))
			to_chat(src, "<span class='danger'>[M] is implanted with a loyalty implant - Remove it first!</span>")
		else
			if(world.time < M.mind.rev_cooldown)
				to_chat(src, "<span class='warning'>Wait five seconds before reconversion attempt.</span>")
				return
			to_chat(src, "<span class='warning'>Attempting to convert [M]...</span>")
			log_admin("[src]([src.ckey]) attempted to convert [M].")
			message_admins("<span class='warning'>[src]([src.ckey]) attempted to convert [M].</span>")
			var/choice = alert(M,"Asked by [src]: Do you want to join the revolution?","Align Thyself with the Revolution!","No!","Yes!")
			if(choice == "Yes!")
				ticker.mode:add_revolutionary(M.mind)
				to_chat(M, "<span class='notice'>You join the revolution!</span>")
				to_chat(src, "<span class='notice'><b>[M] joins the revolution!</b></span>")
			else if(choice == "No!")
				to_chat(M, "<span class='warning'>You reject this traitorous cause!</span>")
				to_chat(src, "<span class='danger'>[M] does not support the revolution!</span>")
			M.mind.rev_cooldown = world.time+50

/datum/game_mode/revolution/rp_revolution/process()
	// only perform rev checks once in a while
	if(tried_to_add_revheads < world.time)
		tried_to_add_revheads = world.time+50
		var/active_revs = 0
		for(var/datum/mind/rev_mind in head_revolutionaries)
			if(rev_mind.current.client && rev_mind.current.client.inactivity <= 10*60*20) // 20 minutes inactivity are OK
				active_revs++

		if(active_revs == 0)
			log_debug("There are zero active heads of revolution, trying to add some..")
			var/added_heads = 0
			for(var/mob/living/carbon/human/H in mob_list) if(H.client && H.mind && H.client.inactivity <= 10*60*20 && H.mind in revolutionaries)
				head_revolutionaries += H.mind
				for(var/datum/mind/head_mind in heads)
					var/datum/objective/mutiny/rp/rev_obj = new
					rev_obj.owner = H.mind
					rev_obj.target = head_mind
					rev_obj.explanation_text = "Assassinate or capture [head_mind.name], the [head_mind.assigned_role]."
					H.mind.objectives += rev_obj

				update_rev_icons_added(H.mind)
				H.verbs += /mob/living/carbon/human/proc/RevConvert

				to_chat(H, "<span class='warning'>Congratulations, yer heads of revolution are all gone now, so yer earned yourself a promotion.</span>")
				added_heads = 1
				break

			if(added_heads)
				log_admin("Managed to add new heads of revolution.")
				message_admins("Managed to add new heads of revolution.")
			else
				log_admin("Unable to add new heads of revolution.")
				message_admins("Unable to add new heads of revolution.")
				tried_to_add_revheads = world.time + 6000 // wait 10 minutes

	if(last_command_report == 0 && world.time >= 10 * 60 * 10)
		src.command_report("We are regrettably announcing that your performance has been disappointing, and we are thus forced to cut down on financial support to your station. To achieve this, the pay of all personnal, except the Heads of Staff, has been halved.")
		last_command_report = 1
	else if(last_command_report == 1 && world.time >= 10 * 60 * 30)
		src.command_report("Statistics hint that a high amount of leisure time, and associated activities, are responsible for the poor performance of many of our stations. You are to bolt and close down any leisure facilities, such as the holodeck, the theatre and the bar. Food can be distributed through vendors and the kitchen.")
		last_command_report = 2
	else if(last_command_report == 2 && world.time >= 10 * 60 * 60)
		src.command_report("It is reported that merely closing down leisure facilities has not been successful. You and your Heads of Staff are to ensure that all crew are working hard, and not wasting time or energy. Any crew caught off duty without leave from their Head of Staff are to be warned, and on repeated offence, to be brigged until the next transfer shuttle arrives, which will take them to facilities where they can be of more use.")
		last_command_report = 3

	return ..()

/datum/game_mode/revolution/rp_revolution/proc/command_report(message)
	for (var/obj/machinery/computer/communications/comm in machines)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Announcement'"
			intercept.info = message

			comm.messagetitle.Add("Cent. Com. Announcement")
			comm.messagetext.Add(message)
	to_chat(world, sound('sound/AI/commandreport.ogg'))

/datum/game_mode/revolution/rp_revolution/latespawn(mob/M)
	if(M.mind.assigned_role in command_positions)
		log_debug("Adding head kill/capture/convert objective for [M.name]")
		heads += M

		for(var/datum/mind/rev_mind in head_revolutionaries)
			var/datum/objective/mutiny/rp/rev_obj = new
			rev_obj.owner = rev_mind
			rev_obj.target = M.mind
			rev_obj.explanation_text = "Assassinate, convert or capture [M.real_name], the [M.mind.assigned_role]."
			rev_mind.objectives += rev_obj
			to_chat(rev_mind.current, "<span class='warning'>A new Head of Staff, [M.real_name], the [M.mind.assigned_role] has appeared. Your objectives have been updated.</span>")
