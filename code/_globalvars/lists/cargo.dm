GLOBAL_LIST_INIT(discountable_packs, init_discountable_packs())

GLOBAL_LIST_INIT(exports_list, init_Exports())

GLOBAL_LIST_INIT(pack_discount_odds, list(
	SUPPLY_PACK_STD_DISCOUNTABLE = 45,
	SUPPLY_PACK_UNCOMMON_DISCOUNTABLE = 4,
	SUPPLY_PACK_RARE_DISCOUNTABLE = 1,
))

GLOBAL_LIST_EMPTY(supplypod_loading_bays)

/// Caled when the global discount pack list is initialized
/proc/init_discountable_packs()
	var/list/packs = list()
	for(var/datum/supply_pack/prototype as anything in subtypesof(/datum/supply_pack))
		var/discountable = initial(prototype.discountable)
		if(discountable)
			LAZYADD(packs[discountable], prototype)
	return packs

/// Called when the global exports_list is empty, and sets it up.
/proc/init_Exports()
	var/list/exports = list()
	for(var/datum/export/subtype as anything in valid_subtypesof(/datum/export))
		exports += new subtype
	return exports
