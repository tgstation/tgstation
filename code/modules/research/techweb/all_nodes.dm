
//Current rate: 135000 research points in 90 minutes
//Current cargo price: 500000 points for fullmaxed R&D.

//Base Node
/datum/techweb_node/base
	id = "base"
	starting_node = TRUE
	display_name = "Basic Research Technology"
	description = "NT default research technologies."
	design_ids = list("basic_matter_bin", "basic_cell" "basic_scanning", "basic_capacitor", "basic_micro_laser", "micro_mani",
	"destructive_analyzer", "protolathe", "circuit_imprinter", "experimentor", "rdconsole", "design_disk", "tech_disk", "rdserver", "rdservercontrol", "mechfab",
	"space_heater")			//Default research tech, prevents bricking

/datum/techweb_node/biotech
	id = "biotech"
	display_name = "Biological Technology"
	description = "What makes us tick."	//the MC, silly!
	prereq_ids = list("base")
	design_ids = list("mass_spectrometer")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/mmi
	id = "mmi"
	display_name = "Man Machine Interface"
	description = "A slightly Frankensteinian device that allows human brains to interface natively with software APIs."
	prereq_ids = list("biotech", "neural_programming")
	design_ids = list("mmi")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/posibrain
	id = "posibrain"
	display_name = "Positronic Brain"
	description = "Applied usage of neural technology allowing for autonomous AI units based on special metallic cubes with conductive and processing circuits."
	prereq_ids = list("mmi", "neural_programming")
	design_ids = list("mmi_posi")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/datatheory
	id = "datatheory"
	display_name = "Data Theory"
	description = "Big Data, in space!"
	prereq_ids = list("base")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/neural_programming
	id = "neural_programming"
	display_name = "Neural Programming"
	description = "Study into networks of processing units that mimic our brains."
	prereq_ids = list("biotech", "datatheory")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/computer_hardware_basic				//Modular computers are shitty and nearly useless so until someone makes them actually useful this can be easy to get.
	id = "computer_hardware_basic"
	display_name = "Computer Hardware"
	description = "How computer hardware are made."
	prereq_ids = list("datatheory")
	research_cost = 5000
	export_price = 5000
	design_ids = list("hdd_basic", "hdd_advanced", "hdd_super", "hdd_cluster", "ssd_small", "ssd_micro", "netcard_basic", "netcard_advanced", "netcard_wired",
	"portadrive_basic", "portadrive_advanced", "portadrive_super", "cardslot", "aislot", "miniprinter", "APClink", "bat_control", "bat_normal", "bat_advanced",
	"bat_super", "bat_micro", "bat_nano", "cpu_normal", "pcpu_normal", "cpu_small", "pcpu_small")

/datum/techweb_node/comptech
	id = "comptech"
	display_name = "Computer Consoles"
	description = "Computers and how they work."
	prereq_ids = list("datatheory")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/computer_board_gaming
	id = "computer_board_gaming"
	display_name = "Arcade Games"
	description = "For the slackers on the station."
	prereq_ids = list("datatheory", "comptech")
	design_ids = list("arcade_battle", "arcade_orion", "slotmachine")
	research_cost = 5000
	export_price =5000

/datum/techweb_node/bluespace_basic
	id = "bluespace_basic"
	display_name = "Basic Bluespace Theory"
	description = "Basic studies into the mysterious alternate dimension known as bluespace."
	prereq_ids = list("base")
	design_ids = list("beacon")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/telecomms
	id = "telecomms"
	display_name = "Telecommunications Technology"
	description = "Subspace transmission technology for near-instant communications devices."
	prereq_ids = list("datatheory", "bluespace_basic")
	research_cost = 5000
	export_price = 5000
	design_ids = list("s-reciever", "s-bus", "s-broadcaster", "s-processor", "s-hub", "s-server", "s-relay", "comm_monitor", "comm_server",
	"s-ansible", "s-filter", "s-amplifier", "s-treatment", "s-analyzer", "s-crystal", "s-transmitter")

/datum/techweb_node/comp_recordkeeping
	id = "comp_recordkeeping"
	display_name = "Computerized Recordkeeping"
	description = "Organized record databases and how they're used."
	prereq_ids = list("comptech")
	design_ids = list("secdata", "meddata")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/alientech
	id = "alientech"
	display_name = "Alien Technology"
	description = "Things used by the greys."
	prereq_ids = list("base")
	research_cost = 5000
	export_price = 5000
	hidden = TRUE
	design_ids = list("alienalloy")

