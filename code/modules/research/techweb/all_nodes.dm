
//Current rate: 135000 research points in 90 minutes

//Base Nodes
/datum/techweb_node/base
	id = "base"
	starting_node = TRUE
	display_name = "Basic Research Technology"
	description = "NT default research technologies."
	// Default research tech, prevents bricking
	design_ids = list(
		"basic_capacitor",
		"basic_cell",
		"basic_matter_bin",
		"basic_micro_laser",
		"basic_scanning",
		"bepis",
		"blast",
		"bounced_radio",
		"bowl",
		"bucket",
		"c-reader",
		"c38_rubber",
		"camera_assembly",
		"camera_film",
		"camera",
		"capbox",
		"chisel",
		"circuit_imprinter_offstation",
		"circuit_imprinter",
		"circuit",
		"circuitgreen",
		"circuitred",
		"coffee_cartridge",
		"coffeemaker",
		"coffeepot",
		"condenser",
		"conveyor_belt",
		"conveyor_switch",
		"custom_vendor_refill",
		"destructive_analyzer",
		"destructive_scanner",
		"desttagger",
		"doppler_array",
		"drinking_glass",
		"earmuffs",
		"electropack",
		"experi_scanner",
		"experimentor",
		"extinguisher",
		"fax",
		"fishing_rod",
		"flashlight",
		"fluid_ducts",
		"foam_dart",
		"fork",
		"gas_filter",
		"handcuffs_s",
		"handlabel",
		"health_sensor",
		"holodisk",
		"igniter",
		"infrared_emitter",
		"intercom_frame",
		"kitchen_knife",
		"laptop",
		"light_bulb",
		"light_replacer",
		"light_tube",
		"mechfab",
		"micro_servo",
		"miniature_power_cell",
		"newscaster_frame",
		"oven_tray",
		"packagewrap",
		"pet_carrier",
		"plasmaglass",
		"plasmaman_gas_filter",
		"plasmareinforcedglass",
		"plasteel",
		"plastic_fork",
		"plastic_knife",
		"plastic_spoon",
		"plastitanium",
		"plastitaniumglass",
		"plate",
		"prox_sensor",
		"radio_headset",
		"rdconsole",
		"rdserver",
		"rdservercontrol",
		"receiver",
		"recorder",
		"rglass",
		"roll",
		"sec_38",
		"sec_beanbag_slug",
		"sec_dart",
		"sec_Islug",
		"sec_rshot",
		"servingtray",
		"shaker",
		"shot_glass",
		"signaler",
		"slime_scanner",
		"solar_panel",
		"solar_tracker",
		"space_heater",
		"spoon",
		"status_display_frame",
		"sticky_tape",
		"syrup_bottle",
		"tape",
		"tech_disk",
		"timer",
		"titaniumglass",
		"toner_large",
		"toner",
		"toy_armblade",
		"toy_balloon",
		"toygun",
		"trapdoor_electronics",
		"turbine_part_compressor",
		"turbine_part_rotor",
		"turbine_part_stator",
		"turret_control",
		"universal_scanner",
		"voice_analyzer",
		"watering_can",
	)

/datum/techweb_node/mmi
	id = "mmi"
	starting_node = TRUE
	display_name = "Man Machine Interface"
	description = "A slightly Frankensteinian device that allows human brains to interface natively with software APIs."
	design_ids = list(
		"mmi",
	)

/datum/techweb_node/cyborg
	id = "cyborg"
	starting_node = TRUE
	display_name = "Cyborg Construction"
	description = "Sapient robots with preloaded tool modules and programmable laws."
	design_ids = list(
		"borg_chest",
		"borg_head",
		"borg_l_arm",
		"borg_l_leg",
		"borg_r_arm",
		"borg_r_leg",
		"borg_suit",
		"borg_upgrade_rename",
		"borg_upgrade_restart",
		"borgupload",
		"cyborgrecharger",
		"robocontrol",
		"sflash",
	)

/datum/techweb_node/mech
	id = "mecha"
	starting_node = TRUE
	display_name = "Mechanical Exosuits"
	description = "Mechanized exosuits that are several magnitudes stronger and more powerful than the average human."
	design_ids = list(
		"mech_hydraulic_clamp",
		"mech_recharger",
		"mecha_tracking",
		"mechacontrol",
		"mechapower",
		"ripley_chassis",
		"ripley_left_arm",
		"ripley_left_leg",
		"ripley_main",
		"ripley_peri",
		"ripley_right_arm",
		"ripley_right_leg",
		"ripley_torso",
		"ripleyupgrade",
	)

/datum/techweb_node/mod_basic
	id = "mod"
	starting_node = TRUE
	display_name = "Basic Modular Suits"
	description = "Specialized back mounted power suits with various different modules."
	design_ids = list(
		"mod_boots",
		"mod_chestplate",
		"mod_gauntlets",
		"mod_helmet",
		"mod_paint_kit",
		"mod_shell",
		"mod_plating_standard",
		"mod_storage",
		"mod_welding",
		"mod_mouthhole",
		"mod_flashlight",
		"mod_longfall",
		"mod_thermal_regulator",
		"mod_plasma",
		"mod_sign_radio",
	)

/datum/techweb_node/mech_tools
	id = "mech_tools"
	starting_node = TRUE
	display_name = "Basic Exosuit Equipment"
	description = "Various tools fit for basic mech units"
	design_ids = list(
		"mech_drill",
		"mech_extinguisher",
		"mech_mscanner",
	)

/datum/techweb_node/basic_tools
	id = "basic_tools"
	starting_node = TRUE
	display_name = "Basic Tools"
	description = "Basic mechanical, electronic, surgical and botanical tools."
	design_ids = list(
		"airlock_painter",
		"analyzer",
		"boxcutter",
		"cable_coil",
		"cable_coil",
		"crowbar",
		"cultivator",
		"decal_painter",
		"hatchet",
		"mop",
		"multitool",
		"normtrash",
		"pipe_painter",
		"plant_analyzer",
		"plunger",
		"pushbroom",
		"rwd",
		"razor",
		"screwdriver",
		"secateurs",
		"shovel",
		"spade",
		"spraycan",
		"tile_sprayer",
		"tscanner",
		"welding_helmet",
		"welding_tool",
		"wirebrush",
		"wirecutters",
		"wrench",
		"pickaxe",
	)

/datum/techweb_node/basic_medical
	id = "basic_medical"
	starting_node = TRUE
	display_name = "Basic Medical Equipment"
	description = "Basic medical tools and equipment."
	design_ids = list(
		"beaker",
		"biopsy_tool",
		"blood_filter",
		"bonesetter",
		"cautery",
		"circular_saw",
		"cybernetic_ears",
		"cybernetic_eyes",
		"cybernetic_heart",
		"cybernetic_liver",
		"cybernetic_lungs",
		"cybernetic_stomach",
		"defibmountdefault",
		"dropper",
		"hemostat",
		"large_beaker",
		"mmi_m",
		"operating",
		"petri_dish",
		"pillbottle",
		"plumbing_rcd",
		"plumbing_rcd_service",
		"plumbing_rcd_sci",
		"portable_chem_mixer",
		"retractor",
		"scalpel",
		"stethoscope",
		"surgical_drapes",
		"surgical_tape",
		"surgicaldrill",
		"swab",
		"syringe",
		"xlarge_beaker",
	)

/datum/techweb_node/basic_circuitry
	id = "basic_circuitry"
	starting_node = TRUE
	display_name = "Basic Integrated Circuits"
	description = "Research on how to fully exploit the power of integrated circuits"
	design_ids = list(
		"circuit_multitool",
		"comp_access_checker",
		"comp_arithmetic",
		"comp_assoc_list_pick",
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
		"comp_tonumber",
		"comp_tostring",
		"comp_trigonometry",
		"comp_typecast",
		"comp_typecheck",
		"comp_view_sensor",
		"compact_remote_shell",
		"component_printer",
		"integrated_circuit",
		"module_duplicator",
		"usb_cable"
	)

