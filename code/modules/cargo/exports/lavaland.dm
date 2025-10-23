//Tendril chest artifacts and ruin loot.
//Consumable or one-use items like the magic D20 and gluttony's blessing are omitted
/datum/export/lavaland
	abstract_type = /datum/export/lavaland
	unit_name = "lava planet artifact"
	/// Prefix to add to our unit name after generation
	var/prefix = null

/datum/export/lavaland/New()
	. = ..()
	switch (SSmapping.current_map.minetype)
		if (MINETYPE_NONE)
			unit_name = "unknown artifact"
		if (MINETYPE_LAVALAND)
			unit_name = "lava planet artifact"
		if (MINETYPE_ICE)
			unit_name = "ice moon artifact"

	if (prefix)
		unit_name = "[prefix] [unit_name]"

/datum/export/lavaland/minor
	cost = CARGO_CRATE_VALUE * 20
	prefix = "minor"
	export_types = list(
		/obj/item/immortality_talisman,
		/obj/item/book_of_babel,
		/obj/item/wisp_lantern,
		/obj/item/organ/cyberimp/arm/toolkit/shard/katana,
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
		/obj/item/clockwork_alloy,
	)

/datum/export/lavaland/major //valuable chest/ruin loot, minor megafauna loot
	cost = CARGO_CRATE_VALUE * 40
	export_types = list(
		/obj/item/dragons_blood,
		/obj/item/guardian_creator/miner,
		/obj/item/drake_remains,
		/obj/item/lava_staff,
		/obj/item/melee/ghost_sword,
		/obj/item/prisoncube,
		/obj/item/rod_of_asclepius,
		/obj/item/knife/hunting/wildhunter,
		/obj/item/cain_and_abel,
	)

//Megafauna loot, except for ash drakes

/datum/export/lavaland/megafauna
	cost = CARGO_CRATE_VALUE * 80
	prefix = "major"
	export_types = list(
		/obj/item/hierophant_club,
		/obj/item/melee/cleaving_saw,
		/obj/item/organ/vocal_cords/colossus,
		/obj/machinery/anomalous_crystal,
		/obj/item/mayhem,
		/obj/item/soulscythe,
		/obj/item/storm_staff,
		/obj/item/clothing/suit/hooded/hostile_environment,
		/obj/item/wendigo_blood,
		/obj/item/wendigo_skull,
		/obj/item/ice_energy_crystal,
		/obj/item/resurrection_crystal,
		/obj/item/clothing/shoes/winterboots/ice_boots/ice_trail,
		/obj/item/pickaxe/drill/jackhammer/demonic,
	)

/datum/export/lavaland/megafauna/total_printout(datum/export_report/ex, notes = TRUE) //in the unlikely case a miner feels like selling megafauna loot
	. = ..()
	if(. && notes)
		. += " On behalf of the Nanotrasen RnD division: Thank you for your hard work."
