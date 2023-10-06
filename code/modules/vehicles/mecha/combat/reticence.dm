/obj/vehicle/sealed/mecha/reticence
	desc = "A silent, fast, and nigh-invisible miming exosuit. Popular among mimes and mime assassins."
	name = "\improper reticence"
	icon_state = "reticence"
	base_icon_state = "reticence"
	movedelay = 2
	max_integrity = 100
	armor_type = /datum/armor/mecha_reticence
	max_temperature = 15000
	force = 30
	destruction_sleep_duration = 40
	exit_delay = 40
	wreckage = /obj/structure/mecha_wreckage/reticence
	accesses = list(ACCESS_MECH_SCIENCE, ACCESS_THEATRE)
	mecha_flags = CANSTRAFE | IS_ENCLOSED | HAS_LIGHTS | QUIET_STEPS | QUIET_TURNS | MMI_COMPATIBLE
	mech_type = EXOSUIT_MODULE_RETICENCE
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	step_energy_drain = 4
	color = "#87878715"

/datum/armor/mecha_reticence
	melee = 25
	bullet = 20
	laser = 30
	energy = 15
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/reticence/loaded
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/silenced,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/rcd,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/obj/vehicle/sealed/mecha/reticence/loaded/populate_parts()
	cell = new /obj/item/stock_parts/cell/hyper(src)
	scanmod = new /obj/item/stock_parts/scanning_module/phasic(src)
	capacitor = new /obj/item/stock_parts/capacitor/super(src)
	servo = new /obj/item/stock_parts/servo/pico(src)
	update_part_values()
