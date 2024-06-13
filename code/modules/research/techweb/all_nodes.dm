
//Current rate: 135000 research points in 90 minutes

TIER_1 = 1
TIER_2 = 2
TIER_3 = 3
TIER_4 = 4
TIER_5 = 5
TIER_POINTS = 2500

/datum/techweb_node/unused
	id = "unused"
	starting_node = TRUE
	display_name = "Unused"
	description = "description"
	design_ids = list(
		"camera_assembly",
		"electropack",
		"extinguisher",
		"fluid_ducts",
		"gas_filter",
		"handcuffs_s",
		"holodisk",
		"light_replacer",
		"plasmaman_gas_filter",
		"slime_scanner",
		"space_heater",
		"toy_armblade",
		"turbine_part_compressor",
		"turbine_part_rotor",
		"turbine_part_stator",
		"turret_control",
		"mmi",
		"mmi_m",
		"plunger",
	)


//Base Nodes
/datum/techweb_node/office_equip
	id = "office_equip"
	starting_node = TRUE
	display_name = "Office Equipment"
	description = "description"
	design_ids = list(
		"fax",
		"sec_pen",
		"handlabel",
		"roll",
		"universal_scanner",
		"desttagger",
		"packagewrap",
		"sticky_tape",
		"toner_large",
		"toner",
		"boxcutter",
		"custom_vendor_refill",
		"bounced_radio",
		"radio_headset",
		"earmuffs",
		"recorder",
		"tape",
		"toy_balloon",
		"pet_carrier",
		"chisel",
		"spraycan",
		"camera_film",
		"camera",
		"razor",
		"bucket",
		"mop",
		"pushbroom",
		"normtrash",
		"wirebrush",
		"flashlight",
		"light_bulb",
		"light_tube",
		"intercom_frame",
		"newscaster_frame",
		"status_display_frame",
	)

// Sec tree

/datum/techweb_node/arms_basic
	id = "arms_basic"
	starting_node = TRUE
	display_name = "Basic Arms"
	description = "description"
	design_ids = list(
		"toygun",
		"c38_rubber",
		"sec_38",
		"capbox",
		"foam_dart",
		"sec_beanbag_slug",
		"sec_dart",
		"sec_Islug",
		"sec_rshot",
	)


// Service tree

/datum/techweb_node/cafeteria_equip
	id = "cafeteria_equip"
	starting_node = TRUE
	display_name = "Cafeteria Equipment"
	description = "description"
	design_ids = list(
		"griddle",
		"microwave",
		"souppot",
		"bowl",
		"plate",
		"oven_tray",
		"servingtray",
		"tongs",
		"spoon",
		"fork",
		"kitchen_knife",
		"plastic_spoon",
		"plastic_fork",
		"plastic_knife",
		"shaker",
		"drinking_glass",
		"shot_glass",
		"coffee_cartridge",
		"coffeemaker",
		"coffeepot",
		"syrup_bottle",
	)
/datum/techweb_node/fishing_equip
	id = "fishing_equip"
	starting_node = TRUE
	display_name = "Fishing Equipment"
	description = "description"
	design_ids = list(
		"fish_case",
		"fishing_rod",
		"fishing_portal_generator",
	)


/datum/techweb_node/botany_equip
	id = "botany_equip"
	starting_node = TRUE
	display_name = "Botany Equipment"
	description = "description"
	design_ids = list(
		"seed_extractor",
		"plant_analyzer",
		"watering_can",
		"spade",
		"cultivator",
		"secateurs",
		"hatchet",
	)



// Med tree

/datum/techweb_node/medbay_equip
	id = "medbay_equip"
	starting_node = TRUE
	display_name = "Medbay Equipment"
	description = "description"
	design_ids = list(
		"surgical_drapes",
		"scalpel",
		"retractor",
		"hemostat",
		"cautery",
		"circular_saw",
		"surgicaldrill",
		"bonesetter",
		"blood_filter",
		"surgical_tape",
		"operating",
		"medicalbed",
		"defibmountdefault",
		"defibrillator",
		"penlight",
		"stethoscope",
		"beaker",
		"large_beaker",
		"syringe",
		"dropper",
		"pillbottle",
	)

// Surgery tree

/datum/techweb_node/oldstation_surgery
	id = "oldstation_surgery"
	display_name = "Experimental Dissection"
	description = "Grants access to experimental dissections, which allows generation of research points."
	design_ids = list(
		"surgery_oldstation_dissection",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500)
	hidden = TRUE
	show_on_wiki = FALSE



// Robotics trees

/datum/techweb_node/robotics
	id = "robotics"
	starting_node = TRUE
	display_name = "Robotics"
	description = "description"
	design_ids = list(
		"mechfab",
		"paicard",
		"botnavbeacon",
	)

/datum/techweb_node/mech_assembly
	id = "mech_assembly"
	starting_node = TRUE
	display_name = "Mech Assembly"
	description = "description"
	design_ids = list(
		"mechapower",
		"mech_recharger",
		"ripley_chassis",
		"ripley_left_arm",
		"ripley_left_leg",
		"ripley_right_arm",
		"ripley_right_leg",
		"ripley_torso",
		"ripley_main",
		"ripley_peri",
		"mech_hydraulic_clamp",
	)

