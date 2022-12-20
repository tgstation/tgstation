/// Represents the concept of a stock part.
/// One is created for every stock part type for every level.
/// Machines have these inside their component_parts.
/// For example, scanning modules use /datum/stock_part/scanning_module.
/// In machines, you can perform a loop through something like
/// `for (var/datum/stock_part/scanning_module/part in component_parts)`
/datum/stock_part
	/// Better parts have higher tiers
	var/tier

	/// What object does this stock part refer to?
	var/obj/item/physical_object_type

	/// What's the base path that this stock part refers to?
	/// For example, a tier 2 capacitor will have a physical_object_type
	/// of /obj/item/capacitor/tier2, but a physical_object_base_type of
	/// /obj/item/capacitor
	var/obj/item/physical_object_base_type

	/// A single instance of the physical object type.
	/// Used for icons, should never be moved out.
	var/obj/item/physical_object_reference

/datum/stock_part/New()
	physical_object_reference = new physical_object_type

/datum/stock_part/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	stack_trace("[type] is trying to Destroy. It is a singleton, this should not be happening")
	return QDEL_HINT_LETMELIVE

/// Returns the name of the physical object
/datum/stock_part/proc/name()
	return initial(physical_object_type.name)

/// Map of physical stock part types to their /datum/stock_part
GLOBAL_LIST_EMPTY_TYPED(stock_part_datums_per_object, /datum/stock_part)

/// Map of stock part type to their singleton
GLOBAL_LIST_INIT(stock_part_datums, generate_stock_part_datums())

/proc/generate_stock_part_datums()
	var/list/stock_part_datums = list()

	for (var/datum/stock_part/stock_part_type as anything in subtypesof(/datum/stock_part))
		var/singleton = new stock_part_type
		stock_part_datums[stock_part_type] = singleton

		// Relying on GLOB ordering here somewhat.
		// If this changes, it'll error in CI.
		GLOB.stock_part_datums_per_object[initial(stock_part_type.physical_object_type)] = singleton

	return stock_part_datums

/// Returns the energy rating of the stock part given a level.
/// The higher this is, the more power machines with these parts will consume.
/datum/stock_part/proc/energy_rating()
	switch (tier)
		if (1)
			return 1
		if (2)
			return 3
		if (3)
			return 5
		if (4)
			return 10
		else
			CRASH("Invalid level given to energy_rating: [tier]")

/datum/stock_part/scanning_module
	tier = 1
	physical_object_type = /obj/item/stock_parts/scanning_module
	physical_object_base_type = /obj/item/stock_parts/scanning_module

/datum/stock_part/scanning_module/tier2
	tier = 2
	physical_object_type = /obj/item/stock_parts/scanning_module/adv

/datum/stock_part/scanning_module/tier3
	tier = 3
	physical_object_type = /obj/item/stock_parts/scanning_module/phasic

/datum/stock_part/scanning_module/tier4
	tier = 4
	physical_object_type = /obj/item/stock_parts/scanning_module/triphasic
