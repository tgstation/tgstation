SUBSYSTEM_DEF(assets)
	name = "Assets"
	init_order = INIT_ORDER_ASSETS
	priority = FIRE_PRIORITY_ASSETS
	var/list/datum/asset_cache_item/cache = list()
	var/datum/asset_transport/transport = new()
	var/list/datum/asset/generate_queue = list()

/datum/controller/subsystem/assets/OnConfigLoad()
	var/newtransporttype = /datum/asset_transport
	switch (CONFIG_GET(string/asset_transport))
		if ("webroot")
			newtransporttype = /datum/asset_transport/webroot

	if (newtransporttype == transport.type)
		return

	var/datum/asset_transport/newtransport = new newtransporttype ()
	if (newtransport.validate_config())
		transport = newtransport
	transport.Load()



/datum/controller/subsystem/assets/Initialize()
	var/early_assets_disabled = CONFIG_GET(flag/disable_early_assets)
	for(var/type in typesof(/datum/asset))
		var/datum/asset/A = type
		if (type == initial(A._abstract))
			continue

		A = load_asset_datum(type)
		if (early_assets_disabled || !A.early)
			if (A.should_generate())
				generate_queue += A
			else
				SEND_SIGNAL(A, COMSIG_ASSET_GENERATED)
		CHECK_TICK

	transport.Initialize(cache)

	return SS_INIT_SUCCESS


/datum/controller/subsystem/assets/fire(resumed)
	while(length(generate_queue))
		var/datum/asset/to_load = generate_queue[generate_queue.len]

		to_load.queued_generation()

		if(MC_TICK_CHECK)
			return

		SEND_SIGNAL(to_load, COMSIG_ASSET_GENERATED)
		generate_queue.len--


/datum/controller/subsystem/assets/Recover()
	cache = SSassets.cache
