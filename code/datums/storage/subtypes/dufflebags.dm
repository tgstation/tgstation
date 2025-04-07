///Normal duffle bag
/datum/storage/duffel
	max_total_storage = 30
	max_slots = 21

/datum/storage/duffel/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	set_holdable(exception_hold_list = /obj/item/fish_tank)

// Syndi bags get some FUN extras
// You can fit any 2 bulky objects (assuming they're in the whitelist)
// Should have traitorus stuff in here, not just useful big things
// Idea is to allow for things we typically restrict in exchange for going loud
/datum/storage/duffel/syndicate
	silent = TRUE
	exception_max = 2

/datum/storage/duffel/syndicate/New(
	atom/parent,
	max_slots,
	max_specific_storage,
	max_total_storage,
)
	. = ..()
	var/static/list/exception_type_list = list(
		// Gun and gun-related accessories
		/obj/item/gun,
		/obj/item/pneumatic_cannon,
		// Melee
		/obj/item/kinetic_crusher, //mostly
		/obj/item/dualsaber,
		/obj/item/staff/bostaff,
		/obj/item/fireaxe,
		/obj/item/crowbar/mechremoval,
		/obj/item/spear,
		/obj/item/nullrod,
		/obj/item/melee/cleric_mace,
		/obj/item/melee/ghost_sword,
		/obj/item/melee/cleaving_saw,
		// Deployables
		/obj/item/transfer_valve,
		/obj/item/powersink,
		/obj/item/deployable_turret_folded,
		/obj/item/cardboard_cutout,
		/obj/item/gibtonite,
		// Sustenance
		/obj/item/food/cheese/royal,
		/obj/item/food/powercrepe,
		// Back Items
		/obj/item/tank/jetpack,
		/obj/item/watertank,
		// Skub
		/obj/item/skub,
		// Bulky Supplies
		/obj/item/mecha_ammo,
		/obj/item/golem_shell,
		// Clothing
		/obj/item/clothing/shoes/winterboots/ice_boots/eva,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/armor/heavy,
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/suit/utility,
		// Storage
		/obj/item/storage/bag/money,
		// Heads!
		/obj/item/bodypart/head,
		// Fish
		/obj/item/fish,
		/obj/item/fish_tank,
	)

	set_holdable(exception_hold_list = exception_type_list)

	//...So we can run this without it generating a line for every subtype.
	var/list/desc = list()
	for(var/obj/item/valid_item as anything in exception_type_list)
		desc += "\a [initial(valid_item.name)]"
	can_hold_description = "\n\t[span_notice("[desc.Join("\n\t")]")]"
