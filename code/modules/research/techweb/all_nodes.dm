
//Current rate: 132500 research points in 90 minutes

//Base Node
/datum/techweb_node/base
	id = "base"
	starting_node = TRUE
	display_name = "Basic Research Technology"
	description = "NT default research technologies."
	design_ids = list("basic_matter_bin", "basic_cell", "basic_scanning", "basic_capacitor", "basic_micro_laser", "micro_mani",
	"destructive_analyzer", "circuit_imprinter", "experimentor", "rdconsole", "design_disk", "tech_disk", "rdserver", "rdservercontrol", "mechfab",
	"space_heater", "xlarge_beaker", "sec_rshot", "sec_bshot", "sec_slug", "sec_Islug", "sec_dart", "sec_38")			//Default research tech, prevents bricking


/////////////////////////Biotech/////////////////////////
/datum/techweb_node/biotech
	id = "biotech"
	display_name = "Biological Technology"
	description = "What makes us tick."	//the MC, silly!
	prereq_ids = list("base")
	design_ids = list("chem_heater", "chem_master", "chem_dispenser", "sleeper", "vr_sleeper", "pandemic", "defibmount", "operating", "soda_dispenser", "beer_dispenser", "healthanalyzer")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_biotech
	id = "adv_biotech"
	display_name = "Advanced Biotechnology"
	description = "Advanced Biotechnology"
	prereq_ids = list("biotech")
	design_ids = list("piercesyringe", "smoke_machine", "plasmarefiller", "limbgrower", "defibrillator", "meta_beaker", "healthanalyzer_advanced")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/bio_process
	id = "bio_process"
	display_name = "Biological Processing"
	description = "From slimes to kitchens."
	prereq_ids = list("biotech")
	design_ids = list("smartfridge", "gibber", "deepfryer", "monkey_recycler", "processor", "gibber", "microwave", "reagentgrinder", "dish_drive")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////Advanced Surgery/////////////////////////
/datum/techweb_node/adv_surgery
	id = "adv_surgery"
	display_name = "Advanced Surgery"
	description = "When simple medicine doesn't cut it."
	prereq_ids = list("adv_biotech")
	design_ids = list("surgery_lobotomy", "surgery_reconstruction")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/exp_surgery
	id = "exp_surgery"
	display_name = "Experimental Surgery"
	description = "When evolution isn't fast enough."
	prereq_ids = list("adv_surgery")
	design_ids = list("surgery_revival","surgery_pacify","surgery_vein_thread","surgery_nerve_splice","surgery_nerve_ground","surgery_viral_bond")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/alien_surgery
	id = "alien_surgery"
	display_name = "Alien Surgery"
	description = "Abductors did nothing wrong."
	prereq_ids = list("exp_surgery", "alientech")
	design_ids = list("surgery_brainwashing","surgery_zombie")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

/////////////////////////data theory tech/////////////////////////
/datum/techweb_node/datatheory //Computer science
	id = "datatheory"
	display_name = "Data Theory"
	description = "Big Data, in space!"
	prereq_ids = list("base")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_datatheory
	id = "adv_datatheory"
	display_name = "Advanced Data Theory"
	description = "Better insight into programming and data."
	prereq_ids = list("datatheory")
	design_ids = list("icprinter", "icupgadv", "icupgclo")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////engineering tech/////////////////////////
/datum/techweb_node/engineering
	id = "engineering"
	display_name = "Industrial Engineering"
	description = "A refresher course on modern engineering technology."
	prereq_ids = list("base")
	design_ids = list("solarcontrol", "recharger", "powermonitor", "rped", "pacman", "adv_capacitor", "adv_scanning", "emitter", "high_cell", "adv_matter_bin",
	"atmosalerts", "atmos_control", "recycler", "autolathe", "high_micro_laser", "nano_mani", "mesons", "thermomachine", "rad_collector", "tesla_coil", "grounding_rod",
	"apc_control", "cell_charger", "power control", "airlock_board", "firelock_board", "airalarm_electronics", "firealarm_electronics", "cell_charger", "stack_console", "stack_machine")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
	export_price = 5000

