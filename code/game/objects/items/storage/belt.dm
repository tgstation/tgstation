/obj/item/storage/belt
	name = "not actually a toolbelt"
	desc = "Can hold various things. This is the base type of /belt, are you sure you should have this?"
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utility"
	inhand_icon_state = "utility"
	worn_icon_state = "utility"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("whips", "lashes", "disciplines")
	attack_verb_simple = list("whip", "lash", "discipline")
	max_integrity = 300
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	w_class = WEIGHT_CLASS_BULKY

	///If this is true, the belt will gain overlays based on what it's holding
	var/content_overlays = FALSE

/obj/item/storage/belt/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins belting [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/storage/belt/update_overlays()
	. = ..()
	if(!content_overlays)
		return
	for(var/obj/item/I in contents)
		. += I.get_belt_overlay()

/obj/item/storage/belt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/attack_equip)
	update_appearance()

/obj/item/storage/belt/utility
	name = "toolbelt" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "Holds tools."
	icon_state = "utility"
	inhand_icon_state = "utility"
	worn_icon_state = "utility"
	content_overlays = TRUE
	custom_premium_price = PAYCHECK_CREW * 2
	drop_sound = 'sound/items/handling/toolbelt_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbelt_pickup.ogg'
	storage_type = /datum/storage/utility_belt

/obj/item/storage/belt/utility/chief
	name = "chief engineer's toolbelt"
	desc = "Holds tools, looks snazzy."
	icon_state = "utility_ce"
	inhand_icon_state = "utility_ce"
	worn_icon_state = "utility_ce"

/obj/item/storage/belt/utility/chief/full
	preload = TRUE

/obj/item/storage/belt/utility/chief/full/PopulateContents()
	return list(
		SSwardrobe.provide_type(/obj/item/screwdriver/power, null),
		SSwardrobe.provide_type(/obj/item/crowbar/power, null),
		SSwardrobe.provide_type(/obj/item/weldingtool/experimental, null),
		SSwardrobe.provide_type(/obj/item/multitool, null),
		SSwardrobe.provide_type(/obj/item/stack/cable_coil, null),
		SSwardrobe.provide_type(/obj/item/extinguisher/mini, null),
		SSwardrobe.provide_type(/obj/item/analyzer, null),
	)

/obj/item/storage/belt/utility/chief/full/get_types_to_preload()
	var/list/to_preload = list() //Yes this is a pain. Yes this is the point
	to_preload += /obj/item/screwdriver/power
	to_preload += /obj/item/crowbar/power
	to_preload += /obj/item/weldingtool/experimental
	to_preload += /obj/item/multitool
	to_preload += /obj/item/stack/cable_coil
	to_preload += /obj/item/extinguisher/mini
	to_preload += /obj/item/analyzer
	return to_preload

/obj/item/storage/belt/utility/full/PopulateContents()
	return list(
		SSwardrobe.provide_type(/obj/item/screwdriver, null),
		SSwardrobe.provide_type(/obj/item/wrench, null),
		SSwardrobe.provide_type(/obj/item/weldingtool, null),
		SSwardrobe.provide_type(/obj/item/crowbar, null),
		SSwardrobe.provide_type(/obj/item/wirecutters, null),
		SSwardrobe.provide_type(/obj/item/multitool, null),
		SSwardrobe.provide_type(/obj/item/stack/cable_coil, null),
	)

/obj/item/storage/belt/utility/full/get_types_to_preload()
	var/list/to_preload = list() //Yes this is a pain. Yes this is the point
	to_preload += /obj/item/screwdriver
	to_preload += /obj/item/wrench
	to_preload += /obj/item/weldingtool
	to_preload += /obj/item/crowbar
	to_preload += /obj/item/wirecutters
	to_preload += /obj/item/multitool
	to_preload += /obj/item/stack/cable_coil
	return to_preload

/obj/item/storage/belt/utility/full/powertools
	preload = FALSE