/datum/techweb_node/alien_bio
	id = "alien_bio"
	display_name = "Alien Biological Tools"
	description = "Advanced biological tools."
	prereq_ids = list("alientech", "biotech")
	design_ids = list("alien_scalpel", "alien_hemostat", "alien_retractor", "alien_saw", "alien_drill", "alien_cautery")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/alien_engi
	id = "alien_engi"
	display_name = "Alien Engineering"
	description = "Alien engineering tools"
	prereq_ids = list("alientech", "adv_engi")
	design_ids = list("alien_wrench", "alien_wirecutters", "alien_screwdriver", "alien_crowbar", "alien_welder", "alien_multitool")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/industrial_engineering
	id = "industrial_engineering"
	description = "Modern engineering techonlogy."
	display_name = "Industrial Engineering"
	prereq_ids = list("base")
	design_ids = list("solarcontrol", "power_monitor", "rped", "pacman", "adv_capacitor" "adv_scanning", "emitter" "high_cell" "adv_matter_bin",
	"atmosalerts", "atmos_control", "high_micro_laser", "nano_mani", "weldingmask", "mesons", "thermomachine")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/adv_engi
	id = "adv_engi"
	description = "Advanced engineering research"
	display_name = "Advanced Engineering"
	prereq_ids = list("industrial_engineering", "emp_basic")
	design_ids = list("enginegoggles", "diagnostic_hud", "magboots")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/practical_bluespace
	id = "practical_bluespace"
	display_name = "Applied Bluespace Research"
	description = "Using bluespace to make things faster and better."
	prereq_ids = list("bluespace_basic", "industrial_engineering")
	design_ids = list("bs_rped", "telesci_gps", "bluespacebeaker", "bluespacesyringe", "bluespacebodybag", "phasic_scanning")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/emp_basic
	id = "emp_basic"
	display_name = "Electromagnetic Theory"
	description = "Study into usage of frequencies in the electromagnetic spectrum."
	prereq_ids = list("base")
	design_ids = list("holosign", "inducer", "tray_goggles")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/integrated_HUDs
	id = "integrated_HUDs"
	display_name = "Integrated HUDs"
	description = "The usefulness of computerized records, projected straight onto your eyepiece!"
	prereq_ids = list("comp_recordkeeping", "emp_basic", "datatheory")
	design_ids = list("health_hud", "security+hud", "diagnostic_hud", "scigoggles")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/NVGtech
	id = "NVGtech"
	display_name = "Night Vision Technology"
	description = "Allows seeing in the dark without actual light!"
	prereq_ids = list("integrated_HUDs", "adv_engi", "emp_adv")
	design_ids = list("health_hud_night", "security_hud_night", "diagnostic_hud_night", "night_visision_goggles", "nvgmesons")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/cryotech
	id = "cryotech"
	display_name = "Cryostasis Technology"
	description = "Smart freezing of objects to preserve them!"
	prereq_ids = list("adv_engi", "emp_basic", "biotech")
	design_ids = list("splitbeaker", "noreactsyringe", "cryotube", "cryoGrenade")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/clown
	id = "clown"
	display_name = "Clown Technology"
	description = "Honk?!"
	prereq_ids = list("base")
	design_ids = list("air_horn", "honker_main", "honker_peri", "honker_targ", "honk_chassis", "honk_head", "honk_torso", "honk_left_arm", "honk_right_arm",
	"honk_left_leg", "honk_right_leg", "mech_banana_mortar", "mech_mousetrap_mortar", "mech_honker", "mech_punch_face", "implant_trombone")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/janitor
	id = "janitor"
	display_name = "Advanced Sanitation Technology"
	description = "Clean things better, faster, stronger, and harder!"
	prereq_ids = list("adv_engi")
	design_ids = list("advmop", "buffer", "blutrash", "light_replacer")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/robotics
	id = "robotics"
	display_name = "Basic Robotics Research"
	description = "Programmable machines that make our lives lazier."
	prereq_ids = list("base")
	design_ids = list("paicard")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/cyborg
	id = "cyborg"
	display_name = "Cyborg Construction"
	description = "Sapient robots with preloaded tool modules and programmable laws."
	prereq_ids = list("mmi", "robotics")
	research_cost = 5000
	export_price = 5000
	design_ids = list("robocontrol", "sflash", "borg_suit", "borg_head", "borg_chest", "borg_r_arm", "borg_l_arm", "borg_r_leg", "borg_l_leg", "borgupload",
	"cyborgrecharger")

