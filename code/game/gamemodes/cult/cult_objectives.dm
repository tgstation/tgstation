/datum/objective_team/cult
	name = "blood cult"
	member_name = "cultist"
	var/list/objectives = list()

/datum/objective_team/cult/add_member(datum/mind/new_member)
	. = ..()
	new_member.objectives |= objectives

/datum/objective_team/cult/remove_member(datum/mind/member)
	. = ..()
	member.objectives -= objectives

/datum/objective_team/cult/proc/add_objective(datum/objective/O)
	O.team = src
	O.update_explanation_text()
	objectives += O
	for(var/datum/mind/M in members)
		M.objectives += O

/datum/objective/cult
	var/success_mem_text

/datum/objective/cult/proc/memorization_text()
	if(check_completion() && success_mem_text)
		return success_mem_text
	return explanation_text

/datum/objective/cult/eldergod
	explanation_text = "Summon Nar-Sie by invoking the rune 'Summon Nar-Sie'."
	success_mem_text = "<b>HAIL NAR-SIE.</b>"

/datum/objective/cult/eldergod/New()
	explanation_text = "Summon Nar-Sie by invoking the rune 'Summon Nar-Sie'. <b>The summoning can only be accomplished in [english_list(GLOB.summon_spots)] - where the veil is weak enough for the ritual to begin.</b>"

/datum/objective/cult/eldergod/check_completion()
	return (istype(GLOB.cult_narsie, /obj/singularity/narsie/large) || SSticker.mode.eldergod)

/datum/objective/cult/spread_blood
	success_mem_text = "The station has been properly prepared for the Geometer! <b>HAIL NAR-SIE!</b>"
	var/spilltarget = 100

/datum/objective/cult/spread_blood/New()
	spilltarget = 100 + rand(0, GLOB.player_list.len * 3)
	explanation_text = "We must prepare this place for the Geometer of Blood's coming. Spill blood over [spilltarget] floor tiles."

/datum/objective/cult/spread_blood/check_completion()
	return (GLOB.bloody_tiles.len >= spilltarget)

/datum/objective/cult/sacrifice
	var/datum/mind/sactarget
	success_mem_text = "The veil has already been weakened here, proceed to the final objective."

/datum/objective/cult/sacrifice/New(datum/mind/T)
	if(T)
		sactarget = T
	else
		sactarget = GLOB.sac_mind
	explanation_text = "Sacrifice [sactarget], the [sactarget.assigned_role] via invoking a Sacrifice rune with them on it and three acolytes around it"