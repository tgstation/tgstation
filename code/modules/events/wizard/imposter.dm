/datum/round_event_control/wizard/lookalike //Mirror Mania
	name = "lookalike Wizard"
	weight = 1
	typepath = /datum/round_event/wizard/lookalike
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/wizard/lookalike/start()
	for(var/datum/mind/M as anything in get_antag_minds(/datum/antagonist/wizard))
		if(!ishuman(M.current))
			continue
		var/mob/living/carbon/human/W = M.current
		var/list/candidates = poll_ghost_candidates("Would you like to be an lookalike wizard?", ROLE_WIZARD)
		if(!candidates)
			return //Sad Trombone
		var/mob/dead/observer/C = pick(candidates)

		new /obj/effect/particle_effect/smoke(W.loc)

		var/mob/living/carbon/human/I = new /mob/living/carbon/human(W.loc)
		W.dna.transfer_identity(I, transfer_SE=1)
		I.real_name = I.dna.real_name
		I.name = I.dna.real_name
		I.updateappearance(mutcolor_update=1)
		I.domutcheck()
		I.key = C.key
		var/datum/antagonist/wizard/master = M.has_antag_datum(/datum/antagonist/wizard)
		if(!master.wiz_team)
			master.create_wiz_team()
		var/datum/antagonist/wizard/apprentice/lookalike/lookalike = new()
		lookalike.master = M
		lookalike.wiz_team = master.wiz_team
		master.wiz_team.add_member(lookalike)
		I.mind.add_antag_datum(lookalike)
		I.mind.special_role = "lookalike"
		I.log_message("is an lookalike!", LOG_ATTACK, color="red") //?
		SEND_SOUND(I, sound('sound/effects/magic.ogg'))
