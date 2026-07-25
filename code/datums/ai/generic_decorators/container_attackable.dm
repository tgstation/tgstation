/// Gates on the container being worth attacking (pawn.obj_damage > damage_deflection); fails if pacifist = TRUE.
/datum/bt_node/decorator/container_attackable
	var/pacifist = FALSE
	var/target_key = BB_BASIC_MOB_ESCAPE_TARGET

/datum/bt_node/decorator/container_attackable/check_condition(datum/ai_controller/controller)
	if(pacifist)
		return FALSE
	if(!isbasicmob(controller.pawn))
		return FALSE
	var/atom/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	var/mob/living/basic/basic_pawn = controller.pawn
	return basic_pawn.obj_damage > target.damage_deflection
