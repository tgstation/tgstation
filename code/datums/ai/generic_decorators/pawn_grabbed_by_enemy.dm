/// Gates on the pawn being grabbed above GRAB_PASSIVE by a mob the targeting strategy considers an enemy.
/datum/bt_node/decorator/pawn_grabbed_by_enemy
	var/targeting_strategy_key = BB_TARGETING_STRATEGY
	child_typepath = /datum/bt_node/ai_behavior/resist

/datum/bt_node/decorator/pawn_grabbed_by_enemy/check_condition(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	var/mob/puller = pawn.pulledby
	if(isnull(puller) || puller.grab_state <= GRAB_PASSIVE)
		return FALSE
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	if(!strategy?.can_attack(pawn, puller))
		return FALSE
	var/list/friends = controller.blackboard[BB_FRIENDS_LIST] || list()
	return !(puller in friends)
