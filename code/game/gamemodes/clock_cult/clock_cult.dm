/*

CLOCKWORK CULT: Based off of the failed pull requests from vgstation

While Nar-Sie is the oldest and most prominent of the elder gods, there are other forces at work in the universe.
Ratvar, the Clockwork Justiciar, a homage to Nar-Sie granted sentience by its own power, is one such other force.
Imprisoned within a massive construct known as the Celestial Derelict - or Reebe - an intense hatred of the Blood God festers.
Ratvar, unable to act in the mortal plane, seeks to return and forms covenants with mortals in order to bolster his influence.
Due to his mechanical nature, Ratvar is also capable of influencing silicon-based lifeforms, unlike Nar-Sie, who can only influence natural life.

This is a team-based gamemode.

There are three possible objectives the Enlightened - Ratvar's minions - can have:
	1. Ensure X amount of Enlightened escape the station through the shuttle or otherwise.
	2. Convert all silicon lifeforms on the station to Ratvar's cause.
	3. Summon Ratvar via construction of a Gateway.

The clockwork version of an arcane tome is the clockwork slab.
While it can perform certain actions, it consumes a resource called components.
Components, which are fallen fragments of Ratvar's body as he rusts in Reebe, are powerful and have various effects.
Game-wise, clockwork slabs will generate components over time, with more powerful components being slower.

This file's folder contains:
	__clock_defines.dm: Defined variables
	clock_cult.dm: Core gamemode files.
	clock_mobs.dm: Hostile and benign clockwork creatures.
	clock_items.dm: Items
	clock_structures.dm: Structures and effects
	clock_ratvar.dm: The Ark of the Clockwork Justiciar and Ratvar himself. Important enough to have his own file.
	clock_scripture.dm: Scripture and rites.
	clock_unsorted.dm: Anything else with no place to be

*/

///////////
// PROCS //
///////////

/proc/is_servant_of_ratvar(mob/living/M)
	return M && istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.servants_of_ratvar)

/proc/is_eligible_servant(mob/living/M)
	if(!istype(M))
		return 0
	if(!M.mind)
		return 0
	if(ishuman(M) && (M.mind.assigned_role in list("Captain", "Chaplain")))
		return 0
	if(iscultist(M))
		return 0
	if(isconstruct(M))
		return 0
	if(isguardian(M))
		var/mob/living/simple_animal/hostile/guardian/G = M
		if(!is_servant_of_ratvar(G.summoner))
			return 0 //can't convert it unless the owner is converted
	if(isloyal(M))
		return 0
	if(M.mind.enslaved_to)
		return 0
	if(isdrone(M))
		return 0
	return 1

/proc/add_servant_of_ratvar(mob/M, silent = FALSE)
	if(is_servant_of_ratvar(M) || !ticker || !ticker.mode)
		return 0
	if(iscarbon(M))
		if(!silent)
			M << "<span class='heavy_brass'>Your mind is racing! Your body feels incredibly light! Your world glows a brilliant yellow! All at once it comes to you. Ratvar, the Clockwork \
			Justiciar, lies in exile, derelict and forgotten in an unseen realm.</span>"
	else if(issilicon(M))
		if(!silent)
			M << "<span class='heavy_brass'>You are unable to compute this truth. Your vision glows a brilliant yellow, and all at once it comes to you. Ratvar, the Clockwork Justiciar, lies in \
			exile, derelict and forgotten in an unseen realm.</span>"
		if(!is_eligible_servant(M))
			if(!M.stat)
				M.visible_message("<span class='warning'>[M] whirs as it resists an outside influence!</span>")
			M << "<span class='warning'><b>Corrupt data purged. Resetting cortex chip to factory defaults... complete.</b></span>" //silicons have a custom fail message
			return 0
	else if(istype(M, /mob/living/simple_animal/drone))
		if(!silent)
			M << "<span class='heavy_brass'>You must not involve yourself in other affairs, but... this one... you see it all. Your world glows a brilliant yellow, and all it once it comes to you. \
			Ratvar, the Clockwork Justiciar, lies derelict and forgotten in an unseen realm.</span>"
		var/mob/living/simple_animal/drone/D = M
		D.update_drone_hack(TRUE, TRUE)
		D.languages |= HUMAN
	else if(!silent)
		M << "<span class='heavy_brass'>Your world glows a brilliant yellow! All at once it comes to you. Ratvar, the Clockwork Justiciar, lies in exile, derelict and forgotten in an unseen realm.</span>"

	if(!is_eligible_servant(M))
		if(!silent && !M.stat)
			M.visible_message("<span class='warning'>[M] seems to resist an unseen force!</span>")
		M << "<span class='warning'><b>And yet, you somehow push it all away.</b></span>"
		return 0

	if(!silent)
		M.visible_message("<span class='heavy_brass'>[M]'s eyes glow a blazing yellow!</span>", \
		"<span class='heavy_brass'>Assist your new companions in their righteous efforts. Your goal is theirs, and theirs yours. You serve the Clockwork Justiciar above all else. Perform his every \
		whim without hesitation.</span>")
	ticker.mode.servants_of_ratvar += M.mind
	ticker.mode.update_servant_icons_added(M.mind)
	M.mind.special_role = "Servant of Ratvar"
	all_clockwork_mobs += M
	if(issilicon(M))
		var/mob/living/silicon/S = M
		if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			R.UnlinkSelf()
			R.emagged = 1
			R << "<span class='warning'><b>You have been desynced from your master AI. In addition, your onboard camera is no longer active and your safeties have been disabled.</b></span>"
		S.laws = new/datum/ai_laws/ratvar
		S.laws.associate(S)
		S.update_icons()
		S.show_laws()
	if(istype(ticker.mode, /datum/game_mode/clockwork_cult))
		var/datum/game_mode/clockwork_cult/C = ticker.mode
		C.present_tasks(M) //Memorize the objectives
	return 1