/obj/item/storage/belt/utility/full/powertools/PopulateContents()
	return list(
		/obj/item/screwdriver/power,
		/obj/item/crowbar/power,
		/obj/item/weldingtool/experimental,
		/obj/item/multitool,
		/obj/item/holosign_creator/atmos,
		/obj/item/extinguisher/mini,
		/obj/item/stack/cable_coil,
	)

/obj/item/storage/belt/utility/full/powertools/rcd/PopulateContents()
	return list(
		/obj/item/screwdriver/power,
		/obj/item/crowbar/power,
		/obj/item/weldingtool/experimental,
		/obj/item/multitool,
		/obj/item/construction/rcd/loaded/upgraded,
		/obj/item/extinguisher/mini,
		/obj/item/stack/cable_coil,
	)

/obj/item/storage/belt/utility/full/engi/PopulateContents()
	return list(
		SSwardrobe.provide_type(/obj/item/screwdriver, null),
		SSwardrobe.provide_type(/obj/item/wrench, null),
		SSwardrobe.provide_type(/obj/item/weldingtool/largetank, null),
		SSwardrobe.provide_type(/obj/item/crowbar, null),
		SSwardrobe.provide_type(/obj/item/wirecutters, null),
		SSwardrobe.provide_type(/obj/item/multitool, null),
		SSwardrobe.provide_type(/obj/item/stack/cable_coil, null),
	)

/obj/item/storage/belt/utility/full/engi/get_types_to_preload()
	var/list/to_preload = list() //Yes this is a pain. Yes this is the point
	to_preload += /obj/item/screwdriver
	to_preload += /obj/item/wrench
	to_preload += /obj/item/weldingtool/largetank
	to_preload += /obj/item/crowbar
	to_preload += /obj/item/wirecutters
	to_preload += /obj/item/multitool
	to_preload += /obj/item/stack/cable_coil
	return to_preload

/obj/item/storage/belt/utility/atmostech/PopulateContents()
	return list(
		SSwardrobe.provide_type(/obj/item/screwdriver, null),
		SSwardrobe.provide_type(/obj/item/wrench, null),
		SSwardrobe.provide_type(/obj/item/weldingtool, null),
		SSwardrobe.provide_type(/obj/item/crowbar, null),
		SSwardrobe.provide_type(/obj/item/wirecutters, null),
		SSwardrobe.provide_type(/obj/item/t_scanner, null),
		SSwardrobe.provide_type(/obj/item/extinguisher/mini, null),
	)

/obj/item/storage/belt/utility/atmostech/get_types_to_preload()
	var/list/to_preload = list() //Yes this is a pain. Yes this is the point
	to_preload += /obj/item/screwdriver
	to_preload += /obj/item/wrench
	to_preload += /obj/item/weldingtool
	to_preload += /obj/item/crowbar
	to_preload += /obj/item/wirecutters
	to_preload += /obj/item/t_scanner
	to_preload += /obj/item/extinguisher/mini
	return to_preload

/obj/item/storage/belt/utility/full/inducer/PopulateContents()
	return list(
		SSwardrobe.provide_type(/obj/item/screwdriver, null),
		SSwardrobe.provide_type(/obj/item/wrench, null),
		SSwardrobe.provide_type(/obj/item/weldingtool, null),
		SSwardrobe.provide_type(/obj/item/crowbar/red, null),
		SSwardrobe.provide_type(/obj/item/wirecutters, null),
		SSwardrobe.provide_type(/obj/item/multitool, null),
		SSwardrobe.provide_type(/obj/item/inducer, null),
	)

/obj/item/storage/belt/utility/full/inducer/get_types_to_preload()
	var/list/to_preload = list() //Yes this is a pain. Yes this is the point
	to_preload += /obj/item/screwdriver
	to_preload += /obj/item/wrench
	to_preload += /obj/item/weldingtool
	to_preload += /obj/item/crowbar
	to_preload += /obj/item/wirecutters
	to_preload += /obj/item/multitool
	to_preload += /obj/item/inducer
	return to_preload

