
//Current rate: 135000 research points in 90 minutes
//Current cargo price: 500000 points for fullmaxed R&D.

//Base Node
/datum/techweb_node/base
	id = "base"
	starting_node = TRUE
	display_name = "Basic Research Technology"
	description = "NT default research technologies."
	design_ids = list("basic_matter_bin", "basic_scanning", "basic_capacitor", "basic_micro_laser", "micro_mani",
	"destructive_analyzer", "protolathe", "circuit_imprinter", "experimentor", "rdconsole", "design_disk", "tech_disk", "rdserver", "rdservercontrol", "mechfab")			//Default research tech, prevents bricking

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
	design_ids = list("s-reciever", "s-bus", "s-broadcaster", "s-processor", "s-hub", "s-server", "s-relay")

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
	design_ids = list("rped", "adv_scanning", "adv_matter_bin", "high_micro_laser", "nano_mani", "weldingmask", "mesons")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/adv_engi
	id = "adv_engi"
	description = "Advanced engineering research"
	display_name = "Advanced Engineering"
	prereq_ids = list("industrial_engineering", "emp_basic")
	design_ids = list("enginegoggles", "diagnostic_hud")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/practical_bluespace
	id = "practical_bluespace"
	display_name = "Applied Bluespace Research"
	description = "Using bluespace to make things faster and better."
	prereq_ids = list("bluespace_basic", "industrial_engineering")
	design_ids = list("bs_rped", "telesci_gps", "bluespacebeaker", "bluespacesyringe", "bluespacebodybag")
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
	design_ids = list("health_hud", "security+hud", "diagnostic_hud")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/NVGtech
	id = "NVGtech"
	display_name = "Night Vision Technology"
	description = "Allows seeing in the dark without actual light!"
	prereq_ids = list("integrated_HUDs", "adv_engi")
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


/////////////////////////////////////////
//////////////////Misc///////////////////
/////////////////////////////////////////
/datum/design/portaseeder
	name = "Portable Seed Extractor"
/datum/design/magboots
	name = "Magnetic Boots"
	id = "magboots"
/datum/design/sci_goggles
	name = "Science Goggles"
	id = "scigoggles"
/datum/design/handdrill
	name = "Hand Drill"
	id = "handdrill"
/datum/design/jawsoflife
	name = "Jaws of Life"
	id = "jawsoflife"
/datum/design/diskplantgene
	name = "Plant Data Disk"
	id = "diskplantgene"
/////////////////////////////////////////
////////////Janitor Designs//////////////
/////////////////////////////////////////
/datum/design/advmop
	name = "Advanced Mop"
	id = "advmop"
/datum/design/blutrash
	name = "Trashbag of Holding"
	id = "blutrash"
/datum/design/buffer
	name = "Floor Buffer Upgrade"
	id = "buffer"
/////////////////////////////////////////
////////////Tools//////////////
/////////////////////////////////////////
/datum/design/exwelder
	name = "Experimental Welding Tool"
	id = "exwelder"
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
////////////Medical Tools////////////////
/////////////////////////////////////////
/datum/design/adv_mass_spectrometer
	name = "Advanced Mass-Spectrometer"
	id = "adv_mass_spectrometer"
	build_path = /obj/item/device/mass_spectrometer/adv
/datum/design/piercesyringe
	name = "Piercing Syringe"
	id = "piercesyringe"
	build_path = /obj/item/reagent_containers/syringe/piercing
/datum/design/plasmarefiller
	name = "Plasma-Man Jumpsuit Refill"
	id = "plasmarefiller"
	req_tech = list("materials" = 2, "plasmatech" = 3) //Why did this have no plasmatech
	build_path = /obj/item/device/extinguisher_refill

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
/////////////////////////////////////////
////////////Regular Implants/////////////
/////////////////////////////////////////
/datum/design/implanter
	name = "Implanter"
	id = "implanter"
/datum/design/implantcase
	name = "Implant Case"
	id = "implantcase"
