/// Gates on the buckle target having TRAIT_DANGEROUS_BUCKLE; fails if pacifist = TRUE.
/datum/bt_node/decorator/buckle_target_dangerous
	var/pacifist = FALSE
	var/target_key = BB_BASIC_MOB_ESCAPE_TARGET

/datum/bt_node/decorator/buckle_target_dangerous/check_condition(datum/ai_controller/controller)
	if(pacifist)
		return FALSE
	var/atom/target = controller.blackboard[target_key]
	return !isnull(target) && HAS_TRAIT(target, TRAIT_DANGEROUS_BUCKLE)