/obj/item/storage/belt/utility/syndicate
	preload = FALSE

/obj/item/storage/belt/utility/syndicate/PopulateContents()
	return list(
		/obj/item/screwdriver/nuke,
		/obj/item/wrench/combat,
		/obj/item/weldingtool/largetank,
		/obj/item/crowbar,
		/obj/item/wirecutters,
		/obj/item/multitool,
		/obj/item/inducer/syndicate,
	)

/obj/item/storage/belt/medical
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medical"
	inhand_icon_state = "medical"
	worn_icon_state = "medical"
	drop_sound = 'sound/items/handling/toolbelt_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbelt_pickup.ogg'
	storage_type = /datum/storage/medical_belt

/obj/item/storage/belt/medical/paramedic
	name = "EMT belt"
	icon_state = "emt"
	inhand_icon_state = "security"
	worn_icon_state = "emt"
	preload = TRUE

/obj/item/storage/belt/medical/paramedic/PopulateContents()
	return list(
		SSwardrobe.provide_type(/obj/item/sensor_device, null),
		SSwardrobe.provide_type(/obj/item/stack/medical/gauze/twelve, null),
		SSwardrobe.provide_type(/obj/item/stack/medical/bone_gel, null),
		SSwardrobe.provide_type(/obj/item/stack/sticky_tape/surgical, null),
		SSwardrobe.provide_type(/obj/item/reagent_containers/syringe, null),
		SSwardrobe.provide_type(/obj/item/reagent_containers/cup/bottle/ammoniated_mercury, null),
		SSwardrobe.provide_type(/obj/item/reagent_containers/cup/bottle/formaldehyde, null),
	)

/obj/item/storage/belt/medical/paramedic/get_types_to_preload()
	var/list/to_preload = list() //Yes this is a pain. Yes this is the point
	to_preload += /obj/item/sensor_device
	to_preload += /obj/item/stack/medical/gauze/twelve
	to_preload += /obj/item/stack/medical/bone_gel
	to_preload += /obj/item/stack/sticky_tape/surgical
	to_preload += /obj/item/reagent_containers/syringe
	to_preload += /obj/item/reagent_containers/cup/bottle/ammoniated_mercury
	to_preload += /obj/item/reagent_containers/cup/bottle/formaldehyde
	return to_preload

/obj/item/storage/belt/medical/ert
	icon_state = "emt"
	inhand_icon_state = "security"
	worn_icon_state = "emt"
	preload = TRUE

/obj/item/storage/belt/medical/ert/PopulateContents()
	return list(
		SSwardrobe.provide_type(/obj/item/sensor_device, null),
		SSwardrobe.provide_type(/obj/item/pinpointer/crew, null),
		SSwardrobe.provide_type(/obj/item/scalpel/advanced, null),
		SSwardrobe.provide_type(/obj/item/retractor/advanced, null),
		SSwardrobe.provide_type(/obj/item/stack/medical/bone_gel, null),
		SSwardrobe.provide_type(/obj/item/cautery/advanced, null),
		SSwardrobe.provide_type(/obj/item/surgical_drapes, null),
	)

/obj/item/storage/belt/medical/ert/get_types_to_preload()
	var/list/to_preload = list()
	to_preload += /obj/item/sensor_device
	to_preload += /obj/item/pinpointer/crew
	to_preload += /obj/item/scalpel/advanced
	to_preload += /obj/item/retractor/advanced
	to_preload += /obj/item/stack/medical/bone_gel
	to_preload += /obj/item/cautery/advanced
	to_preload += /obj/item/surgical_drapes
	return to_preload

/obj/item/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "security"
	inhand_icon_state = "security"//Could likely use a better one.
	worn_icon_state = "security"
	content_overlays = TRUE
	storage_type = /datum/storage/security_belt