/datum/design/implant_chem
	name = "Chemical Implant Case"
	id = "implant_chem"
/datum/design/implant_tracking
	name = "Tracking Implant Case"
	id = "implant_tracking"
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
//Cyborg
/datum/design/borg_suit
	name = "Cyborg Endoskeleton"
	id = "borg_suit"
	build_path = /obj/item/robot_suit
	construction_time = 500
/datum/design/borg_chest
	name = "Cyborg Torso"
	id = "borg_chest"
	construction_time = 350
/datum/design/borg_head
	name = "Cyborg Head"
	id = "borg_head"
	construction_time = 350
/datum/design/borg_l_arm
	name = "Cyborg Left Arm"
	id = "borg_l_arm"
	build_path = /obj/item/bodypart/l_arm/robot
	construction_time = 200
/datum/design/borg_r_arm
	name = "Cyborg Right Arm"
	id = "borg_r_arm"
	build_path = /obj/item/bodypart/r_arm/robot
	construction_time = 200
/datum/design/borg_l_leg
	name = "Cyborg Left Leg"
	id = "borg_l_leg"
	build_path = /obj/item/bodypart/l_leg/robot
	construction_time = 200
/datum/design/borg_r_leg
	name = "Cyborg Right Leg"
	id = "borg_r_leg"
	build_path = /obj/item/bodypart/r_leg/robot
	construction_time = 200
//Ripley
/datum/design/ripley_chassis
	name = "Exosuit Chassis (APLU \"Ripley\")"
	id = "ripley_chassis"
	build_path = /obj/item/mecha_parts/chassis/ripley
	construction_time = 100
//firefighter subtype
/datum/design/firefighter_chassis
	name = "Exosuit Chassis (APLU \"Firefighter\")"
	id = "firefighter_chassis"
	build_path = /obj/item/mecha_parts/chassis/firefighter
	construction_time = 100
/datum/design/ripley_torso
	name = "Exosuit Torso (APLU \"Ripley\")"
	id = "ripley_torso"
	build_path = /obj/item/mecha_parts/part/ripley_torso
	construction_time = 200
/datum/design/ripley_left_arm
	name = "Exosuit Left Arm (APLU \"Ripley\")"
	id = "ripley_left_arm"
	build_path = /obj/item/mecha_parts/part/ripley_left_arm
	construction_time = 150
/datum/design/ripley_right_arm
	name = "Exosuit Right Arm (APLU \"Ripley\")"
	id = "ripley_right_arm"
	build_path = /obj/item/mecha_parts/part/ripley_right_arm
	construction_time = 150
/datum/design/ripley_left_leg
	name = "Exosuit Left Leg (APLU \"Ripley\")"
	id = "ripley_left_leg"
	build_path = /obj/item/mecha_parts/part/ripley_left_leg
	construction_time = 150
/datum/design/ripley_right_leg
	name = "Exosuit Right Leg (APLU \"Ripley\")"
	id = "ripley_right_leg"
	build_path = /obj/item/mecha_parts/part/ripley_right_leg
	construction_time = 150
//Odysseus
/datum/design/odysseus_chassis
	name = "Exosuit Chassis (\"Odysseus\")"
	id = "odysseus_chassis"
	build_path = /obj/item/mecha_parts/chassis/odysseus
	construction_time = 100
/datum/design/odysseus_torso
	name = "Exosuit Torso (\"Odysseus\")"
	id = "odysseus_torso"
	build_path = /obj/item/mecha_parts/part/odysseus_torso
	construction_time = 180
/datum/design/odysseus_head
	name = "Exosuit Head (\"Odysseus\")"
	id = "odysseus_head"
	build_path = /obj/item/mecha_parts/part/odysseus_head
	construction_time = 100
/datum/design/odysseus_left_arm
	name = "Exosuit Left Arm (\"Odysseus\")"
	id = "odysseus_left_arm"
	build_path = /obj/item/mecha_parts/part/odysseus_left_arm
	construction_time = 120
