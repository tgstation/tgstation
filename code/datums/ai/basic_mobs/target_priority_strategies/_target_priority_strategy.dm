/// Target priority datum, exists to allow target acquisition behaviors to have custom selection policies. Singleton.
/datum/target_priority_strategy

/// Returns a number representing the priority of a target, higher -> more likely to be selected.
/datum/target_priority_strategy/proc/get_target_priority(datum/ai_controller/controller, atom/target)
	return 1

/// Returns a single atom from the list of passed targets
/datum/target_priority_strategy/proc/select_target(datum/ai_controller/controller, list/atom/targets)
	var/list/target_priorities = list()
	for (var/atom/target as anything in targets)
		target_priorities[target] = get_target_priority(controller, target)
	return pick_weight(target_priorities)

/// Returns TRUE if candidate may replace current_target during a reselection pass.
/// The default is sticky on ties to avoid otherwise-equivalent targets changing every search tick.
/datum/target_priority_strategy/proc/can_replace_target(datum/ai_controller/controller, atom/current_target, atom/candidate)
	return get_target_priority(controller, candidate) > get_target_priority(controller, current_target)

/// Selects the closest candidate.
/datum/target_priority_strategy/nearest

/datum/target_priority_strategy/nearest/get_target_priority(datum/ai_controller/controller, atom/target)
	return -get_dist(controller.pawn, target)

/datum/target_priority_strategy/nearest/select_target(datum/ai_controller/controller, list/atom/targets)
	return get_closest_atom(/atom/, targets, get_turf(controller.pawn))

/// Selects the living candidate with the lowest health.
/datum/target_priority_strategy/most_wounded

/datum/target_priority_strategy/most_wounded/get_target_priority(datum/ai_controller/controller, atom/target)
	var/mob/living/living_target = target
	if(!istype(living_target))
		return -INFINITY
	return -living_target.health

/datum/target_priority_strategy/most_wounded/select_target(datum/ai_controller/controller, list/atom/targets)
	var/list/living_targets = list()
	for(var/mob/living/living_target in targets)
		living_targets += living_target
	if(!length(living_targets))
		return ..()
	sortTim(living_targets, GLOBAL_PROC_REF(cmp_mob_health))
	return living_targets[living_targets.len]

/// Selects candidates carrying the trait configured in trait_key before candidates without it.
/datum/target_priority_strategy/prioritize_trait
	/// Blackboard key holding the trait which identifies preferred targets.
	var/trait_key = BB_TARGET_PRIORITY_TRAIT

/datum/target_priority_strategy/prioritize_trait/get_target_priority(datum/ai_controller/controller, atom/target)
	return HAS_TRAIT(target, controller.blackboard[trait_key]) ? 2 : 1

/datum/target_priority_strategy/prioritize_trait/select_target(datum/ai_controller/controller, list/atom/targets)
	var/list/priority_targets = list()
	var/priority_trait = controller.blackboard[trait_key]
	for(var/atom/target in targets)
		if(HAS_TRAIT(target, priority_trait))
			priority_targets += target
	return ..(controller, length(priority_targets) ? priority_targets : targets)

/// Chooses a nonempty target type tier by weight, then randomly chooses a target within that tier.
/// This prevents a large number of low-priority candidates from drowning out one high-priority candidate.
/datum/target_priority_strategy/type_weighted
	/// Blackboard key holding an ordered associative list of target typepaths to weights.
	var/priorities_key = BB_STEAL_TARGET_PRIORITIES
	/// Blackboard key holding the weight for targets which match no configured type.
	var/fallback_priority_key = BB_STEAL_FALLBACK_PRIORITY

/datum/target_priority_strategy/type_weighted/proc/matches_priority_type(atom/target, priority_type)
	return istype(target, priority_type)

/datum/target_priority_strategy/type_weighted/get_target_priority(datum/ai_controller/controller, atom/target)
	var/list/priorities = controller.blackboard[priorities_key]
	for(var/priority_type in priorities)
		if(matches_priority_type(target, priority_type))
			return priorities[priority_type]
	return controller.blackboard[fallback_priority_key] || 1

/datum/target_priority_strategy/type_weighted/select_target(datum/ai_controller/controller, list/atom/targets)
	var/list/priorities = controller.blackboard[priorities_key]
	if(!length(priorities))
		return ..()

	var/list/type_buckets = list()
	var/list/fallback_targets = list()
	for(var/atom/target as anything in targets)
		var/matched_type
		for(var/priority_type in priorities)
			if(matches_priority_type(target, priority_type))
				matched_type = priority_type
				break
		if(isnull(matched_type))
			fallback_targets += target
			continue
		var/list/bucket = type_buckets[matched_type]
		if(isnull(bucket))
			bucket = list()
			type_buckets[matched_type] = bucket
		bucket += target

	var/static/fallback_tier = "fallback"
	var/list/available_weights = list()
	for(var/priority_type in priorities)
		if(length(type_buckets[priority_type]))
			available_weights[priority_type] = priorities[priority_type]
	if(length(fallback_targets))
		available_weights[fallback_tier] = controller.blackboard[fallback_priority_key] || 1

	var/selected_tier = pick_weight(available_weights)
	var/list/selected_targets = selected_tier == fallback_tier ? fallback_targets : type_buckets[selected_tier]
	return pick(selected_targets)
