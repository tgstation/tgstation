/datum/storage/duffel
	max_total_storage = 30
	max_slots = 21

// Syndi bags get some FUN extras
// You can fit any 3 bulky objects (assuming they're in the whitelist)
// Should have traitorus stuff in here, not just useful big things
// Idea is to allow for things we typically restrict in exchange for going loud
/datum/storage/duffel/syndicate
	silent = TRUE
	exception_max = 3

/datum/storage/duffel/syndicate/New()
	. = ..()

	var/static/list/exception_cache = typecacheof(list(
		/obj/item/gun,
		/obj/item/staff/bostaff,
		/obj/item/deployable_turret_folded,
		/obj/item/cardboard_cutout,
		/obj/item/dualsaber,
		/obj/item/fireaxe,
		/obj/item/pneumatic_cannon,
		/obj/item/spear,
		/obj/item/powersink,
		/obj/item/transfer_valve,
		/obj/item/food/cheese/royal,
		/obj/item/food/powercrepe,
		/obj/item/melee/cleric_mace,
		/obj/item/tank/jetpack,
		/obj/item/watertank,
		/obj/item/clothing/shoes/winterboots/ice_boots/eva,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/armor/heavy,
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/suit/utility,
		/obj/item/nullrod,
		/obj/item/storage/bag/money,
		/obj/item/kinetic_crusher,
		/obj/item/melee/ghost_sword,
		/obj/item/melee/cleaving_saw,
		/obj/item/bodypart/head,
	))
	exception_hold = exception_cache
