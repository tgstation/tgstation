///////////////////////////////////
//////////Mecha Module Disks///////
///////////////////////////////////

/datum/design/board/ripley_main
	name = "APLU \"Ripley\" Central Control module"
	desc = "Allows for the construction of a \"Ripley\" Central Control module."
	id = "ripley_main"
	build_path = /obj/item/circuitboard/mecha/ripley/main
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_RIPLEY
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/ripley_peri
	name = "APLU \"Ripley\" Peripherals Control module"
	desc = "Allows for the construction of a \"Ripley\" Peripheral Control module."
	id = "ripley_peri"
	build_path = /obj/item/circuitboard/mecha/ripley/peripherals
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_RIPLEY
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/odysseus_main
	name = "\"Odysseus\" Central Control module"
	desc = "Allows for the construction of a \"Odysseus\" Central Control module."
	id = "odysseus_main"
	build_path = /obj/item/circuitboard/mecha/odysseus/main
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_ODYSSEUS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/odysseus_peri
	name = "\"Odysseus\" Peripherals Control module"
	desc = "Allows for the construction of a \"Odysseus\" Peripheral Control module."
	id = "odysseus_peri"
	build_path = /obj/item/circuitboard/mecha/odysseus/peripherals
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_ODYSSEUS
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/gygax_main
	name = "\"Gygax\" Central Control module"
	desc = "Allows for the construction of a \"Gygax\" Central Control module."
	id = "gygax_main"
	build_path = /obj/item/circuitboard/mecha/gygax/main
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_GYGAX
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/gygax_peri
	name = "\"Gygax\" Peripherals Control module"
	desc = "Allows for the construction of a \"Gygax\" Peripheral Control module."
	id = "gygax_peri"
	build_path = /obj/item/circuitboard/mecha/gygax/peripherals
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_GYGAX
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/gygax_targ
	name = "\"Gygax\" Weapons & Targeting Control module"
	desc = "Allows for the construction of a \"Gygax\" Weapons & Targeting Control module."
	id = "gygax_targ"
	build_path = /obj/item/circuitboard/mecha/gygax/targeting
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_GYGAX
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/durand_main
	name = "\"Durand\" Central Control module"
	desc = "Allows for the construction of a \"Durand\" Central Control module."
	id = "durand_main"
	build_path = /obj/item/circuitboard/mecha/durand/main
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_DURAND
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/durand_peri
	name = "\"Durand\" Peripherals Control module"
	desc = "Allows for the construction of a \"Durand\" Peripheral Control module."
	id = "durand_peri"
	build_path = /obj/item/circuitboard/mecha/durand/peripherals
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_DURAND
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/durand_targ
	name = "\"Durand\" Weapons & Targeting Control module"
	desc = "Allows for the construction of a \"Durand\" Weapons & Targeting Control module."
	id = "durand_targ"
	build_path = /obj/item/circuitboard/mecha/durand/targeting
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_DURAND
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/honker_main
	name = "\"H.O.N.K.\" Central Control module"
	desc = "Allows for the construction of a \"H.O.N.K.\" Central Control module."
	id = "honker_main"
	build_path = /obj/item/circuitboard/mecha/honker/main
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_HONK
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/honker_peri
	name = "\"H.O.N.K.\" Peripherals Control module"
	desc = "Allows for the construction of a \"H.O.N.K.\" Peripheral Control module."
	id = "honker_peri"
	build_path = /obj/item/circuitboard/mecha/honker/peripherals
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_HONK
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/honker_targ
	name = "\"H.O.N.K.\" Weapons & Targeting Control module"
	desc = "Allows for the construction of a \"H.O.N.K.\" Weapons & Targeting Control module."
	id = "honker_targ"
	build_path = /obj/item/circuitboard/mecha/honker/targeting
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_HONK
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/phazon_main
	name = "\"Phazon\" Central Control module"
	desc = "Allows for the construction of a \"Phazon\" Central Control module."
	id = "phazon_main"
	materials = list(/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/bluespace =SMALL_MATERIAL_AMOUNT)
	build_path = /obj/item/circuitboard/mecha/phazon/main
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_PHAZON
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/phazon_peri
	name = "\"Phazon\" Peripherals Control module"
	desc = "Allows for the construction of a \"Phazon\" Peripheral Control module."
	id = "phazon_peri"
	materials = list(/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/bluespace =SMALL_MATERIAL_AMOUNT)
	build_path = /obj/item/circuitboard/mecha/phazon/peripherals
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_PHAZON
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/phazon_targ
	name = "\"Phazon\" Weapons & Targeting Control module"
	desc = "Allows for the construction of a \"Phazon\" Weapons & Targeting Control module."
	id = "phazon_targ"
	materials = list(/datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/bluespace =SMALL_MATERIAL_AMOUNT)
	build_path = /obj/item/circuitboard/mecha/phazon/targeting
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_PHAZON
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/clarke_main
	name = "\"Clarke\" Central Control module"
	desc = "Allows for the construction of a \"Clarke\" Central Control module."
	id = "clarke_main"
	build_path = /obj/item/circuitboard/mecha/clarke/main
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_CLARKE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/clarke_peri
	name = "\"Clarke\" Peripherals Control module"
	desc = "Allows for the construction of a \"Clarke\" Peripheral Control module."
	id = "clarke_peri"
	build_path = /obj/item/circuitboard/mecha/clarke/peripherals
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_CLARKE
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/savannah_ivanov_main
	name = "\"Savannah-Ivanov\" Central Control module"
	desc = "Allows for the construction of a \"Savannah-Ivanov\" Central Control module."
	id = "savannah_ivanov_main"
	build_path = /obj/item/circuitboard/mecha/savannah_ivanov/main
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_SAVANNAH_IVANOV
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/savannah_ivanov_peri
	name = "\"Savannah-Ivanov\" Peripherals Control module"
	desc = "Allows for the construction of a \"Savannah-Ivanov\" Peripheral Control module."
	id = "savannah_ivanov_peri"
	build_path = /obj/item/circuitboard/mecha/savannah_ivanov/peripherals
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_SAVANNAH_IVANOV
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/board/savannah_ivanov_targ
	name = "\"Savannah-Ivanov\" Weapons & Targeting Control module"
	desc = "Allows for the construction of a \"Savannah-Ivanov\" Weapons & Targeting Control module."
	id = "savannah_ivanov_targ"
	build_path = /obj/item/circuitboard/mecha/savannah_ivanov/targeting
	category = list(
		RND_CATEGORY_EXOSUIT_BOARDS + RND_SUBCATEGORY_EXOSUIT_BOARDS_SAVANNAH_IVANOV
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

////////////////////////////////////////
/////////// Mecha Equpment /////////////
////////////////////////////////////////

/datum/design/mech_scattershot
	name = "LBX AC 10 \"Scattershot\""
	desc = "Allows for the construction of LBX AC 10."
	id = "mech_scattershot"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_scattershot_ammo
	name = "LBX AC 10 Ammunition"
	desc = "Ammunition for the LBX AC 10 exosuit weapon."
	id = "mech_scattershot_ammo"
	build_type = MECHFAB
	build_path = /obj/item/mecha_ammo/scattershot
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*3)
	construction_time = 2 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_carbine
	name = "FNX-99 \"Hades\" Carbine"
	desc = "Allows for the construction of FNX-99 \"Hades\" Carbine."
	id = "mech_carbine"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_carbine_ammo
	name = "FNX-99 Carbine Ammunition"
	desc = "Ammunition for the FNX-99 \"Hades\" Carbine."
	id = "mech_carbine_ammo"
	build_type = MECHFAB
	build_path = /obj/item/mecha_ammo/incendiary
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*3)
	construction_time = 2 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_ion
	name = "MKIV Ion Heavy Cannon"
	desc = "Allows for the construction of MKIV Ion Heavy Cannon."
	id = "mech_ion"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,/datum/material/silver=SHEET_MATERIAL_AMOUNT*3,/datum/material/uranium=SHEET_MATERIAL_AMOUNT)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_tesla
	name = "MKI Tesla Cannon"
	desc = "Allows for the construction of MKI Tesla Cannon."
	id = "mech_tesla"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,/datum/material/silver=SHEET_MATERIAL_AMOUNT*4)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_laser
	name = "CH-PS \"Immolator\" Laser"
	desc = "Allows for the construction of CH-PS Laser."
	id = "mech_laser"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_laser_heavy
	name = "CH-LC \"Solaris\" Laser Cannon"
	desc = "Allows for the construction of CH-LC Laser Cannon."
	id = "mech_laser_heavy"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_disabler
	name = "CH-DS \"Peacemaker\" Disabler"
	desc = "Allows for the construction of CH-DS Disabler."
	id = "mech_disabler"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/disabler
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_grenade_launcher
	name = "SGL-6 Grenade Launcher"
	desc = "Allows for the construction of SGL-6 Grenade Launcher."
	id = "mech_grenade_launcher"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*11,/datum/material/gold=SHEET_MATERIAL_AMOUNT*3,/datum/material/silver=SHEET_MATERIAL_AMOUNT*4)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_grenade_launcher_ammo
	name = "SGL-6 Grenade Launcher Ammunition"
	desc = "Ammunition for the SGL-6 Grenade Launcher."
	id = "mech_grenade_launcher_ammo"
	build_type = MECHFAB
	build_path = /obj/item/mecha_ammo/flashbang
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*2,/datum/material/gold=SMALL_MATERIAL_AMOUNT*5)
	construction_time = 2 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_missile_rack
	name = "PEP-6 Missile Rack"
	desc = "Allows for the construction of an PEP-6 Breaching Missile Rack."
	id = "mech_missile_rack"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/breaching
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*11,/datum/material/gold=SHEET_MATERIAL_AMOUNT*3,/datum/material/silver=SHEET_MATERIAL_AMOUNT*4)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_missile_rack_ammo
	name = "PEP-6 Missile Rack Ammunition"
	desc = "Ammunition for the PEP-6 Missile Rack."
	id = "mech_missile_rack_ammo"
	build_type = MECHFAB
	build_path = /obj/item/mecha_ammo/missiles_pep
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*4,/datum/material/gold=SMALL_MATERIAL_AMOUNT*5)
	construction_time = 2 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/clusterbang_launcher
	name = "SOB-3 Clusterbang Launcher"
	desc = "A weapon that violates the Geneva Convention at 3 rounds per minute."
	id = "clusterbang_launcher"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/clusterbang
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,/datum/material/gold=SHEET_MATERIAL_AMOUNT*5,/datum/material/uranium=SHEET_MATERIAL_AMOUNT*5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/clusterbang_launcher_ammo
	name = "SOB-3 Clusterbang Launcher Ammunition"
	desc = "Ammunition for the SOB-3 Clusterbang Launcher"
	id = "clusterbang_launcher_ammo"
	build_type = MECHFAB
	build_path = /obj/item/mecha_ammo/clusterbang
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*3,/datum/material/gold=HALF_SHEET_MATERIAL_AMOUNT * 1.5,/datum/material/uranium=HALF_SHEET_MATERIAL_AMOUNT * 1.5)
	construction_time = 2 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_WEAPONS,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_wormhole_gen
	name = "Localized Wormhole Generator"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	id = "mech_wormhole_gen"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/wormhole_generator
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_MECHFAB_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_teleporter
	name = "Teleporter Module"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	id = "mech_teleporter"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/teleporter
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*5,/datum/material/diamond=SHEET_MATERIAL_AMOUNT*5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_MECHFAB_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_rcd
	name = "RCD Module"
	desc = "An exosuit-mounted Rapid Construction Device."
	id = "mech_rcd"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/rcd
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*15,/datum/material/gold=SHEET_MATERIAL_AMOUNT*10,/datum/material/plasma=SHEET_MATERIAL_AMOUNT*12.5,/datum/material/silver=SHEET_MATERIAL_AMOUNT*10)
	construction_time = 2 MINUTES
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_MECHFAB_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_thrusters
	name = "RCS Thruster Package"
	desc = "A thruster package for exosuits. Expels gas from the internal life-support air tank to generate thrust."
	id = "mech_thrusters"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/thrusters/gas
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*12.5,/datum/material/titanium=SHEET_MATERIAL_AMOUNT * 2.5,/datum/material/silver=SHEET_MATERIAL_AMOUNT*1.5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MODULES,
		RND_CATEGORY_MECHFAB_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_gravcatapult
	name = "Gravitational Catapult Module"
	desc = "An exosuit mounted Gravitational Catapult."
	id = "mech_gravcatapult"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/gravcatapult
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_MECHFAB_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_repair_droid
	name = "Repair Droid Module"
	desc = "Automated Repair Droid. BEEP BOOP"
	id = "mech_repair_droid"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/repair_droid
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*5,/datum/material/glass =SHEET_MATERIAL_AMOUNT * 2.5,/datum/material/gold=HALF_SHEET_MATERIAL_AMOUNT,/datum/material/silver=SHEET_MATERIAL_AMOUNT)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MODULES,
		RND_CATEGORY_MECHFAB_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_ccw_armor
	name = "Exosuit Impact Cushion Plates"
	desc = "Exosuit-mounted melee armor booster."
	id = "mech_ccw_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/armor/anticcw_armor_booster
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,/datum/material/silver=SHEET_MATERIAL_AMOUNT * 2.5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MODULES,
		RND_CATEGORY_MECHFAB_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_proj_armor
	name = "Exosuit Projectile Shielding"
	desc = "Exosuit-mounted ranged armor booster."
	id = "mech_proj_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/armor/antiproj_armor_booster
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,/datum/material/gold=SHEET_MATERIAL_AMOUNT * 2.5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MODULES,
		RND_CATEGORY_MECHFAB_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_emp_armor
	name = "Exosuit Ablative Insulation"
	desc = "Exosuit-mounted energy and EMP armor booster. WARNING: This retrofit compromises exosuit hull plating stress points."
	id = "mech_emp_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/armor/antiemp_armor_booster
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,/datum/material/gold=SHEET_MATERIAL_AMOUNT * 2.5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MODULES,
		RND_CATEGORY_MECHFAB_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_diamond_drill
	name = "Diamond Mining Drill"
	desc = "An upgraded version of the standard drill."
	id = "mech_diamond_drill"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*5,/datum/material/diamond=SHEET_MATERIAL_AMOUNT*3.25)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_MECHFAB_RIPLEY + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_MECHFAB_CLARKE + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_plasma_cutter
	name = "217-D Heavy Plasma Cutter"
	desc = "A device that shoots resonant plasma bursts at extreme velocity. The blasts are capable of crushing rock and demolishing solid obstacles."
	id = "mech_plasma_cutter"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*4, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/plasma =SHEET_MATERIAL_AMOUNT)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_MECHFAB_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mecha_kineticgun
	name = "Exosuit Proto-Kinetic Accelerator"
	desc = "An exosuit-mounted mining tool that does increased damage in low pressure. Drawing from an onboard power source allows it to project further than the handheld version."
	id = "mecha_kineticgun"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/mecha_kineticgun
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*4, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_MECHFAB_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_lmg
	name = "Ultra AC 2 LMG"
	desc = "A weapon for combat exosuits. Shoots a rapid, three shot burst."
	id = "mech_lmg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_lmg_ammo
	name = "Ultra AC 2 Ammunition"
	desc = "Ammunition for the Ultra AC 2 LMG"
	id = "mech_lmg_ammo"
	build_type = MECHFAB
	build_path = /obj/item/mecha_ammo/lmg
	materials = list(/datum/material/iron= SHEET_MATERIAL_AMOUNT *2)
	construction_time = 2 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_MECHFAB_PADDY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT,
		RND_CATEGORY_MECHFAB_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_sleeper
	name = "Mounted Sleeper"
	desc = "Equipment for medical exosuits. A mounted sleeper that stabilizes patients and can inject reagents in the exosuit's reserves."
	id = "mech_sleeper"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/sleeper/medical
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/glass = SHEET_MATERIAL_AMOUNT*5)
	construction_time = 10 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MEDICAL,
		RND_CATEGORY_MECHFAB_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_syringe_gun
	name = "Exosuit Medical (Syringe Gun)"
	desc = "Equipment for medical exosuits. A chem synthesizer with syringe gun. Reagents inside are held in stasis, so no reactions will occur."
	id = "mech_syringe_gun"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*1.5, /datum/material/glass =SHEET_MATERIAL_AMOUNT)
	construction_time = 20 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MEDICAL,
		RND_CATEGORY_MECHFAB_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/mech_medical_beamgun
	name = "Exosuit Medical (Medical Beamgun)"
	desc = "Equipment for medical exosuits. A mounted medical nanite projector which will treat patients with a focused beam."
	id = "mech_medi_beam"
	build_type = MECHFAB
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*7.5, /datum/material/glass = SHEET_MATERIAL_AMOUNT*4, /datum/material/plasma =SHEET_MATERIAL_AMOUNT*1.5, /datum/material/gold = SHEET_MATERIAL_AMOUNT*4, /datum/material/diamond =SHEET_MATERIAL_AMOUNT)
	construction_time = 25 SECONDS
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam
	category = list(
		RND_CATEGORY_MECHFAB_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MEDICAL,
		RND_CATEGORY_MECHFAB_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
