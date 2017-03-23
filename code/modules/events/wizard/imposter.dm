/datum/round_event_control/wizard/imposter //Mirror Mania
	name = "Imposter Wizard"
	weight = 1
	typepath = /datum/round_event/wizard/imposter
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/wizard/imposter/start()

	for(var/datum/mind/M in ticker.mode.wizards)
		if(!ishuman(M.current))
			continue
		var/mob/living/carbon/human/W = M.current
		var/list/candidates = get_candidates(ROLE_WIZARD)
		if(!candidates)
			return //Sad Trombone
		var/client/C = pick(candidates)

		new /obj/effect/particle_effect/smoke(W.loc)

		var/mob/living/carbon/human/I = new /mob/living/carbon/human(W.loc)
		W.dna.transfer_identity(I, transfer_SE=1)
		I.real_name = I.dna.real_name
		I.name = I.dna.real_name
		I.updateappearance(mutcolor_update=1)
		I.domutcheck()
		if(W.ears)
			I.equip_to_slot_or_del(new W.ears.type, slot_ears)
		if(W.w_uniform)
			I.equip_to_slot_or_del(new W.w_uniform.type	, slot_w_uniform)
		if(W.shoes)
			I.equip_to_slot_or_del(new W.shoes.type, slot_shoes)
		if(W.wear_suit)
			I.equip_to_slot_or_del(new W.wear_suit.type, slot_wear_suit)
		if(W.head)
			I.equip_to_slot_or_del(new W.head.type, slot_head)
		if(W.back)
			I.equip_to_slot_or_del(new W.back.type, slot_back)
		I.key = C.key

		//Operation: Fuck off and scare people
		I.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(null))
		I.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/turf_teleport/blink(null))
		I.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null))

		ticker.mode.apprentices += I.mind
		I.mind.special_role = "imposter"

		var/datum/objective/protect/protect_objective = new /datum/objective/protect
		protect_objective.owner = I.mind
		protect_objective.target = W.mind
		protect_objective.explanation_text = "Protect [W.real_name], the wizard."
		I.mind.objectives += protect_objective
		ticker.mode.update_wiz_icons_added(I.mind)

		I.log_message("<font color='red'>Is an imposter!</font>", INDIVIDUAL_ATTACK_LOG)
		to_chat(I, "<B>You are an imposter! Trick and confuse the crew to misdirect malice from your handsome original!</B>")
		I << sound('sound/effects/magic.ogg')