/datum/techweb_node/adv_engi
	id = "adv_engi"
	display_name = "Advanced Engineering"
	description = "Pushing the boundaries of physics, one chainsaw-fist at a time."
	prereq_ids = list("engineering", "emp_basic")
	design_ids = list("engine_goggles", "magboots", "weldingmask")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/anomaly
	id = "anomaly_research"
	display_name = "Anomaly Research"
	description = "Unlock the potential of the mysterious anomalies that appear on station."
	prereq_ids = list("adv_engi", "practical_bluespace")
	design_ids = list("reactive_armour", "anomaly_neutralizer")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/high_efficiency
	id = "high_efficiency"
	display_name = "High Efficiency Parts"
	description = "Finely-tooled manufacturing techniques allowing for picometer-perfect precision levels."
	prereq_ids = list("engineering", "datatheory")
	design_ids = list("pico_mani", "super_matter_bin")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
	export_price = 5000

/datum/techweb_node/adv_power
	id = "adv_power"
	display_name = "Advanced Power Manipulation"
	description = "How to get more zap."
	prereq_ids = list("engineering")
	design_ids = list("smes", "super_cell", "hyper_cell", "super_capacitor", "superpacman", "mrspacman", "power_turbine", "power_turbine_console", "power_compressor", "circulator", "teg")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////Bluespace tech/////////////////////////
/datum/techweb_node/bluespace_basic //Bluespace-memery
	id = "bluespace_basic"
	display_name = "Basic Bluespace Theory"
	description = "Basic studies into the mysterious alternate dimension known as bluespace."
	prereq_ids = list("base")
	design_ids = list("beacon", "xenobioconsole", "telesci_gps")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_bluespace
	id = "adv_bluespace"
	display_name = "Advanced Bluespace Research"
	description = "Deeper understanding of how the Bluespace dimension works"
	prereq_ids = list("practical_bluespace", "high_efficiency")
	design_ids = list("bluespace_matter_bin", "femto_mani", "triphasic_scanning", "tele_station", "tele_hub", "quantumpad", "launchpad", "launchpad_console",
	"teleconsole", "bag_holding", "bluespace_crystal", "wormholeprojector", "bluespace_pod")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 15000)
	export_price = 5000