/////////////////////////Biotech/////////////////////////

/datum/techweb_node/biotech
	id = "biotech"
	display_name = "Biological Technology"
	description = "What makes us tick." //the MC, silly!
	prereq_ids = list("base")
	design_ids = list(
		"beer_dispenser",
		"blood_pack",
		"chem_dispenser",
		"chem_heater",
		"chem_mass_spec",
		"chem_master",
		"chem_pack",
		"defibmount",
		"defibrillator",
		"genescanner",
		"healthanalyzer",
		"med_spray_bottle",
		"medical_kiosk",
		"medigel",
		"medipen_refiller",
		"pandemic",
		"soda_dispenser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	required_experiments = list(/datum/experiment/autopsy/human)

/datum/techweb_node/adv_biotech
	id = "adv_biotech"
	display_name = "Advanced Biotechnology"
	description = "Advanced Biotechnology"
	prereq_ids = list("biotech")
	design_ids = list(
		"autopsyscanner",
		"crewpinpointer",
		"defibrillator_compact",
		"harvester",
		"healthanalyzer_advanced",
		"holobarrier_med",
		"limbgrower",
		"meta_beaker",
		"ph_meter",
		"piercesyringe",
		"plasmarefiller",
		"smoke_machine",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	required_experiments = list(/datum/experiment/autopsy/nonhuman)
	discount_experiments = list(/datum/experiment/scanning/random/material/meat = 4000)

/datum/techweb_node/xenoorgan_biotech
	id = "xenoorgan_bio"
	display_name = "Xeno-organ Biology"
	description = "Plasmaman, Ethereals, Lizardpeople... What makes our non-human crewmembers tick?"
	prereq_ids = list("adv_biotech")
	design_ids = list(
		"limbdesign_ethereal",
		"limbdesign_felinid",
		"limbdesign_lizard",
		"limbdesign_plasmaman",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 6500)
	discount_experiments = list(
		/datum/experiment/scanning/random/cytology/easy = 1000,
		/datum/experiment/scanning/points/slime/hard = 5000,
		/datum/experiment/autopsy/xenomorph = 5000,
	)

/datum/techweb_node/morphological_theory
	id = "morphological_theory"
	display_name = "Anomalous Morphology"
	description = "Use poorly understood energies to change your body."
	prereq_ids = list("adv_biotech", "anomaly_research")
	design_ids = list("polymorph_belt")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	discount_experiments = list(
		/datum/experiment/scanning/people/novel_organs = 5000,
	)

/datum/techweb_node/bio_process
	id = "bio_process"
	display_name = "Biological Processing"
	description = "From slimes to kitchens."
	prereq_ids = list("biotech")
	design_ids = list(
		"deepfryer",
		"dish_drive",
		"fat_sucker",
		"gibber",
		"griddle",
		"microwave",
		"monkey_recycler",
		"oven",
		"processor",
		"range", // should be in a further node, probably
		"reagentgrinder",
		"smartfridge",
		"stove",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4000)
	discount_experiments = list(/datum/experiment/scanning/random/cytology = 3000) //Big discount to reinforce doing it.

/////////////////////////Advanced Surgery/////////////////////////

/datum/techweb_node/imp_wt_surgery
	id = "imp_wt_surgery"
	display_name = "Improved Wound-Tending Surgery"
	description = "Who would have known being more gentle with a hemostat decreases patient pain?"
	prereq_ids = list("biotech")
	design_ids = list(
		"surgery_heal_brute_upgrade",
		"surgery_heal_burn_upgrade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)


/datum/techweb_node/adv_surgery
	id = "adv_surgery"
	display_name = "Advanced Surgery"
	description = "When simple medicine doesn't cut it."
	prereq_ids = list("imp_wt_surgery")
	design_ids = list(
		"surgery_heal_brute_upgrade_femto",
		"surgery_heal_burn_upgrade_femto",
		"surgery_heal_combo",
		"surgery_lobotomy",
		"surgery_wing_reconstruction",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)

/datum/techweb_node/exp_surgery
	id = "exp_surgery"
	display_name = "Experimental Surgery"
	description = "When evolution isn't fast enough."
	prereq_ids = list("adv_surgery")
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
	discount_experiments = list(/datum/experiment/scanning/random/plants/traits = 4500)

/datum/techweb_node/alien_surgery
	id = "alien_surgery"
	display_name = "Alien Surgery"
	description = "Abductors did nothing wrong."
	prereq_ids = list("exp_surgery", "alientech")
	design_ids = list(
		"surgery_brainwashing",
		"surgery_heal_combo_upgrade_femto",
		"surgery_zombie",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)

/////////////////////////data theory tech/////////////////////////

/datum/techweb_node/datatheory //Computer science
	id = "datatheory"
	display_name = "Data Theory"
	description = "Big Data, in space!"
	prereq_ids = list("base")
	design_ids = list(
		"bounty_pad",
		"bounty_pad_control",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)


/////////////////////////engineering tech/////////////////////////

/datum/techweb_node/engineering
	id = "engineering"
	display_name = "Industrial Engineering"
	description = "A refresher course on modern engineering technology."
	prereq_ids = list("base")
	design_ids = list(
		"adv_capacitor",
		"adv_matter_bin",
		"adv_scanning",
		"airalarm_electronics",
		"airlock_board",
		"anomaly_refinery",
		"apc_control",
		"atmos_control",
		"atmos_thermal",
		"atmosalerts",
		"autolathe",
		"cell_charger",
		"crystallizer",
		"electrolyzer",
		"emergency_oxygen_engi",
		"emergency_oxygen",
		"emitter",
		"firealarm_electronics",
		"firelock_board",
		"generic_tank",
		"grounding_rod",
		"high_cell",
		"high_micro_laser",
		"mesons",
		"nano_servo",
		"oxygen_tank",
		"pacman",
		"plasma_tank",
		"plasmaman_tank_belt",
		"pneumatic_seal",
		"power_control",
		"powermonitor",
		"recharger",
		"recycler",
		"rped",
		"scanner_gate",
		"solarcontrol",
		"stack_console",
		"stack_machine",
		"suit_storage_unit",
		"tank_compressor",
		"tesla_coil",
		"thermomachine",
		"w-recycler",
		"welding_goggles",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 12500)
	discount_experiments = list(/datum/experiment/scanning/random/material/easy = 7500)

/datum/techweb_node/adv_engi
	id = "adv_engi"
	display_name = "Advanced Engineering"
	description = "Pushing the boundaries of physics, one chainsaw-fist at a time."
	prereq_ids = list("engineering", "emp_basic")
	design_ids = list(
		"HFR_core",
		"HFR_corner",
		"HFR_fuel_input",
		"HFR_interface",
		"HFR_moderator_input",
		"HFR_waste_output",
		"engine_goggles",
		"forcefield_projector",
		"magboots",
		"rcd_loaded",
		"rcd_ammo",
		"rpd_loaded",
		"rtd_loaded",
		"sheetifier",
		"weldingmask",
		"bolter_wrench",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 15000)
	discount_experiments = list(
		/datum/experiment/scanning/random/material/medium/one = 4000,
		/datum/experiment/ordnance/gaseous/bz = 10000,
	)

/datum/techweb_node/anomaly
	id = "anomaly_research"
	display_name = "Anomaly Research"
	description = "Unlock the potential of the mysterious anomalies that appear on station."
	prereq_ids = list("adv_engi", "practical_bluespace")
	design_ids = list(
		"anomaly_neutralizer",
		"reactive_armour",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

/datum/techweb_node/high_efficiency
	id = "high_efficiency"
	display_name = "High Efficiency Parts"
	description = "Finely-tooled manufacturing techniques allowing for picometer-perfect precision levels."
	prereq_ids = list("engineering", "datatheory")
	design_ids = list(
		"pico_servo",
		"super_matter_bin",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier2_lathes = 5000)

/datum/techweb_node/adv_power
	id = "adv_power"
	display_name = "Advanced Power Manipulation"
	description = "How to get more zap."
	prereq_ids = list("engineering")
	design_ids = list(
		"hyper_cell",
		"power_turbine_console",
		"smes",
		"super_capacitor",
		"super_cell",
		"turbine_compressor",
		"turbine_rotor",
		"turbine_stator",
		"modular_shield_generator",
		"modular_shield_node",
		"modular_shield_relay",
		"modular_shield_charger",
		"modular_shield_well",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3500)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_pinpoint_scan/tier2_capacitors = 2500)

/////////////////////////Bluespace tech/////////////////////////
/datum/techweb_node/bluespace_basic //Bluespace-memery
	id = "bluespace_basic"
	display_name = "Basic Bluespace Theory"
	description = "Basic studies into the mysterious alternate dimension known as bluespace."
	prereq_ids = list("base")
	design_ids = list(
		"beacon",
		"bluespace_crystal",
		"telesci_gps",
		"xenobioconsole",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/bluespace_travel
	id = "bluespace_travel"
	display_name = "Bluespace Travel"
	description = "Application of Bluespace for static teleportation technology."
	prereq_ids = list("practical_bluespace")
	design_ids = list(
		"bluespace_pod",
		"launchpad",
		"launchpad_console",
		"quantumpad",
		"tele_hub",
		"tele_station",
		"teleconsole",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier3_bluespacemachines = 4000)

/datum/techweb_node/micro_bluespace
	id = "micro_bluespace"
	display_name = "Miniaturized Bluespace Research"
	description = "Extreme reduction in space required for bluespace engines, leading to portable bluespace technology."
	prereq_ids = list("bluespace_travel", "practical_bluespace", "high_efficiency")
	design_ids = list(
		"bluespace_matter_bin",
		"bluespacebodybag",
		"femto_servo",
		"quantum_keycard",
		"swapper",
		"triphasic_scanning",
		"wormholeprojector",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier3_variety = 5000)
		/* /datum/experiment/exploration_scan/random/condition) this should have a point cost but im not even sure the experiment works properly lmao*/

/datum/techweb_node/advanced_bluespace
	id = "bluespace_storage"
	display_name = "Advanced Bluespace Storage"
	description = "With the use of bluespace we can create even more advanced storage devices than we could have ever done"
	prereq_ids = list("micro_bluespace", "janitor")
	design_ids = list(
		"bag_holding",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

/datum/techweb_node/practical_bluespace
	id = "practical_bluespace"
	display_name = "Applied Bluespace Research"
	description = "Using bluespace to make things faster and better."
	prereq_ids = list("bluespace_basic", "engineering")
	design_ids = list(
		"bluespacebeaker",
		"bluespacesyringe",
		"bluespace_coffeepot",
		"bs_rped",
		"minerbag_holding",
		"ore_silo",
		"phasic_scanning",
		"plumbing_receiver",
		"roastingstick",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_pinpoint_scan/tier2_scanmodules = 3500)

/datum/techweb_node/bluespace_power
	id = "bluespace_power"
	display_name = "Bluespace Power Technology"
	description = "Even more powerful.. power!"
	prereq_ids = list("adv_power", "practical_bluespace")
	design_ids = list(
		"bluespace_cell",
		"quadratic_capacitor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4000)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_pinpoint_scan/tier3_cells = 3000)

/datum/techweb_node/regulated_bluespace
	id = "regulated_bluespace"
	display_name = "Regulated Bluespace Research"
	description = "Bluespace technology using stable and balanced procedures. Required by galactic convention for public use."
	prereq_ids = list("base")
	design_ids = list(
		"spaceship_navigation_beacon",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/unregulated_bluespace
	id = "unregulated_bluespace"
	display_name = "Unregulated Bluespace Research"
	description = "Bluespace technology using unstable or unbalanced procedures, prone to damaging the fabric of bluespace. Outlawed by galactic conventions."
	prereq_ids = list("bluespace_travel", "syndicate_basic")
	design_ids = list(
		"desynchronizer",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)


/////////////////////////plasma tech/////////////////////////
/datum/techweb_node/basic_plasma
	id = "basic_plasma"
	display_name = "Basic Plasma Research"
	description = "Research into the mysterious and dangerous substance, plasma."
	prereq_ids = list("engineering")
	design_ids = list(
		"mech_generator",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_plasma
	id = "adv_plasma"
	display_name = "Advanced Plasma Research"
	description = "Research on how to fully exploit the power of plasma."
	prereq_ids = list("basic_plasma")
	design_ids = list(
		"mech_plasma_cutter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/////////////////////////integrated circuits tech/////////////////////////

/datum/techweb_node/adv_shells
	id = "adv_shells"
	display_name = "Advanced Shell Research"
	description = "Grants access to more complicated shell designs."
	prereq_ids = list("basic_circuitry", "engineering")
	design_ids = list(
		"assembly_shell",
		"bot_shell",
		"comp_mod_action",
		"controller_shell",
		"dispenser_shell",
		"door_shell",
		"gun_shell",
		"keyboard_shell",
		"module_shell",
		"money_bot_shell",
		"scanner_gate_shell",
		"scanner_shell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/bci_shells
	id = "bci_shells"
	display_name = "Brain-Computer Interfaces"
	description = "Grants access to biocompatable shell designs and components."
	prereq_ids = list("adv_shells")
	design_ids = list(
		"bci_implanter",
		"bci_shell",
		"comp_bar_overlay",
		"comp_bci_action",
		"comp_counter_overlay",
		"comp_install_detector",
		"comp_object_overlay",
		"comp_reagent_injector",
		"comp_target_intercept",
		"comp_thought_listener",
		"comp_vox",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500)

/datum/techweb_node/movable_shells_tech
	id = "movable_shells"
	display_name = "Movable Shell Research"
	description = "Grants access to movable shells."
	prereq_ids = list("adv_shells", "robotics")
	design_ids = list(
		"comp_pathfind",
		"comp_pull",
		"drone_shell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)

/datum/techweb_node/server_shell_tech
	id = "server_shell"
	display_name = "Server Technology Research"
	description = "Grants access to a server shell that has a very high capacity for components."
	prereq_ids = list("adv_shells", "computer_data_disks")
	design_ids = list(
		"server_shell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)

/////////////////////////robotics tech/////////////////////////
/datum/techweb_node/robotics
	id = "robotics"
	display_name = "Basic Robotics Research"
	description = "Programmable machines that make our lives lazier."
	prereq_ids = list("base")
	design_ids = list(
		"paicard",
		"mecha_camera",
		"botnavbeacon",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_robotics
	id = "adv_robotics"
	display_name = "Advanced Robotics Research"
	description = "Machines using actual neural networks to simulate human lives."
	prereq_ids = list("neural_programming", "robotics")
	design_ids = list(
		"mmi_posi",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_bots
	id = "adv_bots"
	display_name = "Advanced Bots Research"
	description = "Grants access to a special launchpad designed for bots."
	prereq_ids = list("robotics")
	design_ids = list(
		"botpad",
		"botpad_remote",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/exodrone_tech
	id = "exodrone"
	display_name = "Exploration Drone Research"
	description = "Technology for exploring far away locations."
	prereq_ids = list("robotics")
	design_ids = list(
		"exodrone_console",
		"exodrone_launcher",
		"exoscanner",
		"exoscanner_console",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/neural_programming
	id = "neural_programming"
	display_name = "Neural Programming"
	description = "Study into networks of processing units that mimic our brains."
	prereq_ids = list("biotech", "datatheory")
	design_ids = list(
		"skill_station",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/cyborg_upg_util
	id = "cyborg_upg_util"
	display_name = "Cyborg Upgrades: Utility"
	description = "Utility upgrades for cyborgs."
	prereq_ids = list("adv_robotics")
	design_ids = list(
		"borg_upgrade_advancedmop",
		"borg_upgrade_broomer",
		"borg_upgrade_expand",
		"borg_upgrade_prt",
		"borg_upgrade_selfrepair",
		"borg_upgrade_thrusters",
		"borg_upgrade_trashofholding",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)

/datum/techweb_node/cyborg_upg_util/New()
	. = ..()
	if(!CONFIG_GET(flag/disable_secborg))
		design_ids += "borg_upgrade_disablercooler"

/datum/techweb_node/cyborg_upg_serv
	id = "cyborg_upg_serv"
	display_name = "Cyborg Upgrades: Service"
	description = "Service upgrades for cyborgs."
	prereq_ids = list("adv_robotics")
	design_ids = list(
		"borg_upgrade_rolling_table",
		"borg_upgrade_condiment_synthesizer",
		"borg_upgrade_silicon_knife",
		"borg_upgrade_service_apparatus",
		"borg_upgrade_service_cookbook",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)

/datum/techweb_node/cyborg_upg_engiminer
	id = "cyborg_upg_engiminer"
	display_name = "Cyborg Upgrades: Engineering & Mining"
	description = "Engineering and Mining upgrades for cyborgs."
	prereq_ids = list("adv_engi", "basic_mining")
	design_ids = list(
		"borg_upgrade_circuitapp",
		"borg_upgrade_diamonddrill",
		"borg_upgrade_holding",
		"borg_upgrade_lavaproof",
		"borg_upgrade_rped",
		"borg_upgrade_hypermod",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)

/datum/techweb_node/cyborg_upg_med
	id = "cyborg_upg_med"
	display_name = "Cyborg Upgrades: Medical"
	description = "Medical upgrades for cyborgs."
	prereq_ids = list("adv_biotech")
	design_ids = list(
		"borg_upgrade_beakerapp",
		"borg_upgrade_defibrillator",
		"borg_upgrade_expandedsynthesiser",
		"borg_upgrade_piercinghypospray",
		"borg_upgrade_pinpointer",
		"borg_upgrade_surgicalprocessor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)

/datum/techweb_node/ai_basic
	id = "ai_basic"
	display_name = "Artificial Intelligence"
	description = "AI unit research."
	prereq_ids = list("adv_robotics")
	design_ids = list(
		"aicore",
		"borg_ai_control",
		"intellicard",
		"mecha_tracking_ai_control",
		"aifixer",
		"aiupload",
		"reset_module",
		"asimov_module",
		"default_module",
		"nutimov_module",
		"paladin_module",
		"robocop_module",
		"corporate_module",
		"drone_module",
		"oxygen_module",
		"safeguard_module",
		"protectstation_module",
		"quarantine_module",
		"freeform_module",
		"remove_module",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/ai_adv
	id = "ai_adv"
	display_name = "Advanced Artificial Intelligence"
	description = "State of the art lawsets to be used for AI research."
	prereq_ids = list("ai_basic")
	design_ids = list(
		"asimovpp_module",
		"paladin_devotion_module",
		"dungeon_master_module",
		"painter_module",
		"ten_commandments_module",
		"hippocratic_module",
		"maintain_module",
		"liveandletlive_module",
		"reporter_module",
		"hulkamania_module",
		"peacekeeper_module",
		"overlord_module",
		"tyrant_module",
		"antimov_module",
		"balance_module",
		"thermurderdynamic_module",
		"damaged_module",
		"freeformcore_module",
		"onehuman_module",
		"purge_module",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)

//Any kind of point adjustment needs to happen before SSresearch sets up the whole node tree, it gets cached
/datum/techweb_node/ai/New()
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI))
		research_costs[TECHWEB_POINT_TYPE_GENERIC] *= 3

/////////////////////////EMP tech/////////////////////////
/datum/techweb_node/emp_basic //EMP tech for some reason
	id = "emp_basic"
	display_name = "Electromagnetic Theory"
	description = "Study into usage of frequencies in the electromagnetic spectrum."
	prereq_ids = list("base")
	design_ids = list(
		"holosign",
		"holosignsec",
		"holosignengi",
		"holosignatmos",
		"holosignrestaurant",
		"holosignbar",
		"inducer",
		"tray_goggles",
		"holopad",
		"vendatray",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/emp_adv
	id = "emp_adv"
	display_name = "Advanced Electromagnetic Theory"
	description = "Determining whether reversing the polarity will actually help in a given situation."
	prereq_ids = list("emp_basic")
	design_ids = list(
		"ultra_micro_laser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_pinpoint_scan/tier2_microlaser = 1500)

/datum/techweb_node/emp_super
	id = "emp_super"
	display_name = "Quantum Electromagnetic Technology" //bs
	description = "Even better electromagnetic technology."
	prereq_ids = list("emp_adv")
	design_ids = list(
		"quadultra_micro_laser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 15000)
	discount_experiments = list(
		/datum/experiment/scanning/points/machinery_pinpoint_scan/tier3_microlaser = 4000,
		/datum/experiment/ordnance/gaseous/noblium = 10000,
	)

/////////////////////////Clown tech/////////////////////////
/datum/techweb_node/clown
	id = "clown"
	display_name = "Clown Technology"
	description = "Honk?!"
	prereq_ids = list("base")
	design_ids = list(
		"air_horn",
		"borg_transform_clown",
		"honk_chassis",
		"honk_head",
		"honk_left_arm",
		"honk_left_leg",
		"honk_right_arm",
		"honk_right_leg",
		"honk_torso",
		"honker_main",
		"honker_peri",
		"honker_targ",
		"implant_trombone",
		"mech_banana_mortar",
		"mech_honker",
		"mech_mousetrap_mortar",
		"mech_punching_face",
		"clown_firing_pin",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

////////////////////////Computer tech////////////////////////
/datum/techweb_node/comptech
	id = "comptech"
	display_name = "Computer Consoles"
	description = "Computers and how they work."
	prereq_ids = list("datatheory")
	design_ids = list(
		"cargo",
		"cargorequest",
		"comconsole",
		"bankmachine",
		"crewconsole",
		"idcard",
		"libraryconsole",
		"mining",
		"rdcamera",
		"seccamera",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)

/datum/techweb_node/data_disks
	id = "computer_data_disks"
	display_name = "Computer Data Disks"
	description = "Data disks used for storing modular computer stuff."
	prereq_ids = list("comptech")
	design_ids = list(
		"portadrive_advanced",
		"portadrive_basic",
		"portadrive_super",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/computer_board_gaming
	id = "computer_board_gaming"
	display_name = "Arcade Games"
	description = "For the slackers on the station."
	prereq_ids = list("comptech")
	design_ids = list(
		"arcade_battle",
		"arcade_orion",
		"slotmachine",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3250)
	discount_experiments = list(/datum/experiment/physical/arcade_winner = 3000)

/datum/techweb_node/comp_recordkeeping
	id = "comp_recordkeeping"
	display_name = "Computerized Recordkeeping"
	description = "Organized record databases and how they're used."
	prereq_ids = list("comptech")
	design_ids = list(
		"account_console",
		"automated_announcement",
		"med_data",
		"prisonmanage",
		"secdata",
		"vendor",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/telecomms
	id = "telecomms"
	display_name = "Telecommunications Technology"
	description = "Subspace transmission technology for near-instant communications devices."
	prereq_ids = list("comptech", "bluespace_basic")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	design_ids = list(
		"comm_monitor",
		"comm_server",
		"ntnet_relay",
		"s_amplifier",
		"s_analyzer",
		"s_ansible",
		"s_broadcaster",
		"s_bus",
		"s_crystal",
		"s_filter",
		"s_hub",
		"s_messaging",
		"s_processor",
		"s_receiver",
		"s_relay",
		"s_server",
		"s_transmitter",
		"s_treatment",
	)

/datum/techweb_node/integrated_hud
	id = "integrated_HUDs"
	display_name = "Integrated HUDs"
	description = "The usefulness of computerized records, projected straight onto your eyepiece!"
	prereq_ids = list("comp_recordkeeping", "emp_basic")
	design_ids = list(
		"diagnostic_hud",
		"health_hud",
		"scigoggles",
		"security_hud",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)

/datum/techweb_node/nvg_tech
	id = "NVGtech"
	display_name = "Night Vision Technology"
	description = "Allows seeing in the dark without actual light!"
	prereq_ids = list("integrated_HUDs", "adv_engi", "emp_adv")
	design_ids = list(
		"diagnostic_hud_night",
		"health_hud_night",
		"night_visision_goggles",
		"nvgmesons",
		"nv_scigoggles",
		"security_hud_night",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

////////////////////////Medical////////////////////////
/datum/techweb_node/genetics
	id = "genetics"
	display_name = "Genetic Engineering"
	description = "We have the technology to change him."
	prereq_ids = list("biotech")
	design_ids = list(
		"dna_disk",
		"dnainfuser",
		"dnascanner",
		"scan_console",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/cryotech
	id = "cryotech"
	display_name = "Cryostasis Technology"
	description = "Smart freezing of objects to preserve them!"
	prereq_ids = list("adv_engi", "biotech")
	design_ids = list(
		"cryo_grenade",
		"cryotube",
		"splitbeaker",
		"stasis",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)

/datum/techweb_node/subdermal_implants
	id = "subdermal_implants"
	display_name = "Subdermal Implants"
	description = "Electronic implants buried beneath the skin."
	prereq_ids = list("biotech")
	design_ids = list(
		"c38_trac",
		"implant_chem",
		"implant_tracking",
		"implantcase",
		"implanter",
		"locator",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/cyber_organs
	id = "cyber_organs"
	display_name = "Cybernetic Organs"
	description = "We have the technology to rebuild him."
	prereq_ids = list("biotech")
	design_ids = list(
		"cybernetic_ears_u",
		"cybernetic_eyes_improved",
		"cybernetic_heart_tier2",
		"cybernetic_liver_tier2",
		"cybernetic_lungs_tier2",
		"cybernetic_stomach_tier2",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/cyber_organs/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500)

/datum/techweb_node/cyber_organs_upgraded
	id = "cyber_organs_upgraded"
	display_name = "Upgraded Cybernetic Organs"
	description = "We have the technology to upgrade him."
	prereq_ids = list("adv_biotech", "cyber_organs")
	design_ids = list(
		"cybernetic_ears_whisper",
		"cybernetic_ears_xray",
		"ci-gloweyes",
		"ci-welding",
		"cybernetic_heart_tier3",
		"cybernetic_liver_tier3",
		"cybernetic_lungs_tier3",
		"cybernetic_stomach_tier3",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)

/datum/techweb_node/cyber_organs_upgraded/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/cyber_implants
	id = "cyber_implants"
	display_name = "Cybernetic Implants"
	description = "Electronic implants that improve humans."
	prereq_ids = list("adv_biotech", "datatheory")
	design_ids = list(
		"ci-breather",
		"ci-diaghud",
		"ci-medhud",
		"ci-nutriment",
		"ci-sechud",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/cyber_implants/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/adv_cyber_implants
	id = "adv_cyber_implants"
	display_name = "Advanced Cybernetic Implants"
	description = "Upgraded and more powerful cybernetic implants."
	prereq_ids = list("neural_programming", "cyber_implants","integrated_HUDs")
	design_ids = list(
		"ci-nutrimentplus",
		"ci-reviver",
		"ci-surgery",
		"ci-toolset",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_cyber_implants/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)

/datum/techweb_node/combat_cyber_implants
	id = "combat_cyber_implants"
	display_name = "Combat Cybernetic Implants"
	description = "Military grade combat implants to improve performance."
	prereq_ids = list("adv_cyber_implants","weaponry","NVGtech","high_efficiency")
	design_ids = list(
		"ci-antidrop",
		"ci-antistun",
		"ci-thermals",
		"ci-thrusters",
		"ci-xray",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/combat_cyber_implants/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)

////////////////////////Tools////////////////////////

/datum/techweb_node/basic_mining
	id = "basic_mining"
	display_name = "Mining Technology"
	description = "Better than Efficiency V."
	prereq_ids = list("engineering", "basic_plasma")
	design_ids = list(
		"borg_upgrade_cooldownmod",
		"borg_upgrade_damagemod",
		"borg_upgrade_rangemod",
		"cargoexpress",
		"cooldownmod",
		"damagemod",
		"drill",
		"mecha_kineticgun",
		"mining_equipment_vendor",
		"ore_redemption",
		"plasmacutter",
		"rangemod",
		"superresonator",
		"triggermod",
		"mining_scanner",
	)//e a r l y    g a  m e)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_mining
	id = "adv_mining"
	display_name = "Advanced Mining Technology"
	description = "Efficiency Level 127" //dumb mc references
	prereq_ids = list("basic_mining", "adv_power", "adv_plasma")
	design_ids = list(
		"drill_diamond",
		"hypermod",
		"jackhammer",
		"plasmacutter_adv",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
	discount_experiments = list(/datum/experiment/scanning/random/material/hard/one = 5000)

/datum/techweb_node/janitor
	id = "janitor"
	display_name = "Advanced Sanitation Technology"
	description = "Clean things better, faster, stronger, and harder!"
	prereq_ids = list("adv_engi")
	design_ids = list(
		"advmop",
		"beartrap",
		"blutrash",
		"buffer",
		"vacuum",
		"holobarrier_jani",
		"light_replacer_blue",
		"paint_remover",
		"spraybottle",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4000)
	discount_experiments = list(/datum/experiment/scanning/random/janitor_trash = 3000) //75% discount for scanning some trash, seems fair right?

/datum/techweb_node/botany
	id = "botany"
	display_name = "Botanical Engineering"
	description = "Botanical tools"
	prereq_ids = list("biotech")
	design_ids = list(
		"biogenerator",
		"flora_gun",
		"gene_shears",
		"hydro_tray",
		"portaseeder",
		"seed_extractor",
		"adv_watering_can",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4000)
	required_experiments = list(/datum/experiment/scanning/random/plants/wild)
	discount_experiments = list(/datum/experiment/scanning/random/plants/traits = 3000)

/datum/techweb_node/exp_tools
	id = "exp_tools"
	display_name = "Experimental Tools"
	description = "Highly advanced tools."
	prereq_ids = list("adv_engi")
	design_ids = list(
		"exwelder",
		"handdrill",
		"jawsoflife",
		"laserscalpel",
		"mechanicalpinches",
		"rangedanalyzer",
		"searingtool",
		"adv_fire_extinguisher",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
	discount_experiments = list(/datum/experiment/scanning/random/material/hard/one = 5000)

/datum/techweb_node/sec_basic
	id = "sec_basic"
	display_name = "Basic Security Equipment"
	description = "Standard equipment used by security."
	prereq_ids = list("base")
	design_ids = list(
		"bola_energy",
		"evidencebag",
		"pepperspray",
		"seclite",
		"zipties",
		"inspector",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

/datum/techweb_node/rcd_upgrade
	id = "rcd_upgrade"
	display_name = "Rapid Device Upgrade Designs"
	description = "Unlocks new designs that improve rapid devices."
	prereq_ids = list("adv_engi")
	design_ids = list(
		"rcd_upgrade_frames",
		"rcd_upgrade_furnishing",
		"rcd_upgrade_simple_circuits",
		"rpd_upgrade_unwrench",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_rcd_upgrade
	id = "adv_rcd_upgrade"
	display_name = "Advanced RCD Designs Upgrade"
	description = "Unlocks new RCD designs."
	design_ids = list(
		"rcd_upgrade_silo_link",
	)
	prereq_ids = list(
		"bluespace_travel",
		"rcd_upgrade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	discount_experiments = list(/datum/experiment/scanning/random/material/hard/two = 5000)

/////////////////////////weaponry tech/////////////////////////
/datum/techweb_node/weaponry
	id = "weaponry"
	display_name = "Weapon Development Technology"
	description = "Our researchers have found new ways to weaponize just about everything now."
	prereq_ids = list("engineering")
	design_ids = list(
		"pin_testing",
		"tele_shield",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 20000)
	discount_experiments = list(/datum/experiment/ordnance/explosive/pressurebomb = 10000)

/datum/techweb_node/adv_weaponry
	id = "adv_weaponry"
	display_name = "Advanced Weapon Development Technology"
	description = "Our weapons are breaking the rules of reality by now."
	prereq_ids = list("adv_engi", "weaponry")
	design_ids = list(
		"pin_loyalty",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)

/datum/techweb_node/electric_weapons
	id = "electronic_weapons"
	display_name = "Electric Weapons"
	description = "Weapons using electric technology"
	prereq_ids = list("weaponry", "adv_power"  , "emp_basic")
	design_ids = list(
		"ioncarbine",
		"stunrevolver",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/radioactive_weapons
	id = "radioactive_weapons"
	display_name = "Radioactive Weaponry"
	description = "Weapons using radioactive technology."
	prereq_ids = list("adv_engi", "adv_weaponry")
	design_ids = list(
		"nuclear_gun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/beam_weapons
	id = "beam_weapons"
	display_name = "Beam Weaponry"
	description = "Various basic beam weapons"
	prereq_ids = list("adv_weaponry")
	design_ids = list(
		"temp_gun",
		"xray_laser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/adv_beam_weapons
	id = "adv_beam_weapons"
	display_name = "Advanced Beam Weaponry"
	description = "Various advanced beam weapons"
	prereq_ids = list("beam_weapons")
	design_ids = list(
		"beamrifle",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/explosive_weapons
	id = "explosive_weapons"
	display_name = "Explosive & Pyrotechnical Weaponry"
	description = "If the light stuff just won't do it."
	prereq_ids = list("adv_weaponry")
	design_ids = list(
		"adv_grenade",
		"large_grenade",
		"pyro_grenade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/exotic_ammo
	id = "exotic_ammo"
	display_name = "Exotic Ammunition"
	description = "They won't know what hit em."
	prereq_ids = list("weaponry")
	design_ids = list(
		"c38_hotshot",
		"c38_iceblox",
		"techshotshell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/gravity_gun
	id = "gravity_gun"
	display_name = "One-point Bluespace-gravitational Manipulator"
	description = "Fancy wording for gravity gun."
	prereq_ids = list("adv_weaponry", "bluespace_travel")
	design_ids = list(
		"gravitygun",
		"mech_gravcatapult",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

//MODsuit tech

/datum/techweb_node/mod_advanced
	id = "mod_advanced"
	display_name = "Advanced Modular Suits"
	description = "More advanced modules, to improve modular suits."
	prereq_ids = list("robotics")
	design_ids = list(
		"mod_visor_diaghud",
		"mod_gps",
		"mod_reagent_scanner",
		"mod_clamp",
		"mod_drill",
		"mod_orebag",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mod_engineering
	id = "mod_engineering"
	display_name = "Engineering Modular Suits"
	description = "Engineering suits, for powered engineers."
	prereq_ids = list("mod_advanced", "engineering")
	design_ids = list(
		"mod_plating_engineering",
		"mod_visor_meson",
		"mod_t_ray",
		"mod_magboot",
		"mod_tether",
		"mod_constructor",
		"mod_mister_atmos",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mod_advanced_engineering
	id = "mod_advanced_engineering"
	display_name = "Advanced Engineering Modular Suits"
	description = "Advanced Engineering suits, for advanced powered engineers."
	prereq_ids = list("mod_engineering", "adv_engi")
	design_ids = list(
		"mod_plating_atmospheric",
		"mod_jetpack",
		"mod_rad_protection",
		"mod_emp_shield",
		"mod_storage_expanded",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3500)

/datum/techweb_node/mod_advanced_engineering/New()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_RADIOACTIVE_NEBULA)) //we'll really need the rad protection modsuit module
		starting_node = TRUE

	return ..()

/datum/techweb_node/mod_medical
	id = "mod_medical"
	display_name = "Medical Modular Suits"
	description = "Medical suits for quick rescue purposes."
	prereq_ids = list("mod_advanced", "biotech")
	design_ids = list(
		"mod_plating_medical",
		"mod_visor_medhud",
		"mod_health_analyzer",
		"mod_quick_carry",
		"mod_injector",
		"mod_organ_thrower",
		"mod_dna_lock",
		"mod_patienttransport",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mod_advanced_medical
	id = "mod_advanced_medical"
	display_name = "Advanced Medical Modular Suits"
	description = "Advanced medical suits for quicker rescue purposes."
	prereq_ids = list("mod_medical", "adv_biotech")
	design_ids = list(
		"mod_defib",
		"mod_threadripper",
		"mod_surgicalprocessor",
		"mod_statusreadout",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3500)

/datum/techweb_node/mod_security
	id = "mod_security"
	display_name = "Security Modular Suits"
	description = "Security suits for space crime handling."
	prereq_ids = list("mod_advanced", "sec_basic")
	design_ids = list(
		"mod_plating_security",
		"mod_visor_sechud",
		"mod_stealth",
		"mod_mag_harness",
		"mod_pathfinder",
		"mod_holster",
		"mod_sonar",
		"mod_projectile_dampener",
		"mod_criminalcapture",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mod_entertainment
	id = "mod_entertainment"
	display_name = "Entertainment Modular Suits"
	description = "Powered suits for protection against low-humor environments."
	prereq_ids = list("mod_advanced", "clown")
	design_ids = list(
		"mod_plating_cosmohonk",
		"mod_bikehorn",
		"mod_microwave_beam",
		"mod_waddle",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mod_anomaly
	id = "mod_anomaly"
	display_name = "Anomalock Modular Suits"
	description = "Modules for modular suits that require anomaly cores to function."
	prereq_ids = list("mod_advanced", "anomaly_research")
	design_ids = list(
		"mod_antigrav",
		"mod_teleporter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mod_anomaly_engi
	id = "mod_anomaly_engi"
	display_name = "Engineering Anomalock Modular Suits"
	description = "Advanced modules for modular suits, using anomaly cores to become even better engineers."
	prereq_ids = list("mod_advanced_engineering", "mod_anomaly")
	design_ids = list(
		"mod_kinesis",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)

////////////////////////mech technology////////////////////////
/datum/techweb_node/adv_mecha
	id = "adv_mecha"
	display_name = "Advanced Exosuits"
	description = "For when you just aren't Gundam enough."
	prereq_ids = list("adv_robotics")
	design_ids = list(
		"mech_repair_droid",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
	discount_experiments = list(/datum/experiment/scanning/random/material/medium/three = 5000)

/datum/techweb_node/odysseus
	id = "mecha_odysseus"
	display_name = "EXOSUIT: Odysseus"
	description = "Odysseus exosuit designs"
	prereq_ids = list("base")
	design_ids = list(
		"odysseus_chassis",
		"odysseus_head",
		"odysseus_left_arm",
		"odysseus_left_leg",
		"odysseus_main",
		"odysseus_peri",
		"odysseus_right_arm",
		"odysseus_right_leg",
		"odysseus_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/clarke
	id = "mecha_clarke"
	display_name = "EXOSUIT: Clarke"
	description = "Clarke exosuit designs"
	prereq_ids = list("engineering")
	design_ids = list(
		"clarke_chassis",
		"clarke_head",
		"clarke_left_arm",
		"clarke_main",
		"clarke_peri",
		"clarke_right_arm",
		"clarke_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/gygax
	id = "mech_gygax"
	display_name = "EXOSUIT: Gygax"
	description = "Gygax exosuit designs"
	prereq_ids = list("adv_mecha", "adv_mecha_armor")
	design_ids = list(
		"gygax_armor",
		"gygax_chassis",
		"gygax_head",
		"gygax_left_arm",
		"gygax_left_leg",
		"gygax_main",
		"gygax_peri",
		"gygax_right_arm",
		"gygax_right_leg",
		"gygax_targ",
		"gygax_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier3_mechbay = 5000)

/datum/techweb_node/durand
	id = "mech_durand"
	display_name = "EXOSUIT: Durand"
	description = "Durand exosuit designs"
	prereq_ids = list("adv_mecha", "adv_mecha_armor")
	design_ids = list(
		"durand_armor",
		"durand_chassis",
		"durand_head",
		"durand_left_arm",
		"durand_left_leg",
		"durand_main",
		"durand_peri",
		"durand_right_arm",
		"durand_right_leg",
		"durand_targ",
		"durand_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier3_mechbay = 3500)

/datum/techweb_node/phazon
	id = "mecha_phazon"
	display_name = "EXOSUIT: Phazon"
	description = "Phazon exosuit designs"
	prereq_ids = list("adv_mecha", "adv_mecha_armor" , "micro_bluespace")
	design_ids = list(
		"phazon_armor",
		"phazon_chassis",
		"phazon_head",
		"phazon_left_arm",
		"phazon_left_leg",
		"phazon_main",
		"phazon_peri",
		"phazon_right_arm",
		"phazon_right_leg",
		"phazon_targ",
		"phazon_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier3_mechbay = 2500)

/datum/techweb_node/savannah_ivanov
	id = "mecha_savannah_ivanov"
	display_name = "EXOSUIT: Savannah-Ivanov"
	description = "Savannah-Ivanov exosuit designs"
	prereq_ids = list("adv_mecha", "weaponry", "exp_tools")
	design_ids = list(
		"savannah_ivanov_armor",
		"savannah_ivanov_chassis",
		"savannah_ivanov_head",
		"savannah_ivanov_left_arm",
		"savannah_ivanov_left_leg",
		"savannah_ivanov_main",
		"savannah_ivanov_peri",
		"savannah_ivanov_right_arm",
		"savannah_ivanov_right_leg",
		"savannah_ivanov_targ",
		"savannah_ivanov_torso",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier3_mechbay = 3000)

/datum/techweb_node/adv_mecha_tools
	id = "adv_mecha_tools"
	display_name = "Advanced Exosuit Equipment"
	description = "Tools for high level mech suits"
	prereq_ids = list("adv_mecha")
	design_ids = list(
		"mech_rcd",
		"mech_thrusters",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/med_mech_tools
	id = "med_mech_tools"
	display_name = "Medical Exosuit Equipment"
	description = "Tools for high level mech suits"
	prereq_ids = list("adv_biotech")
	design_ids = list(
		"mech_medi_beam",
		"mech_sleeper",
		"mech_syringe_gun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_armor
	id = "adv_mecha_armor"
	display_name = "Exosuit Heavy Armor Research"
	description = "Recreating heavy armor with new rapid fabrication techniques."
	prereq_ids = list("adv_mecha", "bluespace_power")
	design_ids = list(
		"mech_ccw_armor",
		"mech_proj_armor",
	)
	required_experiments = list(/datum/experiment/scanning/random/mecha_damage_scan)
	discount_experiments = list(/datum/experiment/scanning/random/mecha_destroyed_scan = 5000)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)

/datum/techweb_node/mech_scattershot
	id = "mecha_tools"
	display_name = "Exosuit Weapon (LBX AC 10 \"Scattershot\")"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("adv_mecha")
	design_ids = list(
		"mech_scattershot",
		"mech_scattershot_ammo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_carbine
	id = "mech_carbine"
	display_name = "Exosuit Weapon (FNX-99 \"Hades\" Carbine)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("exotic_ammo")
	design_ids = list(
		"mech_carbine",
		"mech_carbine_ammo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_ion
	id = "mmech_ion"
	display_name = "Exosuit Weapon (MKIV Ion Heavy Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("electronic_weapons", "emp_adv")
	design_ids = list(
		"mech_ion",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_tesla
	id = "mech_tesla"
	display_name = "Exosuit Weapon (MKI Tesla Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("electronic_weapons", "adv_power")
	design_ids = list(
		"mech_tesla",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_laser
	id = "mech_laser"
	display_name = "Exosuit Weapon (CH-PS \"Immolator\" Laser)"
	description = "A basic piece of mech weaponry"
	prereq_ids = list("beam_weapons")
	design_ids = list(
		"mech_laser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_laser_heavy
	id = "mech_laser_heavy"
	display_name = "Exosuit Weapon (CH-LC \"Solaris\" Laser Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("adv_beam_weapons")
	design_ids = list(
		"mech_laser_heavy",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_disabler
	id = "mech_disabler"
	display_name = "Exosuit Weapon (CH-DS \"Peacemaker\" Mounted Disabler)"
	description = "A basic piece of mech weaponry"
	prereq_ids = list("adv_mecha")
	design_ids = list(
		"mech_disabler",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_grenade_launcher
	id = "mech_grenade_launcher"
	display_name = "Exosuit Weapon (SGL-6 Grenade Launcher)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("explosive_weapons")
	design_ids = list(
		"mech_grenade_launcher",
		"mech_grenade_launcher_ammo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_missile_rack
	id = "mech_missile_rack"
	display_name = "Exosuit Weapon (BRM-6 Missile Rack)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("explosive_weapons")
	design_ids = list(
		"mech_missile_rack",
		"mech_missile_rack_ammo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/clusterbang_launcher
	id = "clusterbang_launcher"
	display_name = "Exosuit Module (SOB-3 Clusterbang Launcher)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("explosive_weapons")
	design_ids = list(
		"clusterbang_launcher",
		"clusterbang_launcher_ammo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_teleporter
	id = "mech_teleporter"
	display_name = "Exosuit Module (Teleporter Module)"
	description = "An advanced piece of mech Equipment"
	prereq_ids = list("micro_bluespace")
	design_ids = list(
		"mech_teleporter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_wormhole_gen
	id = "mech_wormhole_gen"
	display_name = "Exosuit Module (Localized Wormhole Generator)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("bluespace_travel")
	design_ids = list(
		"mech_wormhole_gen",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_lmg
	id = "mech_lmg"
	display_name = "Exosuit Weapon (\"Ultra AC 2\" LMG)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("adv_mecha")
	design_ids = list(
		"mech_lmg",
		"mech_lmg_ammo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/datum/techweb_node/mech_diamond_drill
	id = "mech_diamond_drill"
	display_name = "Exosuit Diamond Drill"
	description = "A diamond drill fit for a large exosuit"
	prereq_ids = list("adv_mining")
	design_ids = list(
		"mech_diamond_drill",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

////////////////////////Alien technology////////////////////////
/datum/techweb_node/alientech //AYYYYYYYYLMAOO tech
	id = "alientech"
	display_name = "Alien Technology"
	description = "Things used by the greys."
	prereq_ids = list("biotech","engineering")
	boost_item_paths = list(
		/obj/item/abductor,
		/obj/item/cautery/alien,
		/obj/item/circuitboard/machine/abductor,
		/obj/item/circular_saw/alien,
		/obj/item/crowbar/abductor,
		/obj/item/gun/energy/alien,
		/obj/item/gun/energy/shrink_ray,
		/obj/item/hemostat/alien,
		/obj/item/melee/baton/abductor,
		/obj/item/multitool/abductor,
		/obj/item/retractor/alien,
		/obj/item/scalpel/alien,
		/obj/item/screwdriver/abductor,
		/obj/item/surgicaldrill/alien,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)
	design_ids = list(
		"alienalloy",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	hidden = TRUE

/datum/techweb_node/alientech/on_research() //Unlocks the Zeta shuttle for purchase
		SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_ALIENTECH] = TRUE

/datum/techweb_node/alien_bio
	id = "alien_bio"
	display_name = "Alien Biological Tools"
	description = "Advanced biological tools."
	prereq_ids = list("alientech", "adv_biotech")
	design_ids = list(
		"alien_cautery",
		"alien_drill",
		"alien_hemostat",
		"alien_retractor",
		"alien_saw",
		"alien_scalpel",
	)

	boost_item_paths = list(
		/obj/item/abductor,
		/obj/item/cautery/alien,
		/obj/item/circuitboard/machine/abductor,
		/obj/item/circular_saw/alien,
		/obj/item/crowbar/abductor,
		/obj/item/gun/energy/alien,
		/obj/item/gun/energy/shrink_ray,
		/obj/item/hemostat/alien,
		/obj/item/melee/baton/abductor,
		/obj/item/multitool/abductor,
		/obj/item/retractor/alien,
		/obj/item/scalpel/alien,
		/obj/item/screwdriver/abductor,
		/obj/item/surgicaldrill/alien,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 12500)
	discount_experiments = list(/datum/experiment/scanning/points/slime/hard = 10000)
	hidden = TRUE

/datum/techweb_node/alien_engi
	id = "alien_engi"
	display_name = "Alien Engineering"
	description = "Alien engineering tools"
	prereq_ids = list("alientech", "adv_engi")

	design_ids = list(
		"alien_crowbar",
		"alien_multitool",
		"alien_screwdriver",
		"alien_welder",
		"alien_wirecutters",
		"alien_wrench",
	)

	boost_item_paths = list(
		/obj/item/abductor,
		/obj/item/circuitboard/machine/abductor,
		/obj/item/crowbar/abductor,
		/obj/item/gun/energy/shrink_ray,
		/obj/item/melee/baton/abductor,
		/obj/item/multitool/abductor,
		/obj/item/screwdriver/abductor,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
	)

	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE

/datum/techweb_node/syndicate_basic
	id = "syndicate_basic"
	display_name = "Illegal Technology"
	description = "Dangerous research used to create dangerous objects."
	prereq_ids = list("adv_engi", "adv_weaponry", "explosive_weapons")
	design_ids = list(
		"advanced_camera",
		"ai_cam_upgrade",
		"borg_syndicate_module",
		"decloner",
		"donksoft_refill",
		"donksofttoyvendor",
		"largecrossbow",
		"mag_autorifle",
		"mag_autorifle_ap",
		"mag_autorifle_ic",
		"rapidsyringe",
		"suppressor",
		"super_pointy_tape",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	hidden = TRUE

/datum/techweb_node/syndicate_basic/New() //Crappy way of making syndicate gear decon supported until there's another way.
	. = ..()
	if(!SSearly_assets.initialized)
		RegisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(register_uplink_items))
	else
		register_uplink_items()

/**
 * This needs some clarification: The uplink_items_by_type list is populated on datum/asset/json/uplink/generate.
 * SStraitor doesn't actually initialize. I'm bamboozled.
 */
/datum/techweb_node/syndicate_basic/proc/register_uplink_items()
	SIGNAL_HANDLER
	UnregisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	boost_item_paths = list()
	for(var/datum/uplink_item/item_path as anything in SStraitor.uplink_items_by_type)
		var/datum/uplink_item/item = SStraitor.uplink_items_by_type[item_path]
		if(!item.item || !item.illegal_tech)
			continue
		boost_item_paths |= item.item //allows deconning to unlock.


////////////////////////B.E.P.I.S. Locked Techs////////////////////////
/datum/techweb_node/light_apps
	id = "light_apps"
	display_name = "Illumination Applications"
	description = "Applications of lighting and vision technology not originally thought to be commercially viable."
	prereq_ids = list("base")
	design_ids = list(
		"bright_helmet",
		"rld_mini",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/extreme_office
	id = "extreme_office"
	display_name = "Advanced Office Applications"
	description = "Some of our smartest lab guys got together on a Friday and improved our office efficiency by 350%. Here's how."
	prereq_ids = list("base")
	design_ids = list(
		"mauna_mug",
		"rolling_table",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/spec_eng
	id = "spec_eng"
	display_name = "Specialized Engineering"
	description = "Conventional wisdom has deemed these engineering products 'technically' safe, but far too dangerous to traditionally condone."
	prereq_ids = list("base")
	design_ids = list(
		"eng_gloves",
		"lava_rods",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/aus_security
	id = "aus_security"
	display_name = "Australicus Security Protocols"
	description = "It is said that security in the Australicus sector is tight, so we took some pointers from their equipment. Thankfully, our sector lacks any signs of these, 'dropbears'."
	prereq_ids = list("base")
	design_ids = list(
		"pin_explorer",
		"stun_boomerang",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/interrogation
	id = "interrogation"
	display_name = "Enhanced Interrogation Technology"
	description = "By cross-referencing several declassified documents from past dictatorial regimes, we were able to develop an incredibly effective interrogation device. \
	Ethical concerns about loss of free will do not apply to criminals, according to galactic law."
	prereq_ids = list("base")
	design_ids = list(
		"hypnochair",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3500)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/sticky_advanced
	id = "sticky_advanced"
	display_name = "Advanced Sticky Technology"
	description = "Taking a good joke too far? Nonsense!"
	design_ids = list(
		"pointy_tape",
		"super_sticky_tape",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/tackle_advanced
	id = "tackle_advanced"
	display_name = "Advanced Grapple Technology"
	description = "Nanotrasen would like to remind its researching staff that it is never acceptable to \"glomp\" your coworkers, and further \"scientific trials\" on the subject \
	will no longer be accepted in its academic journals."
	design_ids = list(
		"tackle_dolphin",
		"tackle_rocket",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/mod_experimental
	id = "mod_experimental"
	display_name = "Experimental Modular Suits"
	description = "Applications of experimentality when creating MODsuits have created these..."
	prereq_ids = list("base")
	design_ids = list(
		"mod_disposal",
		"mod_joint_torsion",
		"mod_recycler",
		"mod_shooting",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/fishing
	id = "fishing"
	display_name = "Fishing Technology"
	description = "Cutting edge fishing advancements."
	prereq_ids = list("base")
	design_ids = list(
		"fishing_rod_tech",
		"stabilized_hook",
		"fish_analyzer",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	hidden = TRUE
	experimental = TRUE
