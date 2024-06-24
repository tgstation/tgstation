/datum/armament_entry/company_import/donk
	category = DONK_CO_NAME
	company_bitflag = CARGO_COMPANY_DONK

// Donk Co foods, like donk pockets and ready donk

/datum/armament_entry/company_import/donk/food
	subcategory = "Microwave Foods"
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/donk/food/ready_donk
	item_type = /obj/item/food/ready_donk

/datum/armament_entry/company_import/donk/food/ready_donkhiladas
	item_type = /obj/item/food/ready_donk/donkhiladas

/datum/armament_entry/company_import/donk/food/ready_donk_n_cheese
	item_type = /obj/item/food/ready_donk/mac_n_cheese

/datum/armament_entry/company_import/donk/food/pockets
	item_type = /obj/item/storage/box/donkpockets

/datum/armament_entry/company_import/donk/food/berry_pockets
	item_type = /obj/item/storage/box/donkpockets/donkpocketberry

/datum/armament_entry/company_import/donk/food/honk_pockets
	item_type = /obj/item/storage/box/donkpockets/donkpockethonk

/datum/armament_entry/company_import/donk/food/pizza_pockets
	item_type = /obj/item/storage/box/donkpockets/donkpocketpizza

/datum/armament_entry/company_import/donk/food/spicy_pockets
	item_type = /obj/item/storage/box/donkpockets/donkpocketspicy

/datum/armament_entry/company_import/donk/food/teriyaki_pockets
	item_type = /obj/item/storage/box/donkpockets/donkpocketteriyaki

// Random donk toy items, fake jumpsuits, balloons, so on

// Donk merch gives you more interest than other items, buy donk bling and get company interest faster!

/datum/armament_entry/company_import/donk/merch
	subcategory = "Donk Co. Merchandise"

/datum/armament_entry/company_import/donk/merch/donk_carpet
	item_type = /obj/item/stack/tile/carpet/donk/thirty
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/donk/merch/tacticool_turtleneck
	item_type = /obj/item/clothing/under/syndicate/tacticool
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/donk/merch/tacticool_turtleneck_skirt
	item_type = /obj/item/clothing/under/syndicate/tacticool/skirt
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/donk/merch/fake_centcom_turtleneck
	item_type = /obj/item/clothing/under/rank/centcom/officer/replica
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/donk/merch/fake_centcom_turtleneck_skirt
	item_type = /obj/item/clothing/under/rank/centcom/officer_skirt/replica
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/donk/merch/snack_rig
	item_type = /obj/item/storage/belt/military/snack
	cost = PAYCHECK_COMMAND

/datum/armament_entry/company_import/donk/merch/fake_syndie_suit
	item_type = /obj/item/storage/box/fakesyndiesuit
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/donk/merch/valid_bloon
	item_type = /obj/item/toy/balloon/arrest
	cost = PAYCHECK_CREW

// Donksoft weapons

/datum/armament_entry/company_import/donk/foamforce
	subcategory = "Foam Force (TM) Blasters"

/datum/armament_entry/company_import/donk/foamforce/foam_pistol
	item_type = /obj/item/gun/ballistic/automatic/pistol/toy
	cost = PAYCHECK_COMMAND

/datum/armament_entry/company_import/donk/foamforce/foam_shotgun
	item_type = /obj/item/gun/ballistic/shotgun/toy/unrestricted
	cost = PAYCHECK_COMMAND

/datum/armament_entry/company_import/donk/foamforce/foam_smg
	item_type = /obj/item/gun/ballistic/automatic/toy/unrestricted
	cost = PAYCHECK_COMMAND * 3

/datum/armament_entry/company_import/donk/foamforce/foam_c20
	item_type = /obj/item/gun/ballistic/automatic/c20r/toy/unrestricted
	cost = PAYCHECK_COMMAND * 3

/datum/armament_entry/company_import/donk/foamforce/foam_lmg
	item_type = /obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted
	cost = PAYCHECK_COMMAND * 5

/datum/armament_entry/company_import/donk/mod_modules
	subcategory = "Donk Co. MOD modules"
	cost = PAYCHECK_COMMAND

/*
/datum/armament_entry/company_import/donk/mod_modules/dart_collector_safe
	item_type = /obj/item/mod/module/recycler/donk/safe
	cost = PAYCHECK_COMMAND

/datum/armament_entry/company_import/donk/mod_modules/dart_collector
	item_type = /obj/item/mod/module/recycler/donk
	cost = PAYCHECK_COMMAND * 4
*/

/datum/armament_entry/company_import/donk/foamforce_ammo
	subcategory = "Foam Force (TM) Dart Accessories"
	cost = PAYCHECK_CREW

/datum/armament_entry/company_import/donk/foamforce_ammo/darts
	item_type = /obj/item/ammo_box/foambox
	cost = PAYCHECK_LOWER

/datum/armament_entry/company_import/donk/foamforce_ammo/riot_darts
	item_type = /obj/item/ammo_box/foambox/riot
	cost = PAYCHECK_COMMAND * 1.5

/datum/armament_entry/company_import/donk/foamforce_ammo/pistol_mag
	item_type = /obj/item/ammo_box/magazine/toy/pistol

/datum/armament_entry/company_import/donk/foamforce_ammo/smg_mag
	item_type = /obj/item/ammo_box/magazine/toy/smg

/datum/armament_entry/company_import/donk/foamforce_ammo/smgm45_mag
	item_type = /obj/item/ammo_box/magazine/toy/smgm45

/datum/armament_entry/company_import/donk/foamforce_ammo/m762_mag
	item_type = /obj/item/ammo_box/magazine/toy/m762
