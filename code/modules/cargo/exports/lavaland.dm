//Tendril chest artifacts and ruin loot.
//Consumable or one-use items like the magic D20 and gluttony's blessing are omitted

/datum/export/lavaland/minor
	cost = CARGO_CRATE_VALUE * 20
	unit_name = "minor lava planet artifact"
	export_types = list(
		/obj/item/immortality_talisman,
		/obj/item/book_of_babel,
		/obj/item/wisp_lantern,
		/obj/item/organ/cyberimp/arm/shard/katana,
		/obj/item/clothing/neck/cloak/wolf_coat,
		/obj/item/clothing/glasses/godeye,
		/obj/item/clothing/neck/necklace/memento_mori,
		/obj/item/organ/heart/cursed/wizard,
		/obj/item/clothing/suit/hooded/cloak/drake,
		/obj/item/ship_in_a_bottle,
		/obj/item/clothing/shoes/clown_shoes/banana_shoes,
		/obj/item/gun/magic/staff/honk,
		/obj/item/knife/envy,
		/obj/item/gun/ballistic/revolver/russian/soul,
		/obj/item/veilrender/vealrender,
		/obj/item/clothing/suit/hooded/berserker,
		/obj/item/freeze_cube,
		/obj/item/soulstone/anybody/mining,
		/obj/item/clothing/gloves/gauntlets,
		/obj/item/jacobs_ladder,
		/obj/item/borg/upgrade/modkit/lifesteal,
	)

/datum/export/lavaland/major //valuable chest/ruin loot, minor megafauna loot
	cost = CARGO_CRATE_VALUE * 40
	unit_name = "lava planet artifact"
	export_types = list(
		/obj/item/dragons_blood,
		/obj/item/guardian_creator/miner,
		/obj/item/drake_remains,
		/obj/item/lava_staff,
		/obj/item/melee/ghost_sword,
		/obj/item/prisoncube,
		/obj/item/rod_of_asclepius,
	)

//Megafauna loot, except for ash drakes

/datum/export/lavaland/megafauna
	cost = CARGO_CRATE_VALUE * 80
	unit_name = "major lava planet artifact"
	export_types = list(
		/obj/item/hierophant_club,
		/obj/item/melee/cleaving_saw,
		/obj/item/organ/vocal_cords/colossus,
		/obj/machinery/anomalous_crystal,
		/obj/item/mayhem,
		/obj/item/soulscythe,
		/obj/item/storm_staff,
		/obj/item/clothing/suit/hooded/hostile_environment,
	)

/datum/export/lavaland/megafauna/total_printout(datum/export_report/ex, notes = TRUE) //in the unlikely case a miner feels like selling megafauna loot
	. = ..()
	if(. && notes)
		. += " On behalf of the Nanotrasen RnD division: Thank you for your hard work."
