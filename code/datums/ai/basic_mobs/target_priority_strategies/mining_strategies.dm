/// Ashies get lower priorities than humans
#define AGGRO_PRIORITY_ASHWALKER 1
/// Everyone by default
#define AGGRO_PRIORITY_HUMAN 2
/// Mobs who have attacked someone in our view recently
#define AGGRO_PRIORITY_MINER 8
/// NODE drone priority
#define AGGRO_PRIORITY_NODE 10
/// NODE drone priority for legion broods and brimdemons
#define AGGRO_PRIORITY_NODE_LOW_PRIO 3
/// Priority for mobs we're retaliating against
#define AGGRO_PRIORITY_RETALIATE 15

/// Prioritizes NODE drones until attacked, then swaps back onto miners
/datum/target_priority_strategy/mining
	/// For how long do we keep aggro on mobs over NODE drones?
	var/retaliate_aggro_memory = 25 SECONDS
	/// Priority for NODE drones
	var/node_priority = AGGRO_PRIORITY_NODE

/datum/target_priority_strategy/mining/get_target_priority(datum/ai_controller/controller, mob/living/target)
	if (!isliving(target))
		return ..()

	// If a mob recently attacked us, it has higher priority than NODE drones, otherwise we care about NODE drones more
	var/list/shitlist = controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
	if (shitlist?[target] && (shitlist[target] + retaliate_aggro_memory > world.time))
		// Does not decay until it passes the retaliate memory threshold to avoid constant target swapping
		return AGGRO_PRIORITY_RETALIATE

	if (istype(target, /mob/living/basic/node_drone))
		return node_priority

	// Check if they've recently attacked any of our friends, if so - increase their priority by 1 for each attack in the past [retaliate_aggro_memory] seconds
	var/list/allies_shitlist = controller.blackboard[BB_MINING_MOB_REINFORCEMENTS_REQUESTS]
	var/list/target_requests = allies_shitlist?[target]
	if (!target_requests)
		return target.has_faction(FACTION_ASHWALKER) ? AGGRO_PRIORITY_ASHWALKER : AGGRO_PRIORITY_HUMAN

	var/aggro_boost = 0
	var/total_requests = length(target_requests)
	// Goes end-to-start because we do not care about requests older than [retaliate_aggro_memory]
	for (var/i in 1 to total_requests)
		var/request_time = target_requests[total_requests - i + 1]
		if (request_time + retaliate_aggro_memory < world.time)
			break
		aggro_boost += 1

	if (aggro_boost)
		return AGGRO_PRIORITY_MINER + aggro_boost
	return target.has_faction(FACTION_ASHWALKER) ? AGGRO_PRIORITY_ASHWALKER : AGGRO_PRIORITY_HUMAN

/datum/target_priority_strategy/mining/select_target(datum/ai_controller/controller, list/atom/targets)
	var/max_priority = 0
	var/min_distance = INFINITY
	var/lucky_fella = null

	// Selects highest priority targets, then picks the closest
	for (var/atom/target as anything in targets)
		var/target_prio = get_target_priority(controller, target)
		if (target_prio < max_priority)
			continue

		if (target_prio > max_priority)
			max_priority = target_prio
			min_distance = INFINITY

		var/target_dist = get_dist(controller.pawn, target)
		if (target_dist < min_distance)
			lucky_fella = target
			min_distance = target_dist

	return pick(lucky_fella)

/datum/target_priority_strategy/mining/low_node_priority
	// Higher than normal humans but will instantly pivot towards anyone who attacks or attacked mobs in our vicinity
	node_priority = AGGRO_PRIORITY_NODE_LOW_PRIO

#undef AGGRO_PRIORITY_ASHWALKER
#undef AGGRO_PRIORITY_HUMAN
#undef AGGRO_PRIORITY_MINER
#undef AGGRO_PRIORITY_NODE
#undef AGGRO_PRIORITY_NODE_LOW_PRIO
#undef AGGRO_PRIORITY_RETALIATE