/datum/techweb_node/exp_tools
	id = "exp_tools"
	display_name = "Experimental Tools"
	description = "Highly advanced construction tools."
	design_ids = list("ex_welder", "jawsoflife", "handdrill")
	prereq_ids = list("adv_engi")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/mecha
	id = "mecha"
	display_name = "Mechanical Exosuits"
	description = "Mechanized exosuits that are several magnitudes stronger and more powerful than the average human."
	prereq_ids = list("robotics", "adv_engi")
	design_ids = list("mecha_tracking", "mechacontrol", "mechapower", "mech_recharger")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/ripley
	id = "mecha_ripley"
	display_name = "EXOSUIT: Ripley APLU"
	description = "Ripley APLU exosuit designs"
	prereq_ids = list("mecha")
	design_ids = list("ripley_chassis", "firefighter_chassis", "ripley_torso", "ripley_left_arm", "ripley_right_arm", "ripley_left_leg", "ripley_right_leg",
	"ripley_main", "ripley_peri")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/odysseus
	id = "mecha_odysseus"
	display_name = "EXOSUIT: Odysseus"
	description = "Odysseus exosuit designs"
	prereq_ids = list("mecha")
	design_ids = list("odysseus_chassis", "odysseus_torso", "odysseus_head", "oddyesus_left_arm", "odysseus_right_arm" ,"odysseus_left_leg", "odysseus_right_leg",
	"odysseus_main", "odysseus_peri")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/gygax
	id = "mecha_gygax"
	display_name = "EXOSUIT: Gygax"
	description = "Gygax exosuit designs"
	prereq_ids = list("mecha")
	design_ids = list("gygax_chassis", "gygax_torso", "gygax_head", "gygax_left_arm", "gygax_right_arm", "gygax_left_leg", "gygax_right_leg", "gygax_main",
	"gygax_peri", "gygax_targ", "gygax_armor")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/durand
	id = "mecha_durand"
	display_name = "EXOSUIT: Durand"
	description = "Durand exosuit designs"
	prereq_ids = list("mecha")
	design_ids = list("durand_chassis", "durand_torso", "durand_head", "durand_left_arm", "durand_right_arm", "durand_left_leg", "durand_right_leg", "durand_main",
	"durand_peri", "durand_target", "durand_armor")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/phazon
	id = "mecha_phazon"
	display_name = "EXOSUIT: Phazon"
	description = "Phazon exosuit designs"
	prereq_ids = list("mecha")
	design_ids = list("phazon_chassis", "phazon_torso", "phazon_head", "phazon_left_arm", "phazon_right_arm", "phazon_left_leg", "phazon_right_leg", "phazon_main",
	"phazon_peri", "phazon_target", "phazon_armor")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/ai
	id = "ai"
	display_name = "Artificial Intelligence"
	description = "AI unit research."
	prereq_ids = list("robotics", "neural_programming")
	design_ids = list("aicore", "safeguard_module", "onehuman_module", "protectstation_module", "quarantine_module", "oxygen_module", "freeform_module",
	"reset_module", "purge_module", "remove_module", "freeformcore_module", "asimov_module", "paladin_module", "tyrant_module", "corporate_module",
	"default_module", "borg_ai_control", "mecha_tracking_ai_control", "ai_upload", "intellicard"
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/cloning
	id = "cloning"
	display_name = "Cloning Technology"
	description = "We have the technology to remake him.")
	prereq_ids = list("biotech")
	design_ids = list("clonecontrol", "clonepod", "clonescanner")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/subdermal_implants
	id = "subdermal_implants"
	display_name = "Subdermal Implants"
	description = "Electronic implants buried beneath the skin."
	prereq_ids = list("biotech")
	design_ids = list("implanter", "implantcase", "implant_chem", "implant_tracking")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/adv_biotech
	id = "adv_biotech"
	display_name = "Advanced Biotechnology"
	description = "Advanced Biotechnology"
	prereq_ids = list("biotech")
	design_ids = list("piercesyringe", "adv_mass_spectrometer", "plasmarefiller")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/botany
	id = "botany"
	display_name = "Botanical Engineering"
	description = "Botanical tools"
	prereq_ids = list("biotech", "adv_engi")
	design_ids = list("diskplantgene", "portaseeder", "plantgenes", "flora_gun", "hydro_tray", "biogenerator")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/high_efficiency
	id = "high_efficiency"
	display_name = "High Efficiency Parts"
	description = "High Efficiency Parts"
	prereq_ids = list("industrial_engineering", "datatheory")
	design_ids = list("pico_mani", "super_matter_bin")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/adv_bluespace
	id = "adv_bluespace"
	display_name = "Advanced Bluespace Research"
	description = "Deeper understanding of how the Bluespace dimension works")
	prereq_ids = list("practical_bluespace", "high_efficiency")
	design_ids = list("bluespace_matter_bin", "femto_mani", "triphasic_scanning", "tele_station", "tele_hub", "quantumpad", "launchpad", "launchpad_console",
	"teleconsole")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/adv_power
	id = "adv_power"
	display_name = "Advanced Power Manipulation"
	description = "How to get more zap."
	prereq_ids = list("industrial_engineering")
	design_ids = list("smes", "super_cell", "hyper_cell", "super_capacitor", "superpacman", "mrspacman", "power_turbine", "power_turbine_console", "power_compressor")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/bluespace_power
	id = "bluespace_power"
	display_name = "Bluespace Power Technology"
	description = "Even more powerful.. power!"
	prereq_ids = list("adv_power", "adv_bluespace")
	design_ids = list("bluespace_cell", "quadratic_capcitor")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/emp_adv
	id = "emp_adv"
	display_name = "Advanced Electromagnetic Theory"
	prereq_ids = list("emp_basic")
	design_ids = list("ultra_micro_laser")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/emp_super
	id = "emp_super"
	display_name = "Quantum Electromagnetic Technology"	//bs
	description = "Even better electromagnetic technology"
	prereq_ids = list("emp_adv")
	design_ids = list("quad_ultra_micro_laser")
	research_cost = 5000
	export_price = 5000

/datum/
/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////
/datum/design/drill
	name = "Mining Drill"
	id = "drill"
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000) //expensive, but no need for miners.
/datum/design/drill_diamond
	name = "Diamond-Tipped Mining Drill"
	desc = "Yours is the drill that will pierce the heavens!"
	id = "drill_diamond"
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000, MAT_DIAMOND = 2000) //Yes, a whole diamond is needed.
/datum/design/plasmacutter
	name = "Plasma Cutter"
	desc = "You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	id = "plasmacutter"
