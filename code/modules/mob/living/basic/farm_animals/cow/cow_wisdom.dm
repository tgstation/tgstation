///Wisdom cow, gives XP to a random skill and speaks wisdoms
/mob/living/basic/cow/wisdom
	name = "wisdom cow"
	desc = "Known for its wisdom, shares it with all."
	gold_core_spawnable = FALSE
	ai_controller = /datum/ai_controller/basic_controller/cow/wisdom

/mob/living/basic/cow/wisdom/setup_eating()
	return //cannot tame me! and I don't care about eatin' nothing, neither!

/datum/ai_controller/basic_controller/cow/wisdom
	//don't give a targetting datum
	blackboard = list(
		BB_BASIC_MOB_TIP_REACTING = FALSE,
		BB_BASIC_MOB_TIPPER = null,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/tip_reaction,
		/datum/ai_planning_subtree/random_speech/cow/wisdom,
	)

///Give intense wisdom to the attacker if they're being friendly about it
/mob/living/basic/cow/wisdom/attack_hand(mob/living/carbon/user, list/modifiers)
	if(!stat && !user.combat_mode)
		to_chat(user, span_nicegreen("[src] whispers you some intense wisdoms and then disappears!"))
		user.mind?.adjust_experience(pick(GLOB.skill_types), 500)
		do_smoke(1, holder = src, location = get_turf(src))
		qdel(src)
		return
	return ..()