/datum/design/odysseus_right_arm
	name = "Exosuit Right Arm (\"Odysseus\")"
	id = "odysseus_right_arm"
	build_path = /obj/item/mecha_parts/part/odysseus_right_arm
	construction_time = 120
/datum/design/odysseus_left_leg
	name = "Exosuit Left Leg (\"Odysseus\")"
	id = "odysseus_left_leg"
	build_path = /obj/item/mecha_parts/part/odysseus_left_leg
	construction_time = 130
/datum/design/odysseus_right_leg
	name = "Exosuit Right Leg (\"Odysseus\")"
	id = "odysseus_right_leg"
	build_path = /obj/item/mecha_parts/part/odysseus_right_leg
	construction_time = 130
/*/datum/design/odysseus_armor
	name = "Exosuit Armor (\"Odysseus\")"
	id = "odysseus_armor"
	build_path = /obj/item/mecha_parts/part/odysseus_armor
	construction_time = 200
	*/
//Gygax
/datum/design/gygax_chassis
	name = "Exosuit Chassis (\"Gygax\")"
	id = "gygax_chassis"
	build_path = /obj/item/mecha_parts/chassis/gygax
	construction_time = 100
/datum/design/gygax_torso
	name = "Exosuit Torso (\"Gygax\")"
	id = "gygax_torso"
	build_path = /obj/item/mecha_parts/part/gygax_torso
	construction_time = 300
/datum/design/gygax_head
	name = "Exosuit Head (\"Gygax\")"
	id = "gygax_head"
	build_path = /obj/item/mecha_parts/part/gygax_head
	construction_time = 200
/datum/design/gygax_left_arm
	name = "Exosuit Left Arm (\"Gygax\")"
	id = "gygax_left_arm"
	build_path = /obj/item/mecha_parts/part/gygax_left_arm
	construction_time = 200
/datum/design/gygax_right_arm
	name = "Exosuit Right Arm (\"Gygax\")"
	id = "gygax_right_arm"
	build_path = /obj/item/mecha_parts/part/gygax_right_arm
	construction_time = 200
/datum/design/gygax_left_leg
	name = "Exosuit Left Leg (\"Gygax\")"
	id = "gygax_left_leg"
	build_path = /obj/item/mecha_parts/part/gygax_left_leg
	construction_time = 200
/datum/design/gygax_right_leg
	name = "Exosuit Right Leg (\"Gygax\")"
	id = "gygax_right_leg"
	build_path = /obj/item/mecha_parts/part/gygax_right_leg
	construction_time = 200
/datum/design/gygax_armor
	name = "Exosuit Armor (\"Gygax\")"
	id = "gygax_armor"
	build_path = /obj/item/mecha_parts/part/gygax_armor
	construction_time = 600
//Durand
/datum/design/durand_chassis
	name = "Exosuit Chassis (\"Durand\")"
	id = "durand_chassis"
	build_path = /obj/item/mecha_parts/chassis/durand
	construction_time = 100
/datum/design/durand_torso
	name = "Exosuit Torso (\"Durand\")"
	id = "durand_torso"
	build_path = /obj/item/mecha_parts/part/durand_torso
	construction_time = 300
/datum/design/durand_head
	name = "Exosuit Head (\"Durand\")"
	id = "durand_head"
	build_path = /obj/item/mecha_parts/part/durand_head
	construction_time = 200
/datum/design/durand_left_arm
	name = "Exosuit Left Arm (\"Durand\")"
	id = "durand_left_arm"
	build_path = /obj/item/mecha_parts/part/durand_left_arm
	construction_time = 200
/datum/design/durand_right_arm
	name = "Exosuit Right Arm (\"Durand\")"
	id = "durand_right_arm"
	build_path = /obj/item/mecha_parts/part/durand_right_arm
	construction_time = 200
