
//Current rate: 135000 research points in 90 minutes

#define TIER_1_POINTS 2000
#define TIER_2_POINTS 4000
#define TIER_3_POINTS 6000
#define TIER_4_POINTS 8000
#define TIER_5_POINTS 10000

// Service trees
/datum/techweb_node/office_equip
	id = "office_equip"
	starting_node = TRUE
	display_name = "Office Equipment"
	description = "Nanotrasen's finest in ergonomic office tech, ensuring station admin stays productive and compliant with corporate policies — because even in space, paperwork never stops."
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
	)

/datum/techweb_node/sanitation
	id = "sanitation"
	display_name = "Advanced Sanitation Technology"
	description = "Nanotrasen's latest in janitorial tech, making sure the station stays spotless and bear-free."
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
	discount_experiments = list(/datum/experiment/scanning/random/janitor_trash = TIER_2_POINTS)

/datum/techweb_node/toys
	id = "toys"
	display_name = "New Toys"
	description = "For new pranks."
	prereq_ids = list("office_equip")
	design_ids = list(
		"smoke_machine",
		"toy_armblade",
		"air_horn",
		"clown_firing_pin",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/consoles
	id = "consoles"
	display_name = "Civilian Consoles"
	description = "User-friendly consoles for non-technical crew members, enhancing communication and access to essential station information."
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
		"c-reader",
		"libraryconsole",
		"barcode_scanner",
		"vendor",
		"custom_vendor_refill",
		"bounty_pad_control",
		"bounty_pad",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/gaming
	id = "gaming"
	display_name = "Gaming"
	description = "For the slackers on the station."
	prereq_ids = list("toys", "consoles")
	design_ids = list(
		"arcade_battle",
		"arcade_orion",
		"slotmachine",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/physical/arcade_winner = TIER_2_POINTS)

/datum/techweb_node/bitrunning
	id = "bitrunning"
	display_name = "Bitrunning Technology"
	description = "Bluespace technology has led to the development of quantum-scale computing, which unlocks the means to materialize atomic structures while executing advanced programs."
	prereq_ids = list("gaming", "bluespace_travel")
	design_ids = list(
		"byteforge",
		"quantum_console",
		"netpod",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)

// Kitchen tree
/datum/techweb_node/cafeteria_equip
	id = "cafeteria_equip"
	starting_node = TRUE
	display_name = "Cafeteria Equipment"
	description = "When standard-issue tubed food no longer satisfies the station crew's appetite..."
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
	description = "Top-tier kitchen appliances from Nanotrasen, designed to keep the crew well-fed and happy."
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

// Fishing tree
/datum/techweb_node/fishing_equip
	id = "fishing_equip"
	starting_node = TRUE
	display_name = "Fishing Equipment"
	description = "Basic fishing gear tailored for space station environments, perfect for extraterrestrial aquatic pursuits."
	design_ids = list(
		"fishing_portal_generator",
		"fishing_rod",
		"fish_case",
	)

/datum/techweb_node/fishing_equip_adv
	id = "fishing_equip_adv"
	display_name = "Advanced Fishing Tools"
	description = "Continuing advancements in fishing technology, incorporating cutting-edge features in space fishing operations. Just don't try this on space carps..."
	prereq_ids = list("fishing_equip")
	design_ids = list(
		"fishing_rod_tech",
		"stabilized_hook",
		"auto_reel",
		"fish_analyzer",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)
	required_experiments = list(/datum/experiment/scanning/fish)

/datum/techweb_node/marine_util
	id = "marine_util"
	display_name = "Marine Utility"
	description = "Fish are nice to look at and all, but they can be put to use."
	prereq_ids = list("fishing_equip_adv")
	design_ids = list(
		"bioelec_gen",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)
	// only available if you've done the first fishing experiment (thus unlocking fishing tech), but not a strict requirement to get the tech
	discount_experiments = list(/datum/experiment/scanning/fish/second = TIER_3_POINTS)

// Botany tree
/datum/techweb_node/botany_equip
	id = "botany_equip"
	starting_node = TRUE
	display_name = "Botany Equipment"
	description = "Essential tools for maintaining onboard gardens, supporting plant growth in the unique environment of the space station."
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
	description = "Research into advanced hydroponic systems for efficient and sustainable plant cultivation."
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
	description = "Advancement in plant cultivation techniques through artificial selection, enabling precise manipulation of plant DNA."
	prereq_ids = list("hydroponics")
	design_ids = list(
		"flora_gun",
		"gene_shears",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)
	required_experiments = list(/datum/experiment/scanning/random/plants/wild)
	discount_experiments = list(/datum/experiment/scanning/random/plants/traits = TIER_3_POINTS)

// Medbay trees
/datum/techweb_node/medbay_equip
	id = "medbay_equip"
	starting_node = TRUE
	display_name = "Medbay Equipment"
	description = "Essential medical tools to patch you up while medbay is still intact."
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
	description = "Advanced technology for analyzing patient health and reagent compositions, ensuring precise diagnostics and treatment in the medical bay."
	prereq_ids = list("medbay_equip")
	design_ids = list(
		"healthanalyzer",
		"autopsyscanner",
		"medical_kiosk",
		"chem_master",
		"ph_meter",
		"scigoggles",
		"mod_reagent_scanner",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/cytology
	id = "cytology"
	display_name = "Cytology"
	description = "Cellular biology research focused on cultivation of limbs and diverse organisms from cells."
	prereq_ids = list("bio_scan")
	design_ids = list(
		"limbgrower",
		"pandemic",
		"petri_dish",
		"swab",
		"biopsy_tool",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/xenobiology
	id = "xenobiology"
	display_name = "Xenobiology"
	description = "Exploration of non-human biology, unlocking the secrets of extraterrestrial lifeforms and their unique biological processes."
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
	description = "Research into sophisticated DNA manipulation techniques, enabling the modification of human genetic traits to unlock specific abilities and enhancements."
	prereq_ids = list("selection", "xenobiology")
	design_ids = list(
		"dnascanner",
		"scan_console",
		"dna_disk",
		"dnainfuser",
		"genescanner",
		"mod_dna_lock",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)
	discount_experiments = list(
		/datum/experiment/scanning/random/plants/traits = TIER_2_POINTS,
		/datum/experiment/scanning/points/slime/hard = TIER_2_POINTS,
		)

// Chemistry tree
/datum/techweb_node/chem_synthesis
	id = "chem_synthesis"
	display_name = "Chemical Synthesis"
	description = "Synthesizing complex chemicals from electricity and thin air... Don't ask how..."
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
	description = "Essential infrastructure for building chemical factories. To scale up the production of happy pills to an industrial level."
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
	description = "The result of clown accidentally drinking a chemical, now repurposed for safely preserving crew members in suspended animation."
	prereq_ids = list("plumbing", "plasma_control")
	design_ids = list(
		"cryotube",
		"mech_sleeper",
		"stasis",
		"cryo_grenade",
		"splitbeaker",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)
	required_experiments = list(/datum/experiment/scanning/reagent/cryoxadone)

/datum/techweb_node/medbay_equip_adv
	id = "medbay_equip_adv"
	display_name = "Advanced Medbay Equipment"
	description = "State-of-the-art medical gear for keeping the crew in one piece — mostly."
	prereq_ids = list("cryostasis")
	design_ids = list(
		"chem_mass_spec",
		"healthanalyzer_advanced",
		"mod_health_analyzer",
		"crewpinpointer",
		"defibrillator_compact",
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
	description = "Who would have known being more gentle with a hemostat decreases patient pain?"
	prereq_ids = list("medbay_equip")
	design_ids = list(
		"surgery_heal_brute_upgrade",
		"surgery_heal_burn_upgrade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/surgery_adv
	id = "surgery_adv"
	display_name = "Advanced Surgery"
	description = "When simple medicine doesn't cut it."
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
	description = "When evolution isn't fast enough."
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
	description = "Surgical instruments of dual purpose for quick operations."
	prereq_ids = list("surgery_exp")
	design_ids = list(
		"laserscalpel",
		"searingtool",
		"mechanicalpinches",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/autopsy/xenomorph = TIER_4_POINTS)

// Sec tree
/datum/techweb_node/basic_arms
	id = "basic_arms"
	starting_node = TRUE
	display_name = "Basic Arms"
	description = "Ballistics can be unpredictable in space."
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
	description = "All the essentials to subdue a mime."
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
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/riot_supression
	id = "riot_supression"
	display_name = "Riot Supression"
	description = "When you are on the opposing side of a revolutionary movement."
	prereq_ids = list("sec_equip")
	design_ids = list(
		"pin_testing",
		"pin_loyalty",
		"tele_shield",
		"ballistic_shield",
		"bola_energy",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/ammo
	id = "ammo"
	display_name = "Exotic Ammunition"
	description = "Specialized bullets designed to ignite, freeze, and inflict various other effects on targets, expanding combat capabilities."
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
	description = "Advanced energy-based weaponry designed for both lethal and non-lethal applications."
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
	description = "For once, intentional explosions."
	prereq_ids = list("ammo")
	design_ids = list(
		"large_grenade",
		"adv_grenade",
		"pyro_grenade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)
	required_experiments = list(/datum/experiment/ordnance/explosive/lowyieldbomb)
	discount_experiments = list(/datum/experiment/ordnance/explosive/highyieldbomb = TIER_4_POINTS)

/datum/techweb_node/beam_weapons
	id = "beam_weapons"
	display_name = "Advanced Beam Weaponry"
	description = "So advanced, even engineers are baffled by its operational principles."
	prereq_ids = list("electric_weapons")
	design_ids = list(
		"beamrifle",
		"nuclear_gun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

// Sci trees
/datum/techweb_node/robotics
	id = "robotics"
	starting_node = TRUE
	display_name = "Robotics"
	description = "Programmable machines that make our lives lazier."
	design_ids = list(
		"mechfab",
		"botnavbeacon",
		"paicard",
	)

/datum/techweb_node/exodrone
	id = "exodrone"
	display_name = "Exploration Drones"
	description = "Adapted arcade machines to covertly harness gamers' skills in controlling real drones for practical purposes."
	prereq_ids = list("robotics")
	design_ids = list(
		"exoscanner_console",
		"exoscanner",
		"exodrone_console",
		"exodrone_launcher",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

// AI tree
/datum/techweb_node/ai
	id = "ai"
	display_name = "Artificial Intelligence"
	description = "Exploration of AI systems, more intelligent than the entire crew put together."
	prereq_ids = list("robotics")
	design_ids = list(
		"aiupload",
		"aifixer",
		"intellicard",
		"mecha_tracking_ai_control",
		"borg_ai_control",
		"aicore",
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/ai/New()
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_HUMAN_AI))
		design_ids -= list(
			"aicore",
			"borg_ai_control",
			"intellicard",
			"mecha_tracking_ai_control",
			"aifixer",
			"aiupload",
		)
	else if(HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI))
		research_costs[TECHWEB_POINT_TYPE_GENERIC] *= 3

/datum/techweb_node/ai_laws
	id = "ai_laws"
	display_name = "Advanced AI Laws"
	description = "Delving into sophisticated AI directives, with hopes that they won't lead to humanity's extinction."
	prereq_ids = list("ai")
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
		"yesman_module",
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)

// Mech tree
/datum/techweb_node/mech_assembly
	id = "mech_assembly"
	starting_node = TRUE
	display_name = "Mech Assembly"
	description = "Development of mech designed to contend with artificial gravity while transporting cargo."
	design_ids = list(
		"mechapower",
		"mech_recharger",
		"ripley_chassis",
		"ripley_torso",
		"ripley_left_arm",
		"ripley_right_arm",
		"ripley_left_leg",
		"ripley_right_leg",
		"ripley_main",
		"ripley_peri",
		"mech_hydraulic_clamp",
	)

/datum/techweb_node/mech_equipment
	id = "mech_equipment"
	display_name = "Hostile Environment Equipment"
	description = "Specialized mech gear tailored for navigating space and celestial bodies, ensuring durability and functionality in the harshest conditions."
	prereq_ids = list("mech_assembly")
	design_ids = list(
		"mechacontrol",
		"botpad",
		"botpad_remote",
		"ripleyupgrade",
		"mech_air_tank",
		"mech_thrusters",
		"mech_extinguisher",
		"mecha_camera",
		"mecha_tracking",
		"mech_radio",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/mech_clown
	id = "mech_clown"
	display_name = "Funny Robots"
	description = "Fueled by laughter."
	prereq_ids = list("mech_assembly")
	design_ids = list(
		"honk_chassis",
		"honk_torso",
		"honk_head",
		"honk_left_arm",
		"honk_right_arm",
		"honk_left_leg",
		"honk_right_leg",
		"honker_main",
		"honker_peri",
		"honker_targ",
		"mech_banana_mortar",
		"mech_honker",
		"mech_mousetrap_mortar",
		"mech_punching_face",
		"borg_transform_clown",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)


/datum/techweb_node/mech_medical
	id = "mech_medical"
	display_name = "Medical Mech"
	description = "Advanced robotic unit equipped with syringe guns and healing beams, revolutionizing medical assistance in hazardous environments."
	prereq_ids = list("mech_assembly", "chem_synthesis")
	design_ids = list(
		"odysseus_chassis",
		"odysseus_torso",
		"odysseus_head",
		"odysseus_left_arm",
		"odysseus_right_arm",
		"odysseus_left_leg",
		"odysseus_right_leg",
		"odysseus_main",
		"odysseus_peri",
		"mech_medi_beam",
		"mech_syringe_gun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/mech_mining
	id = "mech_mining"
	display_name = "Mining Mech"
	description = "Robust mech engineered to withstand lava and storms for continuous off-station mining operations."
	prereq_ids = list("mech_equipment", "mining")
	design_ids = list(
		"clarke_chassis",
		"clarke_torso",
		"clarke_head",
		"clarke_left_arm",
		"clarke_right_arm",
		"clarke_main",
		"clarke_peri",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/mech_combat
	id = "mech_combat"
	display_name = "Combat Mechs"
	description = "Modular armor upgrades and specialized equipment for security mechs."
	prereq_ids = list("mech_equipment")
	design_ids = list(
		"mech_ccw_armor",
		"mech_proj_armor",
		"paddyupgrade",
		"mech_hydraulic_claw",
		"mech_disabler",
		"mech_repair_droid",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)
	required_experiments = list(/datum/experiment/scanning/random/mecha_equipped_scan)
	discount_experiments = list(/datum/experiment/scanning/random/mecha_damage_scan = TIER_2_POINTS)

/datum/techweb_node/mech_assault
	id = "mech_assault"
	display_name = "Assault Mech"
	description = "Heavy battle mech boasting robust armor but sacrificing speed for enhanced durability."
	prereq_ids = list("mech_combat")
	design_ids = list(
		"durand_armor",
		"durand_chassis",
		"durand_torso",
		"durand_head",
		"durand_left_arm",
		"durand_right_arm",
		"durand_left_leg",
		"durand_right_leg",
		"durand_main",
		"durand_peri",
		"durand_targ",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)

/datum/techweb_node/mech_light
	id = "mech_light"
	display_name = "Light Combat Mech"
	description = "Agile combat mech equipped with overclocking capabilities for temporary speed boosts, prioritizing speed over durability on the battlefield."
	prereq_ids = list("mech_combat")
	design_ids = list(
		"gygax_armor",
		"gygax_chassis",
		"gygax_torso",
		"gygax_head",
		"gygax_left_arm",
		"gygax_right_arm",
		"gygax_left_leg",
		"gygax_right_leg",
		"gygax_main",
		"gygax_peri",
		"gygax_targ",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)

/datum/techweb_node/mech_firearms
	id = "mech_firearms"
	display_name = "Mech Firearms"
	description = "Mounted ballistic weaponry, enhancing combat capabilities for mechanized units."
	prereq_ids = list("mech_combat", "ammo")
	design_ids = list(
		"mech_lmg",
		"mech_lmg_ammo",
		"mech_scattershot",
		"mech_scattershot_ammo",
		"mech_carbine",
		"mech_carbine_ammo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

/datum/techweb_node/mech_heavy
	id = "mech_heavy"
	display_name = "Heavy Mech"
	description = "Advanced heavy mechanized unit with dual pilot capability, designed for robust battlefield performance and increased tactical versatility."
	prereq_ids = list("mech_assault")
	design_ids = list(
		"savannah_ivanov_armor",
		"savannah_ivanov_chassis",
		"savannah_ivanov_torso",
		"savannah_ivanov_head",
		"savannah_ivanov_left_arm",
		"savannah_ivanov_right_arm",
		"savannah_ivanov_left_leg",
		"savannah_ivanov_right_leg",
		"savannah_ivanov_main",
		"savannah_ivanov_peri",
		"savannah_ivanov_targ",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

/datum/techweb_node/mech_infiltrator
	id = "mech_infiltrator"
	display_name = "Infiltration Mech"
	description = "Advanced mech with phasing capabilities, allowing it to move through walls and obstacles, ideal for covert and special operations."
	prereq_ids = list("mech_light", "anomaly_research")
	design_ids = list(
		"phazon_armor",
		"phazon_chassis",
		"phazon_torso",
		"phazon_head",
		"phazon_left_arm",
		"phazon_right_arm",
		"phazon_left_leg",
		"phazon_right_leg",
		"phazon_main",
		"phazon_peri",
		"phazon_targ",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)


/datum/techweb_node/mech_energy_guns
	id = "mech_energy_guns"
	display_name = "Mech Energy Guns"
	description = "Scaled-up versions of electric weapons optimized for mech deployment."
	prereq_ids = list("mech_firearms", "electric_weapons")
	design_ids = list(
		"mech_laser",
		"mech_laser_heavy",
		"mech_ion",
		"mech_tesla",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)

/datum/techweb_node/mech_heavy_arms
	id = "mech_heavy_arms"
	display_name = "Heavy Mech Firearms"
	description = "High-impact weaponry integrated into mechs, optimized for maximum firepower."
	prereq_ids = list("mech_heavy", "explosives")
	design_ids = list(
		"clusterbang_launcher",
		"clusterbang_launcher_ammo",
		"mech_grenade_launcher",
		"mech_grenade_launcher_ammo",
		"mech_missile_rack",
		"mech_missile_rack_ammo",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)

/datum/techweb_node/mech_equip_bluespace
	id = "mech_equip_bluespace"
	display_name = "Bluespace Mech Equipment"
	description = "An array of equipment empowered by bluespace, providing unmatched mobility and utility."
	prereq_ids = list("mech_infiltrator", "bluespace_travel")
	design_ids = list(
		"mech_gravcatapult",
		"mech_teleporter",
		"mech_wormhole_gen",
		"mech_rcd",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)

// Exosuit tree
/datum/techweb_node/mod_suit
	id = "mod_suit"
	starting_node = TRUE
	display_name = "Modular Exosuit"
	description = "Specialized back mounted power suits with various different modules."
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

/datum/techweb_node/mod_equip
	id = "mod_equip"
	display_name = "Modular Suit Equipment"
	description = "More advanced modules, to improve modular suits."
	prereq_ids = list("mod_suit")
	design_ids = list(
		"modlink_scryer",
		"mod_clamp",
		"mod_tether",
		"mod_welding",
		"mod_safety",
		"mod_mouthhole",
		"mod_longfall",
		"mod_thermal_regulator",
		"mod_sign_radio",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/mod_entertainment
	id = "mod_entertainment"
	display_name = "Entertainment Modular Suit"
	description = "Powered suits for protection against low-humor environments."
	prereq_ids = list("mod_suit")
	design_ids = list(
		"mod_plating_cosmohonk",
		"mod_bikehorn",
		"mod_microwave_beam",
		"mod_waddle",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/mod_medical
	id = "mod_medical"
	display_name = "Medical Modular Suit"
	description = "Medical exosuits for quick rescue purposes."
	prereq_ids = list("mod_suit", "chem_synthesis")
	design_ids = list(
		"mod_plating_medical",
		"mod_quick_carry",
		"mod_injector",
		"mod_organ_thrower",
		"mod_patienttransport",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/mod_engi
	id = "mod_engi"
	display_name = "Engineering Modular Suits"
	description = "Engineering suits, for powered engineers."
	prereq_ids = list("mod_equip")
	design_ids = list(
		"mod_plating_engineering",
		"mod_t_ray",
		"mod_magboot",
		"mod_constructor",
		"mod_mister_atmos",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/mod_security
	id = "mod_security"
	display_name = "Security Modular Suits"
	description = "Security suits for space crime handling."
	prereq_ids = list("mod_equip")
	design_ids = list(
		"mod_plating_security",
		"mod_stealth",
		"mod_mag_harness",
		"mod_pathfinder",
		"mod_holster",
		"mod_sonar",
		"mod_projectile_dampener",
		"mod_criminalcapture",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/mod_medical_adv
	id = "mod_medical_adv"
	display_name = "Advanced Medical Modular Suit"
	description = "Medical exosuit equipment designed for conducting surgical operations in field conditions."
	prereq_ids = list("mod_medical")
	design_ids = list(
		"mod_defib",
		"mod_threadripper",
		"mod_surgicalprocessor",
		"mod_statusreadout",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)

/datum/techweb_node/mod_engi_adv
	id = "mod_engi_adv"
	display_name = "Advanced Engineering Modular Suit"
	description = "Advanced Engineering suits, for advanced powered engineers."
	prereq_ids = list("mod_engi")
	design_ids = list(
		"mod_plating_atmospheric",
		"mod_jetpack",
		"mod_rad_protection",
		"mod_emp_shield",
		"mod_storage_expanded",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)

/datum/techweb_node/mod_engi_adv/New()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_RADIOACTIVE_NEBULA)) //we'll really need the rad protection modsuit module
		starting_node = TRUE
	return ..()

/datum/techweb_node/mod_anomaly
	id = "mod_anomaly"
	display_name = "Anomalock Modular Suit"
	description = "Modules for exosuits that require anomaly cores to function."
	prereq_ids = list("mod_engi_adv", "anomaly_research")
	design_ids = list(
		"mod_antigrav",
		"mod_teleporter",
		"mod_kinesis",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

// Cyborg tree
/datum/techweb_node/augmentation
	id = "augmentation"
	starting_node = TRUE
	display_name = "Augmentation"
	description = "For those who prefer shiny metal over squishy flesh."
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

/datum/techweb_node/cybernetics
	id = "cybernetics"
	display_name = "Cybernetics"
	description = "Sapient robots with preloaded tool modules and programmable laws."
	prereq_ids = list("augmentation")
	design_ids = list(
		"robocontrol",
		"borgupload",
		"cyborgrecharger",
		"borg_suit",
		"mmi_posi",
		"mmi",
		"mmi_m",
		"advanced_l_arm",
		"advanced_r_arm",
		"advanced_l_leg",
		"advanced_r_leg",
		"borg_upgrade_rename",
		"borg_upgrade_restart",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/borg_service
	id = "borg_service"
	display_name = "Service Cyborg Upgrades"
	description = "Let them do the cookin' by the book."
	prereq_ids = list("cybernetics")
	design_ids = list(
		"borg_upgrade_rolling_table",
		"borg_upgrade_condiment_synthesizer",
		"borg_upgrade_silicon_knife",
		"borg_upgrade_service_apparatus",
		"borg_upgrade_drink_apparatus",
		"borg_upgrade_service_cookbook",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/borg_medical
	id = "borg_medical"
	display_name = "Medical Cyborg Upgrades"
	description = "Let them follow Asimov's First Law."
	prereq_ids = list("borg_service", "surgery_adv")
	design_ids = list(
		"borg_upgrade_pinpointer",
		"borg_upgrade_beakerapp",
		"borg_upgrade_defibrillator",
		"borg_upgrade_expandedsynthesiser",
		"borg_upgrade_piercinghypospray",
		"borg_upgrade_surgicalprocessor",
		"borg_upgrade_surgicalomnitool",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)

/datum/techweb_node/borg_utility
	id = "borg_utility"
	display_name = "Untility Cyborg Upgrades"
	description = "Let them wipe our floors for us."
	prereq_ids = list("borg_service", "surgery_adv")
	design_ids = list(
		"borg_upgrade_advancedmop",
		"borg_upgrade_broomer",
		"borg_upgrade_expand",
		"borg_upgrade_prt",
		"borg_upgrade_selfrepair",
		"borg_upgrade_thrusters",
		"borg_upgrade_trashofholding",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)

/datum/techweb_node/borg_utility/New()
	. = ..()
	if(!CONFIG_GET(flag/disable_secborg))
		design_ids += "borg_upgrade_disablercooler"

/datum/techweb_node/borg_engi
	id = "borg_engi"
	display_name = "Engineering & Mining Cyborg Upgrades"
	description = "To slack even more."
	prereq_ids = list("borg_utility", "exp_tools")
	design_ids = list(
		"borg_upgrade_rped",
		"borg_upgrade_inducer",
		"borg_upgrade_engineeringomnitool",
		"borg_upgrade_circuitapp",
		"borg_upgrade_lavaproof",
		"borg_upgrade_diamonddrill",
		"borg_upgrade_holding",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)

// Implants tree
/datum/techweb_node/implants
	id = "implants"
	display_name = "Passive Implants"
	description = "Implants designed to operate seamlessly without active user input, enhancing various physiological functions or providing continuous benefits."
	prereq_ids = list("cybernetics")
	design_ids = list(
		"skill_station",
		"c38_trac",
		"implant_trombone",
		"implant_chem",
		"implant_tracking",
		"implant_exile",
		"implant_beacon",
		"implant_bluespace",
		"implantcase",
		"implanter",
		"locator",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/cyber/cyber_implants
	id = "cyber_implants"
	display_name = "Cybernetic Implants"
	description = "Advanced technological enhancements integrated into the body, offering improved physical capabilities."
	prereq_ids = list("implants")
	design_ids = list(
		"ci-breather",
		"ci-nutriment",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)

/datum/techweb_node/cyber/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs[TECHWEB_POINT_TYPE_GENERIC] /= 2

/datum/techweb_node/cyber/combat_cyber_implants
	id = "combat_cyber_implants"
	display_name = "Combat Cybernetic Implants"
	description = "Implants offering protection against stunning effects, preventing accidental weapon drops, and enabling controlled flight in zero gravity."
	prereq_ids = list("cyber_implants")
	design_ids = list(
		"ci-thrusters",
		"ci-antidrop",
		"ci-antistun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

/datum/techweb_node/cyber/adv_cyber_implants
	id = "adv_cyber_implants"
	display_name = "Advanced Cybernetic Implants"
	description = "Decades of contraband smuggling by assistants have led to the development of an entire toolbox that fits seamlessly into your arm."
	prereq_ids = list("combat_cyber_implants", "exp_tools")
	design_ids = list(
		"ci-nutrimentplus",
		"ci-reviver",
		"ci-toolset",
		"ci-surgery",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)

/datum/techweb_node/cyber/cyber_organs
	id = "cyber_organs"
	display_name = "Cybernetic Organs"
	description = "We have the technology to rebuild him."
	prereq_ids = list("cybernetics")
	design_ids = list(
		"cybernetic_eyes_improved",
		"cybernetic_eyes_improved_moth",
		"cybernetic_ears_u",
		"cybernetic_lungs_tier2",
		"cybernetic_stomach_tier2",
		"cybernetic_liver_tier2",
		"cybernetic_heart_tier2",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/cyber/cyber_organs_upgraded
	id = "cyber_organs_upgraded"
	display_name = "Upgraded Cybernetic Organs"
	description = "We have the technology to upgrade him."
	prereq_ids = list("cyber_organs")
	design_ids = list(
		"ci-gloweyes",
		"ci-welding",
		"ci-gloweyes-moth",
		"ci-welding-moth",
		"cybernetic_ears_whisper",
		"cybernetic_lungs_tier3",
		"cybernetic_stomach_tier3",
		"cybernetic_liver_tier3",
		"cybernetic_heart_tier3",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)
	required_experiments = list(/datum/experiment/scanning/people/augmented_organs)

/datum/techweb_node/cyber/cyber_organs_adv
	id = "cyber_organs_adv"
	display_name = "Advanced Cybernetic Organs"
	description = "Cutting-edge cybernetic organs offering enhanced sensory capabilities, making it easier than ever to detect ERP."
	prereq_ids = list("cyber_organs_upgraded", "night_vision")
	design_ids = list(
		"cybernetic_ears_xray",
		"ci-thermals",
		"ci-xray",
		"ci-thermals-moth",
		"ci-xray-moth",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)

// Programmed circuits tree
/datum/techweb_node/programming
	id = "programming"
	starting_node = TRUE
	display_name = "Programming"
	description = "Dedicate an entire shift to program the fridge to greet you when opened."
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

/datum/techweb_node/circuit_shells
	id = "circuit_shells"
	display_name = "Advanced Circuit Shells"
	description = "Adding brains to more things."
	prereq_ids = list("programming")
	design_ids = list(
		"assembly_shell",
		"bot_shell",
		"controller_shell",
		"dispenser_shell",
		"door_shell",
		"gun_shell",
		"keyboard_shell",
		"module_shell",
		"money_bot_shell",
		"scanner_gate_shell",
		"scanner_shell",
		"comp_equip_action",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/programmed_bot
	id = "programmed_bot"
	display_name = "Programmed Bot"
	description = "Grants access to movable shells, allowing for remote operations and pranks."
	prereq_ids = list("circuit_shells")
	design_ids = list(
		"drone_shell",
		"comp_pathfind",
		"comp_pull",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/bci
	id = "bci"
	display_name = "Brain-Computer Interface"
	description = "Embedded brain circuits. May occasionally stream Nanotrasen ads in dreams."
	prereq_ids = list("programmed_bot", "implants")
	design_ids = list(
		"bci_implanter",
		"bci_shell",
		"comp_bar_overlay",
		"comp_camera_bci",
		"comp_counter_overlay",
		"comp_install_detector",
		"comp_object_overlay",
		"comp_reagent_injector",
		"comp_target_intercept",
		"comp_thought_listener",
		"comp_vox",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)

/datum/techweb_node/programmed_server
	id = "programmed_server"
	display_name = "Programmed Server"
	description = "Grants access to a server shell that has a very high capacity for components."
	prereq_ids = list("bci")
	design_ids = list(
		"server_shell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

// Research tree
/datum/techweb_node/fundamental_sci
	id = "fundamental_sci"
	starting_node = TRUE
	display_name = "Fundamental Science"
	description = "Establishing the bedrock of scientific understanding, paving the way for deeper exploration and theoretical inquiry."
	design_ids = list(
		"rdserver",
		"rdservercontrol",
		"rdconsole",
		"tech_disk",
		"portadrive_basic",
		"portadrive_advanced",
		"portadrive_super",
		"doppler_array",
		"experimentor",
		"destructive_analyzer",
		"destructive_scanner",
		"experi_scanner",
		"laptop",
	)

/datum/techweb_node/bluespace_theory
	id = "bluespace_theory"
	display_name = "Bluespace Theory"
	description = "Basic studies into the mysterious alternate dimension known as bluespace."
	prereq_ids = list("fundamental_sci")
	design_ids = list(
		"bluespace_crystal",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/applied_bluespace
	id = "applied_bluespace"
	display_name = "Applied Bluespace Research"
	description = "With a heightened grasp of bluespace dynamics, sophisticated applications and technologies can be devised using data from bluespace crystal analyses."
	prereq_ids = list("bluespace_theory")
	design_ids = list(
		"ore_silo",
		"minerbag_holding",
		"plumbing_receiver",
		"bluespacebeaker",
		"adv_watering_can",
		"bluespace_coffeepot",
		"bluespacesyringe",
		"blutrash",
		"light_replacer_blue",
		"bluespacebodybag",
		"medicalbed_emergency",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)
	required_experiments = list(/datum/experiment/scanning/bluespace_crystal)

/datum/techweb_node/anomaly_research
	id = "anomaly_research"
	display_name = "Anomaly Research"
	description = "Delving into the study of mysterious anomalies to investigate methods to refine and harness their unpredictable energies."
	prereq_ids = list("applied_bluespace")
	design_ids = list(
		"anomaly_refinery",
		"anomaly_neutralizer",
		"reactive_armour",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)

/datum/techweb_node/anomaly_shells
	id = "anomaly_shells"
	display_name = "Advanced Anomaly Shells"
	description = "New shells designed to utilize anomaly cores, maximizing their potential in innovative ways."
	prereq_ids = list("anomaly_research")
	design_ids = list(
		"bag_holding",
		"wormholeprojector",
		"gravitygun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

/datum/techweb_node/anomaly_morph
	id = "anomaly_morph"
	display_name = "Anomalous Morphology"
	description = "Use poorly understood energies to change your body."
	prereq_ids = list("anomaly_shells")
	design_ids = list(
		"polymorph_belt"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)

// Parts tree
/datum/techweb_node/parts
	id = "parts"
	starting_node = TRUE
	display_name = "Essential Stock Parts"
	description = "Foundational components that form the backbone of station operations, encompassing a range of essential equipment necessary for day-to-day functionality."
	design_ids = list(
		"micro_servo",
		"basic_capacitor",
		"basic_matter_bin",
		"basic_micro_laser",
		"basic_scanning",
		"high_cell",
		"basic_cell",
		"miniature_power_cell",
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

/datum/techweb_node/parts_upg
	id = "parts_upg"
	display_name = "Upgraded Parts"
	description = "Offering enhanced capabilities beyond their basic counterparts."
	prereq_ids = list("parts")
	design_ids = list(
		"rped",
		"high_micro_laser",
		"adv_capacitor",
		"nano_servo",
		"adv_matter_bin",
		"adv_scanning",
		"super_cell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/parts_adv
	id = "parts_adv"
	display_name = "Advanced Parts"
	description = "The most finely tuned and accurate stock parts."
	prereq_ids = list("parts_upg", "energy_manipulation")
	design_ids = list(
		"ultra_micro_laser",
		"super_capacitor",
		"pico_servo",
		"super_matter_bin",
		"phasic_scanning",
		"hyper_cell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/parts_bluespace
	id = "parts_bluespace"
	display_name = "Bluespace Parts"
	description = "Integrating the latest in bluespace technology, these advanced components not only enhance functionality but also open up new possibilities for the station's technological capabilities."
	prereq_ids = list("parts_adv", "applied_bluespace")
	design_ids = list(
		"bs_rped",
		"quadultra_micro_laser",
		"quadratic_capacitor",
		"femto_servo",
		"bluespace_matter_bin",
		"triphasic_scanning",
		"bluespace_cell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)

/datum/techweb_node/bluespace_travel
	id = "bluespace_travel"
	display_name = "Bluespace Travel"
	description = "Facilitate teleportation methods based on bluespace principles to revolutionize logistical efficiency."
	prereq_ids = list("parts_bluespace")
	design_ids = list(
		"teleconsole",
		"tele_station",
		"tele_hub",
		"launchpad_console",
		"quantumpad",
		"launchpad",
		"bluespace_pod",
		"quantum_keycard",
		"swapper",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

/datum/techweb_node/telecomms
	id = "telecomms"
	display_name = "Telecommunications Technology"
	description = "A comprehensive suite of machinery for station-wide communication setups, ensuring seamless connectivity and operational coordination."
	prereq_ids = list("bluespace_travel")
	design_ids = list(
		"comm_monitor",
		"comm_server",
		"message_monitor",
		"automated_announcement",
		"ntnet_relay",
		"s_hub",
		"s_messaging",
		"s_server",
		"s_processor",
		"s_relay",
		"s_bus",
		"s_broadcaster",
		"s_receiver",
		"s_amplifier",
		"s_analyzer",
		"s_ansible",
		"s_crystal",
		"s_filter",
		"s_transmitter",
		"s_treatment",
		"gigabeacon",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)

// Engi trees
// Energy tree
/datum/techweb_node/construction
	id = "construction"
	starting_node = TRUE
	display_name = "Construction"
	description = "Tools and essential machinery used for station maintenance and expansion."
	design_ids = list(
		"circuit_imprinter_offstation",
		"circuit_imprinter",
		"solarcontrol",
		"solar_panel",
		"solar_tracker",
		"power_control",
		"airalarm_electronics",
		"airlock_board",
		"firealarm_electronics",
		"firelock_board",
		"trapdoor_electronics",
		"blast",
		"tile_sprayer",
		"airlock_painter",
		"decal_painter",
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
		"light_bulb",
		"light_tube",
		"intercom_frame",
		"newscaster_frame",
		"status_display_frame",
		"circuit",
		"circuitgreen",
		"circuitred",
		"tram_floor_dark",
		"tram_floor_light",
		"tram_controller",
		"tram_display",
		"crossing_signal",
		"guideway_sensor",
	)

/datum/techweb_node/energy_manipulation
	id = "energy_manipulation"
	display_name = "Energy Manipulation"
	description = "Harnessing the raw power of lightning arcs through sophisticated energy control methods."
	prereq_ids = list("construction")
	design_ids = list(
		"apc_control",
		"powermonitor",
		"smes",
		"emitter",
		"grounding_rod",
		"tesla_coil",
		"cell_charger",
		"recharger",
		"inducer",
		"inducerengi",
		"welding_goggles",
		"tray_goggles",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/holographics
	id = "holographics"
	display_name = "Holographics"
	description = "Use of holographic technology for signage and barriers."
	prereq_ids = list("energy_manipulation")
	design_ids = list(
		"forcefield_projector",
		"holosign",
		"holosignsec",
		"holosignengi",
		"holosignatmos",
		"holosignrestaurant",
		"holosignbar",
		"holobarrier_jani",
		"holobarrier_med",
		"holopad",
		"vendatray",
		"holodisk",
		"modular_shield_generator",
		"modular_shield_node",
		"modular_shield_relay",
		"modular_shield_charger",
		"modular_shield_well",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/hud
	id = "hud"
	display_name = "Integrated HUDs"
	description = "Initially developed for assistants to learn the nuances of different professions through augmented reality."
	prereq_ids = list("holographics", "implants")
	design_ids = list(
		"health_hud",
		"diagnostic_hud",
		"security_hud",
		"mod_visor_medhud",
		"mod_visor_diaghud",
		"mod_visor_sechud",
		"ci-medhud",
		"ci-diaghud",
		"ci-sechud",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)

/datum/techweb_node/night_vision
	id = "night_vision"
	display_name = "Night Vision Technology"
	description = "There are whispers that Nanotrasen pushed for this technology to extend shift durations, ensuring productivity around the clock."
	prereq_ids = list("hud")
	design_ids = list(
		"diagnostic_hud_night",
		"health_hud_night",
		"night_visision_goggles",
		"nvgmesons",
		"nv_scigoggles",
		"security_hud_night",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

// Atmos tree
/datum/techweb_node/atmos
	id = "atmos"
	starting_node = TRUE
	display_name = "Atmospherics"
	description = "Maintaining station air and related life support systems."
	design_ids = list(
		"atmos_control",
		"atmosalerts",
		"thermomachine",
		"space_heater",
		"generic_tank",
		"oxygen_tank",
		"plasma_tank",
		"plasmaman_tank_belt",
		"plasmarefiller",
		"extinguisher",
		"gas_filter",
		"plasmaman_gas_filter",
		"analyzer",
		"pipe_painter",
	)

/datum/techweb_node/gas_compression
	id = "gas_compression"
	display_name = "Gas Compression"
	description = "Highly pressurized gases hold potential for unlocking immense energy capabilities."
	prereq_ids = list("atmos")
	design_ids = list(
		"tank_compressor",
		"emergency_oxygen",
		"emergency_oxygen_engi",
		"power_turbine_console",
		"turbine_part_compressor",
		"turbine_part_rotor",
		"turbine_part_stator",
		"turbine_compressor",
		"turbine_rotor",
		"turbine_stator",
		"atmos_thermal",
		"pneumatic_seal",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/plasma_control
	id = "plasma_control"
	display_name = "Controlled Plasma"
	description = "Experiments with high-pressure gases and electricity resulting in crystallization and controlled plasma reactions."
	prereq_ids = list("gas_compression", "energy_manipulation")
	design_ids = list(
		"crystallizer",
		"electrolyzer",
		"pacman",
		"mech_generator",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/fusion
	id = "fusion"
	display_name = "Fusion"
	description = "Investigating fusion reactor technology to achieve sustainable and efficient energy production through controlled plasma reactions involving noble gases."
	prereq_ids = list("plasma_control")
	design_ids = list(
		"HFR_core",
		"HFR_corner",
		"HFR_fuel_input",
		"HFR_interface",
		"HFR_moderator_input",
		"HFR_waste_output",
		"bolter_wrench",
		"rpd_loaded",
		"engine_goggles",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)
	required_experiments = list(/datum/experiment/ordnance/gaseous/bz)
	discount_experiments = list(/datum/experiment/ordnance/gaseous/nitrous_oxide = TIER_3_POINTS)

/datum/techweb_node/exp_tools
	id = "exp_tools"
	display_name = "Experimental Tools"
	description = "Enhances the functionality and versatility of station tools."
	prereq_ids = list("fusion", "plasma")
	design_ids = list(
		"flatpacker",
		"handdrill",
		"exwelder",
		"jawsoflife",
		"rangedanalyzer",
		"rtd_loaded",
		"rcd_loaded",
		"rcd_ammo",
		"weldingmask",
		"magboots",
		"adv_fire_extinguisher",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/ordnance/gaseous/noblium = TIER_4_POINTS)

/datum/techweb_node/rcd_upgrade
	id = "rcd_upgrade"
	display_name = "Rapid Device Upgrade Designs"
	description = "New designs and enhancements for RCD and RPD."
	prereq_ids = list("exp_tools")
	design_ids = list(
		"rcd_upgrade_anti_interrupt",
		"rcd_upgrade_cooling",
		"rcd_upgrade_frames",
		"rcd_upgrade_furnishing",
		"rcd_upgrade_simple_circuits",
		"rpd_upgrade_unwrench",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)

/datum/techweb_node/rcd_upgrade_adv
	id = "rcd_upgrade_adv"
	display_name = "Advanced RCD Designs Upgrade"
	description = "New RCD upgrade utilizing bluespace for instant matter delivery from centralized storage."
	prereq_ids = list("rcd_upgrade", "bluespace_travel")
	design_ids = list(
		"rcd_upgrade_silo_link",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)

// Cargo tree
/datum/techweb_node/material_processing
	id = "material_proc"
	starting_node = TRUE
	display_name = "Material Processing"
	description = "Refinement and processing of alloys and ores to enhance their utility and value."
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
	)

/datum/techweb_node/mining
	id = "mining"
	display_name = "Mining Technology"
	description = "Development of tools meant to optimize mining operations and resource extraction."
	prereq_ids = list("material_proc")
	design_ids = list(
		"cargoexpress",
		"brm",
		"b_smelter",
		"b_refinery",
		"ore_redemption",
		"mining_equipment_vendor",
		"drill",
		"mining_scanner",
		"mech_mscanner",
		"mech_drill",
		"mod_drill",
		"mod_orebag",
		"beacon",
		"telesci_gps",
		"mod_gps",
		"mod_visor_meson",
		"mesons",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/low_pressure_excavation
	id = "low_pressure_excavation"
	display_name = "Low-Pressure Excavation"
	description = "Research of Proto-Kinetic Accelerators (PKAs), pneumatic guns renowned for their exceptional performance in low-pressure environments."
	prereq_ids = list("mining", "gas_compression")
	design_ids = list(
		"superresonator",
		"mecha_kineticgun",
		"damagemod",
		"rangemod",
		"cooldownmod",
		"triggermod",
		"borg_upgrade_damagemod",
		"borg_upgrade_rangemod",
		"borg_upgrade_cooldownmod",
		"borg_upgrade_hypermod",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)

/datum/techweb_node/plasma_mining
	id = "plasma_mining"
	display_name = "Plasma Beam Mining"
	description = "Specialized cutters for precision mining operations and welding, leveraging advanced plasma control technology."
	prereq_ids = list("low_pressure_excavation", "plasma_control")
	design_ids = list(
		"mech_plasma_cutter",
		"plasmacutter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

/datum/techweb_node/mining_adv
	id = "mining_adv"
	display_name = "Advanced Mining Technology"
	description = "High-level mining equipment, pushing the boundaries of efficiency and effectiveness in resource extraction."
	prereq_ids = list("plasma_mining")
	design_ids = list(
		"mech_diamond_drill",
		"drill_diamond",
		"jackhammer",
		"plasmacutter_adv",
		"hypermod",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)

// B.E.P.I.S. Locked Techs
/datum/techweb_node/light_apps
	id = "light_apps"
	display_name = "Illumination Applications"
	description = "Applications of lighting and vision technology not originally thought to be commercially viable."
	design_ids = list(
		"bright_helmet",
		"rld_mini",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/extreme_office
	id = "extreme_office"
	display_name = "Advanced Office Applications"
	description = "Some of our smartest lab guys got together on a Friday and improved our office efficiency by 350%. Here's how."
	design_ids = list(
		"mauna_mug",
		"rolling_table",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/spec_eng
	id = "spec_eng"
	display_name = "Specialized Engineering"
	description = "Conventional wisdom has deemed these engineering products 'technically' safe, but far too dangerous to traditionally condone."
	design_ids = list(
		"eng_gloves",
		"lava_rods",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/aus_security
	id = "aus_security"
	display_name = "Australicus Security Protocols"
	description = "It is said that security in the Australicus sector is tight, so we took some pointers from their equipment. Thankfully, our sector lacks any signs of these, 'dropbears'."
	design_ids = list(
		"pin_explorer",
		"stun_boomerang",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/interrogation
	id = "interrogation"
	display_name = "Enhanced Interrogation Technology"
	description = "By cross-referencing several declassified documents from past dictatorial regimes, we were able to develop an incredibly effective interrogation device. \
	Ethical concerns about loss of free will do not apply to criminals, according to galactic law."
	design_ids = list(
		"hypnochair",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/mod_experimental
	id = "mod_experimental"
	display_name = "Experimental Modular Suits"
	description = "Applications of experimentality when creating MODsuits have created these..."
	design_ids = list(
		"mod_disposal",
		"mod_joint_torsion",
		"mod_recycler",
		"mod_shooting",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/mod_experimental
	id = "mod_experimental"
	display_name = "Experimental Modular Suits"
	description = "Applications of experimentality when creating MODsuits have created these..."
	design_ids = list(
		"mod_disposal",
		"mod_joint_torsion",
		"mod_recycler",
		"mod_shooting",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE

/datum/techweb_node/posisphere
	id = "positronic_sphere"
	display_name = "Experimental Spherical Positronic Brain"
	description = "Recent developments on cost-cutting measures have allowed us to cut positronic brain cubes into twice-as-cheap spheres. Unfortunately, it also allows them to move around the lab via rolling maneuvers."
	design_ids = list(
		"posisphere",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)
	hidden = TRUE
	experimental = TRUE

// Alien technology
/datum/techweb_node/alientech //AYYYYYYYYLMAOO tech
	id = "alientech"
	display_name = "Alien Technology"
	description = "Things used by the greys."
	prereq_ids = list("bluespace_travel")
	required_items_to_unlock = list(
		/obj/item/stack/sheet/mineral/abductor,
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)
	hidden = TRUE

/datum/techweb_node/alientech/on_station_research()
	SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_ALIENTECH] = TRUE

/datum/techweb_node/alien_engi
	id = "alien_engi"
	display_name = "Alien Engineering"
	description = "Alien engineering tools"
	prereq_ids = list("alientech", "exp_tools")
	design_ids = list(
		"alien_crowbar",
		"alien_multitool",
		"alien_screwdriver",
		"alien_welder",
		"alien_wirecutters",
		"alien_wrench",
	)
	required_items_to_unlock = list(
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)
	hidden = TRUE

/datum/techweb_node/alien_surgery
	id = "alien_surgery"
	display_name = "Alien Surgery"
	description = "Abductors did nothing wrong."
	prereq_ids = list("alientech", "surgery_tools")
	design_ids = list(
		"alien_cautery",
		"alien_drill",
		"alien_hemostat",
		"alien_retractor",
		"alien_saw",
		"alien_scalpel",
		"surgery_brainwashing",
		"surgery_heal_combo_upgrade_femto",
		"surgery_zombie",
	)
	required_items_to_unlock = list(
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/slime/hard = TIER_5_POINTS)

// Syndicate tech
/datum/techweb_node/syndicate_basic
	id = "syndicate_basic"
	display_name = "Illegal Technology"
	description = "Dangerous research used to create dangerous objects."
	prereq_ids = list("exp_tools", "explosives")
	design_ids = list(
		"advanced_camera",
		"ai_cam_upgrade",
		"borg_syndicate_module",
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)
	hidden = TRUE

/datum/techweb_node/syndicate_basic/New() //Crappy way of making syndicate gear decon supported until there's another way.
	. = ..()
	if(!SSearly_assets.initialized)
		RegisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(register_uplink_items))
	else
		register_uplink_items()

/datum/techweb_node/syndicate_basic/proc/register_uplink_items()
	SIGNAL_HANDLER
	UnregisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	required_items_to_unlock = list()
	for(var/datum/uplink_item/item_path as anything in SStraitor.uplink_items_by_type)
		var/datum/uplink_item/item = SStraitor.uplink_items_by_type[item_path]
		if(!item.item || !item.illegal_tech)
			continue
		required_items_to_unlock |= item.item //allows deconning to unlock.

/datum/techweb_node/unregulated_bluespace
	id = "unregulated_bluespace"
	display_name = "Unregulated Bluespace Research"
	description = "Bluespace technology using unstable or unbalanced procedures, prone to damaging the fabric of bluespace. Outlawed by galactic conventions."
	prereq_ids = list("bluespace_travel", "syndicate_basic")
	design_ids = list(
		"desynchronizer",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)


#undef TIER_1_POINTS
#undef TIER_2_POINTS
#undef TIER_3_POINTS
#undef TIER_4_POINTS
#undef TIER_5_POINTS
