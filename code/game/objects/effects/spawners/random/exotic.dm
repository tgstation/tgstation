/obj/effect/spawner/random/exotic
	name = "exotic spawner"
	desc = "Super duper rare stuff."

/obj/effect/spawner/random/exotic/technology
	name = "technology spawner"
	icon_state = "disk"
	spawn_loot_count = 2
	loot = list( // Space loot spawner. Couple of random bits of technology-adjacent stuff including anomaly cores and BEPIS techs.
		/obj/item/raw_anomaly_core/random,
		/obj/item/disk/design_disk/bepis,
		/obj/item/disk/computer/syndicate/camera_app,
	)

/obj/effect/spawner/random/exotic/languagebook
	name = "language book spawner"
	icon_state = "book"
	loot = list( // A single roundstart species language book.
		/obj/item/language_manual/roundstart_species = 96,
		/obj/item/book/granter/sign_language = 10,
		/obj/item/language_manual/piratespeak = 4,
		/obj/item/language_manual/roundstart_species/five = 3,
		/obj/item/language_manual/roundstart_species/unlimited = 1,
	)

/obj/effect/spawner/random/exotic/tool
	name = "exotic tool spawner"
	icon_state = "wrench"
	loot = list( // Some sort of random and rare tool.
		/obj/effect/spawner/random/engineering/tool_alien,
		/obj/effect/spawner/random/medical/surgery_tool_alien,
		/obj/effect/spawner/random/engineering/tool_advanced,
	)

/obj/effect/spawner/random/exotic/syndie
	name = "syndie cosmetic spawner"
	icon_state = "syndicate"
	spawn_loot_count = 2
	loot = list( // A selection of cosmetic syndicate items. Just a couple. No space suits or weapons.
		/obj/effect/spawner/random/clothing/syndie = 8,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
		/obj/effect/spawner/random/entertainment/cigarette_pack = 1,
	)

/obj/effect/spawner/random/exotic/antag_gear_weak
	name = "loot weak"
	icon_state = "syndi_toolbox"
	loot = list(
		/obj/item/clothing/glasses/science/night = 15,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 10,
		/obj/item/storage/toolbox/syndicate = 10,
		/obj/item/shield/riot = 10,
		/obj/item/storage/box/syndie_kit/chameleon = 10,
		/obj/item/knife/combat = 10,
		/obj/item/grenade/clusterbuster/smoke = 10,
		/obj/item/stack/sheet/mineral/diamond{amount = 15} = 5,
		/obj/item/stack/sheet/mineral/uranium{amount = 15} = 5,
		/obj/item/stack/sheet/mineral/plasma{amount = 15} = 5,
		/obj/item/stack/sheet/mineral/gold{amount = 15} = 5,
		/obj/item/implantcase/deathrattle = 5,
	)

/obj/effect/spawner/random/exotic/antag_gear
	name = "antag gear"
	icon_state = "esword"
	loot = list(
		/obj/item/mod/control/pre_equipped/empty/syndicate = 9,
		/obj/item/mod/control/pre_equipped/responsory/inquisitory/syndie/less_mods = 1,
		/obj/item/mod/module/energy_shield/prototype = 2,
		/obj/item/mod/module/jetpack/advanced = 2,
		/obj/item/mod/module/visor/night = 2,
		/obj/item/mod/module/storage/syndicate = 2,
		/obj/item/mod/module/jetpack/advanced = 2,
		/obj/item/gun/ballistic/automatic/pistol/m1911 = 5,//replaces makarov
		/obj/item/melee/energy/sword/saber/blue = 1,
		/obj/item/pen/edagger = 4,
		/obj/item/autosurgeon/syndicate/anti_stun/single_use = 2,
		/obj/item/autosurgeon/syndicate/emaggedsurgerytoolset/single_use = 3,
		/obj/item/climbing_hook/syndicate = 5,
		/obj/item/dualsaber/toy = 5,
		/obj/item/card/emag = 5,
		/obj/item/storage/box/syndie_kit/imp_storage = 5,
		/obj/item/storage/box/syndie_kit/imp_radio = 5,
		/obj/item/gun/ballistic/automatic/napad = 1,
		/obj/item/gun/ballistic/automatic/smartgun = 4,
		/obj/item/flashlight/lantern/syndicate = 5,
		/obj/item/reagent_containers/spray/syndicate = 5,
		/obj/item/storage/box/survival/syndie = 5,
		/obj/item/storage/box/evilmeds = 5,
		/obj/item/storage/box/syndie_kit/space = 5,
		/obj/effect/spawner/random/exotic/antag_sub_spawner = 1,
		/obj/item/storage/box/stockparts/deluxe = 4,
		/obj/item/storage/box/alchemist_random_chems = 5,
	)

/obj/effect/spawner/random/exotic/antag_sub_spawner
	name = "antag gear sub spawner"
	loot = list(
		/obj/effect/spawner/random/exotic/antag_gear = 98,
		/obj/item/storage/box/syndicate/bundle_b = 1,
		/obj/item/storage/box/syndicate/bundle_a = 1,
	)

/obj/effect/spawner/random/exotic/snow_gear
	name = "snow gear"
	icon_state = "snowman"
	loot = list(
		/obj/item/toy/snowball = 6,
		/obj/item/stack/sheet/mineral/snow{amount = 25} = 2,
		/obj/item/shovel = 2,
	)

/obj/effect/spawner/random/exotic/ripley
	name = "ripley spawner"
	icon_state = "ripley"
	loot = list(
		/obj/structure/mecha_wreckage/ripley = 3,
		/obj/vehicle/sealed/mecha/ripley/mining = 1,
	)