/datum/design/durand_left_leg
	name = "Exosuit Left Leg (\"Durand\")"
	id = "durand_left_leg"
	build_path = /obj/item/mecha_parts/part/durand_left_leg
	construction_time = 200
/datum/design/durand_right_leg
	name = "Exosuit Right Leg (\"Durand\")"
	id = "durand_right_leg"
	build_path = /obj/item/mecha_parts/part/durand_right_leg
	construction_time = 200
/datum/design/durand_armor
	name = "Exosuit Armor (\"Durand\")"
	id = "durand_armor"
	build_path = /obj/item/mecha_parts/part/durand_armor
	construction_time = 600
//Phazon
/datum/design/phazon_chassis
	name = "Exosuit Chassis (\"Phazon\")"
	id = "phazon_chassis"
	build_path = /obj/item/mecha_parts/chassis/phazon
	construction_time = 100
/datum/design/phazon_torso
	name = "Exosuit Torso (\"Phazon\")"
	id = "phazon_torso"
	build_path = /obj/item/mecha_parts/part/phazon_torso
	construction_time = 300
/datum/design/phazon_head
	name = "Exosuit Head (\"Phazon\")"
	id = "phazon_head"
	build_path = /obj/item/mecha_parts/part/phazon_head
	construction_time = 200
/datum/design/phazon_left_arm
	name = "Exosuit Left Arm (\"Phazon\")"
	id = "phazon_left_arm"
	build_path = /obj/item/mecha_parts/part/phazon_left_arm
	construction_time = 200
/datum/design/phazon_right_arm
	name = "Exosuit Right Arm (\"Phazon\")"
	id = "phazon_right_arm"
	build_path = /obj/item/mecha_parts/part/phazon_right_arm
	construction_time = 200
/datum/design/phazon_left_leg
	name = "Exosuit Left Leg (\"Phazon\")"
	id = "phazon_left_leg"
	build_path = /obj/item/mecha_parts/part/phazon_left_leg
	construction_time = 200
/datum/design/phazon_right_leg
	name = "Exosuit Right Leg (\"Phazon\")"
	id = "phazon_right_leg"
	build_path = /obj/item/mecha_parts/part/phazon_right_leg
	construction_time = 200
/datum/design/phazon_armor
	name = "Exosuit Armor (\"Phazon\")"
	id = "phazon_armor"
	build_path = /obj/item/mecha_parts/part/phazon_armor
	construction_time = 300
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
/datum/design/boris_ai_controller
	name = "B.O.R.I.S. AI-Cyborg Remote Control Module"
	id = "borg_ai_control"
	construction_time = 50
//Misc
/datum/design/mecha_tracking
	name = "Exosuit Tracking Beacon"
	id = "mecha_tracking"
	build_path =/obj/item/mecha_parts/mecha_tracking
	construction_time = 50
/datum/design/mecha_tracking_ai_control
	name = "AI Control Beacon"
	id = "mecha_tracking_ai_control"
	build_path = /obj/item/mecha_parts/mecha_tracking/ai_control
	construction_time = 50
/datum/design/drone_shell
	name = "Drone Shell"
	id = "drone_shell"
	construction_time=150
	build_path = /obj/item/drone_shell
/datum/design/synthetic_flash
	name = "Flash"
	id = "sflash"
	construction_time = 100
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
/datum/design/board/smes
	name = "Machine Design (SMES Board)"
	id = "smes"
	category = list ("Engineering Machinery")
/datum/design/board/announcement_system
	name = "Machine Design (Automated Announcement System Board)"
	id = "automated_announcement"
	build_path = /obj/item/circuitboard/machine/announcement_system
/datum/design/board/turbine_computer
	name = "Computer Design (Power Turbine Console Board)"
	id = "power_turbine_console"
	build_path = /obj/item/circuitboard/computer/turbine_computer
	category = list ("Engineering Machinery")
/datum/design/board/emitter
	name = "Machine Design (Emitter Board)"
	id = "emitter"
	category = list ("Engineering Machinery")