/datum/techweb_node/practical_bluespace
	id = "practical_bluespace"
	display_name = "Applied Bluespace Research"
	description = "Using bluespace to make things faster and better."
	prereq_ids = list("bluespace_basic", "engineering")
	design_ids = list("bs_rped","minerbag_holding", "bluespacebeaker", "bluespacesyringe", "bluespacebodybag", "phasic_scanning", "roastingstick")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/bluespace_power
	id = "bluespace_power"
	display_name = "Bluespace Power Technology"
	description = "Even more powerful.. power!"
	prereq_ids = list("adv_power", "adv_bluespace")
	design_ids = list("bluespace_cell", "quadratic_capacitor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000


/////////////////////////plasma tech/////////////////////////
/datum/techweb_node/basic_plasma
	id = "basic_plasma"
	display_name = "Basic Plasma Research"
	description = "Research into the mysterious and dangerous substance, plasma."
	prereq_ids = list("engineering")
	design_ids = list("mech_generator")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_plasma
	id = "adv_plasma"
	display_name = "Advanced Plasma Research"
	description = "Research on how to fully exploit the power of plasma."
	prereq_ids = list("basic_plasma")
	design_ids = list("mech_plasma_cutter")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////robotics tech/////////////////////////
/datum/techweb_node/robotics
	id = "robotics"
	display_name = "Basic Robotics Research"
	description = "Programmable machines that make our lives lazier."
	prereq_ids = list("base")
	design_ids = list("paicard")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_robotics
	id = "adv_robotics"
	display_name = "Advanced Robotics Research"
	description = "It can even do the dishes!"
	prereq_ids = list("robotics")
	design_ids = list("borg_upgrade_diamonddrill", "borg_upgrade_trashofholding", "borg_upgrade_advancedmop")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/neural_programming
	id = "neural_programming"
	display_name = "Neural Programming"
	description = "Study into networks of processing units that mimic our brains."
	prereq_ids = list("biotech", "datatheory")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mmi
	id = "mmi"
	display_name = "Man Machine Interface"
	description = "A slightly Frankensteinian device that allows human brains to interface natively with software APIs."
	prereq_ids = list("neural_programming")
	design_ids = list("mmi")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/posibrain
	id = "posibrain"
	display_name = "Positronic Brain"
	description = "Applied usage of neural technology allowing for autonomous AI units based on special metallic cubes with conductive and processing circuits."
	prereq_ids = list("neural_programming", "mmi")
	design_ids = list("mmi_posi")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/cyborg
	id = "cyborg"
	display_name = "Cyborg Construction"
	description = "Sapient robots with preloaded tool modules and programmable laws."
	prereq_ids = list("mmi", "robotics")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 5000
	design_ids = list("robocontrol", "sflash", "borg_suit", "borg_head", "borg_chest", "borg_r_arm", "borg_l_arm", "borg_r_leg", "borg_l_leg", "borgupload",
	"cyborgrecharger", "borg_upgrade_restart", "borg_upgrade_rename")

/datum/techweb_node/cyborg_upg_util
	id = "cyborg_upg_util"
	display_name = "Cyborg Upgrades: Utility"
	description = "Utility upgrades for cybogs."
	prereq_ids = list("engineering", "cyborg")
	design_ids = list("borg_upgrade_holding", "borg_upgrade_lavaproof", "borg_upgrade_thrusters", "borg_upgrade_selfrepair", "borg_upgrade_expand", "borg_upgrade_rped")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 5000

/datum/techweb_node/cyborg_upg_med
	id = "cyborg_upg_med"
	display_name = "Cyborg Upgrades: Medical"
	description = "Medical upgrades for cyborgs."
	prereq_ids = list("adv_biotech", "cyborg")
	design_ids = list("borg_upgrade_defibrillator", "borg_upgrade_piercinghypospray", "borg_upgrade_highstrengthsynthesiser", "borg_upgrade_expandedsynthesiser", "borg_upgrade_pinpointer")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 5000

/datum/techweb_node/cyborg_upg_combat
	id = "cyborg_upg_combat"
	display_name = "Cyborg Upgrades: Combat"
	description = "Military grade upgrades for cyborgs."
	prereq_ids = list("adv_robotics", "adv_engi" , "weaponry")
	design_ids = list("borg_upgrade_vtec", "borg_upgrade_disablercooler")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/datum/techweb_node/ai
	id = "ai"
	display_name = "Artificial Intelligence"
	description = "AI unit research."
	prereq_ids = list("robotics", "posibrain")
	design_ids = list("aifixer", "aicore", "safeguard_module", "onehuman_module", "protectstation_module", "quarantine_module", "oxygen_module", "freeform_module",
	"reset_module", "purge_module", "remove_module", "freeformcore_module", "asimov_module", "paladin_module", "tyrant_module", "corporate_module",
	"default_module", "borg_ai_control", "mecha_tracking_ai_control", "aiupload", "intellicard")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/////////////////////////EMP tech/////////////////////////
/datum/techweb_node/emp_basic //EMP tech for some reason
	id = "emp_basic"
	display_name = "Electromagnetic Theory"
	description = "Study into usage of frequencies in the electromagnetic spectrum."
	prereq_ids = list("base")
	design_ids = list("holosign", "holosignsec", "holosignengi", "holosignatmos", "inducer", "tray_goggles", "holopad")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/emp_adv
	id = "emp_adv"
	display_name = "Advanced Electromagnetic Theory"
	description = "Determining whether reversing the polarity will actually help in a given situation."
	prereq_ids = list("emp_basic")
	design_ids = list("ultra_micro_laser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
	export_price = 5000

/datum/techweb_node/emp_super
	id = "emp_super"
	display_name = "Quantum Electromagnetic Technology"	//bs
	description = "Even better electromagnetic technology."
	prereq_ids = list("emp_adv")
	design_ids = list("quadultra_micro_laser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
	export_price = 5000

/////////////////////////Clown tech/////////////////////////
/datum/techweb_node/clown
	id = "clown"
	display_name = "Clown Technology"
	description = "Honk?!"
	prereq_ids = list("base")
	design_ids = list("air_horn", "honker_main", "honker_peri", "honker_targ", "honk_chassis", "honk_head", "honk_torso", "honk_left_arm", "honk_right_arm",
	"honk_left_leg", "honk_right_leg", "mech_banana_mortar", "mech_mousetrap_mortar", "mech_honker", "mech_punching_face", "implant_trombone", "borg_transform_clown")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

////////////////////////Computer tech////////////////////////
/datum/techweb_node/comptech
	id = "comptech"
	display_name = "Computer Consoles"
	description = "Computers and how they work."
	prereq_ids = list("datatheory")
	design_ids = list("cargo", "cargorequest", "libraryconsole", "mining", "crewconsole", "rdcamera", "comconsole", "idcardconsole", "seccamera")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 5000

/datum/techweb_node/computer_hardware_basic				//Modular computers are shitty and nearly useless so until someone makes them actually useful this can be easy to get.
	id = "computer_hardware_basic"
	display_name = "Computer Hardware"
	description = "How computer hardware are made."
	prereq_ids = list("comptech")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)  //they are really shitty
	export_price = 2000
	design_ids = list("hdd_basic", "hdd_advanced", "hdd_super", "hdd_cluster", "ssd_small", "ssd_micro", "netcard_basic", "netcard_advanced", "netcard_wired",
	"portadrive_basic", "portadrive_advanced", "portadrive_super", "cardslot", "aislot", "miniprinter", "APClink", "bat_control", "bat_normal", "bat_advanced",
	"bat_super", "bat_micro", "bat_nano", "cpu_normal", "pcpu_normal", "cpu_small", "pcpu_small")

/datum/techweb_node/computer_board_gaming
	id = "computer_board_gaming"
	display_name = "Arcade Games"
	description = "For the slackers on the station."
	prereq_ids = list("comptech")
	design_ids = list("arcade_battle", "arcade_orion", "slotmachine")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 2000

/datum/techweb_node/comp_recordkeeping
	id = "comp_recordkeeping"
	display_name = "Computerized Recordkeeping"
	description = "Organized record databases and how they're used."
	prereq_ids = list("comptech")
	design_ids = list("secdata", "med_data", "prisonmanage", "vendor", "automated_announcement")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 2000

/datum/techweb_node/telecomms
	id = "telecomms"
	display_name = "Telecommunications Technology"
	description = "Subspace transmission technology for near-instant communications devices."
	prereq_ids = list("comptech", "bluespace_basic")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000
	design_ids = list("s-receiver", "s-bus", "s-broadcaster", "s-processor", "s-hub", "s-server", "s-relay", "comm_monitor", "comm_server",
	"s-ansible", "s-filter", "s-amplifier", "ntnet_relay", "s-treatment", "s-analyzer", "s-crystal", "s-transmitter")

/datum/techweb_node/integrated_HUDs
	id = "integrated_HUDs"
	display_name = "Integrated HUDs"
	description = "The usefulness of computerized records, projected straight onto your eyepiece!"
	prereq_ids = list("comp_recordkeeping", "emp_basic")
	design_ids = list("health_hud", "security_hud", "diagnostic_hud", "scigoggles")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1500)
	export_price = 5000

/datum/techweb_node/NVGtech
	id = "NVGtech"
	display_name = "Night Vision Technology"
	description = "Allows seeing in the dark without actual light!"
	prereq_ids = list("integrated_HUDs", "adv_engi", "emp_adv")
	design_ids = list("health_hud_night", "security_hud_night", "diagnostic_hud_night", "night_visision_goggles", "nvgmesons")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

////////////////////////Medical////////////////////////
/datum/techweb_node/cloning
	id = "cloning"
	display_name = "Genetic Engineering"
	description = "We have the technology to make him."
	prereq_ids = list("biotech")
	design_ids = list("clonecontrol", "clonepod", "clonescanner", "scan_console", "cloning_disk")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/cryotech
	id = "cryotech"
	display_name = "Cryostasis Technology"
	description = "Smart freezing of objects to preserve them!"
	prereq_ids = list("adv_engi", "biotech")
	design_ids = list("splitbeaker", "noreactsyringe", "cryotube", "cryo_Grenade")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2000)
	export_price = 4000

