/obj/vehicle/sealed/mecha/honker
	desc = "Produced by \"Tyranny of Honk, INC\", this exosuit is designed as heavy clown-support. Used to spread the fun and joy of life. HONK!"
	name = "\improper H.O.N.K"
	ui_theme = "neutral"
	icon_state = "honker"
	base_icon_state = "honker"
	movedelay = 3
	max_integrity = 140
	force = 30
	armor_type = /datum/armor/mecha_honker
	max_temperature = 25000
	destruction_sleep_duration = 40
	exit_delay = 40
	accesses = list(ACCESS_MECH_SCIENCE, ACCESS_THEATRE)
	wreckage = /obj/structure/mecha_wreckage/honker
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE
	mech_type = EXOSUIT_MODULE_HONK
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 4,
		MECHA_POWER = 1,
		MECHA_ARMOR = 0,
	)
	var/squeak = TRUE

/datum/armor/mecha_honker
	melee = -20
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/honker/Initialize(mapload, built_manually)
	. = ..()
	AddElementTrait(TRAIT_WADDLING, REF(src), /datum/element/waddling)

/obj/vehicle/sealed/mecha/honker/play_stepsound()
	if(squeak)
		playsound(src, SFX_CLOWN_STEP, 70, 1)
	squeak = !squeak


//DARK H.O.N.K.

/obj/vehicle/sealed/mecha/honker/dark
	desc = "Produced by \"Tyranny of Honk, INC\", this exosuit is designed as heavy clown-support. This one has been painted black for maximum fun. HONK!"
	name = "\improper Dark H.O.N.K"
	ui_theme = "syndicate"
	icon_state = "darkhonker"
	max_integrity = 300
	armor_type = /datum/armor/honker_dark
	max_temperature = 35000
	accesses = list(ACCESS_SYNDICATE)
	wreckage = /obj/structure/mecha_wreckage/honker/dark
	mecha_flags = ID_LOCK_ON | CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 2,
	)

/obj/vehicle/sealed/mecha/honker/dark/loaded
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/honker,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar/bombanana,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/radio, /obj/item/mecha_parts/mecha_equipment/air_tank/full, /obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/datum/armor/honker_dark
	melee = 40
	bullet = 40
	laser = 50
	energy = 35
	bomb = 20
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/honker/dark/loaded/populate_parts()
	cell = new /obj/item/stock_parts/power_store/cell/hyper(src)
	scanmod = new /obj/item/stock_parts/scanning_module/phasic(src)
	capacitor = new /obj/item/stock_parts/capacitor/super(src)
	servo = new /obj/item/stock_parts/servo/pico(src)
	update_part_values()

/obj/structure/mecha_wreckage/honker/dark
	name = "\improper Dark H.O.N.K wreckage"
	icon_state = "darkhonker-broken"
