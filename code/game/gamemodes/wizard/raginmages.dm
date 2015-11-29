/datum/game_mode/wizard/raginmages
	name = "Ragin' Mages"
	config_tag = "raginmages"
	required_players = 1
	required_players_secret = 15
	var/max_mages = 0
	var/making_mage = 0
	var/mages_made = 1
	var/time_checked = 0
	var/exhausted_pool = 0
	rage = 1

/datum/game_mode/wizard/announce()
	to_chat(world, "<B>The current game mode is - Ragin' Mages!</B>")
	to_chat(world, "<B>The <span class='danger'>Space Wizard Federation is pissed, help defeat all the space wizards!</span>")

/datum/game_mode/sandbox/pre_setup()
	log_admin("Starting a round of Ragin' Mages.")
	message_admins("Starting a round of Ragin' Mages.")
	return 1

/datum/game_mode/wizard/raginmages/post_setup()
	var/playercount = 0
	..()
	if(!max_mages)
		for(var/mob/living/player in mob_list)
			if (player.client && player.stat != 2)
				playercount += 1
			max_mages = round(playercount / 5)

/datum/game_mode/wizard/raginmages/greet_wizard(var/datum/mind/wizard, var/you_are=1)
	if (you_are)
		to_chat(wizard.current, "<span class='danger'>You are the Space Wizard!</span>")
	to_chat(wizard.current, "<B>The Space Wizards Federation has given you the following tasks:</B>")

	var/obj_count = 1
	to_chat(wizard.current, "<b>Objective Alpha</b>: Make sure the station pays for its actions against our diplomats")
	for(var/datum/objective/objective in wizard.objectives)
		to_chat(wizard.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	return

/datum/game_mode/wizard/raginmages/check_finished()
	var/wizards_alive = 0
	for(var/datum/mind/wizard in wizards)
		if(!istype(wizard.current,/mob/living/carbon))
			continue
		if(istype(wizard.current,/mob/living/carbon/brain))
			continue
		if(wizard.current.stat == DEAD)
			continue
		if(wizard.current.stat == UNCONSCIOUS)
			if(wizard.current.health < 0)
				to_chat(wizard.current, "<span class='warning'><font size='4'>The Space Wizard Federation is upset with your performance and have terminated your employment.</font></span>")
				wizard.current.stat = DEAD
				continue
		wizards_alive++

	if (wizards_alive)
		if(!time_checked) time_checked = world.time
		if(world.time > time_checked + 12000 && (mages_made < max_mages))
			time_checked = world.time
			make_more_mages()
	else
		if(!making_mage && (wizards.len >= max_mages || exhausted_pool >= 5))
			finished = 1
			return 1
		else
			make_more_mages()
			return 0
	return ..() // Check for shuttle and nuke.

/datum/game_mode/wizard/raginmages/proc/make_more_mages()


	if(making_mage || emergency_shuttle.departed)
		return 0
	if(mages_made >= max_mages)
		return 0
	making_mage = 1
	mages_made++
	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	spawn(rand(200, 600))
		message_admins("SWF is still pissed, sending another wizard - [max_mages - mages_made] left.")
		for(var/mob/dead/observer/G in get_active_candidates(ROLE_WIZARD, poll="Do you wish to be considered for the position of Space Wizard Foundation 'diplomat'?"))
			if(G.client && !G.client.holder && !jobban_isbanned(G, "wizard") && !jobban_isbanned(G, "Syndicate"))
				if(G.mind && G.mind.isScrying)
					if(G.mind.current.stat < DEAD || !iscarbon(G.mind.current) || isbrain(G.mind.current))
						continue
				candidates += G
		if(!candidates.len)
			message_admins("No candidates found, sleeping until another mage check...")
			exhausted_pool++
			making_mage = 0
			mages_made--
			return
		else
			exhausted_pool = 0
			shuffle(candidates)
			for(var/mob/i in candidates)
				if(!i || !i.client) continue //Dont bother removing them from the list since we only grab one wizard

				theghost = i
				break

		if(theghost)
			var/mob/living/carbon/human/new_character= makeBody(theghost)
			new_character.mind.make_Wizard()
			new_character.dna.ResetSE() //Manually cleaning this antag as he isn't caught by the gameticker
			making_mage = 0
			return 1

/datum/game_mode/wizard/raginmages/declare_completion()
	if(finished)
		feedback_set_details("round_end_result","loss - wizard killed")
		to_chat(world, "<span class='danger'><FONT size = 3> The crew has managed to hold off the wizard attack! The Space Wizards Federation has been taught a lesson they will not soon forget!</FONT></span>")
	..(1)