/datum/design/board/power_compressor
	name = "Machine Design (Power Compressor Board)"
	id = "power_compressor"
	build_path = /obj/item/circuitboard/machine/power_compressor
	category = list ("Engineering Machinery")
/datum/design/board/power_turbine
	name = "Machine Design (Power Turbine Board)"
	id = "power_turbine"
	build_path = /obj/item/circuitboard/machine/power_turbine
	category = list ("Engineering Machinery")
/datum/design/board/thermomachine
	name = "Machine Design (Freezer/Heater Board)"
	id = "thermomachine"
	category = list ("Engineering Machinery")
/datum/design/board/space_heater
	name = "Machine Design (Space Heater Board)"
	id = "space_heater"
	build_path = /obj/item/circuitboard/machine/space_heater
	category = list ("Engineering Machinery")
/datum/design/board/teleport_station
	name = "Machine Design (Teleportation Station Board)"
	id = "tele_station"
	build_path = /obj/item/circuitboard/machine/teleporter_station
	category = list ("Teleportation Machinery")
/datum/design/board/teleport_hub
	name = "Machine Design (Teleportation Hub Board)"
	id = "tele_hub"
	build_path = /obj/item/circuitboard/machine/teleporter_hub
	category = list ("Teleportation Machinery")
/datum/design/board/quantumpad
	name = "Machine Design (Quantum Pad Board)"
	id = "quantumpad"
	category = list ("Teleportation Machinery")
/datum/design/board/launchpad
	name = "Machine Design (Bluespace Launchpad Board)"
	id = "launchpad"
	category = list ("Teleportation Machinery")
/datum/design/board/launchpad_console
	name = "Machine Design (Bluespace Launchpad Console Board)"
	id = "launchpad_console"
	build_path = /obj/item/circuitboard/computer/launchpad_console
	category = list ("Teleportation Machinery")
/datum/design/board/teleconsole
	name = "Computer Design (Teleporter Console)"
	id = "teleconsole"
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
/datum/design/board/clonecontrol
	name = "Computer Design (Cloning Machine Console)"
	id = "clonecontrol"
/datum/design/board/clonepod
	name = "Machine Design (Clone Pod)"
	id = "clonepod"
/datum/design/board/clonescanner
	name = "Machine Design (Cloning Scanner)"
	id = "clonescanner"
/datum/design/board/biogenerator
	name = "Machine Design (Biogenerator Board)"
	id = "biogenerator"
	category = list ("Hydroponics Machinery")
/datum/design/board/hydroponics
	name = "Machine Design (Hydroponics Tray Board)"
	id = "hydro_tray"
	category = list ("Hydroponics Machinery")
/datum/design/board/cyborgrecharger
	name = "Machine Design (Cyborg Recharger Board)"
	id = "cyborgrecharger"
/datum/design/board/mech_recharger
	name = "Machine Design (Mechbay Recharger Board)"
	id = "mech_recharger"
	build_path = /obj/item/circuitboard/machine/mech_recharger
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
/datum/design/board/plantgenes
	name = "Machine Design (Plant DNA Manipulator Board)"
	id = "plantgenes"
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
///////////////////////////////////
//////////Mecha Module Disks///////
///////////////////////////////////
/datum/design/board/ripley_main
	name = "APLU \"Ripley\" Central Control module"
	desc = "Allows for the construction of a \"Ripley\" Central Control module."
	id = "ripley_main"
/datum/design/board/ripley_peri
	name = "APLU \"Ripley\" Peripherals Control module"
	desc = "Allows for the construction of a  \"Ripley\" Peripheral Control module."
	id = "ripley_peri"
/datum/design/board/odysseus_main
	name = "\"Odysseus\" Central Control module"
	desc = "Allows for the construction of a \"Odysseus\" Central Control module."
	id = "odysseus_main"