/obj/item/storage/belt/security/full/PopulateContents()
	return list(
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/grenade/flashbang,
		/obj/item/assembly/flash/handheld,
		/obj/item/melee/baton/security/loaded,
	)

/obj/item/storage/belt/security/webbing
	name = "security webbing"
	desc = "Unique and versatile chest rig, can hold security gear."
	icon_state = "securitywebbing"
	inhand_icon_state = "securitywebbing"
	worn_icon_state = "securitywebbing"
	content_overlays = FALSE
	custom_premium_price = PAYCHECK_COMMAND * 3
	storage_type = /datum/storage/security_belt/webbing

/obj/item/storage/belt/mining
	name = "explorer's webbing"
	desc = "A versatile chest rig, cherished by miners and hunters alike."
	icon_state = "explorer1"
	inhand_icon_state = "explorer1"
	worn_icon_state = "explorer1"
	w_class = WEIGHT_CLASS_BULKY
	storage_type = /datum/storage/mining_belt

/obj/item/storage/belt/mining/vendor/PopulateContents()
	return /obj/item/survivalcapsule

/obj/item/storage/belt/mining/alt
	icon_state = "explorer2"
	inhand_icon_state = "explorer2"
	worn_icon_state = "explorer2"

/obj/item/storage/belt/mining/healing/PopulateContents()
	var/list/obj/item/insert = list(
		/obj/item/reagent_containers/hypospray/medipen/survival/luxury,
		/obj/item/reagent_containers/hypospray/medipen/survival/luxury,
		/obj/item/reagent_containers/hypospray/medipen/survival,
		/obj/item/reagent_containers/hypospray/medipen/survival,
	)

	for(var/i in 1 to 2)
		var/obj/item/organ/monster_core/core = new /obj/item/organ/monster_core/regenerative_core/legion(null)
		core.preserve()
		insert += core

	return insert

/obj/item/storage/belt/mining/primitive
	name = "hunter's belt"
	desc = "A versatile belt, woven from sinew."
	icon_state = "ebelt"
	inhand_icon_state = "ebelt"
	worn_icon_state = "ebelt"
	storage_type = /datum/storage/mining_belt/primitive

/obj/item/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away."
	icon_state = "soulstonebelt"
	inhand_icon_state = "soulstonebelt"
	worn_icon_state = "soulstonebelt"
	drop_sound = 'sound/items/handling/toolbelt_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbelt_pickup.ogg'
	storage_type = /datum/storage/soulstone_belt

/obj/item/storage/belt/soulstone/full/PopulateContents()
	. = list()
	for(var/_ in 1 to 6)
		. += /obj/item/soulstone/mystic

/obj/item/storage/belt/soulstone/full/chappy/PopulateContents()
	. = list()
	for(var/_ in 1 to 6)
		. += /obj/item/soulstone/anybody/chaplain

/obj/item/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	inhand_icon_state = "championbelt"
	worn_icon_state = "championbelt"
	custom_materials = list(/datum/material/gold=SMALL_MATERIAL_AMOUNT * 4)
	storage_type = /datum/storage/champion_belt

/obj/item/storage/belt/champion/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/adjust_fishing_difficulty, -2)

/obj/item/storage/belt/military
	name = "chest rig"
	desc = "A set of tactical webbing worn by Syndicate boarding parties."
	icon_state = "militarywebbing"
	inhand_icon_state = "militarywebbing"
	worn_icon_state = "militarywebbing"
	resistance_flags = FIRE_PROOF
	storage_type = /datum/storage/military_belt

/obj/item/storage/belt/military/assault/fisher/PopulateContents()
	return list(
		/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher, // 11 TC: 7 (pistol) + 3 (suppressor) + lightbreaker (1 TC, black market meme/util item)
		/obj/item/ammo_box/magazine/m10mm, // 1 TC
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/card/emag/doorjack, // 3 TC
		/obj/item/knife/combat, //comparable to the e-dagger, 2 TC
	)

