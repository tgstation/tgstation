/datum/ai_planning_subtree/use_mob_ability/evolve
	ability_key = BB_SLIME_EVOLVE

/datum/ai_planning_subtree/use_mob_ability/reproduce
	ability_key = BB_SLIME_REPRODUCE

//Handles the slime changing their facial overlays
/datum/ai_planning_subtree/change_slime_face
	var/face_change_chance = 5

/datum/ai_planning_subtree/change_slime_face/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!SPT_PROB(face_change_chance, seconds_per_tick))
		return

	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn))
		return

	if(slime_pawn.stat) //dead slimes make no smiles
		return

	controller.queue_behavior(/datum/ai_behavior/perform_change_slime_face)

// Slime subtree for hunting down people to drain
/datum/ai_planning_subtree/find_and_hunt_target/find_slime_food
	finding_behavior = /datum/ai_behavior/find_hunt_target/find_slime_food
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/slime
	hunt_targets = list(/mob/living)
	hunt_range = 7

/datum/ai_planning_subtree/find_and_hunt_target/find_slime_food/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.buckled)
		return

	//Slimes don't want to hunt if they are neither rabid, hungry or feeling attack right now
	if( (controller.blackboard[BB_SLIME_HUNGER_LEVEL] == SLIME_HUNGER_NONE) && !controller.blackboard[BB_SLIME_RABID] && isnull(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]))
		return

	return ..()

/datum/ai_planning_subtree/basic_melee_attack_subtree/slime

/datum/ai_planning_subtree/basic_melee_attack_subtree/slime/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.buckled)
		return
	return ..()

/datum/ai_planning_subtree/random_speech/slime
	speech_chance = 1
	speak = list("Blorble...","Bzzt...","")
	emote_hear = list("blorbles.")
	emote_see = list("lights up for a bit, then stops.","bounces in place.", "jiggles!","vibrates!")
