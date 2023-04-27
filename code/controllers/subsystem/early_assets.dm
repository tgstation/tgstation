/// Initializes any assets that need to be loaded ASAP.
/// This houses preference menu assets, since they can be loaded at any time,
/// most dangerously before the atoms SS initializes.
/// Thus, we want it to fail consistently in CI as if it would've if a player
/// opened it up early.
SUBSYSTEM_DEF(early_assets)
	name = "Early Assets"
	init_order = INIT_ORDER_EARLY_ASSETS
	flags = SS_NO_FIRE

/datum/controller/subsystem/early_assets/OnConfigLoad()
	if(CONFIG_GET(flag/disable_early_assets))
		flags |= SS_NO_INIT

/datum/controller/subsystem/early_assets/Initialize()
	for (var/datum/asset/asset_type as anything in subtypesof(/datum/asset))
		if (initial(asset_type._abstract) == asset_type)
			continue

		if (!initial(asset_type.early))
			continue

		var/datum/asset/asset = load_asset_datum(asset_type)
		if (!asset)
			stack_trace("Could not initialize early asset [asset_type]!")
			continue

		CHECK_TICK
		if (asset.should_generate())
			while(TRUE)
				asset.queued_generation()
				if(!TICK_CHECK)
					break
				stoplag()

		SEND_SIGNAL(asset, COMSIG_ASSET_GENERATED)

	return SS_INIT_SUCCESS
