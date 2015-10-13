/datum/design/mech_wormhole_gen
	name = "Module Design (Localized Wormhole Generator)"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	id = "mech_wormhole_gen"
	build_type = MECHFAB
	req_tech = list("bluespace" = 3, "magnets" = 2)
	build_path = /obj/item/mecha_parts/mecha_equipment/wormhole_generator
	category = "Exosuit_Tools"
	materials = list(MAT_IRON=10000)

/datum/design/mech_teleporter
	name = "Module Design (Teleporter Module)"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	id = "mech_teleporter"
	build_type = MECHFAB
	req_tech = list("bluespace" = 10, "magnets" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/teleporter
	category = "Exosuit_Tools"
	materials = list(MAT_IRON=10000)

/datum/design/mech_rcd
	name = "Module Design (RCD Module)"
	desc = "An exosuit-mounted Rapid Construction Device."
	id = "mech_rcd"
	build_type = MECHFAB
	req_tech = list("materials" = 4, "bluespace" = 3, "magnets" = 4, "powerstorage"=4, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/rcd
	category = "Exosuit_Tools"
	materials = list(MAT_IRON=30000,MAT_PLASMA=25000,MAT_SILVER=20000,MAT_GOLD=20000)

/datum/design/mech_gravcatapult
	name = "Module Design (Gravitational Catapult Module)"
	desc = "An exosuit mounted Gravitational Catapult."
	id = "mech_gravcatapult"
	build_type = MECHFAB
	req_tech = list("bluespace" = 2, "magnets" = 3, "engineering" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/gravcatapult
	category = "Exosuit_Tools"
	materials = list(MAT_IRON=10000)

/datum/design/mech_repair_droid
	name = "Module Design (Repair Droid Module)"
	desc = "Automated Repair Droid. BEEP BOOP"
	id = "mech_repair_droid"
	build_type = MECHFAB
	req_tech = list("magnets" = 3, "programming" = 3, "engineering" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/repair_droid
	category = "Exosuit_Modules"
	materials = list(MAT_IRON=10000,MAT_GOLD=1000,MAT_SILVER=2000,MAT_GLASS=5000)

/* MISSING
/datum/design/mech_plasma_generator
	name = "Module Design (Plasma Converter Module)"
	desc = "Exosuit-mounted plasma converter."
	id = "mech_plasma_generator"
	build_type = MECHFAB
	req_tech = list("plasmatech" = 2, "powerstorage"= 2, "engineering" = 2)
	build_path = /obj/item/mecha_parts/mecha_equipment/plasma_generator
	category = "Exosuit_Modules"
*/

/datum/design/mech_energy_relay
	name = "Module Design (Tesla Energy Relay)"
	desc = "Tesla Energy Relay"
	id = "mech_energy_relay"
	build_type = MECHFAB
	req_tech = list("magnets" = 4, "powerstorage" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	category = "Exosuit_Modules"
	materials = list(MAT_IRON=10000,MAT_GOLD=2000,MAT_SILVER=3000,MAT_GLASS=2000)

/datum/design/mech_ccw_armor
	name = "Module Design (Melee Armor Booster Module)"
	desc = "Exosuit-mounted armor booster."
	id = "mech_ccw_armor"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	category = "Exosuit_Modules"
	materials = list(MAT_IRON=20000,MAT_SILVER=5000)

/datum/design/mech_proj_armor
	name = "Module Design (Projectile Armor Booster Module)"
	desc = "Exosuit-mounted armor booster."
	id = "mech_proj_armor"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "combat" = 5, "engineering"=3)
	build_path = /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	category = "Exosuit_Modules"
	materials = list(MAT_IRON=20000,MAT_GOLD=5000)

/datum/design/mech_syringe_gun
	name = "Module Design (Syringe Gun)"
	desc = "Exosuit-mounted syringe gun and chemical synthesizer."
	id = "mech_syringe_gun"
	build_type = MECHFAB
	req_tech = list("materials" = 3, "biotech"=4, "magnets"=4, "programming"=3)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/syringe_gun
	category = "Exosuit_Tools"
	materials = list(MAT_IRON=3000,MAT_GLASS=2000)

/datum/design/mech_scythe
	name = "Module Design (Heavy-Duty Pneumatic Scythe)"
	desc = "An exosuit-mounted pneumatic scythe, fit for complete weed extermination."
	id = "mech_scythe"
	build_type = MECHFAB
	req_tech = list("materials" = 1, "engineering" = 2, "combat" = 2)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/scythe
	category = "Exosuit_Tools"
	materials = list(MAT_IRON=7500)

/datum/design/mech_drill
	name = "Module Design (Mining Drill)"
	desc = "A mech-mountable mining drill."
	id = "mech_drill"
	build_type = MECHFAB
	req_tech = list("materials" = 1, "engineering" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/drill
	category = "Exosuit_Tools"
	materials = list(MAT_IRON=10000)

/datum/design/mech_diamond_drill
	name = "Module Design (Diamond Mining Drill)"
	desc = "An upgraded version of the standard drill."
	id = "mech_diamond_drill"
	build_type = MECHFAB
	req_tech = list("materials" = 4, "engineering" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
	category = "Exosuit_Tools"
	materials = list(MAT_IRON=10000,MAT_DIAMOND=6500)

/datum/design/mech_hydro_clamp
	name = "Module Design (Hydraulic Clamp)"
	desc = "A hydraulic clamp for lifting heavy objects."
	id = "mech_hydro_clamp"
	build_type = MECHFAB
	req_tech = list("materials" = 1, "engineering" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	category = "Exosuit_Tools"
	materials = list(MAT_IRON=10000)

/datum/design/mech_cable
	name = "Module Design (Cable Layer)"
	desc = "An automatic cable layer for mechs."
	id = "mech_cable"
	build_type = MECHFAB
	req_tech = list("engineering" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/cable_layer
	category = "Exosuit_Tools"
	materials = list(MAT_IRON=10000)

/datum/design/mech_extinguisher
	name = "Module Design (Foam Extinguisher)"
	desc = "A foam extinguisher module for firefighting mechs."
	id = "mech_extinguisher"
	build_type = MECHFAB
	req_tech = list("materials" = 1, "engineering" = 2)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/extinguisher
	category = "Exosuit_Tools"
	materials = list(MAT_IRON=10000)

/datum/design/mech_generator_plasma
	name = "Module Design (Plasma Generator)"
	desc = "A power generator that runs on burning plasma."
	id = "mech_generator_plasma"
	build_type = MECHFAB
	req_tech = list("engineering" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/generator
	category = "Exosuit_Tools"
	materials = list(MAT_IRON=10000,MAT_SILVER=500,MAT_GLASS=1000)

/datum/design/mech_sleeper
	name = "Module Design (Mounted Sleeper)"
	desc = "A mech-mountable sleeper for treating the ill."
	id = "mech_sleeper"
	build_type = MECHFAB
	req_tech = list("biotech" = 1)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/sleeper
	category = "Exosuit_Tools"
	materials = list(MAT_IRON=5000,MAT_GLASS=10000)

/datum/design/mech_generator_nuclear
	name = "Module Design (ExoNuclear Reactor)"
	desc = "Compact nuclear reactor module"
	id = "mech_generator_nuclear"
	build_type = MECHFAB
	req_tech = list("powerstorage"= 3, "engineering" = 3, "materials" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/generator/nuclear
	category = "Exosuit_Modules"
	materials = list(MAT_IRON=10000,MAT_SILVER=500,MAT_GLASS=1000)

/datum/design/mech_jetpack
	name = "Module Design (Exosuit Jetpack)"
	desc = "An exosuit-mounted Jetpack module."
	id = "mech_jetpack"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "magnets" = 4, "engineering" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/jetpack
	category = "Exosuit_Modules"
	materials = list("$iron"=25000,"$plasma"=25000,"$uranium"=7500)

/datum/design/mech_jail_cell
	name = "Exosuit Module Design (Mounted Jail Cell)"
	desc = "Exosuit-controlled secure holding cell"
	id = "mech_jail_cell"
	build_type = MECHFAB
	req_tech = list("biotech" = 2, "combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/jail
	category = "Exosuit_Tools"
	materials = list(MAT_IRON=7500,MAT_GLASS=10000)

/datum/design/mech_tracker
	name = "Exosuit Tracking Device"
	desc = "Exosuit tracker, for tracking exosuits."
	id = "mech_tracker"
	build_type = MECHFAB
	req_tech = list("engineering" = 1)
	build_path = /obj/item/mecha_parts/mecha_tracking
	category = "Misc"
	materials = list(MAT_IRON=500)