/datum/techweb_node/integrated_circuits
	id = "integrated_circuits"
	starting_node = TRUE
	display_name = "Integrated Circuits"
	description = "description"
	design_ids = list(
		"component_printer",
		"module_duplicator",
		"circuit_multitool",
		"compact_remote_shell",
		"usb_cable"
		"integrated_circuit",
		"comp_access_checker",
		"comp_arctan2",
		"comp_arithmetic",
		"comp_assoc_list_pick",
		"comp_assoc_list_remove",
		"comp_assoc_list_set",
		"comp_binary_convert",
		"comp_clock",
		"comp_comparison",
		"comp_concat",
		"comp_concat_list",
		"comp_decimal_convert",
		"comp_delay",
		"comp_direction",
		"comp_element_find",
		"comp_filter_list",
		"comp_foreach",
		"comp_format",
		"comp_format_assoc",
		"comp_get_column",
		"comp_gps",
		"comp_health",
		"comp_health_state",
		"comp_hear",
		"comp_id_access_reader",
		"comp_id_getter",
		"comp_id_info_reader",
		"comp_index",
		"comp_index_assoc",
		"comp_index_table",
		"comp_laserpointer",
		"comp_length",
		"comp_light",
		"comp_list_add",
		"comp_list_assoc_literal",
		"comp_list_clear",
		"comp_list_literal",
		"comp_list_pick",
		"comp_list_remove",
		"comp_logic",
		"comp_matscanner",
		"comp_mmi",
		"comp_module",
		"comp_multiplexer",
		"comp_not",
		"comp_ntnet_receive",
		"comp_ntnet_send",
		"comp_ntnet_send_list_literal",
		"comp_pinpointer",
		"comp_pressuresensor",
		"comp_radio",
		"comp_random",
		"comp_reagents",
		"comp_router",
		"comp_select_query",
		"comp_self",
		"comp_set_variable_trigger",
		"comp_soundemitter",
		"comp_species",
		"comp_speech",
		"comp_speech",
		"comp_split",
		"comp_string_contains",
		"comp_tempsensor",
		"comp_textcase",
		"comp_timepiece",
		"comp_toggle",
		"comp_tonumber",
		"comp_tostring",
		"comp_trigonometry",
		"comp_typecast",
		"comp_typecheck",
		"comp_view_sensor",
	)

/datum/techweb_node/mod_suit
	id = "mod_suit"
	starting_node = TRUE
	display_name = "Modular Suit"
	description = "description"
	design_ids = list(
		"mod_shell",
		"mod_chestplate",
		"mod_helmet",
		"mod_gauntlets",
		"mod_boots",
		"mod_plating_standard",
		"mod_paint_kit",
		"suit_storage_unit",
		"mod_storage",
		"mod_plasma",
		"mod_flashlight",
	)

/datum/techweb_node/augmentation
	id = "augmentation"
	starting_node = TRUE
	display_name = "Augmentation"
	description = "description"
	design_ids = list(
		"borg_chest",
		"borg_head",
		"borg_l_arm",
		"borg_l_leg",
		"borg_r_arm",
		"borg_r_leg",
		"cybernetic_eyes",
		"cybernetic_eyes_moth",
		"cybernetic_ears",
		"cybernetic_lungs",
		"cybernetic_stomach",
		"cybernetic_liver",
		"cybernetic_heart",
	)






// Sci tree

/datum/techweb_node/fundamental_sci
	id = "fundamental_sci"
	starting_node = TRUE
	display_name = "Fundamental Science"
	description = "description"
	design_ids = list(
		"rdserver",
		"rdservercontrol",
		"rdconsole",
		"tech_disk",
		"doppler_array",
		"anomaly_refinery",
		"experimentor",
		"destructive_analyzer",
		"destructive_scanner",
		"experi_scanner",
		"laptop",
		"c-reader",
	)

/datum/techweb_node/parts_essential
	id = "parts_essential"
	starting_node = TRUE
	display_name = "Essential Stock Parts"
	description = "description"
	design_ids = list(
		"micro_servo",
		"basic_capacitor",
		"basic_matter_bin",
		"basic_micro_laser",
		"basic_scanning",
		"basic_cell",
		"miniature_power_cell",
		"trapdoor_electronics",
		"blast",
		"condenser",
		"igniter",
		"infrared_emitter",
		"prox_sensor",
		"signaler",
		"timer",
		"voice_analyzer",
		"health_sensor",
		"sflash",
	)

// Engi tree

/datum/techweb_node/engi_essential
	id = "engi_essential"
	starting_node = TRUE
	display_name = "Engineering Essentials"
	description = "description"
	design_ids = list(
		"circuit_imprinter_offstation",
		"circuit_imprinter",
		"solar_panel",
		"solar_tracker",
		"tile_sprayer",
		"airlock_painter",
		"decal_painter",
		"pipe_painter",
		"rwd",
		"cable_coil",
		"welding_helmet",
		"welding_tool",
		"tscanner",
		"analyzer",
		"multitool",
		"wrench",
		"crowbar",
		"screwdriver",
		"wirecutters",
	)

// Cargo tree

/datum/techweb_node/material_processing
	id = "material_processing"
	starting_node = TRUE
	display_name = "Material Processing"
	description = "description"
	design_ids = list(
		"pickaxe",
		"shovel",
		"conveyor_switch",
		"conveyor_belt",
		"mass_driver",
		"recycler",
		"stack_machine",
		"stack_console",
		"autolathe",
		"rglass",
		"plasmaglass",
		"plasmareinforcedglass",
		"titaniumglass",
		"plasteel",
		"plastitanium",
		"plastitaniumglass",
		"circuit",
		"circuitgreen",
		"circuitred",
		"tram_floor_dark",
		"tram_floor_light",
	)



/datum/techweb_node/nodeid
	id = "nodeid"
	starting_node = TRUE
	display_name = "name"
	description = "description"
	design_ids = list(
		"mmi",
	)
