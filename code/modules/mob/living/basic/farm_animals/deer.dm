/mob/living/basic/deer
	name = "doe"
	desc = "A gentle, peaceful forest animal. How did this get into space?"
	icon_state = "deer-doe"
	icon_living = "deer-doe"
	icon_dead = "deer-doe-dead"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_emote = list("grunts","grunts lowly")
	speed = 0.8 //deer are fuckin fast when they want to be
	see_in_dark = 6
	faction = list("deer") //humans are neutral, so if the deer was neutral it wouldn't run from them.
	butcher_results = list(/obj/item/food/meat/slab = 3)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently nudges"
	response_disarm_simple = "gently nudges aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "bucks"
	attack_verb_simple = "buck"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 75
	maxHealth = 75
	blood_volume = BLOOD_VOLUME_NORMAL
	footstep_type = FOOTSTEP_MOB_SHOE

	ai_controller = /datum/ai_controller/basic_controller/deer

/datum/ai_controller/basic_controller/deer
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance

	//IMPLEMENT IDLE BEHAVIOR HERE

	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/deer,
		/datum/ai_planning_subtree/simple_find_target/close,
		/datum/ai_planning_subtree/run_away,
	)

//REMOVE THIS
/datum/ai_controller/basic_controller/deer/PerformIdleBehavior(delta_time)
	. = ..()
	var/mob/living/living_pawn = pawn
	if(DT_PROB(25, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)
