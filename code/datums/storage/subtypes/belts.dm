///Utility belt
/datum/storage/utility_belt
	max_total_storage = 21

/datum/storage/utility_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(GLOB.tool_items + list(
		/obj/item/clothing/gloves,
		/obj/item/radio,
		/obj/item/melee/sickly_blade/lock,
		/obj/item/reagent_containers/cup/soda_cans,
	))

///Medical belt
/datum/storage/medical_belt
	max_total_storage = 21

/datum/storage/medical_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/bikehorn/rubberducky,
		/obj/item/blood_filter,
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/clothing/glasses,
		/obj/item/clothing/gloves,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/muzzle,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/head/utility/surgerycap,
		/obj/item/construction/plumbing,
		/obj/item/dnainjector,
		/obj/item/extinguisher/mini,
		/obj/item/flashlight/pen,
		/obj/item/geiger_counter,
		/obj/item/gun/syringe/syndicate,
		/obj/item/healthanalyzer,
		/obj/item/hemostat,
		/obj/item/holosign_creator/medical,
		/obj/item/implant,
		/obj/item/implantcase,
		/obj/item/implanter,
		/obj/item/lazarus_injector,
		/obj/item/lighter,
		/obj/item/pinpointer/crew,
		/obj/item/plunger,
		/obj/item/radio,
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/medigel,
		/obj/item/reagent_containers/applicator,
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/syringe,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/shears,
		/obj/item/stack/medical,
		/obj/item/stack/sticky_tape, //surgical tape
		/obj/item/stamp,
		/obj/item/sensor_device,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/surgical_drapes, //for true paramedics
		/obj/item/surgicaldrill,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/wrench/medical,
		/obj/item/knife/ritual,
		/obj/item/flesh_shears,
		/obj/item/blood_scanner,
		/obj/item/reflexhammer,
	))

///Security belt
/datum/storage/security_belt
	max_slots = 5
	open_sound = 'sound/items/handling/holster_open.ogg'
	open_sound_vary = TRUE
	rustle_sound = null

/datum/storage/security_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing/shotgun,
		/obj/item/assembly/flash/handheld,
		/obj/item/clothing/glasses,
		/obj/item/clothing/gloves,
		/obj/item/flashlight/seclite,
		/obj/item/food/donut,
		/obj/item/grenade,
		/obj/item/holosign_creator/security,
		/obj/item/knife/combat,
		/obj/item/melee/baton,
		/obj/item/radio,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/restraints/legcuffs/bola,
	))

///Webbing security belt
/datum/storage/security_belt/webbing
	max_slots = 6

///Mining belt
/datum/storage/mining_belt
	max_slots = 6
	max_total_storage = 20

/datum/storage/mining_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/analyzer,
		/obj/item/clothing/gloves,
		/obj/item/crowbar,
		/obj/item/extinguisher/mini,
		/obj/item/flashlight,
		/obj/item/gps,
		/obj/item/mining_stabilizer,
		/obj/item/key/lasso,
		/obj/item/knife,
		/obj/item/lighter,
		/obj/item/mining_scanner,
		/obj/item/multitool,
		/obj/item/organ/monster_core,
		/obj/item/pickaxe,
		/obj/item/radio,
		/obj/item/reagent_containers/cup/glass,
		/obj/item/reagent_containers/cup/glass/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/applicator/pill,
		/obj/item/resonator,
		/obj/item/screwdriver,
		/obj/item/shovel,
		/obj/item/stack/cable_coil,
		/obj/item/stack/marker_beacon,
		/obj/item/stack/medical,
		/obj/item/stack/ore,
		/obj/item/stack/sheet/animalhide,
		/obj/item/stack/sheet/bone,
		/obj/item/stack/sheet/sinew,
		/obj/item/storage/bag/ore,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/survivalcapsule,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/wormhole_jaunter,
		/obj/item/skeleton_key,
	))

///Primitive mining belt
/datum/storage/mining_belt/primitive
	max_slots = 5

///Soulstone belt
/datum/storage/soulstone_belt
	max_slots = 6

/datum/storage/soulstone_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/soulstone)

///Champion belt
/datum/storage/champion_belt
	max_slots = 1

/datum/storage/champion_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/clothing/mask/luchador)

