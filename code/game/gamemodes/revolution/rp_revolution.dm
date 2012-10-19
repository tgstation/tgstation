// BS12's less violent revolution mode

/datum/game_mode/revolution/rp_revolution
	name = "rp-revolution"
	config_tag = "rp-revolution"
	required_players = 12
	required_enemies = 3
	recommended_enemies = 3

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
			rev_obj.explanation_text = "Assassinate or capture [head_mind.name], the [head_mind.assigned_role]."
			rev_mind.objectives += rev_obj

		update_rev_icons_added(rev_mind)

	for(var/datum/mind/rev_mind in head_revolutionaries)
		greet_revolutionary(rev_mind)
		rev_mind.current.verbs += /mob/living/carbon/human/proc/RevConvert
	modePlayer += head_revolutionaries
	spawn (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/revolution/rp_revolution/greet_revolutionary(var/datum/mind/rev_mind, var/you_are=1)
	var/obj_count = 1
	if (you_are)
		rev_mind.current << "\blue You are a member of the revolutionaries' leadership!"
	for(var/datum/objective/objective in rev_mind.objectives)
		rev_mind.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		rev_mind.special_role = "Head Revolutionary"
		obj_count++

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
	rev_mind.current << "\red <FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill, capture or convert the heads to win the revolution!</FONT>"
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
			if(!rev_mind.current.handcuffed && T && T.z == 1)
				return 0
	return 1

///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/rp_revolution/announce()
	world << "<B>The current game mode is - Revolution!</B>"
	world << "<B>Some crewmembers are attempting to start a revolution!</B>"


//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/rp_revolution/declare_completion()
	if(finished == 1)
		feedback_set_details("round_end_result","win - heads overthrown")
		world << "\red <FONT size = 3><B> The heads of staff were overthrown! The revolutionaries win!</B></FONT>"
	else if(finished == 2)
		feedback_set_details("round_end_result","loss - revolution stopped")
		world << "\red <FONT size = 3><B> The heads of staff managed to stop the revolution!</B></FONT>"
	..()
	return 1

/datum/game_mode/revolution/proc/is_convertible(mob/M)
	for(var/obj/item/weapon/implant/loyalty/L in M)//Checking that there is a loyalty implant in the contents
		if(L.imp_in == M)//Checking that it's actually implanted
			return 0

	return 1

/mob/living/carbon/human/proc/RevConvert(mob/M as mob in oview(src))
	set name = "Rev-Convert"
	if(((src.mind in ticker.mode:head_revolutionaries) || (src.mind in ticker.mode:revolutionaries)))
		if((M.mind in ticker.mode:head_revolutionaries) || (M.mind in ticker.mode:revolutionaries))
			src << "\red <b>[M] is already be a revolutionary!</b>"
		else if(!ticker.mode:is_convertible(M))
			src << "\red <b>[M] is implanted with a loyalty implant - Remove it first!</b>"
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

/datum/game_mode/revolution/rp_revolution/process()
	// only perform rev checks once in a while
	if(tried_to_add_revheads < world.time)
		tried_to_add_revheads = world.time+50
		var/active_revs = 0
		for(var/datum/mind/rev_mind in head_revolutionaries)
			if(rev_mind.current.client && rev_mind.current.client.inactivity <= 10*60*20) // 20 minutes inactivity are OK
				active_revs++

		if(active_revs == 0)
			log_admin("There are zero active head revolutionists, trying to add some..")
			message_admins("There are zero active head revolutionists, trying to add some..")
			var/added_heads = 0
			for(var/mob/living/carbon/human/H in world) if(H.client && H.mind && H.client.inactivity <= 10*60*20 && H.mind in revolutionaries)
				head_revolutionaries += H.mind
				for(var/datum/mind/head_mind in heads)
					var/datum/objective/mutiny/rp/rev_obj = new
					rev_obj.owner = H.mind
					rev_obj.target = head_mind
					rev_obj.explanation_text = "Assassinate or capture [head_mind.name], the [head_mind.assigned_role]."
					H.mind.objectives += rev_obj

				update_rev_icons_added(H.mind)
				H.verbs += /mob/living/carbon/human/proc/RevConvert

				H << "\red Congratulations, yer heads of revolution are all gone now, so yer earned yourself a promotion."
				added_heads = 1
				break

			if(added_heads)
				log_admin("Managed to add new heads of revolution.")
				message_admins("Managed to add new heads of revolution.")
			else
				log_admin("Unable to add new heads of revolution.")
				message_admins("Unable to add new heads of revolution.")
				tried_to_add_revheads = world.time + 6000 // wait 10 minutes

	return ..()