/datum/design/board/odysseus_peri
	name = "\"Odysseus\" Peripherals Control module"
	desc = "Allows for the construction of a \"Odysseus\" Peripheral Control module."
	id = "odysseus_peri"
/datum/design/board/gygax_main
	name = "\"Gygax\" Central Control module"
	desc = "Allows for the construction of a \"Gygax\" Central Control module."
	id = "gygax_main"
/datum/design/board/gygax_peri
	name = "\"Gygax\" Peripherals Control module"
	desc = "Allows for the construction of a \"Gygax\" Peripheral Control module."
	id = "gygax_peri"
/datum/design/board/gygax_targ
	name = "\"Gygax\" Weapons & Targeting Control module"
	desc = "Allows for the construction of a \"Gygax\" Weapons & Targeting Control module."
	id = "gygax_targ"
/datum/design/board/durand_main
	name = "\"Durand\" Central Control module"
	desc = "Allows for the construction of a \"Durand\" Central Control module."
	id = "durand_main"
/datum/design/board/durand_peri
	name = "\"Durand\" Peripherals Control module"
	desc = "Allows for the construction of a \"Durand\" Peripheral Control module."
	id = "durand_peri"
/datum/design/board/durand_targ
	name = "\"Durand\" Weapons & Targeting Control module"
	desc = "Allows for the construction of a \"Durand\" Weapons & Targeting Control module."
	id = "durand_targ"
/datum/design/board/phazon_main
	name = "\"Phazon\" Central Control module"
	desc = "Allows for the construction of a \"Phazon\" Central Control module."
	id = "phazon_main"
/datum/design/board/phazon_peri
	name = "\"Phazon\" Peripherals Control module"
	desc = "Allows for the construction of a \"Phazon\" Peripheral Control module."
	id = "phazon_peri"
/datum/design/board/phazon_targ
	name = "\"Phazon\" Weapons & Targeting Control module"
	desc = "Allows for the construction of a \"Phazon\" Weapons & Targeting Control module."
	id = "phazon_targ"
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
/datum/design/intellicard
	name = "Intellicard AI Transportation System"
	id = "intellicard"
/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	id = "paicard"
///////////////////Computer Boards///////////////////////////////////
/datum/design/board/seccamera
	name = "Computer Design (Security Camera)"
	id = "seccamera"
/datum/design/board/xenobiocamera
	name = "Computer Design (Xenobiology Console)"
	id = "xenobioconsole"
/datum/design/board/aiupload
	name = "Computer Design (AI Upload)"
	id = "aiupload"
/datum/design/board/borgupload
	name = "Computer Design (Cyborg Upload)"
	id = "borgupload"
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
/datum/design/board/atmosalerts
	name = "Computer Design (Atmosphere Alert)"
	id = "atmosalerts"
	build_path = /obj/item/circuitboard/computer/atmos_alert
/datum/design/board/atmos_control
	name = "Computer Design (Atmospheric Monitor)"
	id = "atmos_control"
	build_path = /obj/item/circuitboard/computer/atmos_control
/datum/design/board/robocontrol
	name = "Computer Design (Robotics Control Console)"
	id = "robocontrol"
/datum/design/board/powermonitor
	name = "Computer Design (Power Monitor)"
	id = "powermonitor"
/datum/design/board/solarcontrol
	name = "Computer Design (Solar Control)"
	id = "solarcontrol"
	build_path = /obj/item/circuitboard/computer/solar_control
/datum/design/board/prisonmanage
	name = "Computer Design (Prisoner Management Console)"
	id = "prisonmanage"
/datum/design/board/mechacontrol
	name = "Computer Design (Exosuit Control Console)"
	id = "mechacontrol"
	build_path = /obj/item/circuitboard/computer/mecha_control
/datum/design/board/mechapower
	name = "Computer Design (Mech Bay Power Control Console)"
	id = "mechapower"
	build_path = /obj/item/circuitboard/computer/mech_bay_power_console
