///Datum for basic mobs to define what they can attack.GET_TARGETING_STRATEGY\((/[^,]*)\),
///Global, just like ai_behaviors
/datum/targeting_strategy

///Returns true or false depending on if the target can be attacked by the mob
/datum/targeting_strategy/proc/can_attack(mob/living/living_mob, atom/target, vision_range)
	return

///Returns something the target might be hiding inside of
/datum/targeting_strategy/proc/find_hidden_mobs(mob/living/living_mob, atom/target)
	var/atom/target_hiding_location
	if(istype(target.loc, /obj/structure/closet) || istype(target.loc, /obj/machinery/disposal) || istype(target.loc, /obj/machinery/sleeper))
		target_hiding_location = target.loc
	return target_hiding_location

/datum/targeting_strategy/basic
	/// When we do our basic faction check, do we look for exact faction matches?
	/// Factions are only considered for neutral mobs, so this doesn't apply to friends and enemies.
	var/check_factions_exactly = FALSE
	/// Whether we care for seeing the target or not
	var/ignore_sight = FALSE

	/// how should we check for a similar faction
	var/faction_check = FACTION_CHECK_ANY

	///whether friends, foes, and those who are neither should be targets
	var/relationship_target_flags = TARGET_NEUTRALS | TARGET_FOES

	/// Blackboard key containing the minimum stat of a living mob to target
	var/minimum_stat_key = BB_TARGET_MINIMUM_STAT

/datum/targeting_strategy/basic/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	var/datum/ai_controller/basic_controller/our_controller = living_mob.ai_controller

	if(isnull(our_controller))
		return FALSE

	if(isturf(the_target) || isnull(the_target)) // bail out on invalids
		return FALSE

	if(isobj(the_target.loc))
		var/obj/container = the_target.loc
		if(container.resistance_flags & INDESTRUCTIBLE)
			return FALSE

	if(ismob(the_target)) //Target is in godmode, ignore it.
		if(living_mob.loc == the_target)
			return FALSE // We've either been eaten or are shapeshifted, let's assume the latter because we're still alive
		var/mob/M = the_target
		if(M.status_flags & GODMODE)
			return FALSE

	if(!ignore_sight && !can_see(living_mob, the_target, vision_range)) //Target has moved behind cover and we have lost line of sight to it
		return FALSE

	if(living_mob.see_invisible < the_target.invisibility) //Target's invisible to us, forget it
		return FALSE

	if(!isturf(living_mob.loc))
		return FALSE
	if(isturf(the_target.loc) && living_mob.z != the_target.z) // z check will always fail if target is in a mech or pawn is shapeshifted or jaunting
		return FALSE

	if(isliving(the_target)) //Targeting vs living mobs
		var/mob/living/living_target = the_target
		if(!is_relationship_target(our_controller, living_mob, living_target))
			return FALSE
		if(living_target.stat > our_controller.blackboard[minimum_stat_key])
			return FALSE

		return TRUE

	if(ismecha(the_target)) //Targeting vs mechas
		var/obj/vehicle/sealed/mecha/M = the_target
		for(var/occupant in M.occupants)
			if(can_attack(living_mob, occupant)) //Can we attack any of the occupants?
				return TRUE

	if(istype(the_target, /obj/machinery/porta_turret)) //Cringe turret! kill it!
		var/obj/machinery/porta_turret/P = the_target
		if(P.in_faction(living_mob)) //Don't attack if the turret is in the same faction
			return FALSE
		if(P.has_cover && !P.raised) //Don't attack invincible turrets
			return FALSE
		if(P.machine_stat & BROKEN) //Or turrets that are already broken
			return FALSE
		return TRUE

	return FALSE

/// Returns a boolean for whether the mob has a targetable relationship to the controller.
/// Neutral mobs are also checked for factions
/datum/targeting_strategy/basic/proc/is_relationship_target(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	/// check for special relations

	var/same_faction = FALSE
	if(faction_check != FACTION_CHECK_SKIP)
		same_faction = living_mob.faction_check_atom(the_target, exact_match = faction_check)
	var/is_friend = FALSE
	if(same_faction || (controller.blackboard_key_exists(BB_FRIENDS) && (the_target in controller.blackboard[BB_FRIENDS])))
		is_friend = TRUE
		if(relationship_target_flags & TARGET_FRIENDS)
			return TRUE
	var/is_foe = FALSE
	if(controller.blackboard_key_exists(BB_FOES))
		is_foe = (the_target in controller.blackboard[BB_FOES])
		if(relationship_target_flags & TARGET_FOES)
			return TRUE
	if(relationship_target_flags & TARGET_NEUTRALS && (!is_friend && !is_foe))
		return TRUE //already failed a faction check by not being a friend
	return FALSE

/// Subtype which searches for mobs of a size relative to ours
/datum/targeting_strategy/basic/of_size
	/// If true, we will return mobs which are smaller than us. If false, larger.
	var/find_smaller = TRUE
	/// If true, we will return mobs which are the same size as us.
	var/inclusive = TRUE

/datum/targeting_strategy/basic/of_size/can_attack(mob/living/owner, atom/target, vision_range)
	if(!isliving(target))
		return FALSE
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/mob_target = target
	if(inclusive && owner.mob_size == mob_target.mob_size)
		return TRUE
	if(owner.mob_size > mob_target.mob_size)
		return find_smaller
	return !find_smaller

// This is just using the default values but the subtype makes it clearer
/datum/targeting_strategy/basic/of_size/ours_or_smaller

/datum/targeting_strategy/basic/of_size/larger
	find_smaller = FALSE
	inclusive = FALSE


/datum/targeting_strategy/basic/of_size/smaller
	inclusive = FALSE

/// Makes the mob only target their friends, which also includes faction members. Useful for supportive plans!
/// cannot have an early return, because faction members are friends
/datum/targeting_strategy/basic/friends
	relationship_target_flags = TARGET_FRIENDS

/// Makes the mob only target anyone who is not a foe.
/datum/targeting_strategy/basic/not_foes
	relationship_target_flags = TARGET_FRIENDS | TARGET_NEUTRALS

/// Makes the mob only attack their enemies instead of also including neutral mobs. Useful for retaliation!
/datum/targeting_strategy/basic/foes
	relationship_target_flags = TARGET_FOES

/datum/targeting_strategy/basic/foes/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	var/datum/ai_controller/basic_controller/our_controller = living_mob.ai_controller
	if(!our_controller || !our_controller.blackboard_key_exists(BB_FOES))
		return FALSE //saves a lot of processing to early return when we know we won't find any target
	. = ..()

/datum/targeting_strategy/basic/any_relationship
	relationship_target_flags = TARGET_FRIENDS | TARGET_NEUTRALS | TARGET_FOES

/// closed turfs are valid targets!
/datum/targeting_strategy/basic/closed_turfs

/datum/targeting_strategy/basic/closed_turfs/can_attack(mob/living/living_mob, atom/target, vision_range)
	if(isclosedturf(target))
		return TRUE
	return ..()
