/obj/vehicle/sealed/mecha/gygax
	desc = "A lightweight, security exosuit. Popular among private and corporate security."
	name = "\improper Gygax"
	icon_state = "gygax"
	base_icon_state = "gygax"
	movedelay = 3
	max_integrity = 250
	accesses = list(ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY)
	armor_type = /datum/armor/mecha_gygax
	max_temperature = 25000
	force = 25
	destruction_sleep_duration = 40
	exit_delay = 40
	wreckage = /obj/structure/mecha_wreckage/gygax
	mech_type = EXOSUIT_MODULE_GYGAX
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	step_energy_drain = 4
	can_use_overclock = TRUE
	overclock_safety_available = TRUE
	overclock_safety = TRUE

/datum/armor/mecha_gygax
	melee = 25
	bullet = 20
	laser = 30
	energy = 15
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/gygax/dark
	desc = "A lightweight exosuit, painted in a dark scheme. This model's armor has been upgraded with a cutting-edge armor composite, resulting in greater protection and performance at the cost of modularity."
	name = "\improper Dark Gygax"
	ui_theme = "syndicate"
	icon_state = "darkgygax"
	base_icon_state = "darkgygax"
	max_integrity = 300
	armor_type = /datum/armor/gygax_dark
	max_temperature = 35000
	overclock_coeff = 2
	overclock_temp_danger = 20
	force = 30
	can_be_tracked = FALSE
	accesses = list(ACCESS_SYNDICATE)
	wreckage = /obj/structure/mecha_wreckage/gygax/dark
	mecha_flags = ID_LOCK_ON | CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 4,
		MECHA_POWER = 1,
		MECHA_ARMOR = 0,
	)
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/radio, /obj/item/mecha_parts/mecha_equipment/air_tank/full, /obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	destruction_sleep_duration = 20

/datum/armor/gygax_dark
	melee = 70
	bullet = 50
	laser = 55
	energy = 35
	bomb = 20
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/gygax/dark/loaded/Initialize(mapload)
	. = ..()
	max_ammo()

/obj/vehicle/sealed/mecha/gygax/dark/loaded/populate_parts()
	cell = new /obj/item/stock_parts/power_store/cell/bluespace(src)
	scanmod = new /obj/item/stock_parts/scanning_module/triphasic(src)
	capacitor = new /obj/item/stock_parts/capacitor/quadratic(src)
	servo = new /obj/item/stock_parts/servo/femto(src)
	update_part_values()
