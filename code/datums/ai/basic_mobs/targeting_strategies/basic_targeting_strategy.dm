/datum/targeting_strategy/basic
	/// When we do our basic faction check, do we look for exact faction matches?
	var/check_factions_exactly = FALSE
	/// Whether we care for seeing the target or not
	var/ignore_sight = FALSE
	/// Blackboard key containing the minimum stat of a living mob to target
	var/minimum_stat_key = BB_TARGET_MINIMUM_STAT
	/// If this blackboard key is TRUE, makes us only target wounded mobs
	var/target_wounded_key

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
		if(HAS_TRAIT(the_target, TRAIT_GODMODE))
			return FALSE

	if (vision_range && get_dist(living_mob, the_target) > vision_range)
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
		if(faction_check(our_controller, living_mob, living_target))
			return FALSE
		if(living_target.stat > our_controller.blackboard[minimum_stat_key])
			return FALSE
		if(target_wounded_key && our_controller.blackboard[target_wounded_key] && living_target.health == living_target.maxHealth)
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

/// Returns true if the mob and target share factions
/datum/targeting_strategy/basic/proc/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	if (controller.blackboard[BB_ALWAYS_IGNORE_FACTION] || controller.blackboard[BB_TEMPORARILY_IGNORE_FACTION])
		return FALSE
	return living_mob.faction_check_atom(the_target, exact_match = check_factions_exactly)

/// Subtype more forgiving for items.
/// Careful, this can go wrong and keep a mob hyper-focused on an item it can't lose aggro on
/datum/targeting_strategy/basic/allow_items

/datum/targeting_strategy/basic/allow_items/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	. = ..()
	if(isitem(the_target))
		// trust fall exercise
		return TRUE

/datum/targeting_strategy/basic/require_traits

/datum/targeting_strategy/basic/require_traits/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	. = ..()
	if (!.)
		return FALSE
	var/list/required_traits = living_mob.ai_controller.blackboard[BB_TARGET_ONLY_WITH_TRAITS]
	if (!length(required_traits))
		return TRUE

	for (var/trait in required_traits)
		if (HAS_TRAIT(the_target, trait))
			return TRUE
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

/// Makes the mob only attack their own faction. Useful mostly if their attacks do something helpful (e.g. healing touch).
/datum/targeting_strategy/basic/same_faction

/datum/targeting_strategy/basic/same_faction/faction_check(mob/living/living_mob, mob/living/the_target)
	return !..() // inverts logic to ONLY target mobs that share a faction

/datum/targeting_strategy/basic/allow_turfs

/datum/targeting_strategy/basic/allow_turfs/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	if(isturf(the_target))
		return TRUE
	return ..()

/// Subtype which searches for mobs that havent been gutted by megafauna
/datum/targeting_strategy/basic/no_gutted_mobs

/datum/targeting_strategy/basic/no_gutted_mobs/can_attack(mob/living/owner, mob/living/target, vision_range)
	if(!istype(target) || target.has_status_effect(/datum/status_effect/gutted))
		return FALSE
	return ..()