/obj/item/storage/belt/military/snack
	name = "tactical snack rig"
	storage_type = /datum/storage/military_belt/snacks

/obj/item/storage/belt/military/snack/Initialize(mapload)
	. = ..()
	var/sponsor = pick("Donk Co.", "Waffle Corp.", "Roffle Co.", "Gorlex Marauders", "Tiger Cooperative")
	desc = "A set of snack-tical webbing worn by athletes of the [sponsor] VR sports division."

/obj/item/storage/belt/military/snack/full/PopulateContents()
	var/obj/item/snack = pick(list(
		/obj/item/food/candy,
		/obj/item/food/cheesiehonkers,
		/obj/item/food/cheesynachos,
		/obj/item/food/chips,
		/obj/item/food/cubannachos,
		/obj/item/food/donkpocket,
		/obj/item/food/nachos,
		/obj/item/food/nugget,
		/obj/item/food/rofflewaffles,
		/obj/item/food/sosjerky,
		/obj/item/food/spacetwinkie,
		/obj/item/food/spaghetti/pastatomato,
		/obj/item/food/syndicake,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/nuka_cola,
		/obj/item/reagent_containers/cup/glass/dry_ramen,
		/obj/item/reagent_containers/cup/soda_cans/cola,
		/obj/item/reagent_containers/cup/soda_cans/dr_gibb,
		/obj/item/reagent_containers/cup/soda_cans/lemon_lime,
		/obj/item/reagent_containers/cup/soda_cans/pwr_game,
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind,
		/obj/item/reagent_containers/cup/soda_cans/space_up,
		/obj/item/reagent_containers/cup/soda_cans/starkist,
	))

	. = list()
	for(var/_ in 1 to 5)
		. += snack

/obj/item/storage/belt/military/abductor
	name = "agent belt"
	desc = "A belt used by abductor agents."
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "belt"
	inhand_icon_state = "security"
	worn_icon_state = "security"
	content_overlays = TRUE

/obj/item/storage/belt/military/abductor/full/PopulateContents()
	return list(
		/obj/item/screwdriver/abductor,
		/obj/item/wrench/abductor,
		/obj/item/weldingtool/abductor,
		/obj/item/crowbar/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/multitool/abductor,
		/obj/item/stack/cable_coil,
	)

/obj/item/storage/belt/military/army
	name = "army belt"
	desc = "A belt used by military forces."
	icon_state = "military"
	inhand_icon_state = "security"
	worn_icon_state = "military"

/obj/item/storage/belt/military/assault
	name = "assault belt"
	desc = "A tactical assault belt."
	icon_state = "assault"
	inhand_icon_state = "security"
	worn_icon_state = "assault"
	storage_type = /datum/storage/military_belt/assault

/obj/item/storage/belt/military/assault/full/PopulateContents()
	return flatten_quantified_list(list(
		/obj/item/ammo_box/magazine/wt550m9 = 4,
		/obj/item/ammo_box/magazine/wt550m9/wtap = 2,
	))

/obj/item/storage/belt/grenade
	name = "grenadier belt"
	desc = "A belt for holding grenades."
	icon_state = "grenadebeltnew"
	inhand_icon_state = "security"
	worn_icon_state = "grenadebeltnew"
	drop_sound = 'sound/items/handling/toolbelt_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbelt_pickup.ogg'
	storage_type = /datum/storage/grenade_belt

/obj/item/storage/belt/grenade/full/PopulateContents()
	return flatten_quantified_list(list(
		/obj/item/grenade/chem_grenade/incendiary = 2,
		/obj/item/grenade/empgrenade = 2,
		/obj/item/grenade/frag = 10,
		/obj/item/grenade/flashbang = 2,
		/obj/item/grenade/gluon = 4,
		/obj/item/grenade/smokebomb = 4,
		/obj/item/grenade/syndieminibomb = 2,
		/obj/item/multitool = 1,
		/obj/item/screwdriver = 1,
	))


