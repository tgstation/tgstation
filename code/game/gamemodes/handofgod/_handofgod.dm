
var/global/list/global_handofgod_traptypes = list()
var/global/list/global_handofgod_structuretypes = list()

#define CONDUIT_RANGE	15


/datum/game_mode
	var/list/datum/mind/red_deities = list()
	var/list/datum/mind/red_deity_prophets = list()
	var/list/datum/mind/red_deity_followers = list()

	var/list/datum/mind/blue_deities = list()
	var/list/datum/mind/blue_deity_prophets = list()
	var/list/datum/mind/blue_deity_followers = list()

	var/list/datum/mind/unassigned_followers = list() //for roundstart team assigning
	var/list/datum/mind/assigned_to_red = list()
	var/list/datum/mind/assigned_to_blue = list()


/datum/game_mode/hand_of_god
	name = "hand of god"
	config_tag = "handofgod"
	antag_flag = ROLE_HOG_CULTIST		//Followers use ROLE_HOG_CULTIST, Gods are picked later on with ROLE_HOG_GOD

	required_players = 25
	required_enemies = 8
	recommended_enemies = 8
	restricted_jobs = list("Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")


/datum/game_mode/hand_of_god/announce()
	world << "<B>The current game mode is - Hand of God!</B>"
	world << "<B>Two cults are onboard the station, seeking to overthrow the other, and anyone who stands in their way.</B>"
	world << "<B>Followers</B> - Complete your deity's objectives. Convert crewmembers to your cause by using your deity's nexus. Remember - there is no you, there is only the cult."
	world << "<B>Prophets</B> - Command your cult by the will of your deity.  You are a high-value target, so be careful!"
	world << "<B>Personnel</B> - Do not let any cult succeed in its mission. Mindshield implants and holy water will revert them to neutral, hopefully nonviolent crew."


/////////////
//Pre setup//
/////////////

/datum/game_mode/hand_of_god/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	for(var/F in 1 to recommended_enemies)
		if(!antag_candidates.len)
			break
		var/datum/mind/follower = pick_n_take(antag_candidates)
		unassigned_followers += follower
		follower.restricted_roles = restricted_jobs
		log_game("[follower.key] (ckey) has been selected as a follower, however teams have not been decided yet.")

	while(unassigned_followers.len > (required_enemies / 2))
		var/datum/mind/chosen = pick_n_take(unassigned_followers)
		add_hog_follower(chosen,"red")

	while(unassigned_followers.len)
		var/datum/mind/chosen = pick_n_take(unassigned_followers)
		add_hog_follower(chosen,"blue")

	return 1


//////////////
//Post Setup//
//////////////

//Pick a follower to uplift into a god
/datum/game_mode/hand_of_god/post_setup()

	//Find viable red god
	var/list/red_god_possibilities = get_players_for_role(ROLE_HOG_GOD)
	red_god_possibilities &= red_deity_followers //followers only
	if(!red_god_possibilities.len) //No candidates? just pick any follower regardless of prefs
		red_god_possibilities = red_deity_followers

	//Make red god
	var/datum/mind/red_god = pick_n_take(red_god_possibilities)
	if(red_god)
		red_god.current.become_god("red")
		remove_hog_follower(red_god,0)
		add_god(red_god,"red")

	//Find viable blue god
	var/list/blue_god_possibilities = get_players_for_role(ROLE_HOG_GOD)
	blue_god_possibilities &= blue_deity_followers //followers only
	if(!blue_god_possibilities.len) //No candidates? just pick any follower regardless of prefs
		blue_god_possibilities = blue_deity_followers

	//Make blue god
	var/datum/mind/blue_god = pick_n_take(blue_god_possibilities)
	if(blue_god)
		blue_god.current.become_god("blue")
		remove_hog_follower(blue_god,0)
		add_god(blue_god,"blue")


	//Forge objectives
	//This is done here so that both gods exist
	if(red_god)
		ticker.mode.forge_deity_objectives(red_god)
	if(blue_god)
		ticker.mode.forge_deity_objectives(blue_god)


	..()

///////////////////
//Objective Procs//
///////////////////