/datum/techweb_node/subdermal_implants
	id = "subdermal_implants"
	display_name = "Subdermal Implants"
	description = "Electronic implants buried beneath the skin."
	prereq_ids = list("biotech")
	design_ids = list("implanter", "implantcase", "implant_chem", "implant_tracking")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/cyber_organs
	id = "cyber_organs"
	display_name = "Cybernetic Organs"
	description = "We have the technology to rebuild him."
	prereq_ids = list("adv_biotech", "cyborg")
	design_ids = list("cybernetic_heart", "cybernetic_liver", "cybernetic_liver_u", "cybernetic_lungs")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/cyber_implants
	id = "cyber_implants"
	display_name = "Cybernetic Implants"
	description = "Electronic implants that improve humans."
	prereq_ids = list("adv_biotech", "cyborg", "adv_datatheory")
	design_ids = list("ci-nutriment", "ci-breather", "ci-gloweyes", "ci-welding", "ci-medhud", "ci-sechud")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_cyber_implants
	id = "adv_cyber_implants"
	display_name = "Advanced Cybernetic Implants"
	description = "Upgraded and more powerful cybernetic implants."
	prereq_ids = list("neural_programming", "cyber_implants","integrated_HUDs")
	design_ids = list("ci-toolset", "ci-surgery", "ci-reviver", "ci-nutrimentplus")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/combat_cyber_implants
	id = "combat_cyber_implants"
	display_name = "Combat Cybernetic Implants"
	description = "Military grade combat implants to improve performance."
	prereq_ids = list("adv_cyber_implants","weaponry","NVGtech","high_efficiency")
	design_ids = list("ci-xray", "ci-thermals", "ci-antidrop", "ci-antistun", "ci-thrusters")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

