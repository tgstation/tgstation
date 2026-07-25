/// Passes when shoving the target right now would knock them down rather than just push them back. In the future this could maybe check for any options, right now ti just checks from me to target
/datum/bt_node/decorator/target_can_be_shove_stunned
	/// Blackboard key holding the mob we would shove.
	var/target_key

/datum/bt_node/decorator/target_can_be_shove_stunned/check_condition(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/living_target = controller.blackboard[target_key]

	if(!isliving(living_pawn) || !isliving(living_target))
		return FALSE

	// Standing up, not ourselves, not sharing a turf. Also guarantees a real shove direction below.
	if(!living_pawn.can_disarm(living_target))
		return FALSE

	// Authoritative source for whether this pairing can hit something, is knockdown immune, or gets side kicked.
	var/shove_flags = living_target.get_shove_flags(living_pawn, null)
	if(!(shove_flags & SHOVE_CAN_HIT_SOMETHING))
		return FALSE
	if(shove_flags & (SHOVE_KNOCKDOWN_BLOCKED | SHOVE_CAN_KICK_SIDE))
		return FALSE

	return shove_will_knockdown(living_pawn, living_target)

/// Whether the target has nowhere to be pushed, which is what turns a shove into a knockdown. (and thus succesful)
/datum/bt_node/decorator/target_can_be_shove_stunned/proc/shove_will_knockdown(mob/living/living_pawn, mob/living/living_target)
	var/shove_dir = get_dir(living_pawn.loc, living_target.loc)
	var/turf/target_turf = get_turf(living_target)
	var/turf/shove_turf = get_step(target_turf, shove_dir)

	// Nothing behind them at all, so they've got nowhere to go.
	if(isnull(shove_turf))
		return TRUE

	// Passing the target as source_atom runs CanPass, which covers directional windows on the far turf.
	if(shove_turf.is_blocked_turf(source_atom = living_target))
		return TRUE

	// A border object on their own turf facing the way we'd shove stops them leaving it in the first place,
	// which is_blocked_turf() on the destination can't see.
	if(!(shove_dir in GLOB.cardinals))
		return FALSE
	for(var/obj/obj_content in target_turf)
		if((obj_content.flags_1 & ON_BORDER_1) && obj_content.dir == shove_dir && obj_content.density)
			return TRUE

	return FALSE
