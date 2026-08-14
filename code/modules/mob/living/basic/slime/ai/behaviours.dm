/datum/bt_node/ai_behavior/hunt_target/interact_with_target/slime

/datum/bt_node/ai_behavior/hunt_target/interact_with_target/slime/target_caught(mob/living/basic/slime/hunter, mob/living/hunted)
	if (!hunter.can_feed_on(hunted)) // Target is no longer edible
		hunter.UnarmedAttack(hunted, TRUE)
		return

	if((hunted.body_position != STANDING_UP) || prob(20)) //Not standing, or we rolled well? Feed.
		hunter.start_feeding(hunted)
		return

	if(hunted.client && hunted.health >= 20) //If target has a client and is healthy, punch them a bit before feasting
		hunter.UnarmedAttack(hunted, TRUE)
		return

	hunter.start_feeding(hunted)

/datum/bt_node/ai_behavior/hunt_target/interact_with_target/slime/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(!slime_pawn.can_feed_on(target))
		controller.clear_blackboard_key(target_key)
