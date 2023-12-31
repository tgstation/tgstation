#define STARTING_COMMON_CONTRACTS 3
#define STARTING_UNCOMMON_CONTRACTS 2
#define STARTING_RARE_CONTRACTS 1
/datum/component/uplink/proc/become_contractor()
	uplink_handler.uplink_flag = UPLINK_CONTRACTORS
	uplink_handler.clear_secondaries()
	uplink_handler.generate_objectives(list(
		/datum/traitor_objective/target_player/kidnapping/common = STARTING_COMMON_CONTRACTS,
		/datum/traitor_objective/target_player/kidnapping/uncommon = STARTING_UNCOMMON_CONTRACTS,
		/datum/traitor_objective/target_player/kidnapping/rare = STARTING_RARE_CONTRACTS,
	))
	for(var/item as anything in subtypesof(/datum/contractor_item))
		uplink_handler.contractor_market_items += new item

#undef STARTING_COMMON_CONTRACTS
#undef STARTING_UNCOMMON_CONTRACTS
#undef STARTING_RARE_CONTRACTS
