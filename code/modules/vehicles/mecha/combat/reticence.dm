/obj/vehicle/sealed/mecha/combat/reticence
	desc = "A silent, fast, and nigh-invisible miming exosuit. Popular among mimes and mime assassins."
	name = "\improper reticence"
	icon_state = "reticence"
	base_icon_state = "reticence"
	movedelay = 2
	dir_in = 1 //Facing North.
	max_integrity = 100
	armor = list(MELEE = 25, BULLET = 20, LASER = 30, ENERGY = 15, BOMB = 0, BIO = 0, FIRE = 100, ACID = 100)
	max_temperature = 15000
	wreckage = /obj/structure/mecha_wreckage/reticence
	operation_req_access = list(ACCESS_THEATRE)
	internals_req_access = list(ACCESS_MECH_SCIENCE, ACCESS_THEATRE)
	mecha_flags = CANSTRAFE | IS_ENCLOSED | HAS_LIGHTS | QUIET_STEPS | QUIET_TURNS | MMI_COMPATIBLE
	mech_type = EXOSUIT_MODULE_COMBAT
	max_equip_by_category = list(
		MECHA_UTILITY = 1,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	step_energy_drain = 3
	color = "#87878715"

/obj/vehicle/sealed/mecha/combat/reticence/loaded
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/silenced,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/rcd,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