/datum/design/plasmacutter_adv
	name = "Advanced Plasma Cutter"
	desc = "It's an advanced plasma cutter, oh my god."
	id = "plasmacutter_adv"
/datum/design/jackhammer
	name = "Sonic Jackhammer"
	id = "jackhammer"
/datum/design/superresonator
	name = "Upgraded Resonator"
	id = "superresonator"
/datum/design/trigger_guard_mod
	name = "Kinetic Accelerator Trigger Guard Mod"
	id = "triggermod"
	build_path = /obj/item/borg/upgrade/modkit/trigger_guard
/datum/design/damage_mod
	name = "Kinetic Accelerator Damage Mod"
	id = "damagemod"
/datum/design/cooldown_mod
	name = "Kinetic Accelerator Cooldown Mod"
	id = "cooldownmod"
/datum/design/range_mod
	name = "Kinetic Accelerator Range Mod"
	id = "rangemod"
/datum/design/hyperaccelerator
	name = "Kinetic Accelerator Mining AoE Mod"
	id = "hypermod"

/////////////////////////////////////////
//////////Cybernetic Implants////////////
/////////////////////////////////////////
/datum/design/cyberimp_welding
	name = "Welding Shield Eyes"
	id = "ci-welding"
	construction_time = 40
/datum/design/cyberimp_gloweyes
	name = "Luminescent Eyes"
	id = "ci-gloweyes"
	construction_time = 40
/datum/design/cyberimp_breather
	name = "Breathing Tube Implant"
	id = "ci-breather"
	construction_time = 35
	build_path = /obj/item/organ/cyberimp/mouth/breathing_tube
