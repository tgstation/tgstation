// Lazy fishing spot element so fisheable turfs do not have a component each since they're usually pretty common on their respective maps (lava/water/etc)
/datum/element/lazy_fishing_spot
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	argument_hash_start_idx = 2
	var/configuration

/datum/element/lazy_fishing_spot/Attach(datum/target, configuration)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	if(!configuration)
		CRASH("Lazy fishing spot had no configuration passed in.")
	src.configuration = configuration

	RegisterSignal(target, COMSIG_PRE_FISHING, PROC_REF(create_fishing_spot))

/datum/element/lazy_fishing_spot/Detach(datum/target)
	UnregisterSignal(target, COMSIG_PRE_FISHING)
	return ..()

/datum/element/lazy_fishing_spot/proc/create_fishing_spot(datum/source)
	SIGNAL_HANDLER

	source.AddComponent(/datum/component/fishing_spot, configuration)
	Detach(source)
