/datum/game_mode
	var/list/datum/mind/sintouched = list()
	var/list/datum/mind/devils = list()
	var/devil_ascended = 0 // Number of arch devils on station

/datum/game_mode/proc/auto_declare_completion_sintouched()
	var/text = ""
	if(sintouched.len)
		text += "<br><span class='big'><b>The sintouched were:</b></span>"
		var/list/sintouchedUnique = uniqueList(sintouched)
		for(var/S in sintouchedUnique)
			var/datum/mind/sintouched_mind = S
			text += printplayer(sintouched_mind)
			text += printobjectives(sintouched_mind)
			text += "<br>"
		text += "<br>"
	world << text

/datum/game_mode/proc/auto_declare_completion_devils()
	/var/text = ""
	if(devils.len)
		text += "<br><span class='big'><b>The devils were:</b></span>"
		for(var/D in devils)
			var/datum/mind/devil = D
			text += printplayer(devil)
			text += printdevilinfo(devil)
			text += printobjectives(devil)
			text += "<br>"
		text += "<br>"
	world << text


/datum/game_mode/proc/finalize_devil(datum/mind/devil_mind)

	var/trueName= randomDevilName()

	devil_mind.devilinfo = devilInfo(trueName, 1)
	devil_mind.store_memory("Your devilic true name is [devil_mind.devilinfo.truename]<br>[lawlorify[LAW][devil_mind.devilinfo.ban]]<br>You may not use violence to coerce someone into selling their soul.<br>You may not directly and knowingly physically harm a devil, other than yourself.<br>[lawlorify[LAW][devil_mind.devilinfo.bane]]<br>[lawlorify[LAW][devil_mind.devilinfo.obligation]]<br>[lawlorify[LAW][devil_mind.devilinfo.banish]]<br>")
	devil_mind.devilinfo.owner = devil_mind
	devil_mind.devilinfo.give_base_spells(1)
	spawn(10)
		devil_mind.devilinfo.update_hud()
		if(devil_mind.assigned_role == "Clown" && ishuman(devil_mind.current))
			var/mob/living/carbon/human/S = devil_mind.current
			S << "<span class='notice'>Your infernal nature has allowed you to overcome your clownishness.</span>"
			S.dna.remove_mutation(CLOWNMUT)
	if(issilicon(devil_mind.current))
		add_law_sixsixsix(devil_mind.current)

/datum/game_mode/proc/add_devil_objectives(datum/mind/devil_mind, quantity)
	var/list/validtypes = list(/datum/objective/devil/soulquantity, /datum/objective/devil/soulquality, /datum/objective/devil/sintouch, /datum/objective/devil/buy_target)
	for(var/i = 1 to quantity)
		var/type = pick(validtypes)
		var/datum/objective/devil/objective = new type(null)
		objective.owner = devil_mind
		devil_mind.objectives += objective
		if(!istype(objective, /datum/objective/devil/buy_target))
			validtypes -= type //prevent duplicate objectives, EXCEPT for buy_target.
		else
			objective.find_target()

/datum/mind/proc/announceDevilLaws()
	if(!devilinfo)
		return
	current << "<span class='warning'><b>You remember your link to the infernal.  You are [src.devilinfo.truename], an agent of hell, a devil.  And you were sent to the plane of creation for a reason.  A greater purpose.  Convince the crew to sin, and embroiden Hell's grasp.</b></span>"
	current << "<span class='warning'><b>However, your infernal form is not without weaknesses.</b></span>"
	current << "You may not use violence to coerce someone into selling their soul."
	current << "You may not directly and knowingly physically harm a devil, other than yourself."
	current << lawlorify[LAW][src.devilinfo.bane]
	current << lawlorify[LAW][src.devilinfo.ban]
	current << lawlorify[LAW][src.devilinfo.obligation]
	current << lawlorify[LAW][src.devilinfo.banish]
	current << "<br/><br/><span class='warning'>Remember, the crew can research your weaknesses if they find out your devil name.</span><br>"

/datum/game_mode/proc/printdevilinfo(datum/mind/ply)
	if(!ply.devilinfo)
		return "Target is not a devil."
	var/text = "</br>The devil's true name is: [ply.devilinfo.truename]</br>"
	text += "The devil's bans were:</br>"
	text += "	[lawlorify[LORE][ply.devilinfo.ban]]</br>"
	text += "	[lawlorify[LORE][ply.devilinfo.bane]]</br>"
	text += "	[lawlorify[LORE][ply.devilinfo.obligation]]</br>"
	text += "	[lawlorify[LORE][ply.devilinfo.banish]]</br></br>"
	return text

/datum/game_mode/proc/update_devil_icons_added(datum/mind/devil_mind)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_DEVIL]
	hud.join_hud(devil_mind.current)
	set_antag_hud(devil_mind.current, "devil")

/datum/game_mode/proc/update_devil_icons_removed(datum/mind/devil_mind)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_DEVIL]
	hud.leave_hud(devil_mind.current)
	set_antag_hud(devil_mind.current, null)

/datum/game_mode/proc/update_sintouched_icons_added(datum/mind/sintouched_mind)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_SINTOUCHED]
	hud.join_hud(sintouched_mind.current)
	set_antag_hud(sintouched_mind.current, "sintouched")

/datum/game_mode/proc/update_sintouched_icons_removed(datum/mind/sintouched_mind)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_SINTOUCHED]
	hud.leave_hud(sintouched_mind.current)
	set_antag_hud(sintouched_mind.current, null)

/datum/game_mode/proc/update_soulless_icons_added(datum/mind/soulless_mind)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_SOULLESS]
	hud.join_hud(soulless_mind.current)
	set_antag_hud(soulless_mind.current, "soulless")

/datum/game_mode/proc/update_soulless_icons_removed(datum/mind/soulless_mind)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_SOULLESS]
	hud.leave_hud(soulless_mind.current)
	set_antag_hud(soulless_mind.current, null)