/datum/design/cyberimp_surgical
    name = "Surgical Arm Implant"
    desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
    id = "ci-surgery"
    materials = list (MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
    construction_time = 200
/datum/design/cyberimp_toolset
	name = "Toolset Arm Implant"
	desc = "A stripped-down version of engineering cyborg toolset, designed to be installed on subject's arm."
	id = "ci-toolset"
	materials = list (MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 200
/datum/design/cyberimp_medical_hud
	name = "Medical HUD Implant"
	id = "ci-medhud"
	construction_time = 50
/datum/design/cyberimp_security_hud
	name = "Security HUD Implant"
	id = "ci-sechud"
	construction_time = 50
/datum/design/cyberimp_xray
	name = "X-Ray Eyes"
	id = "ci-xray"
	construction_time = 60
/datum/design/cyberimp_thermals
	name = "Thermal Eyes"
	id = "ci-thermals"
	construction_time = 60
/datum/design/cyberimp_antidrop
	name = "Anti-Drop Implant"
	id = "ci-antidrop"
	construction_time = 60
	build_path = /obj/item/organ/cyberimp/brain/anti_drop
/datum/design/cyberimp_antistun
	name = "CNS Rebooter Implant"
	id = "ci-antistun"
	construction_time = 60
	build_path = /obj/item/organ/cyberimp/brain/anti_stun
/datum/design/cyberimp_nutriment
	name = "Nutriment Pump Implant"
	id = "ci-nutriment"
	construction_time = 40
/datum/design/cyberimp_nutriment_plus
	name = "Nutriment Pump Implant PLUS"
	id = "ci-nutrimentplus"
	construction_time = 50
/datum/design/cyberimp_reviver
	name = "Reviver Implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	id = "ci-reviver"
	construction_time = 60
/datum/design/cyberimp_thrusters
	name = "Thrusters Set Implant"
	id = "ci-thrusters"
	construction_time = 80

//Cybernetic organs
/datum/design/cybernetic_liver
	name = "Cybernetic Liver"
	id = "cybernetic_liver"
/datum/design/cybernetic_heart
	name = "Cybernetic Heart"
	id = "cybernetic_heart"
/datum/design/cybernetic_liver_u
	name = "Upgraded Cybernetic Liver"
	id = "cybernetic_liver_u"

//Exosuit Equipment
/datum/design/mech_hydraulic_clamp
	name = "Exosuit Engineering Equipment (Hydraulic Clamp)"
	id = "mech_hydraulic_clamp"
	build_path = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	construction_time = 100
/datum/design/mech_drill
	name = "Exosuit Engineering Equipment (Drill)"
	id = "mech_drill"
	build_path = /obj/item/mecha_parts/mecha_equipment/drill
	construction_time = 100
/datum/design/mech_mining_scanner
	name = "Exosuit Engineering Equipment (Mining Scanner)"
	id = "mech_mscanner"
	build_path = /obj/item/mecha_parts/mecha_equipment/mining_scanner
	construction_time = 50
/datum/design/mech_extinguisher
	name = "Exosuit Engineering Equipment (Extinguisher)"
	id = "mech_extinguisher"
	build_path = /obj/item/mecha_parts/mecha_equipment/extinguisher
	construction_time = 100
/datum/design/mech_cable_layer
	name = "Exosuit Engineering Equipment (Cable Layer)"
	id = "mech_cable_layer"
	build_path = /obj/item/mecha_parts/mecha_equipment/cable_layer
	construction_time = 100
/datum/design/mech_generator
	name = "Exosuit Equipment (Plasma Generator)"
	id = "mech_generator"
	build_path = /obj/item/mecha_parts/mecha_equipment/generator
	construction_time = 100
/////////////////////////////////////////
//////////////Borg Upgrades//////////////
/////////////////////////////////////////
/datum/design/borg_upgrade_rename
	name = "Cyborg Upgrade (Rename Board)"
	id = "borg_upgrade_rename"
	construction_time = 120
/datum/design/borg_upgrade_restart
	name = "Cyborg Upgrade (Emergency Reboot Board)"
	id = "borg_upgrade_restart"
	construction_time = 120
/datum/design/borg_upgrade_vtec
	name = "Cyborg Upgrade (VTEC Module)"
	id = "borg_upgrade_vtec"
	construction_time = 120
/datum/design/borg_upgrade_thrusters
	name = "Cyborg Upgrade (Ion Thrusters)"
	id = "borg_upgrade_thrusters"
	construction_time = 120
/datum/design/borg_upgrade_disablercooler
	name = "Cyborg Upgrade (Rapid Disabler Cooling Module)"
	id = "borg_upgrade_disablercooler"
	construction_time = 120
/datum/design/borg_upgrade_diamonddrill
	name = "Cyborg Upgrade (Diamond Drill)"
	id = "borg_upgrade_diamonddrill"
	construction_time = 120
/datum/design/borg_upgrade_holding
	name = "Cyborg Upgrade (Ore Satchel of Holding)"
	id = "borg_upgrade_holding"
	construction_time = 120
/datum/design/borg_upgrade_lavaproof
	name = "Cyborg Upgrade (Lavaproof Tracks)"
	id = "borg_upgrade_lavaproof"
	construction_time = 120
/datum/design/borg_syndicate_module
	name = "Cyborg Upgrade (Illegal Modules)"
	id = "borg_syndicate_module"
	construction_time = 120
/datum/design/borg_upgrade_selfrepair
	name = "Cyborg Upgrade (Self-repair)"
	id = "borg_upgrade_selfrepair"
	construction_time = 120
/datum/design/borg_upgrade_expandedsynthesiser
	name = "Cyborg Upgrade (Hypospray Expanded Synthesiser)"
	id = "borg_upgrade_expandedsynthesiser"
	construction_time = 120
/datum/design/borg_upgrade_highstrengthsynthesiser
	name = "Cyborg Upgrade (Hypospray High-Strength Synthesiser)"
	id = "borg_upgrade_highstrengthsynthesiser"
	build_path = /obj/item/borg/upgrade/hypospray/high_strength
	construction_time = 120
/datum/design/borg_upgrade_piercinghypospray
	name = "Cyborg Upgrade (Piercing Hypospray)"
	id = "borg_upgrade_piercinghypospray"
	build_path = /obj/item/borg/upgrade/piercing_hypospray
	construction_time = 120
/datum/design/borg_upgrade_defibrillator
	name = "Cyborg Upgrade (Defibrillator)"
	id = "borg_upgrade_defibrillator"
	construction_time = 120


/datum/design/drone_shell
	name = "Drone Shell"
	id = "drone_shell"
	construction_time=150
	build_path = /obj/item/drone_shell

/datum/design/flightsuit		//Multi step build process/redo WIP
	name = "Flight Suit"
	id = "flightsuit"
	materials = list(MAT_METAL=16000, MAT_GLASS = 8000, MAT_DIAMOND = 200, MAT_GOLD = 3000, MAT_SILVER = 3000, MAT_TITANIUM = 16000)	//This expensive enough for you?
	construction_time = 250
/datum/design/flightpack
	name = "Flight Pack"
	id = "flightpack"
	materials = list(MAT_METAL=16000, MAT_GLASS = 8000, MAT_DIAMOND = 4000, MAT_GOLD = 12000, MAT_SILVER = 12000, MAT_URANIUM = 20000, MAT_PLASMA = 16000, MAT_TITANIUM = 16000)	//This expensive enough for you?
	construction_time = 250
/datum/design/flightshoes
	name = "Flight Shoes"
	id = "flightshoes"
	construction_time = 100
////////////////////////////////////////
//////////////MISC Boards///////////////
////////////////////////////////////////

/datum/design/board/announcement_system
	name = "Machine Design (Automated Announcement System Board)"
	id = "automated_announcement"
	build_path = /obj/item/circuitboard/machine/announcement_system

/datum/design/board/sleeper
	name = "Machine Design (Sleeper Board)"
	id = "sleeper"
	category = list ("Medical Machinery")
/datum/design/board/chem_dispenser
	name = "Machine Design (Portable Chem Dispenser Board)"
	id = "chem_dispenser"
	build_path = /obj/item/circuitboard/machine/chem_dispenser
	category = list ("Medical Machinery")
/datum/design/board/chem_master
	name = "Machine Design (Chem Master Board)"
	id = "chem_master"
	build_path = /obj/item/circuitboard/machine/chem_master
	category = list ("Medical Machinery")
/datum/design/board/chem_heater
	name = "Machine Design (Chemical Heater Board)"
	id = "chem_heater"
	build_path = /obj/item/circuitboard/machine/chem_heater
	category = list ("Medical Machinery")

/datum/design/board/microwave
	name = "Machine Design (Microwave Board)"
	id = "microwave"
	category = list ("Misc. Machinery")
/datum/design/board/gibber
	name = "Machine Design (Gibber Board)"
	id = "gibber"
	category = list ("Misc. Machinery")
/datum/design/board/smartfridge
	name = "Machine Design (Smartfridge Board)"
	id = "smartfridge"
	category = list ("Misc. Machinery")
/datum/design/board/monkey_recycler
	name = "Machine Design (Monkey Recycler Board)"
	id = "monkey_recycler"
	build_path = /obj/item/circuitboard/machine/monkey_recycler
	category = list ("Misc. Machinery")
/datum/design/board/seed_extractor
	name = "Machine Design (Seed Extractor Board)"
	id = "seed_extractor"
	build_path = /obj/item/circuitboard/machine/seed_extractor
	category = list ("Misc. Machinery")
/datum/design/board/processor
	name = "Machine Design (Processor Board)"
	id = "processor"
	category = list ("Misc. Machinery")
/datum/design/board/recycler
	name = "Machine Design (Recycler Board)"
	id = "recycler"
	category = list ("Misc. Machinery")
/datum/design/board/holopad
	name = "Machine Design (AI Holopad Board)"
	id = "holopad"
	category = list ("Misc. Machinery")
/datum/design/board/autolathe
	name = "Machine Design (Autolathe Board)"
	id = "autolathe"
	category = list ("Misc. Machinery")
/datum/design/board/recharger
	name = "Machine Design (Weapon Recharger Board)"
	id = "recharger"
/datum/design/board/vendor
	name = "Machine Design (Vendor Board)"
	id = "vendor"
	category = list ("Misc. Machinery")
/datum/design/board/ore_redemption
	name = "Machine Design (Ore Redemption Board)"
	id = "ore_redemption"
	build_path = /obj/item/circuitboard/machine/ore_redemption
	category = list ("Misc. Machinery")
/datum/design/board/mining_equipment_vendor
	name = "Machine Design (Mining Rewards Vender Board)"
	id = "mining_equipment_vendor"
	build_path = /obj/item/circuitboard/machine/mining_equipment_vendor
	category = list ("Misc. Machinery")
/datum/design/board/tesla_coil
	name = "Machine Design (Tesla Coil Board)"
	id = "tesla_coil"
	build_path = /obj/item/circuitboard/machine/tesla_coil
	category = list ("Misc. Machinery")
/datum/design/board/grounding_rod
	name = "Machine Design (Grounding Rod Board)"
	id = "grounding_rod"
	build_path = /obj/item/circuitboard/machine/grounding_rod
	category = list ("Misc. Machinery")
/datum/design/board/ntnet_relay
	name = "Machine Design (NTNet Relay Board)"
	id = "ntnet_relay"
	build_path = /obj/item/circuitboard/machine/ntnet_relay
/datum/design/board/limbgrower
	name = "Machine Design (Limb Grower Board)"
	id = "limbgrower"
/datum/design/board/deepfryer
	name = "Machine Design (Deep Fryer)"
	id = "deepfryer"
	build_path = /obj/item/circuitboard/machine/deep_fryer
	category = list ("Misc. Machinery")
////////////////////////////////////////
/////////// Mecha Equpment /////////////
////////////////////////////////////////
/datum/design/mech_scattershot
	name = "Exosuit Weapon (LBX AC 10 \"Scattershot\")"
	id = "mech_scattershot"
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	construction_time = 100
/datum/design/mech_carbine
	name = "Exosuit Weapon (FNX-99 \"Hades\" Carbine)"
	desc = "Allows for the construction of FNX-99 \"Hades\" Carbine."
	id = "mech_carbine"
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	construction_time = 100
/datum/design/mech_ion
	name = "Exosuit Weapon (MKIV Ion Heavy Cannon)"
	id = "mech_ion"
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	construction_time = 100
/datum/design/mech_tesla
	name = "Exosuit Weapon (MKI Tesla Cannon)"
	id = "mech_tesla"
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla
	construction_time = 100
/datum/design/mech_laser
	name = "Exosuit Weapon (CH-PS \"Immolator\" Laser)"
	id = "mech_laser"
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	construction_time = 100
/datum/design/mech_laser_heavy
	name = "Exosuit Weapon (CH-LC \"Solaris\" Laser Cannon)"
	id = "mech_laser_heavy"
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	construction_time = 100
/datum/design/mech_grenade_launcher
	name = "Exosuit Weapon (SGL-6 Grenade Launcher)"
	id = "mech_grenade_launcher"
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang
	construction_time = 100
/datum/design/mech_missile_rack
	name = "Exosuit Weapon (SRM-8 Missile Rack)"
	id = "mech_missile_rack"
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	construction_time = 100
/datum/design/clusterbang_launcher
	name = "Exosuit Module (SOB-3 Clusterbang Launcher)"
	id = "clusterbang_launcher"
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/clusterbang
	construction_time = 100
/datum/design/mech_wormhole_gen
	name = "Exosuit Module (Localized Wormhole Generator)"
	id = "mech_wormhole_gen"
	build_path = /obj/item/mecha_parts/mecha_equipment/wormhole_generator
	construction_time = 100
/datum/design/mech_teleporter
	name = "Exosuit Module (Teleporter Module)"
	id = "mech_teleporter"
	build_path = /obj/item/mecha_parts/mecha_equipment/teleporter
	construction_time = 100
/datum/design/mech_rcd
	name = "Exosuit Module (RCD Module)"
	id = "mech_rcd"
	build_path = /obj/item/mecha_parts/mecha_equipment/rcd
	construction_time = 1200
/datum/design/mech_gravcatapult
	name = "Exosuit Module (Gravitational Catapult Module)"
	id = "mech_gravcatapult"
	build_path = /obj/item/mecha_parts/mecha_equipment/gravcatapult
	construction_time = 100
/datum/design/mech_repair_droid
	name = "Exosuit Module (Repair Droid Module)"
	id = "mech_repair_droid"
	build_path = /obj/item/mecha_parts/mecha_equipment/repair_droid
	construction_time = 100
/datum/design/mech_energy_relay
	name = "Exosuit Module (Tesla Energy Relay)"
	id = "mech_energy_relay"
	build_path = /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	construction_time = 100
/datum/design/mech_ccw_armor
	name = "Exosuit Module (Reactive Armor Booster Module)"
	id = "mech_ccw_armor"
	build_path = /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	construction_time = 100
/datum/design/mech_proj_armor
	name = "Exosuit Module (Reflective Armor Booster Module)"
	id = "mech_proj_armor"
	build_path = /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	construction_time = 100
/datum/design/mech_diamond_drill
	name = "Exosuit Module (Diamond Mining Drill)"
	id = "mech_diamond_drill"
	build_path = /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill
	construction_time = 100
/datum/design/mech_generator_nuclear
	name = "Exosuit Module (ExoNuclear Reactor)"
	id = "mech_generator_nuclear"
	build_path = /obj/item/mecha_parts/mecha_equipment/generator/nuclear
	construction_time = 100
/datum/design/mech_plasma_cutter
	name = "Exosuit Module Design (217-D Heavy Plasma Cutter)"
	id = "mech_plasma_cutter"
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
	construction_time = 100
/datum/design/mech_taser
	name = "Exosuit Weapon (PBT \"Pacifier\" Mounted Taser)"
	id = "mech_taser"
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	construction_time = 100
/datum/design/mech_lmg
	name = "Exosuit Weapon (\"Ultra AC 2\" LMG)"
	id = "mech_lmg"
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	construction_time = 100
/datum/design/mech_sleeper
	name = "Exosuit Medical Equipment (Mounted Sleeper)"
	desc = "Equipment for medical exosuits. A mounted sleeper that stabilizes patients and can inject reagents in the exosuit's reserves."
	id = "mech_sleeper"
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/sleeper
	construction_time = 100
/datum/design/mech_syringe_gun
	name = "Exosuit Medical Equipment (Syringe Gun)"
	id = "mech_syringe_gun"
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	construction_time = 200
/datum/design/mech_medical_beamgun
	name = "Exosuit Medical Equipment (Medical Beamgun)"
	id = "mech_medi_beam"
	construction_time = 250
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam
///////////////////////////////////
/////Non-Board Computer Stuff//////
///////////////////////////////////

///////////////////Computer Boards///////////////////////////////////
/datum/design/board/seccamera
	name = "Computer Design (Security Camera)"
	id = "seccamera"
/datum/design/board/xenobiocamera
	name = "Computer Design (Xenobiology Console)"
	id = "xenobioconsole"
/datum/design/board/operating
	name = "Computer Design (Operating Computer)"
	id = "operating"
/datum/design/board/pandemic
	name = "Computer Design (PanD.E.M.I.C. 2200)"
	id = "pandemic"
/datum/design/board/scan_console
	name = "Computer Design (DNA Machine)"
	id = "scan_console"
	build_path = /obj/item/circuitboard/computer/scan_consolenew
/datum/design/board/comconsole
	name = "Computer Design (Communications)"
	id = "comconsole"
/datum/design/board/idcardconsole
	name = "Computer Design (ID Console)"
	id = "idcardconsole"
/datum/design/board/crewconsole
	name = "Computer Design (Crew monitoring computer)"
	id = "crewconsole"

/datum/design/board/prisonmanage
	name = "Computer Design (Prisoner Management Console)"
	id = "prisonmanage"

	build_path = /obj/item/circuitboard/computer/mech_bay_power_console
/datum/design/board/cargo
	name = "Computer Design (Supply Console)"
	id = "cargo"
/datum/design/board/cargorequest
	name = "Computer Design (Supply Request Console)"
	id = "cargorequest"
/datum/design/board/stockexchange
	name = "Computer Design (Stock Exchange Console)"
	id = "stockexchange"
/datum/design/board/mining
	name = "Computer Design (Outpost Status Display)"
	id = "mining"
/datum/design/board/aifixer
	name = "Computer Design (AI Integrity Restorer)"
	id = "aifixer"
/datum/design/board/libraryconsole
	name = "Computer Design (Library Console)"
	id = "libraryconsole"
/datum/design/board/apc_control
	name = "Computer Design (APC Control)"
	id = "apc_control"
	build_path = /obj/item/circuitboard/computer/apc_control
/////////////////////////////////////////
//////////////Blue Space/////////////////
/////////////////////////////////////////
/datum/design/bag_holding
	name = "Bag of Holding"
	id = "bag_holding"
/datum/design/bluespace_crystal
	name = "Artificial Bluespace Crystal"
	id = "bluespace_crystal"
	build_path = /obj/item/ore/bluespace_crystal/artificial
/datum/design/miningsatchel_holding
	name = "Mining Satchel of Holding"
	id = "minerbag_holding"
	materials = list(MAT_GOLD = 250, MAT_URANIUM = 500) //quite cheap, for more convenience
/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////
/datum/design/pin_testing
	name = "Test-Range Firing Pin"
	id = "pin_testing"
	build_path = /obj/item/device/firing_pin/test_range
/datum/design/pin_mindshield
	name = "Mindshield Firing Pin"
	id = "pin_loyalty"
	build_path = /obj/item/device/firing_pin/implant/mindshield
/datum/design/stunrevolver
	name = "Tesla Revolver"
	id = "stunrevolver"
	build_path = /obj/item/gun/energy/tesla_revolver
/datum/design/nuclear_gun
	name = "Advanced Energy Gun"
	id = "nuclear_gun"
	build_path = /obj/item/gun/energy/e_gun/nuclear
/datum/design/tele_shield
	name = "Telescopic Riot Shield"
	id = "tele_shield"
/datum/design/beamrifle
	name = "Beam Marksman Rifle"
	id = "beamrifle"
	build_path = /obj/item/gun/energy/beam_rifle
/datum/design/decloner
	name = "Decloner"
	id = "decloner"
	reagents_list = list("mutagen" = 40)
/datum/design/rapidsyringe
	name = "Rapid Syringe Gun"
	id = "rapidsyringe"
/datum/design/temp_gun
	name = "Temperature Gun"
	desc = "A gun that shoots temperature bullet energythings to change temperature."//Change it if you want
	id = "temp_gun"
/datum/design/large_grenade
	name = "Large Grenade"
	id = "large_Grenade"
	build_path = /obj/item/grenade/chem_grenade/large
/datum/design/pyro_grenade
	name = "Pyro Grenade"
	id = "pyro_Grenade"
	build_path = /obj/item/grenade/chem_grenade/pyro
/datum/design/adv_grenade
	name = "Advanced Release Grenade"
	id = "adv_Grenade"
	build_path = /obj/item/grenade/chem_grenade/adv_release
/datum/design/xray
	name = "Xray Laser Gun"
	id = "xray"
/datum/design/ioncarbine
	name = "Ion Carbine"
	id = "ioncarbine"
/datum/design/wormhole_projector
	name = "Bluespace Wormhole Projector"
	id = "wormholeprojector"
	build_path = /obj/item/gun/energy/wormhole_projector
//WT550 Mags
/datum/design/mag_oldsmg
	name = "WT-550 Auto Gun Magazine (4.6x30mm)"
	id = "mag_oldsmg"
	build_path = /obj/item/ammo_box/magazine/wt550m9
/datum/design/mag_oldsmg/ap_mag
	name = "WT-550 Auto Gun Armour Piercing Magazine (4.6x30mm AP)"
	id = "mag_oldsmg_ap"
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtap
/datum/design/mag_oldsmg/ic_mag
	name = "WT-550 Auto Gun Incendiary Magazine (4.6x30mm IC)"
	id = "mag_oldsmg_ic"
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtic
/datum/design/mag_oldsmg/tx_mag
	name = "WT-550 Auto Gun Uranium Magazine (4.6x30mm TX)"
	id = "mag_oldsmg_tx"
	build_path = /obj/item/ammo_box/magazine/wt550m9/wttx
/datum/design/stunshell
	name = "Stun Shell"
	id = "stunshell"
	build_path = /obj/item/ammo_casing/shotgun/stunslug
/datum/design/techshell
	name = "Unloaded Technological Shotshell"
	id = "techshotshell"
	build_path = /obj/item/ammo_casing/shotgun/techshell
/datum/design/suppressor
	name = "Universal Suppressor"
	id = "suppressor"
/datum/design/gravitygun
	name = "One-point Bluespace-gravitational Manipulator"
	id = "gravitygun"
	build_path = /obj/item/gun/energy/gravity_gun
/datum/design/largecrossbow
	name = "Energy Crossbow"
	id = "largecrossbow"
	build_path = /obj/item/gun/energy/kinetic_accelerator/crossbow/large
