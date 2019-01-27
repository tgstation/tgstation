/datum/team/hivemind
	name = "One Mind"

/mob/living/proc/hive_awaken(objective, one_mind = FALSE)
	if(!src.mind)
		return
	var/datum/mind/M = src.mind
	var/datum/antagonist/hivevessel/vessel = M.has_antag_datum(/datum/antagonist/hivevessel)
	if(vessel)
		var/datum/objective/brainwashing/objective = new(objective)
		vessel.objectives += objective
		vessel.greet()
	else
		vessel = new()
		var/datum/objective/brainwashing/objective = new(objective)
		vessel.objectives += objective
		M.add_antag_datum(vessel)
	if(!one_mind)
		var/message = "<span class='deadsay'><b>[L]</b> has been brainwashed with the following objectives: [objective]."
		deadchat_broadcast(message, follow_target = L, turf_target = get_turf(L), message_type=DEADCHAT_REGULAR)
	else
		//Apply glow and add to team here
		M.AddSpell(new/obj/effect/proc_holder/spell/self/one_mind)

/datum/antagonist/hivemind/apply_innate_effects()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			if(!silent)
				to_chat(traitor_mob, "Our newfound powers allow us to overcome our clownish nature, allowing us to wield weapons with impunity.")
			traitor_mob.dna.remove_mutation(CLOWNMUT)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_HIVE]
	hud.join_hud(owner.current)
	set_antag_hud(owner.current, "hivevessel")

/datum/antagonist/hivemind/remove_innate_effects()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			traitor_mob.dna.add_mutation(CLOWNMUT)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_HIVE]
	hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/antagonist/hivevessel/greet()
	to_chat(owner, "<span class='assimilator'>Your mind is suddenly opened, as you see the pinnacle of evolution...</span>")
	to_chat(owner, "<big><span class='warning'><b>Follow your objectives, at any cost!</b></span></big>")
	var/i = 1
	for(var/X in objectives)
		var/datum/objective/O = X
		to_chat(owner, "<b>[i].</b> [O.explanation_text]")
		i++

/datum/antagonist/hivevessel/farewell()
	to_chat(owner, "<span class='assimilator'>Your mind closes up once more...</span>")
	to_chat(owner, "<big><span class='warning'><b>You feel the weight of your objectives disappear! You no longer have to obey them.</b></span></big>")
	owner.announce_objectives()

/datum/antagonist/hivevessel
	name = "Awoken Vessel"
	job_rank = ROLE_BRAINWASHED
	roundend_category = "awoken vessels"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