////////////////////////Tools////////////////////////
/datum/techweb_node/basic_mining
	id = "basic_mining"
	display_name = "Mining Technology"
	description = "Better than Efficiency V."
	prereq_ids = list("engineering", "basic_plasma")
	design_ids = list("drill", "superresonator", "triggermod", "damagemod", "cooldownmod", "rangemod", "ore_redemption", "mining_equipment_vendor", "cargoexpress", "plasmacutter")//e a r l y    g a  m e)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_mining
	id = "adv_mining"
	display_name = "Advanced Mining Technology"
	description = "Efficiency Level 127"	//dumb mc references
	prereq_ids = list("basic_mining", "adv_engi", "adv_power", "adv_plasma")
	design_ids = list("drill_diamond", "jackhammer", "hypermod", "plasmacutter_adv")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/janitor
	id = "janitor"
	display_name = "Advanced Sanitation Technology"
	description = "Clean things better, faster, stronger, and harder!"
	prereq_ids = list("adv_engi")
	design_ids = list("advmop", "buffer", "blutrash", "light_replacer")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/botany
	id = "botany"
	display_name = "Botanical Engineering"
	description = "Botanical tools"
	prereq_ids = list("adv_engi", "biotech")
	design_ids = list("diskplantgene", "portaseeder", "plantgenes", "flora_gun", "hydro_tray", "biogenerator", "seed_extractor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/exp_tools
	id = "exp_tools"
	display_name = "Experimental Tools"
	description = "Highly advanced construction tools."
	design_ids = list("exwelder", "jawsoflife", "handdrill")
	prereq_ids = list("adv_engi")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/exp_flight
	id = "exp_flight"
	display_name = "Experimental Flight Equipment"
	description = "Highly advanced construction tools."
	design_ids = list("flightshoes", "flightpack", "flightsuit")
	prereq_ids = list("adv_engi","integrated_HUDs", "adv_power" , "high_efficiency")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 5000

/////////////////////////weaponry tech/////////////////////////
/datum/techweb_node/weaponry
	id = "weaponry"
	display_name = "Weapon Development Technology"
	description = "Our researchers have found new to weaponize just about everything now."
	prereq_ids = list("engineering")
	design_ids = list("pin_testing", "tele_shield")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

/datum/techweb_node/adv_weaponry
	id = "adv_weaponry"
	display_name = "Advanced Weapon Development Technology"
	description = "Our weapons are breaking the rules of reality by now."
	prereq_ids = list("adv_engi", "weaponry")
	design_ids = list("pin_loyalty")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000

/datum/techweb_node/electric_weapons
	id = "electronic_weapons"
	display_name = "Electric Weapons"
	description = "Weapons using electric technology"
	prereq_ids = list("weaponry", "adv_power"  , "emp_basic")
	design_ids = list("stunrevolver", "stunshell",  "ioncarbine")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/radioactive_weapons
	id = "radioactive_weapons"
	display_name = "Radioactive Weaponry"
	description = "Weapons using radioactive technology."
	prereq_ids = list("adv_engi", "adv_weaponry")
	design_ids = list("nuclear_gun")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/medical_weapons
	id = "medical_weapons"
	display_name = "Medical Weaponry"
	description = "Weapons using medical technology."
	prereq_ids = list("adv_biotech", "adv_weaponry")
	design_ids = list("rapidsyringe", "shotgundartcryostatis")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/beam_weapons
	id = "beam_weapons"
	display_name = "Beam Weaponry"
	description = "Various basic beam weapons"
	prereq_ids = list("adv_weaponry")
	design_ids = list("temp_gun", "xray_laser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_beam_weapons
	id = "adv_beam_weapons"
	display_name = "Advanced Beam Weaponry"
	description = "Various advanced beam weapons"
	prereq_ids = list("beam_weapons")
	design_ids = list("beamrifle")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/explosive_weapons
	id = "explosive_weapons"
	display_name = "Explosive & Pyrotechnical Weaponry"
	description = "If the light stuff just won't do it."
	prereq_ids = list("adv_weaponry")
	design_ids = list("large_Grenade", "pyro_Grenade", "adv_Grenade")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/ballistic_weapons
	id = "ballistic_weapons"
	display_name = "Ballistic Weaponry"
	description = "This isn't research.. This is reverse-engineering!"
	prereq_ids = list("weaponry")
	design_ids = list("mag_oldsmg", "mag_oldsmg_ap", "mag_oldsmg_ic")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/tech_shell
	id = "tech_shell"
	display_name = "Technological Shells"
	description = "They're more technological than regular shot."
	prereq_ids = list("adv_weaponry")
	design_ids = list("techshotshell")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/gravity_gun
	id = "gravity_gun"
	display_name = "One-point Bluespace-gravitational Manipulator"
	description = "Fancy wording for gravity gun."
	prereq_ids = list("adv_weaponry", "adv_bluespace")
	design_ids = list("gravitygun", "mech_gravcatapult")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

////////////////////////mech technology////////////////////////
/datum/techweb_node/mech
	id = "mecha"
	display_name = "Mechanical Exosuits"
	description = "Mechanized exosuits that are several magnitudes stronger and more powerful than the average human."
	prereq_ids = list("robotics", "adv_engi")
	design_ids = list("mecha_tracking", "mechacontrol", "mechapower", "mech_recharger", "ripley_chassis", "firefighter_chassis", "ripley_torso", "ripley_left_arm", "ripley_right_arm", "ripley_left_leg", "ripley_right_leg",
	"ripley_main", "ripley_peri", "mech_hydraulic_clamp")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_mecha
	id = "adv_mecha"
	display_name = "Advanced Exosuits"
	description = "For when you just aren't Gundam enough."
	prereq_ids = list("adv_robotics", "mecha")
	design_ids = list("mech_repair_droid")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/odysseus
	id = "mecha_odysseus"
	display_name = "EXOSUIT: Odysseus"
	description = "Odysseus exosuit designs"
	prereq_ids = list("mecha")
	design_ids = list("odysseus_chassis", "odysseus_torso", "odysseus_head", "odysseus_left_arm", "odysseus_right_arm" ,"odysseus_left_leg", "odysseus_right_leg",
	"odysseus_main", "odysseus_peri")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/gygax
	id = "mech_gygax"
	display_name = "EXOSUIT: Gygax"
	description = "Gygax exosuit designs"
	prereq_ids = list("adv_mecha", "weaponry")
	design_ids = list("gygax_chassis", "gygax_torso", "gygax_head", "gygax_left_arm", "gygax_right_arm", "gygax_left_leg", "gygax_right_leg", "gygax_main",
	"gygax_peri", "gygax_targ", "gygax_armor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/durand
	id = "mech_durand"
	display_name = "EXOSUIT: Durand"
	description = "Durand exosuit designs"
	prereq_ids = list("adv_mecha", "adv_weaponry")
	design_ids = list("durand_chassis", "durand_torso", "durand_head", "durand_left_arm", "durand_right_arm", "durand_left_leg", "durand_right_leg", "durand_main",
	"durand_peri", "durand_targ", "durand_armor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/phazon
	id = "mecha_phazon"
	display_name = "EXOSUIT: Phazon"
	description = "Phazon exosuit designs"
	prereq_ids = list("adv_mecha", "weaponry" , "adv_bluespace")
	design_ids = list("phazon_chassis", "phazon_torso", "phazon_head", "phazon_left_arm", "phazon_right_arm", "phazon_left_leg", "phazon_right_leg", "phazon_main",
	"phazon_peri", "phazon_targ", "phazon_armor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_tools
	id = "mech_tools"
	display_name = "Basic Exosuit Equipment"
	description = "Various tools fit for basic mech units"
	prereq_ids = list("mecha")
	design_ids = list("mech_drill", "mech_mscanner", "mech_extinguisher", "mech_cable_layer")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/adv_mecha_tools
	id = "adv_mecha_tools"
	display_name = "Advanced Exosuit Equipment"
	description = "Tools for high level mech suits"
	prereq_ids = list("adv_mecha", "mech_tools")
	design_ids = list("mech_rcd")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/med_mech_tools
	id = "med_mech_tools"
	display_name = "Medical Exosuit Equipment"
	description = "Tools for high level mech suits"
	prereq_ids = list("mecha", "adv_biotech", "mech_tools")
	design_ids = list("mech_sleeper", "mech_syringe_gun", "mech_medi_beam")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_modules
	id = "adv_mecha_modules"
	display_name = "Simple Exosuit Modules"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("adv_mecha", "bluespace_power")
	design_ids = list("mech_energy_relay", "mech_ccw_armor", "mech_proj_armor", "mech_generator_nuclear")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_scattershot
	id = "mecha_tools"
	display_name = "Exosuit Weapon (LBX AC 10 \"Scattershot\")"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "ballistic_weapons")
	design_ids = list("mech_scattershot")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_carbine
	id = "mech_carbine"
	display_name = "Exosuit Weapon (FNX-99 \"Hades\" Carbine)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "ballistic_weapons")
	design_ids = list("mech_carbine")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_ion
	id = "mmech_ion"
	display_name = "Exosuit Weapon (MKIV Ion Heavy Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "electronic_weapons", "emp_adv")
	design_ids = list("mech_ion")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_tesla
	id = "mech_tesla"
	display_name = "Exosuit Weapon (MKI Tesla Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "electronic_weapons", "adv_power")
	design_ids = list("mech_tesla")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_laser
	id = "mech_laser"
	display_name = "Exosuit Weapon (CH-PS \"Immolator\" Laser)"
	description = "A basic piece of mech weaponry"
	prereq_ids = list("mecha", "beam_weapons")
	design_ids = list("mech_laser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_laser_heavy
	id = "mech_laser_heavy"
	display_name = "Exosuit Weapon (CH-LC \"Solaris\" Laser Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "adv_beam_weapons")
	design_ids = list("mech_laser_heavy")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_grenade_launcher
	id = "mech_grenade_launcher"
	display_name = "Exosuit Weapon (SGL-6 Grenade Launcher)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "explosive_weapons")
	design_ids = list("mech_grenade_launcher")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_missile_rack
	id = "mech_missile_rack"
	display_name = "Exosuit Weapon (SRM-8 Missile Rack)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "explosive_weapons")
	design_ids = list("mech_missile_rack")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/clusterbang_launcher
	id = "clusterbang_launcher"
	display_name = "Exosuit Module (SOB-3 Clusterbang Launcher)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "explosive_weapons")
	design_ids = list("clusterbang_launcher")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_teleporter
	id = "mech_teleporter"
	display_name = "Exosuit Module (Teleporter Module)"
	description = "An advanced piece of mech Equipment"
	prereq_ids = list("mech_tools", "adv_bluespace")
	design_ids = list("mech_teleporter")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_wormhole_gen
	id = "mech_wormhole_gen"
	display_name = "Exosuit Module (Localized Wormhole Generator)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "mech_tools", "adv_bluespace")
	design_ids = list("mech_wormhole_gen")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_taser
	id = "mech_taser"
	display_name =  "Exosuit Weapon (PBT \"Pacifier\" Mounted Taser)"
	description = "A basic piece of mech weaponry"
	prereq_ids = list("mecha", "electronic_weapons")
	design_ids = list("mech_taser")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_lmg
	id = "mech_lmg"
	display_name = "Exosuit Weapon (\"Ultra AC 2\" LMG)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "ballistic_weapons")
	design_ids = list("mech_lmg")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/techweb_node/mech_diamond_drill
	id = "mech_diamond_drill"
	display_name =  "Exosuit Diamond Drill"
	description = "A diamond drill fit for a large exosuit"
	prereq_ids = list("mecha", "adv_mining")
	design_ids = list("mech_diamond_drill")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

////////////////////////Alien technology////////////////////////
/datum/techweb_node/alientech //AYYYYYYYYLMAOO tech
	id = "alientech"
	display_name = "Alien Technology"
	description = "Things used by the greys."
	prereq_ids = list("biotech","engineering")
	boost_item_paths = list(/obj/item/gun/energy/alien, /obj/item/scalpel/alien, /obj/item/hemostat/alien, /obj/item/retractor/alien, /obj/item/circular_saw/alien,
	/obj/item/cautery/alien, /obj/item/surgicaldrill/alien, /obj/item/screwdriver/abductor, /obj/item/wrench/abductor, /obj/item/crowbar/abductor, /obj/item/multitool/abductor,
	/obj/item/weldingtool/abductor, /obj/item/wirecutters/abductor, /obj/item/circuitboard/machine/abductor, /obj/item/abductor_baton, /obj/item/abductor)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 20000
	hidden = TRUE
	design_ids = list("alienalloy")

/datum/techweb_node/alien_bio
	id = "alien_bio"
	display_name = "Alien Biological Tools"
	description = "Advanced biological tools."
	prereq_ids = list("alientech", "adv_biotech")
	design_ids = list("alien_scalpel", "alien_hemostat", "alien_retractor", "alien_saw", "alien_drill", "alien_cautery")
	boost_item_paths = list(/obj/item/gun/energy/alien, /obj/item/scalpel/alien, /obj/item/hemostat/alien, /obj/item/retractor/alien, /obj/item/circular_saw/alien,
	/obj/item/cautery/alien, /obj/item/surgicaldrill/alien, /obj/item/screwdriver/abductor, /obj/item/wrench/abductor, /obj/item/crowbar/abductor, /obj/item/multitool/abductor,
	/obj/item/weldingtool/abductor, /obj/item/wirecutters/abductor, /obj/item/circuitboard/machine/abductor, /obj/item/abductor_baton, /obj/item/abductor)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 20000
	hidden = TRUE

/datum/techweb_node/alien_engi
	id = "alien_engi"
	display_name = "Alien Engineering"
	description = "Alien engineering tools"
	prereq_ids = list("alientech", "adv_engi")
	design_ids = list("alien_wrench", "alien_wirecutters", "alien_screwdriver", "alien_crowbar", "alien_welder", "alien_multitool")
	boost_item_paths = list(/obj/item/screwdriver/abductor, /obj/item/wrench/abductor, /obj/item/crowbar/abductor, /obj/item/multitool/abductor,
	/obj/item/weldingtool/abductor, /obj/item/wirecutters/abductor, /obj/item/circuitboard/machine/abductor, /obj/item/abductor_baton, /obj/item/abductor)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 20000
	hidden = TRUE

/datum/techweb_node/syndicate_basic
	id = "syndicate_basic"
	display_name = "Illegal Technology"
	description = "Dangerous research used to create dangerous objects."
	prereq_ids = list("adv_engi", "adv_weaponry", "explosive_weapons")
	design_ids = list("decloner", "borg_syndicate_module", "suppressor", "largecrossbow", "donksofttoyvendor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000
	hidden = TRUE

/datum/techweb_node/syndicate_basic/New()		//Crappy way of making syndicate gear decon supported until there's another way.
	. = ..()
	boost_item_paths = list()
	for(var/path in GLOB.uplink_items)
		var/datum/uplink_item/UI = new path
		if(!UI.item)
			continue
		boost_item_paths |= UI.item	//allows deconning to unlock.

//Helpers for debugging/balancing the techweb in its entirety!
/proc/total_techweb_exports()
	var/list/datum/techweb_node/processing = list()
	for(var/i in subtypesof(/datum/techweb_node))
		processing += new i
	. = 0
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		. += TN.export_price

/proc/total_techweb_points()
	var/list/datum/techweb_node/processing = list()
	for(var/i in subtypesof(/datum/techweb_node))
		processing += new i
	var/datum/techweb/TW = new
	TW.research_points = list()
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		TW.add_point_list(TN.research_costs)
	return TW.research_points

/proc/total_techweb_points_printout()
	var/list/datum/techweb_node/processing = list()
	for(var/i in subtypesof(/datum/techweb_node))
		processing += new i
	var/datum/techweb/TW = new
	TW.research_points = list()
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		TW.add_point_list(TN.research_costs)
	return TW.printout_points()
