/*

CLOCKWORK CULT: Based off of the failed pull requests from /vg/

While Nar-Sie is the oldest and most prominent of the elder gods, there are other forces at work in the universe.
Ratvar, the Clockwork Justiciar, a homage to Nar-Sie granted sentience by its own power, is one such other force.
Imprisoned within a massive construct known as the Celestial Derelict - or Reebe - an intense hatred of the Blood God festers.
Ratvar, unable to act in the mortal plane, seeks to return and forms covenants with mortals in order to bolster his influence.
Due to his mechanical nature, Ratvar is also capable of influencing silicon-based lifeforms, unlike Nar-Sie, who can only influence natural life.

This is a team-based gamemode, and the team's objective is shared by all cultists. It can include summoning Ratvar, escaping on the shuttle, or converting the AI and its cyborgs.

The clockwork version of an arcane tome is the clockwork slab.
While it can perform certain actions, it consumes a resource called components.
Components, which are fallen fragments of Ratvar's body as he rusts in Reebe, are powerful and have various effects.
Game-wise, clockwork slabs will generate components over time, with more powerful components being slower.

This file's folder contains:
	__clock_defines.dm: Defined variables
	clock_cult.dm: Core gamemode files.
	clock_items.dm: Items (excluding the proselytizer).
	clock_machines.dm: Machinery like the mending motor.
	clock_mobs.dm: Hostile and benign clockwork creatures.
	clock_proselytizer: The clockwork proselytizer and all of its special interactions.
	clock_ratvar.dm: The Ark of the Clockwork Justiciar and Ratvar himself. Important enough to have his own file.
	clock_scripture.dm: Scripture and rites.
	clock_structures.dm: Structures and effects
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
	if(M.mind.enslaved_to)
		return 0
	if(iscultist(M) || isconstruct(M))
		return 0
	if(isbrain(M))
		return 1
	if(ishuman(M))
		if(isloyal(M) || (M.mind.assigned_role in list("Captain", "Chaplain")))
			return 0
		return 1
	if(isguardian(M))
		var/mob/living/simple_animal/hostile/guardian/G = M
		if(is_servant_of_ratvar(G.summoner))
			return 1 //can't convert it unless the owner is converted
	if(issilicon(M) || isclockmob(M) || istype(M, /mob/living/simple_animal/drone/cogscarab))
		return 1
	return 0

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
	var/list/scripture_states = get_scripture_states()
	ticker.mode.servants_of_ratvar += M.mind
	scripture_unlock_alert(scripture_states)
	ticker.mode.update_servant_icons_added(M.mind)
	M.mind.special_role = "Servant of Ratvar"
	M.languages_spoken |= RATVAR
	M.languages_understood |= RATVAR
	all_clockwork_mobs += M
	M.update_action_buttons_icon() //because a few clockcult things are action buttons and we may be wearing/holding them for whatever reason, we need to update buttons
	M.attack_log += "\[[time_stamp()]\] <span class='brass'>Has been converted to the cult of Ratvar!</span>"
	if(issilicon(M))
		var/mob/living/silicon/S = M
		if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			R.UnlinkSelf()
			R.emagged = 1
			R << "<span class='boldwarning'>You have been desynced from your master AI. In addition, your onboard camera is no longer active and your safeties have been disabled.</span>"
		S.laws = new/datum/ai_laws/ratvar
		S.laws.associate(S)
		S.update_icons()
		S.show_laws()
		var/datum/action/innate/hierophant/H = new()
		H.Grant(S)
		H.title = null //so it's just the borg's name
		S << "<span class='heavy_brass'>You can communicate with other servants by using the Hierophant Network action button in the upper left.</span>"
	if(istype(ticker.mode, /datum/game_mode/clockwork_cult))
		var/datum/game_mode/clockwork_cult/C = ticker.mode
		C.present_tasks(M) //Memorize the objectives
	cache_check(M)
	return 1

/proc/remove_servant_of_ratvar(mob/living/M, silent = FALSE)
	if(!is_servant_of_ratvar(M)) //In this way, is_servant_of_ratvar() checks the existence of ticker and minds
		return 0
	if(!silent)
		M.visible_message("<span class='big'>[M] seems to have remembered their true allegiance!</span>", \
		"<span class='userdanger'>A cold, cold darkness flows through your mind, extinguishing the Justiciar's light and all of your memories as his servant.</span>")
	var/list/scripture_states = get_scripture_states()
	ticker.mode.servants_of_ratvar -= M.mind
	scripture_unlock_alert(scripture_states)
	ticker.mode.update_servant_icons_removed(M.mind)
	all_clockwork_mobs -= M
	M.mind.memory = "" //Not sure if there's a better way to do this
	M.mind.special_role = null
	M.languages_spoken &= ~RATVAR
	M.languages_understood &= ~RATVAR
	M.update_action_buttons_icon() //because a few clockcult things are action buttons and we may be wearing/holding them, we need to update buttons
	M.attack_log += "\[[time_stamp()]\] <span class='brass'>Has renounced the cult of Ratvar!</span>"
	M.clear_alert("nocache")
	for(var/datum/action/innate/function_call/F in M.actions) //Removes any bound Ratvarian spears
		qdel(F)
	for(var/datum/action/innate/hierophant/H in M.actions) //Removes any communication actions
		qdel(H)
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

///////////////
// GAME MODE //
///////////////

/datum/game_mode
	var/list/servants_of_ratvar = list() //The Enlightened servants of Ratvar
	var/required_escapees = 0 //How many servants need to escape, if applicable
	var/required_silicon_converts = 0 //How many robotic lifeforms need to be converted, if applicable
	var/clockwork_objective = "gateway" //The objective that the servants must fulfill
	var/clockwork_explanation = "Construct a Gateway to the Celestial Derelict and free Ratvar." //The description of the current objective

/datum/game_mode/clockwork_cult
	name = "clockwork cult"
	config_tag = "clockwork_cult"
	antag_flag = ROLE_SERVANT_OF_RATVAR
	required_players = 24
	required_enemies = 3
	recommended_enemies = 3
	enemy_minimum_age = 14
	protected_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain") //Silicons can eventually be converted
	restricted_jobs = list("Chaplain", "Captain")
	announce_span = "brass"
	announce_text = "Servants of Ratvar are trying to summon the Justiciar!\n\
	<span class='brass'>Servants</span>: Take over the station and summon Ratvar.\n\
	<span class='notice'>Crew</span>: Stop the servants before they can summon the Clockwork Justiciar."
	var/servants_to_serve = list()

/datum/game_mode/clockwork_cult/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs
	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"
	var/starter_servants = 3 //Guaranteed three servants
	var/number_players = num_players()
	if(number_players > 30) //plus one servant for every additional 15 players
		number_players -= 30
		starter_servants += round(number_players/15)
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
	tasks. This clockwork slab will be instrumental in your triumph. Remember: you can speak discreetly with your fellow servants by using the <span class='brass'>Hierophant Network</span> action button, \
	and you can find a concise tutorial by using the slab in-hand and selecting Recollection.</b>"
	L << "<i>Alternatively, check out the wiki page at </i><b>https://tgstation13.org/wiki/Clockwork_Cult</b><i>, which contains additional information.</i>"
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
			text += "<span class='large_brass'><b>Ratvar's servants have succeeded in fulfilling His goals!</b></span>"
			feedback_set_details("round_end_result", "win - servants completed their objective ([clockwork_objective])")
		else
			var/half_victory = FALSE
			if(clockwork_objective == "gateway")
				var/obj/structure/clockwork/massive/celestial_gateway/G = locate() in all_clockwork_objects
				if(G)
					half_victory = TRUE
			if(!half_victory)
				text += "<span class='large_brass'><b>The crew escaped before Ratvar could rise, but the station was taken over!</b></span>"
				feedback_set_details("round_end_result", "halfwin - round ended before the gateway finished")
			else
				text += "<span class='userdanger'>Ratvar's servants have failed!</span>"
				feedback_set_details("round_end_result", "loss - servants failed their objective ([clockwork_objective])")
		text += "<br><b>The servants' objective was:</b> [clockwork_explanation]<br>"
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