///Military belt
/datum/storage/military_belt
	max_specific_storage = WEIGHT_CLASS_SMALL

///Military snack belt
/datum/storage/military_belt/snack
	max_slots = 6

/datum/storage/military_belt/snack/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/food,
		/obj/item/reagent_containers/cup/glass,
	))

///Military assault belt
/datum/storage/military_belt/assault
	max_slots = 6

///Grenade belt
/datum/storage/grenade_belt
	max_slots = 30
	numerical_stacking = TRUE
	max_total_storage = 60
	max_specific_storage = WEIGHT_CLASS_BULKY

/datum/storage/grenade_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/food/grown/cherry_bomb,
		/obj/item/food/grown/firelemon,
		/obj/item/grenade,
		/obj/item/grenade/c4,
		/obj/item/lighter,
		/obj/item/multitool,
		/obj/item/reagent_containers/cup/glass/bottle/molotov,
		/obj/item/screwdriver,
	))

///Wands belt
/datum/storage/wands_belt
	max_slots = 7

/datum/storage/wands_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/gun/magic/wand)

///Janitor belt
/datum/storage/janitor_belt
	max_slots = 6

/datum/storage/janitor_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/access_key,
		/obj/item/assembly/mousetrap,
		/obj/item/clothing/gloves,
		/obj/item/flashlight,
		/obj/item/forcefield_projector,
		/obj/item/grenade/chem_grenade,
		/obj/item/holosign_creator,
		/obj/item/key/janitor,
		/obj/item/lightreplacer,
		/obj/item/melee/flyswatter,
		/obj/item/paint/paint_remover,
		/obj/item/plunger,
		/obj/item/pushbroom,
		/obj/item/reagent_containers/spray,
		/obj/item/soap,
		/obj/item/wirebrush,
	))

///Bandolier belt
/datum/storage/bandolier_belt
	max_slots = 24
	max_total_storage = 24
	numerical_stacking = TRUE
	allow_quick_gather = TRUE
	allow_quick_empty = TRUE

/datum/storage/bandolier_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/ammo_casing/strilka310,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_casing/c357,
		/obj/item/ammo_casing/junk,
	))

///Fanny pack
/datum/storage/fanny_pack
	max_slots = 3
	max_specific_storage = WEIGHT_CLASS_SMALL
	silent = TRUE

///Sabre belt
/datum/storage/sabre_belt
	max_slots = 1
	do_rustle = FALSE
	max_specific_storage = WEIGHT_CLASS_BULKY
	click_alt_open = FALSE

/datum/storage/sabre_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/melee/sabre)

///Green sabre belt
/datum/storage/green_sabre_belt
	max_slots = 1
	do_rustle = FALSE
	max_specific_storage = WEIGHT_CLASS_BULKY
	click_alt_open = FALSE

/datum/storage/green_sabre_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/melee/parsnip_sabre)

///Plant belt
/datum/storage/plant_belt
	max_slots = 6

/datum/storage/plant_belt/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/cultivator,
		/obj/item/geneshears,
		/obj/item/graft,
		/obj/item/gun/energy/floragun,
		/obj/item/hatchet,
		/obj/item/plant_analyzer,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/tube,
		/obj/item/reagent_containers/spray/pestspray,
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/secateurs,
		/obj/item/seeds,
		/obj/item/shovel/spade,
	))

///Unfathomable curio
/datum/storage/unfathomable_curio
	max_total_storage = 21

/datum/storage/unfathomable_curio/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(list(
		/obj/item/ammo_box/strilka310/lionhunter,
		/obj/item/heretic_labyrinth_handbook,
		/obj/item/bodypart, // Bodyparts are often used in rituals.
		/obj/item/clothing/neck/eldritch_amulet,
		/obj/item/clothing/neck/heretic_focus,
		/obj/item/codex_cicatrix,
		/obj/item/eldritch_potion,
		/obj/item/food/grown/poppy, // Used to regain a Living Heart.
		/obj/item/food/grown/harebell, // Used to reroll targets
		/obj/item/melee/rune_carver,
		/obj/item/melee/sickly_blade,
		/obj/item/organ, // Organs are also often used in rituals.
		/obj/item/reagent_containers/cup/beaker/eldritch,
		/obj/item/stack/sheet/glass, // Glass is often used by moon heretics
	))
