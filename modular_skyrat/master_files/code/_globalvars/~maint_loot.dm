//Loot pool used by default maintenance loot spawners
GLOBAL_LIST_INIT(maintenance_loot, list(
	GLOB.trash_loot = MAINT_TRASH_WEIGHT,
	GLOB.common_loot = MAINT_COMMON_WEIGHT,
	GLOB.uncommon_loot = MAINT_UNCOMMON_WEIGHT,
	GLOB.oddity_loot = MAINT_ODD_WEIGHT,
))

GLOBAL_LIST_INIT(ratking_trash, list(//Garbage: used by the regal rat mob when spawning garbage.
	/obj/item/cigbutt,
	/obj/item/trash/cheesie,
	/obj/item/trash/candy,
	/obj/item/trash/chips,
	/obj/item/trash/pistachios,
	/obj/item/trash/popcorn,
	/obj/item/trash/raisins,
	/obj/item/trash/sosjerky,
	/obj/item/trash/syndi_cakes
))

GLOBAL_LIST_INIT(ratking_coins, list(//Coins: Used by the regal rat mob when spawning coins.
	/obj/item/coin/iron,
	/obj/item/coin/silver,
	/obj/item/coin/plastic,
	/obj/item/coin/titanium
))