/obj/item/storage/belt/wands
	name = "wand belt"
	desc = "A belt designed to hold various rods of power. A veritable fanny pack of exotic magic."
	icon_state = "soulstonebelt"
	inhand_icon_state = "soulstonebelt"
	worn_icon_state = "soulstonebelt"
	storage_type = /datum/storage/wand_belt

/obj/item/storage/belt/wands/full/PopulateContents()
	var/list/obj/item/insert = list(
		new /obj/item/gun/magic/wand/death(null),
		new /obj/item/gun/magic/wand/resurrection(null),
		new /obj/item/gun/magic/wand/polymorph(null),
		new /obj/item/gun/magic/wand/teleport(null),
		new /obj/item/gun/magic/wand/door(null),
		new /obj/item/gun/magic/wand/fireball(null),
		new /obj/item/gun/magic/wand/shrink(null),
	)

	//All wands in this pack come in the best possible condition
	for(var/obj/item/gun/magic/wand/W in insert)
		W.max_charges = initial(W.max_charges)
		W.charges = W.max_charges

	return insert

/obj/item/storage/belt/janitor
	name = "janibelt"
	desc = "A belt used to hold most janitorial supplies."
	icon_state = "janibelt"
	inhand_icon_state = "janibelt"
	worn_icon_state = "janibelt"
	drop_sound = 'sound/items/handling/toolbelt_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbelt_pickup.ogg'
	storage_type = /datum/storage/janitor_belt

/obj/item/storage/belt/janitor/full/PopulateContents()
	return list(
		/obj/item/lightreplacer,
		/obj/item/reagent_containers/spray/cleaner,
		/obj/item/soap/nanotrasen,
		/obj/item/holosign_creator,
		/obj/item/melee/flyswatter,
	)

/obj/item/storage/belt/bandolier
	name = "bandolier"
	desc = "A bandolier for holding rifle shotgun, and bigger revolver caliber ammunition."
	icon_state = "bandolier"
	inhand_icon_state = "bandolier"
	worn_icon_state = "bandolier"
	storage_type = /datum/storage/bandolier_belt

/obj/item/storage/belt/fannypack
	name = "fannypack"
	desc = "A dorky fannypack for keeping small items in. Concealed enough, or ugly enough to avert their eyes, that others won't see what you put in or take out easily."
	icon_state = "fannypack_leather"
	inhand_icon_state = null
	worn_icon_state = "fannypack_leather"
	dying_key = DYE_REGISTRY_FANNYPACK
	custom_price = PAYCHECK_CREW * 2
	storage_type = /datum/storage/fanny_pack

/obj/item/storage/belt/fannypack/black
	name = "black fannypack"
	icon_state = "fannypack_black"
	worn_icon_state = "fannypack_black"

/obj/item/storage/belt/fannypack/red
	name = "red fannypack"
	icon_state = "fannypack_red"
	worn_icon_state = "fannypack_red"

/obj/item/storage/belt/fannypack/purple
	name = "purple fannypack"
	icon_state = "fannypack_purple"
	worn_icon_state = "fannypack_purple"

/obj/item/storage/belt/fannypack/blue
	name = "blue fannypack"
	icon_state = "fannypack_blue"
	worn_icon_state = "fannypack_blue"

/obj/item/storage/belt/fannypack/orange
	name = "orange fannypack"
	icon_state = "fannypack_orange"
	worn_icon_state = "fannypack_orange"

/obj/item/storage/belt/fannypack/white
	name = "white fannypack"
	icon_state = "fannypack_white"
	worn_icon_state = "fannypack_white"

/obj/item/storage/belt/fannypack/green
	name = "green fannypack"
	icon_state = "fannypack_green"
	worn_icon_state = "fannypack_green"

