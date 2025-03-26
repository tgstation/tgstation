/// Initializes any assets that need to be loaded ASAP.
/// This houses preference menu assets, since they can be loaded at any time,
/// most dangerously before the atoms SS initializes.
/// Thus, we want it to fail consistently in CI as if it would've if a player
/// opened it up early.
SUBSYSTEM_DEF(early_assets)
	name = "Early Assets"
	dependencies = list(
		/datum/controller/subsystem/processing/reagents,
		/datum/controller/subsystem/processing/greyscale
	)
	dependents = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms
	)
	init_stage = INITSTAGE_EARLY
	flags = SS_NO_FIRE

/datum/controller/subsystem/early_assets/Initialize()
	for (var/datum/asset/asset_type as anything in subtypesof(/datum/asset))
		if (initial(asset_type._abstract) == asset_type)
			continue

		if (!initial(asset_type.early))
			continue

		if (!load_asset_datum(asset_type))
			stack_trace("Could not initialize early asset [asset_type]!")

		CHECK_TICK

	return SS_INIT_SUCCESS