/datum/design/board/rdconsole
	name = "Computer Design (R&D Console)"
	desc = "Allows for the construction of circuit boards used to build a new R&D console."
	id = "rdconsole"
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
/datum/design/board/comm_monitor
	name = "Computer Design (Telecommunications Monitoring Console)"
	id = "comm_monitor"
	build_path = /obj/item/circuitboard/computer/comm_monitor
/datum/design/board/comm_server
	name = "Computer Design (Telecommunications Server Monitoring Console)"
	id = "comm_server"
	build_path = /obj/item/circuitboard/computer/comm_server
/datum/design/board/message_monitor
	name = "Computer Design (Messaging Monitor Console)"
	id = "message_monitor"
	build_path = /obj/item/circuitboard/computer/message_monitor
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
/datum/design/flora_gun
	name = "Floral Somatoray"
	id = "flora_gun"
	reagents_list = list("radium" = 20)
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
////////////////////////////////////////
/////////////Stock Parts////////////////
////////////////////////////////////////
//Capacitors
/datum/design/adv_capacitor
	name = "Advanced Capacitor"
	id = "adv_capacitor"
	build_path = /obj/item/stock_parts/capacitor/adv
	lathe_time_factor = 0.2
/datum/design/super_capacitor
	name = "Super Capacitor"
	id = "super_capacitor"
	build_path = /obj/item/stock_parts/capacitor/super
	lathe_time_factor = 0.2
/datum/design/quadratic_capacitor
	name = "Quadratic Capacitor"
	id = "quadratic_capacitor"
	build_path = /obj/item/stock_parts/capacitor/quadratic
	lathe_time_factor = 0.2
/datum/design/phasic_scanning
	name = "Phasic Scanning Module"
	id = "phasic_scanning"
	build_path = /obj/item/stock_parts/scanning_module/phasic
	lathe_time_factor = 0.2
/datum/design/triphasic_scanning
	name = "Triphasic Scanning Module"
	id = "triphasic_scanning"
	build_path = /obj/item/stock_parts/scanning_module/triphasic
	lathe_time_factor = 0.2
/datum/design/pico_mani
	name = "Pico Manipulator"
	id = "pico_mani"
	build_path = /obj/item/stock_parts/manipulator/pico
	lathe_time_factor = 0.2
/datum/design/femto_mani
	name = "Femto Manipulator"
	id = "femto_mani"
	build_path = /obj/item/stock_parts/manipulator/femto
	lathe_time_factor = 0.2
/datum/design/ultra_micro_laser
	name = "Ultra-High-Power Micro-Laser"
	id = "ultra_micro_laser"
	build_path = /obj/item/stock_parts/micro_laser/ultra
	lathe_time_factor = 0.2
/datum/design/quadultra_micro_laser
	name = "Quad-Ultra Micro-Laser"
	id = "quadultra_micro_laser"
	build_path = /obj/item/stock_parts/micro_laser/quadultra
	lathe_time_factor = 0.2
/datum/design/super_matter_bin
	name = "Super Matter Bin"
	id = "super_matter_bin"
	build_path = /obj/item/stock_parts/matter_bin/super
	lathe_time_factor = 0.2
/datum/design/bluespace_matter_bin
	name = "Bluespace Matter Bin"
	id = "bluespace_matter_bin"
	build_path = /obj/item/stock_parts/matter_bin/bluespace
	lathe_time_factor = 0.2
//T-Comms devices
/datum/design/subspace_ansible
	name = "Subspace Ansible"
	id = "s-ansible"
	build_path = /obj/item/stock_parts/subspace/ansible
/datum/design/hyperwave_filter
	name = "Hyperwave Filter"
	id = "s-filter"
	build_path = /obj/item/stock_parts/subspace/filter
/datum/design/subspace_amplifier
	name = "Subspace Amplifier"
	id = "s-amplifier"
	build_path = /obj/item/stock_parts/subspace/amplifier