/obj/item/storage/belt/fannypack/pink
	name = "pink fannypack"
	icon_state = "fannypack_pink"
	worn_icon_state = "fannypack_pink"

/obj/item/storage/belt/fannypack/cyan
	name = "cyan fannypack"
	icon_state = "fannypack_cyan"
	worn_icon_state = "fannypack_cyan"

/obj/item/storage/belt/fannypack/yellow
	name = "yellow fannypack"
	icon_state = "fannypack_yellow"
	worn_icon_state = "fannypack_yellow"

/obj/item/storage/belt/fannypack/cummerbund
	name = "cummerbund"
	desc = "A pleated sash that pairs well with a suit jacket."
	icon_state = "cummerbund"
	inhand_icon_state = null
	worn_icon_state = "cummerbund"

/obj/item/storage/belt/sabre
	name = "sabre sheath"
	desc = "An ornate sheath designed to hold an officer's blade."
	icon_state = "sheath"
	inhand_icon_state = "sheath"
	worn_icon_state = "sheath"
	w_class = WEIGHT_CLASS_BULKY
	interaction_flags_click = parent_type::interaction_flags_click | NEED_DEXTERITY | NEED_HANDS
	storage_type = /datum/storage/sabre_belt

/obj/item/storage/belt/sabre/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/storage/belt/sabre/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("Alt-click it to quickly draw the blade.")

/obj/item/storage/belt/sabre/click_alt(mob/user)
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message(span_notice("[user] takes [I] out of [src]."), span_notice("You take [I] out of [src]."))
		user.put_in_hands(I)
		update_appearance()
	else
		balloon_alert(user, "it's empty!")
	return CLICK_ACTION_SUCCESS

/obj/item/storage/belt/sabre/update_icon_state()
	icon_state = initial(inhand_icon_state)
	inhand_icon_state = initial(inhand_icon_state)
	worn_icon_state = initial(worn_icon_state)
	if(contents.len)
		icon_state += "-sabre"
		inhand_icon_state += "-sabre"
		worn_icon_state += "-sabre"
	return ..()

/obj/item/storage/belt/sabre/PopulateContents()
	return /obj/item/melee/sabre

/obj/item/storage/belt/grass_sabre
	name = "sabre sheath"
	desc = "A simple grass sheath designed to hold a sabre of... some sort. An actual metal one might be too sharp, though..."
	icon_state = "grass_sheath"
	inhand_icon_state = "grass_sheath"
	worn_icon_state = "grass_sheath"
	w_class = WEIGHT_CLASS_BULKY
	interaction_flags_click = parent_type::interaction_flags_click | NEED_DEXTERITY | NEED_HANDS
	storage_type = /datum/storage/green_sabre_belt

/obj/item/storage/belt/grass_sabre/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/storage/belt/grass_sabre/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("Alt-click it to quickly draw the blade.")

/obj/item/storage/belt/grass_sabre/click_alt(mob/user)
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message(span_notice("[user] takes [I] out of [src]."), span_notice("You take [I] out of [src]."))
		user.put_in_hands(I)
		update_appearance()
	else
		balloon_alert(user, "it's empty!")
	return CLICK_ACTION_SUCCESS

/obj/item/storage/belt/grass_sabre/update_icon_state()
	icon_state = initial(inhand_icon_state)
	inhand_icon_state = initial(inhand_icon_state)
	worn_icon_state = initial(worn_icon_state)
	if(contents.len)
		icon_state += "-sabre"
		inhand_icon_state += "-sabre"
		worn_icon_state += "-sabre"
	return ..()

/obj/item/storage/belt/plant
	name = "botanical belt"
	desc = "A sturdy leather belt used to hold most hydroponics supplies."
	icon_state = "plantbelt"
	inhand_icon_state = "utility"
	worn_icon_state = "plantbelt"
	content_overlays = TRUE
	storage_type = /datum/storage/plant_belt