/datum/game_mode/proc/forge_deity_objectives(datum/mind/deity)
	switch(rand(1,100))
		if(1 to 30)
			var/datum/objective/deicide/deicide = new
			deicide.owner = deity
			if(deicide.find_target())//Hard to kill the other god if there is none
				deity.objectives += deicide

			if(!(locate(/datum/objective/escape_followers) in deity.objectives))
				var/datum/objective/escape_followers/recruit = new
				recruit.owner = deity
				deity.objectives += recruit
				recruit.gen_amount_goal(8, 12)

		if(31 to 60)
			var/datum/objective/sacrifice_prophet/sacrifice = new
			sacrifice.owner = deity
			deity.objectives += sacrifice

			if(!(locate(/datum/objective/escape_followers) in deity.objectives))
				var/datum/objective/escape_followers/recruit = new
				recruit.owner = deity
				deity.objectives += recruit
				recruit.gen_amount_goal(8, 12)

		if(61 to 85)
			var/datum/objective/build/build = new
			build.owner = deity
			deity.objectives += build
			build.gen_amount_goal(8, 16)

			var/datum/objective/sacrifice_prophet/sacrifice = new
			sacrifice.owner = deity
			deity.objectives += sacrifice

			if(!(locate(/datum/objective/escape_followers) in deity.objectives))
				var/datum/objective/escape_followers/recruit = new
				recruit.owner = deity
				deity.objectives += recruit
				recruit.gen_amount_goal(8, 12)

		else
			if (!locate(/datum/objective/follower_block) in deity.objectives)
				var/datum/objective/follower_block/block = new
				block.owner = deity
				deity.objectives += block

///////////////
//Greet procs//
///////////////

/datum/game_mode/proc/greet_hog_follower(datum/mind/follower_mind,colour)
	if(follower_mind in blue_deity_prophets || follower_mind in red_deity_prophets)
		follower_mind.current << "<span class='danger'><B>You have been appointed as the prophet of the [colour] deity! You are the only one who can communicate with your deity at will. Guide your followers, but be wary, for many will want you dead.</span>"
	else if(colour)
		follower_mind.current << "<span class='danger'><B>You are a follower of the [colour] cult's deity!</span>"
	else
		follower_mind.current << "<span class='danger'><B>You are a follower of a cult's deity!</span>"


/////////////////
//Convert procs//
/////////////////

/datum/game_mode/proc/add_hog_follower(datum/mind/follower_mind, colour = "No Colour")
	var/mob/living/carbon/human/H = follower_mind.current
	if(isloyal(H))
		H << "<span class='danger'>Your mindshield implant blocked the influence of the [colour] deity. </span>"
		return 0
	if((follower_mind in red_deity_followers) || (follower_mind in red_deity_prophets) || (follower_mind in blue_deity_followers) || (follower_mind in blue_deity_prophets))
		H << "<span class='danger'>You already belong to a deity. Your strong faith has blocked out the conversion attempt by the followers of the [colour] deity.</span>"
		return 0
	var/obj/item/weapon/nullrod/N = H.null_rod_check()
	if(N)
		H << "<span class='danger'>Your holy weapon prevented the [colour] deity from brainwashing you.</span>"
		return 0

	if(colour == "red")
		red_deity_followers += follower_mind
	if(colour == "blue")
		blue_deity_followers += follower_mind

	H.faction |= "[colour] god"
	follower_mind.current << "<span class='danger'><FONT size = 3>You are now a follower of the [colour] deity! Follow your deity's prophet in order to complete your deity's objectives. Convert crewmembers to your cause by using your deity's nexus. And remember - there is no you, there is only the cult.</FONT></span>"
	update_hog_icons_added(follower_mind, colour)
	follower_mind.special_role = "Hand of God: [capitalize(colour)] Follower"
	follower_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been converted to the [colour] follower cult!</font>"
	return 1


/datum/game_mode/proc/add_god(datum/mind/god_mind, colour = "No Colour")
	remove_hog_follower(god_mind, announce = 0)
	if(colour == "red")
		red_deities += god_mind
	if(colour == "blue")
		blue_deities += god_mind
	god_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been made into a [colour] deity!</font>"
	god_mind.special_role = "Hand of God: [colour] God"
	update_hog_icons_added(god_mind, colour)

