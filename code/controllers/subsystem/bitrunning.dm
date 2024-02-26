#define REDACTED "???"

SUBSYSTEM_DEF(bitrunning)
	name = "Bitrunning"
	flags = SS_NO_FIRE

	var/list/all_domains = list()

/datum/controller/subsystem/bitrunning/Initialize()
	InitializeDomains()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/bitrunning/proc/InitializeDomains()
	for(var/path in subtypesof(/datum/lazy_template/virtual_domain))
		all_domains += new path()

/// Compiles a list of available domains.
/datum/controller/subsystem/bitrunning/proc/get_available_domains(scanner_tier, points)
	var/list/levels = list()

	for(var/datum/lazy_template/virtual_domain/domain as anything in all_domains)
		if(domain.test_only)
			continue
		var/can_view = domain.difficulty < scanner_tier && domain.cost <= points + 5
		var/can_view_reward = domain.difficulty < (scanner_tier + 1) && domain.cost <= points + 3

		levels += list(list(
			"cost" = domain.cost,
			"desc" = can_view ? domain.desc : "Limited scanning capabilities. Cannot infer domain details.",
			"difficulty" = domain.difficulty,
			"id" = domain.key,
			"is_modular" = domain.is_modular,
			"has_secondary_objectives" = assoc_value_sum(domain.secondary_loot) ? TRUE : FALSE,
			"name" = can_view ? domain.name : REDACTED,
			"reward" = can_view_reward ? domain.reward_points : REDACTED,
		))

	return levels

#undef REDACTED