/datum/design/subspace_treatment
	name = "Subspace Treatment Disk"
	id = "s-treatment"
	build_path = /obj/item/stock_parts/subspace/treatment
/datum/design/subspace_analyzer
	name = "Subspace Analyzer"
	id = "s-analyzer"
	build_path = /obj/item/stock_parts/subspace/analyzer
/datum/design/subspace_crystal
	name = "Ansible Crystal"
	id = "s-crystal"
	build_path = /obj/item/stock_parts/subspace/crystal
/datum/design/subspace_transmitter
	name = "Subspace Transmitter"
	id = "s-transmitter"
	build_path = /obj/item/stock_parts/subspace/transmitter
////////////////////////////////////////
//////////////////Power/////////////////
////////////////////////////////////////
/datum/design/basic_cell
	name = "Basic Power Cell"
	id = "basic_cell"
	construction_time=100
	build_path = /obj/item/stock_parts/cell
/datum/design/high_cell
	name = "High-Capacity Power Cell"
	id = "high_cell"
	construction_time=100
	build_path = /obj/item/stock_parts/cell/high
/datum/design/super_cell
	name = "Super-Capacity Power Cell"
	id = "super_cell"
	construction_time=100
	build_path = /obj/item/stock_parts/cell/super
/datum/design/hyper_cell
	name = "Hyper-Capacity Power Cell"
	id = "hyper_cell"
	construction_time=100
	build_path = /obj/item/stock_parts/cell/hyper
/datum/design/bluespace_cell
	name = "Bluespace Power Cell"
	id = "bluespace_cell"
	construction_time=100
	build_path = /obj/item/stock_parts/cell/bluespace
/datum/design/light_replacer
	name = "Light Replacer"///////////////////////////////////
//////////AI Module Disks//////////
///////////////////////////////////
/datum/design/board/aicore
	name = "AI Design (AI Core)"
	id = "aicore"
/datum/design/board/safeguard_module
	name = "Module Design (Safeguard)"
	id = "safeguard_module"
/datum/design/board/onehuman_module
	name = "Module Design (OneHuman)"
	id = "onehuman_module"
/datum/design/board/protectstation_module
	name = "Module Design (ProtectStation)"
	id = "protectstation_module"
/datum/design/board/quarantine_module
	name = "Module Design (Quarantine)"
	id = "quarantine_module"
/datum/design/board/oxygen_module
	name = "Module Design (OxygenIsToxicToHumans)"
	id = "oxygen_module"
/datum/design/board/freeform_module
	name = "Module Design (Freeform)"
	id = "freeform_module"
/datum/design/board/reset_module
	name = "Module Design (Reset)"
	id = "reset_module"
/datum/design/board/purge_module
	name = "Module Design (Purge)"
	id = "purge_module"
/datum/design/board/remove_module
	name = "Module Design (Law Removal)"
	id = "remove_module"
/datum/design/board/freeformcore_module
	name = "AI Core Module (Freeform)"
	id = "freeformcore_module"
/datum/design/board/asimov
	name = "Core Module Design (Asimov)"
	id = "asimov_module"
/datum/design/board/paladin_module
	name = "Core Module Design (P.A.L.A.D.I.N.)"
	id = "paladin_module"
/datum/design/board/tyrant_module
	name = "Core Module Design (T.Y.R.A.N.T.)"
	id = "tyrant_module"
/datum/design/board/corporate_module
	name = "Core Module Design (Corporate)"
	id = "corporate_module"
/datum/design/board/default_module
	name = "Core Module Design (Default)"
	id = "default_module"
	id = "light_replacer"
/datum/design/board/pacman
	name = "Machine Design (PACMAN-type Generator Board)"
	id = "pacman"
/datum/design/board/pacman/super
	name = "Machine Design (SUPERPACMAN-type Generator Board)"
	id = "superpacman"
/datum/design/board/pacman/mrs
	name = "Machine Design (MRSPACMAN-type Generator Board)"
	id = "mrspacman"