//////////////////
//Deconvert proc//
//////////////////

/datum/game_mode/proc/remove_hog_follower(datum/mind/follower_mind, announce = 1)//deconverts both
	follower_mind.remove_hog_follower_prophet()
	update_hog_icons_removed(follower_mind,"red")
	update_hog_icons_removed(follower_mind,"blue")

	if(follower_mind.current)
		var/mob/living/carbon/human/H = follower_mind.current
		H.faction -= "red god"
		H.faction -= "blue god"

	if(announce)
		follower_mind.current.attack_log += "\[[time_stamp()]\] <font color='red'>Has been deconverted from a deity's cult!</font>"
		follower_mind.current << "<span class='danger'><b>Your mind has been cleared from the brainwashing the followers have done to you.  Now you serve yourself and the crew.</b></span>"
		for(var/mob/living/M in view(follower_mind.current))
			M << "[follower_mind.current] looks like their faith is shattered. They're no longer a cultist!"



//////////////////////
// Mob helper procs //
//////////////////////

/proc/is_handofgod_god(A)
	if(istype(A, /mob/camera/god))
		return 1
	return 0


/proc/is_handofgod_bluecultist(A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.mind)
			if(H.mind in ticker.mode.blue_deity_followers|ticker.mode.blue_deity_prophets)
				return 1
	return 0


/proc/is_handofgod_redcultist(A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.mind)
			if(H.mind in ticker.mode.red_deity_followers|ticker.mode.red_deity_prophets)
				return 1
	return 0


/proc/is_handofgod_blueprophet(A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.mind)
			if(H.mind in ticker.mode.blue_deity_prophets)
				return 1
	return 0


/proc/is_handofgod_redprophet(A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.mind)
			if(H.mind in ticker.mode.red_deity_prophets)
				return 1
	return 0



/proc/is_handofgod_cultist(A) //any of them what so ever, blue, red, hot pink, whatever.
	if(is_handofgod_redcultist(A))
		return 1
	if(is_handofgod_bluecultist(A))
		return 1
	return 0


/proc/is_handofgod_prophet(A) //any of them what so ever, blue, red, hot pink, whatever
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.mind)
			if(H.mind in ticker.mode.blue_deity_prophets|ticker.mode.red_deity_prophets)
				return 1
	return 0


/mob/camera/god/proc/is_handofgod_myprophet(A)
	if(!ishuman(A))
		return 0
	var/mob/living/carbon/human/H = A
	if(!H.mind)
		return 0
	if(side == "red")
		if(H.mind in ticker.mode.red_deity_prophets)
			return 1
	else if(side == "blue")
		if(H.mind in ticker.mode.blue_deity_prophets)
			return 1


/mob/camera/god/proc/is_handofgod_myfollowers(mob/A)
	if(!ishuman(A))
		return 0
	var/mob/living/carbon/human/H = A
	if(!H.mind)
		return 0
	if(side == "red")
		if(H.mind in ticker.mode.red_deity_prophets|ticker.mode.red_deity_followers)
			return 1
	else if(side == "blue")
		if(H.mind in ticker.mode.blue_deity_prophets|ticker.mode.blue_deity_followers)
			return 1

//////////////////////
//Roundend Reporting//
//////////////////////