/proc/remove_servant_of_ratvar(mob/living/M, silent = FALSE)
	if(!is_servant_of_ratvar(M)) //In this way, is_servant_of_ratvar() checks the existence of ticker and minds
		return 0
	if(!silent)
		M.visible_message("<span class='big'>[M] seems to have remembered their true allegiance!</span>", \
		"<span class='userdanger'>A cold, cold darkness flows through your mind, extinguishing the Justiciar's light and all of your memories as his servant.</span>")
	ticker.mode.servants_of_ratvar -= M.mind
	ticker.mode.update_servant_icons_removed(M.mind)
	all_clockwork_mobs -= M
	M.mind.memory = "" //Not sure if there's a better way to do this
	M.mind.special_role = null
	for(var/datum/action/innate/function_call/F in M.actions) //Removes any bound Ratvarian spears
		qdel(F)
	if(issilicon(M))
		var/mob/living/silicon/S = M
		if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			R.emagged = initial(R.emagged)
			R << "<span class='warning'>Despite your freedom from Ratvar's influence, you are still irreparably damaged and no longer possess certain functions such as AI linking.</span>"
		S.make_laws()
		S.update_icons()
		S.show_laws()
	return 1

/proc/send_hierophant_message(mob/user, message, large)
	if(!user || !message || !ticker || !ticker.mode)
		return 0
	var/parsed_message = "<span class='[large ? "big_brass":"heavy_brass"]'>Servant [user.name == user.real_name ? user.name : "[user.real_name] (as [user.name])"]: </span><span class='[large ? "large_brass":"brass"]'>\"[message]\"</span>"
	for(var/M in mob_list)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, user)
			M << "[link] [parsed_message]"
		else if(is_servant_of_ratvar(M))
			M << parsed_message
	return 1

///////////////
// GAME MODE //
///////////////

/datum/game_mode
	var/list/servants_of_ratvar = list() //The Enlightened servants of Ratvar
	var/required_escapees = 0 //How many servants need to escape, if applicable
	var/required_silicon_converts = 0 //How many robotic lifeforms need to be converted, if applicable
	var/clockwork_objective = "escape" //The objective that the servants must fulfill
	var/clockwork_explanation = "Ensure that the meme levels of the station remain high." //The description of the current objective

/datum/game_mode/clockwork_cult
	name = "clockwork cult"
	config_tag = "clockwork_cult"
	antag_flag = ROLE_SERVANT_OF_RATVAR
	required_players = 30
	required_enemies = 2
	recommended_enemies = 4
	enemy_minimum_age = 14
	protected_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain") //Silicons can eventually be converted
	restricted_jobs = list("Chaplain", "Captain")
	var/servants_to_serve = list()

/datum/game_mode/clockwork_cult/announce()
	world << "<b>The game mode is: Clockwork Cult!</b>"
	world << "<b><span class='brass'>Ratvar</span>, the Clockwork Justiciar, has formed a covenant of Enlightened aboard [station_name()].</b>"
	world << "<b><span class='brass'>Enlightened</span>: Serve your master so that his influence might grow.</b>"
	world << "<b><span class='boldannounce'>Crew</span>: Prevent the servants of Ratvar from taking over the station.</b>"

/datum/game_mode/clockwork_cult/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs
	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"
	var/starter_servants = max(1, round(num_players() / 10)) //Guaranteed one cultist - otherwise, about one cultist for every ten players
	while(starter_servants)
		var/datum/mind/servant = pick(antag_candidates)
		servants_to_serve += servant
		antag_candidates -= servant
		modePlayer += servant
		servant.special_role = "Servant of Ratvar"
		servant.restricted_roles = restricted_jobs
		starter_servants--
	return 1

/datum/game_mode/clockwork_cult/post_setup()
	forge_clock_objectives()
	for(var/S in servants_to_serve)
		var/datum/mind/servant = S
		log_game("[servant.key] was made an initial servant of Ratvar")
		var/mob/living/L = servant.current
		greet_servant(L)
		equip_servant(L)
		add_servant_of_ratvar(L, TRUE)
	..()
	return 1

