
//Current rate: 135000 research points in 90 minutes

#define TIER_1_POINTS 2000
#define TIER_2_POINTS 4000
#define TIER_3_POINTS 6000
#define TIER_4_POINTS 8000
#define TIER_5_POINTS 10000

/datum/techweb_node/unused
	id = "unused"
	starting_node = TRUE
	display_name = "Unused"
	description = "description"
	design_ids = list(
		"gas_filter",
		"holodisk",
		"plasmaman_gas_filter",
		"space_heater",
		"turbine_part_compressor",
		"turbine_part_rotor",
		"turbine_part_stator",
		"mmi",
		"mmi_m",
		"anomaly_refinery",
		"blutrash",
		"holobarrier_jani",
		"light_replacer_blue",
		"gravitygun",
	)

// General tree
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

/datum/techweb_node/sanitation
	id = "sanitation"
	display_name = "Advanced Sanitation Technology"
	description = "description"
	prereq_ids = list("office_equip")
	design_ids = list(
		"advmop",
		"light_replacer",
		"spraybottle",
		"paint_remover",
		"beartrap",
		"buffer",
		"vacuum",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/toys
	id = "toys"
	display_name = "New Toys"
	description = "description"
	prereq_ids = list("office_equip")
	design_ids = list(
		"toy_armblade",
		"air_horn",
		"clown_firing_pin",
		"smoke_machine",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/consoles
	id = "consoles"
	display_name = "Civilian Consoles"
	description = "description"
	prereq_ids = list("office_equip")
	design_ids = list(
		"comconsole",
		"cargo",
		"cargorequest",
		"med_data",
		"crewconsole",
		"bankmachine",
		"account_console",
		"idcard",
		"libraryconsole",
		"barcode_scanner",
		"vendor",
		"custom_vendor_refill",
		"bounty_pad_control",
		"bounty_pad",
		"portadrive_advanced",
		"portadrive_basic",
		"portadrive_super",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/gaming
	id = "gaming"
	display_name = "Gaming"
	description = "description"
	prereq_ids = list("toys", "consoles")
	design_ids = list(
		"arcade_battle",
		"arcade_orion",
		"slotmachine",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

// Sec tree
/datum/techweb_node/basic_arms
	id = "basic_arms"
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

/datum/techweb_node/sec_equip
	id = "sec_equip"
	display_name = "Security Equipment"
	description = "description"
	prereq_ids = list("basic_arms")
	design_ids = list(
		"camera_assembly",
		"secdata",
		"mining",
		"prisonmanage",
		"rdcamera",
		"seccamera",
		"security_photobooth",
		"photobooth",
		"scanner_gate",
		"turret_control",
		"pepperspray",
		"inspector",
		"evidencebag",
		"handcuffs_s",
		"zipties",
		"seclite",
		"electropack",
		"bola_energy",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/riot_supression
	id = "riot_supression"
	display_name = "Riot Supression"
	description = "description"
	prereq_ids = list("sec_equip")
	design_ids = list(
		"pin_testing",
		"pin_loyalty",
		"tele_shield",
		"ballistic_shield",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/ammo
	id = "ammo"
	display_name = "Exotic Ammunition"
	description = "description"
	prereq_ids = list("riot_supression")
	design_ids = list(
		"c38_hotshot",
		"c38_iceblox",
		"lasershell",
		"techshotshell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)

/datum/techweb_node/electric_weapons
	id = "electric_weapons"
	display_name = "Electric Weaponry"
	description = "description"
	prereq_ids = list("ammo")
	design_ids = list(
		"ioncarbine",
		"stunrevolver",
		"temp_gun",
		"xray_laser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

/datum/techweb_node/explosives
	id = "explosives"
	display_name = "Explosives"
	description = "description"
	prereq_ids = list("ammo")
	design_ids = list(
		"large_grenade",
		"adv_grenade",
		"pyro_grenade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

/datum/techweb_node/beam_weapons
	id = "beam_weapons"
	display_name = "Advanced Beam Weaponry"
	description = "description"
	prereq_ids = list("electric_weapons")
	design_ids = list(
		"beamrifle",
		"nuclear_gun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)


// Service trees
// Kitchen tree
/datum/techweb_node/cafeteria_equip
	id = "cafeteria_equip"
	starting_node = TRUE
	display_name = "Cafeteria Equipment"
	description = "description"
	design_ids = list(
		"griddle",
		"microwave",
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

/datum/techweb_node/food_proc
	id = "food_proc"
	display_name = "Food Processing"
	description = "description"
	prereq_ids = list("cafeteria_equip")
	design_ids = list(
		"deepfryer",
		"oven",
		"stove",
		"range",
		"souppot",
		"processor",
		"gibber",
		"monkey_recycler",
		"reagentgrinder",
		"microwave_engineering",
		"smartfridge",
		"sheetifier",
		"fat_sucker",
		"dish_drive",
		"roastingstick",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

// Fishing tree
/datum/techweb_node/fishing_equip
	id = "fishing_equip"
	starting_node = TRUE
	display_name = "Fishing Equipment"
	description = "description"
	design_ids = list(
		"fishing_portal_generator",
		"fishing_rod",
		"fish_case",
	)

/datum/techweb_node/fishing_equip_adv
	id = "fishing_equip_adv"
	display_name = "Advanced Fishing Tools"
	description = "description"
	prereq_ids = list("fishing_equip")
	design_ids = list(
		"fishing_rod_tech",
		"stabilized_hook",
		"auto_reel",
		"fish_analyzer",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)
	required_experiments = list(/datum/experiment/scanning/fish)

// Botany tree
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

/datum/techweb_node/hydroponics
	id = "hydroponics"
	display_name = "Hydroponics"
	description = "description"
	prereq_ids = list("botany_equip", "chem_synthesis")
	design_ids = list(
		"biogenerator",
		"hydro_tray",
		"portaseeder",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/selection
	id = "selection"
	display_name = "Artificial Selection"
	description = "description"
	prereq_ids = list("hydroponics")
	design_ids = list(
		"flora_gun",
		"gene_shears",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)
	required_experiments = list(/datum/experiment/scanning/random/plants/wild)

// Medbay trees
/datum/techweb_node/medbay_equip
	id = "medbay_equip"
	starting_node = TRUE
	display_name = "Medbay Equipment"
	description = "description"
	design_ids = list(
		"operating",
		"medicalbed",
		"defibmountdefault",
		"defibrillator",
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
		"penlight",
		"penlight_paramedic",
		"stethoscope",
		"beaker",
		"large_beaker",
		"syringe",
		"dropper",
		"pillbottle",
	)

// Biology tree
/datum/techweb_node/bio_scan
	id = "bio_scan"
	display_name = "Biological Scan"
	description = "description"
	prereq_ids = list("medbay_equip")
	design_ids = list(
		"healthanalyzer",
		"autopsyscanner",
		"medical_kiosk",
		"chem_master",
		"chem_mass_spec",
		"ph_meter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/cytology
	id = "cytology"
	display_name = "Cytology"
	description = "description"
	prereq_ids = list("bio_scan")
	design_ids = list(
		"pandemic",
		"petri_dish",
		"swab",
		"biopsy_tool",
		"limbgrower",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/xenobiology
	id = "xenobiology"
	display_name = "Xenobiology"
	description = "description"
	prereq_ids = list("cytology")
	design_ids = list(
		"xenobioconsole",
		"slime_scanner",
		"limbdesign_ethereal",
		"limbdesign_felinid",
		"limbdesign_lizard",
		"limbdesign_plasmaman",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)
	required_experiments = list(/datum/experiment/scanning/random/cytology)

/datum/techweb_node/gene_engineering
	id = "gene_engineering"
	display_name = "Gene Engineering"
	description = "description"
	prereq_ids = list("selection", "xenobiology")
	design_ids = list(
		"genescanner",
		"mod_dna_lock",
		"dnascanner",
		"scan_console",
		"dna_disk",
		"dnainfuser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

// Chemistry tree
/datum/techweb_node/chem_synthesis
	id = "chem_synthesis"
	display_name = "Chemical Synthesis"
	description = "description"
	prereq_ids = list("medbay_equip")
	design_ids = list(
		"xlarge_beaker",
		"blood_pack",
		"chem_pack",
		"med_spray_bottle",
		"medigel",
		"medipen_refiller",
		"soda_dispenser",
		"beer_dispenser",
		"chem_dispenser",
		"portable_chem_mixer",
		"chem_heater",
		"w-recycler",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/plumbing
	id = "plumbing"
	display_name = "Plumbing"
	description = "description"
	prereq_ids = list("chem_synthesis")
	design_ids = list(
		"plumbing_rcd",
		"plumbing_rcd_service",
		"plumbing_rcd_sci",
		"plunger",
		"fluid_ducts",
		"meta_beaker",
		"piercesyringe",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/cryostasis
	id = "cryostasis"
	display_name = "Cryostasis"
	description = "description"
	prereq_ids = list("plumbing", "fusion")
	design_ids = list(
		"cryo_grenade",
		"cryotube",
		"splitbeaker",
		"stasis",
		"mech_sleeper",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)

/datum/techweb_node/medbay_equip_adv
	id = "medbay_equip_adv"
	display_name = "Advanced Medbay Equipment"
	description = "description"
	prereq_ids = list("cryostasis")
	design_ids = list(
		"healthanalyzer_advanced",
		"mod_health_analyzer",
		"defibrillator_compact",
		"crewpinpointer",
		"plasmarefiller",
		"defibmount",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

// Surgery tree
/datum/techweb_node/oldstation_surgery
	id = "oldstation_surgery"
	display_name = "Experimental Dissection"
	description = "Grants access to experimental dissections, which allows generation of research points."
	prereq_ids = list("medbay_equip")
	design_ids = list(
		"surgery_oldstation_dissection",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)
	hidden = TRUE
	show_on_wiki = FALSE

/datum/techweb_node/surgery
	id = "surgery"
	display_name = "Improved Wound-Tending"
	description = "description"
	prereq_ids = list("medbay_equip")
	design_ids = list(
		"surgery_heal_brute_upgrade",
		"surgery_heal_burn_upgrade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/surgery_adv
	id = "surgery_adv"
	display_name = "Advanced Surgery"
	description = "description"
	prereq_ids = list("surgery")
	design_ids = list(
		"harvester",
		"surgery_heal_brute_upgrade_femto",
		"surgery_heal_burn_upgrade_femto",
		"surgery_heal_combo",
		"surgery_lobotomy",
		"surgery_wing_reconstruction",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)
	required_experiments = list(/datum/experiment/autopsy/human)

/datum/techweb_node/surgery_exp
	id = "surgery_exp"
	display_name = "Experimental Surgery"
	description = "description"
	prereq_ids = list("surgery_adv")
	design_ids = list(
		"surgery_cortex_folding",
		"surgery_cortex_imprint",
		"surgery_heal_combo_upgrade",
		"surgery_ligament_hook",
		"surgery_ligament_reinforcement",
		"surgery_muscled_veins",
		"surgery_nerve_ground",
		"surgery_nerve_splice",
		"surgery_pacify",
		"surgery_vein_thread",
		"surgery_viral_bond",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)
	required_experiments = list(/datum/experiment/autopsy/nonhuman)

/datum/techweb_node/surgery_tools
	id = "surgery_tools"
	display_name = "Advanced Surgery Tools"
	description = "description"
	prereq_ids = list("surgery_exp", "cryostasis")
	design_ids = list(
		"laserscalpel",
		"searingtool",
		"mechanicalpinches",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

// Robotics trees
/datum/techweb_node/robotics
	id = "robotics"
	starting_node = TRUE
	display_name = "Robotics"
	description = "description"
	design_ids = list(
		"mechfab",
		"botnavbeacon",
		"paicard",
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
		"usb_cable",
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
		"suit_storage_unit",
		"mod_shell",
		"mod_chestplate",
		"mod_helmet",
		"mod_gauntlets",
		"mod_boots",
		"mod_plating_standard",
		"mod_paint_kit",
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
		"high_cell",
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

/datum/techweb_node/atmos_equip
	id = "atmos_equip"
	display_name = "Engineering Essentials"
	description = "description"
	prereq_ids = list("engi_essential")
	design_ids = list(
		"extinguisher",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/fusion
	id = "fusion"
	display_name = "Fusion"
	description = "description"
	prereq_ids = list("atmos_equip")
	design_ids = list(
		"extinguisher",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

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
		"plasteel",
		"titaniumglass",
		"plastitanium",
		"plastitaniumglass",
		"circuit",
		"circuitgreen",
		"circuitred",
		"tram_floor_dark",
		"tram_floor_light",
	)




#undef TIER_1_POINTS
#undef TIER_2_POINTS
#undef TIER_3_POINTS
#undef TIER_4_POINTS
#undef TIER_5_POINTS