/datum/game_mode/hand_of_god/declare_completion()
	if(red_deities.len)
		var/text = "<BR><font size=3 color='red'><B>The red cult:</b></font>"
		for(var/datum/mind/red_god in red_deities)
			var/godwin = 1

			text += "<BR><B>[red_god.key]</B> was the red deity, <B>[red_god.name]</B> ("
			if(red_god.current)
				if(red_god.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
			else
				text += "ceased existing"
			text += ")"
			if(red_deity_prophets.len)
				for(var/datum/mind/red_prophet in red_deity_prophets)
					text += "<BR>The red prophet was <B>[red_prophet.name]</B> (<B>[red_prophet.key]</B>)"
			else
				text += "<BR>the red prophet was killed for their beliefs."

			text += "<BR><B>Red follower count: </B> [red_deity_followers.len]"
			text += "<BR><B>Red followers:</B> "
			for(var/datum/mind/player in red_deity_followers)
				text += "[player.name] ([player.key]), "

			var/objectives = ""
			if(red_god.objectives.len)
				var/count = 1
				for(var/datum/objective/O in red_god.objectives)
					if(O.check_completion())
						objectives += "<BR><B>Objective #[count]</B>: [O.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("god_objective","[O.type]|SUCCESS")
					else
						objectives += "<BR><B>Objective #[count]</B>: [O.explanation_text] <font color='red'><B>Fail.</B></font>"
						feedback_add_details("god_objective","[O.type]|FAIL")
						godwin = 0
					count++

			text += objectives

			if(godwin)
				text += "<BR><font color='green'><B>The red cult and deity were successful!</B></font>"
				feedback_add_details("god_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The red cult and deity have failed!</B></font>"
				feedback_add_details("god_success","FAIL")

			text += "<BR>"

		world << text

	if(blue_deities.len)
		var/text = "<BR><font size=3 color='red'><B>The blue cult:</b></font>"
		for(var/datum/mind/blue_god in blue_deities)
			var/godwin = 1

			text += "<BR><B>[blue_god.key]</B> was the blue deity, <B>[blue_god.name]</B> ("
			if(blue_god.current)
				if(blue_god.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
			else
				text += "ceased existing"
			text += ")"
			if(blue_deity_prophets.len)
				for(var/datum/mind/blue_prophet in blue_deity_prophets)
					text += "<BR>The blue prophet was <B>[blue_prophet.name]</B> (<B>[blue_prophet.key]</B>)"
			else
				text += "<BR>the blue prophet was killed for their beliefs."

			text += "<BR><B>Blue follower count: </B> [blue_deity_followers.len]"
			text += "<BR><B>Blue followers:</B> "
			for(var/datum/mind/player in blue_deity_followers)
				text += "[player.name] ([player.key])"

			var/objectives = ""
			if(blue_god.objectives.len)
				var/count = 1
				for(var/datum/objective/O in blue_god.objectives)
					if(O.check_completion())
						objectives += "<BR><B>Objective #[count]</B>: [O.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("god_objective","[O.type]|SUCCESS")
					else
						objectives += "<BR><B>Objective #[count]</B>: [O.explanation_text] <font color='red'><B>Fail.</B></font>"
						feedback_add_details("god_objective","[O.type]|FAIL")
						godwin = 0
					count++

			text += objectives

			if(godwin)
				text += "<BR><font color='green'><B>The blue cult and deity were successful!</B></font>"
				feedback_add_details("god_success","SUCCESS")
			else
				text += "<BR><font color='red'><B>The blue cult and deity have failed!</B></font>"
				feedback_add_details("god_success","FAIL")

			text += "<BR>"

		world << text

	..()
	return 1


/datum/game_mode/proc/update_hog_icons_added(datum/mind/hog_mind,side)
	var/hud_key
	var/rank = 0
	if(side == "red")
		hud_key = ANTAG_HUD_HOG_RED
		if(is_handofgod_redprophet(hog_mind.current))
			rank = 1

	else if(side == "blue")
		hud_key = ANTAG_HUD_HOG_BLUE
		if(is_handofgod_blueprophet(hog_mind.current))
			rank = 1

	if(is_handofgod_god(hog_mind.current))
		rank = 2

	if(hud_key)
		var/datum/atom_hud/antag/hog_hud = huds[hud_key]
		hog_hud.join_hud(hog_mind.current)
		set_antag_hud(hog_mind.current, "hog-[side]-[rank]")


/datum/game_mode/proc/update_hog_icons_removed(datum/mind/hog_mind,side)
	var/hud_key
	if(side == "red")
		hud_key = ANTAG_HUD_HOG_RED
	else if(side == "blue")
		hud_key = ANTAG_HUD_HOG_BLUE

	if(hud_key)
		var/datum/atom_hud/antag/hog_hud = huds[hud_key]
		hog_hud.leave_hud(hog_mind.current)
		set_antag_hud(hog_mind.current,null)