/datum/game_mode/clockwork_cult/proc/forge_clock_objectives() //Determine what objective that Ratvar's servants will fulfill
	var/list/possible_objectives = list("escape", "gateway")
	var/silicons_possible = FALSE
	for(var/mob/living/silicon/S in living_mob_list)
		silicons_possible = TRUE
	if(silicons_possible)
		possible_objectives += "silicons"
	clockwork_objective = pick(possible_objectives)
	clockwork_objective = "gateway" //TEMPORARY, to be removed before merge
	switch(clockwork_objective)
		if("escape")
			required_escapees = max(1, num_players() / 3) //33% of the player count must be cultists
			clockwork_explanation = "Ensure that [required_escapees] servant(s) of Ratvar escape from [station_name()]."
		if("gateway")
			clockwork_explanation = "Construct a Gateway to the Celestial Derelict and free Ratvar."
		if("silicons")
			clockwork_explanation = "Ensure that all silicon-based lifeforms on [station_name()] are servants of Ratvar by the end of the shift."
	return 1

/datum/game_mode/clockwork_cult/proc/greet_servant(mob/M) //Description of their role
	if(!M)
		return 0
	var/greeting_text = "<br><b><span class='large_brass'>You are a servant of Ratvar, the Clockwork Justiciar.</span>\n\
	Rusting eternally in the Celestial Derelict, Ratvar has formed a covenant of mortals, with you as one of its members. As one of the Justiciar's servants, you are to work to the best of your \
	ability to assist in completion of His agenda. You do not know the specifics of how to do so, but luckily you have a vessel to help you learn.</b>"
	M << greeting_text
	return 1

/datum/game_mode/proc/equip_servant(mob/living/L) //Grants a clockwork slab to the mob, with one of each component
	if(!L || !istype(L))
		return 0
	var/slot = "At your feet"
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.back && istype(H.back, /obj/item/weapon/storage/backpack))
			var/obj/item/weapon/storage/backpack/B = H.back
			new/obj/item/clockwork/slab/starter(B)
			slot = "In your [B.name]"
	if(slot == "At your feet")
		new/obj/item/clockwork/slab/starter(get_turf(L))
	L << "<b>[slot] is a link to the halls of Reebe and your master. You may use it to perform many tasks, but also become oriented with the workings of Ratvar and how to best complete your \
	tasks. This clockwork slab will be instrumental in your triumph. Remember: you can speak discreetly with your fellow servants by using Report in your slab's interface, and you can find a \
	concise tutorial in Recollection."
	return 1

/datum/game_mode/clockwork_cult/proc/present_tasks(mob/living/L) //Memorizes and displays the clockwork cult's objective
	if(!L || !istype(L) || !L.mind)
		return 0
	var/datum/mind/M = L.mind
	M.current << "<b>This is Ratvar's will:</b> [clockwork_explanation]"
	M.memory += "<b>Ratvar's will:</b> [clockwork_explanation]<br>"
	return 1

/datum/game_mode/clockwork_cult/proc/check_clockwork_victory()
	switch(clockwork_objective)
		if("escape")
			var/surviving_servants = 0
			for(var/datum/mind/M in servants_of_ratvar)
				if(M.current && M.current.stat != DEAD && (M.current.onCentcom() || M.current.onSyndieBase()))
					surviving_servants++
			if(surviving_servants <= required_escapees)
				return 1
			return 0
		if("silicons")
			for(var/mob/living/silicon/robot/S in mob_list) //Only check robots and AIs
				if(!is_servant_of_ratvar(S))
					return 0
			for(var/mob/living/silicon/ai/A in mob_list)
				if(!is_servant_of_ratvar(A))
					return 0
			return 1
		if("gateway")
			return ratvar_awakens
	return 0 //This shouldn't ever be reached, but just in case it is

/datum/game_mode/clockwork_cult/declare_completion()
	..()
	return 0 //Doesn't end until the round does

/datum/game_mode/proc/auto_declare_completion_clockwork_cult()
	var/text = ""
	if(istype(ticker.mode, /datum/game_mode/clockwork_cult)) //Possibly hacky?
		var/datum/game_mode/clockwork_cult/C = ticker.mode
		if(C.check_clockwork_victory())
			text += "<span class='brass'><b>Ratvar's servants have succeeded in fulfilling His goals!</b></span>"
		else
			text += "<span class='userdanger'>Ratvar's servants have failed!</span>"
		text += "<br><b>The goal of the clockwork cult was:</b> [clockwork_explanation]<br>"
	if(servants_of_ratvar.len)
		text += "<b>Ratvar's servants were:</b>"
		for(var/datum/mind/M in servants_of_ratvar)
			text += printplayer(M)
	world << text

/datum/game_mode/proc/update_servant_icons_added(datum/mind/M)
	var/datum/atom_hud/antag/A = huds[ANTAG_HUD_CLOCKWORK]
	A.join_hud(M.current)
	set_antag_hud(M.current, "clockwork")

/datum/game_mode/proc/update_servant_icons_removed(datum/mind/M)
	var/datum/atom_hud/antag/A = huds[ANTAG_HUD_CLOCKWORK]
	A.leave_hud(M.current)
	set_antag_hud(M.current, null)
