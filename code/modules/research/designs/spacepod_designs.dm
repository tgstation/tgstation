/datum/design/spacepod_main
	construction_time = 100
	name = "Circuit Design (Space Pod Mainboard)"
	desc = "Allows for the construction of a Space Pod mainboard."
	id = "spacepod_main"
	req_tech = list("materials" = 1) //All parts required to build a basic pod have materials 1, so the mechanic can do his damn job.
	build_type = PODFAB
	materials = list(MAT_METAL=5000)
	build_path = /obj/item/circuitboard/mecha/pod
	category = list("Pod Parts")

//////////////////////////////////////////////////
/////////SPACEPOD PARTS///////////////////////////
//////////////////////////////////////////////////

/datum/design/podframe_fp
	construction_time = 200
	name = "Fore port pod frame"
	desc = "Allows for the construction of spacepod frames. This is the fore port component."
	id = "podframefp"
	build_type = PODFAB
	req_tech = list("materials" = 1)
	build_path = /obj/item/pod_parts/pod_frame/fore_port
	category = list("Pod Frame")
	materials = list(MAT_METAL=15000,MAT_GLASS=5000)

/datum/design/podframe_ap
	construction_time = 200
	name = "Aft port pod frame"
	desc = "Allows for the construction of spacepod frames. This is the aft port component."
	id = "podframeap"
	build_type = PODFAB
	req_tech = list("materials" = 1)
	build_path = /obj/item/pod_parts/pod_frame/aft_port
	category = list("Pod Frame")
	materials = list(MAT_METAL=15000,MAT_GLASS=5000)

/datum/design/podframe_fs
	construction_time = 200
	name = "Fore starboard pod frame"
	desc = "Allows for the construction of spacepod frames. This is the fore starboard component."
	id = "podframefs"
	build_type = PODFAB
	req_tech = list("materials" = 1)
	build_path = /obj/item/pod_parts/pod_frame/fore_starboard
	category = list("Pod Frame")
	materials = list(MAT_METAL=15000,MAT_GLASS=5000)

/datum/design/podframe_as
	construction_time = 200
	name = "Aft starboard pod frame"
	desc = "Allows for the construction of spacepod frames. This is the aft starboard component."
	id = "podframeas"
	build_type = PODFAB
	req_tech = list("materials" = 1)
	build_path = /obj/item/pod_parts/pod_frame/aft_starboard
	category = list("Pod Frame")
	materials = list(MAT_METAL=15000,MAT_GLASS=5000)

//////////////////////////
////////POD CORE////////
//////////////////////////

/datum/design/pod_core
	construction_time = 700 //Pod core should take a bit to process, after all, it's a big complicated engine and stuff.
	name = "Spacepod Core"
	desc = "Allows for the construction of a spacepod core system, made up of the engine and life support systems."
	id = "podcore"
	build_type = MECHFAB | PODFAB
	req_tech = list("materials" = 1)
	build_path = /obj/item/pod_parts/core
	category = list("Pod Parts")
	materials = list(MAT_METAL=5000,MAT_URANIUM=1000,MAT_PLASMA=5000)

//////////////////////////////////////////
////////SPACEPOD ARMOR////////////////////
//////////////////////////////////////////

/datum/design/pod_armor_civ
	construction_time = 400 //more time than frames, less than pod core
	name = "Pod Armor (civilian)"
	desc = "Allows for the construction of spacepod armor. This is the civilian version."
	id = "podarmor_civ"
	build_type = PODFAB
	req_tech = list("materials" = 1)
	build_path = /obj/item/pod_parts/armor
	category = list("Pod Armor")
	materials = list(MAT_METAL=15000,MAT_GLASS=5000,MAT_PLASMA=10000)

/datum/design/pod_armor_black
	construction_time = 400 //more time than frames, less than pod core
	name = "Pod Armor (dark)"
	desc = "Allows for the construction of spacepod armor. This is the dark civillian version."
	id = "podarmor_dark"
	build_type = PODFAB
	req_tech = list("materials" = 1)
	build_path = /obj/item/pod_parts/armor/black
	category = list("Pod Armor")
	materials = list(MAT_METAL=15000,MAT_GLASS=5000,MAT_PLASMA=10000)

/datum/design/pod_armor_industrial
	construction_time = 400 //more time than frames, less than pod core
	name = "Pod Armor (industrial)"
	desc = "Allows for the construction of spacepod armor. This is the industrial grade version."
	id = "podarmor_industiral"
	build_type = PODFAB
	req_tech = list("materials" = 6, "engineering" = 5)
	build_path = /obj/item/pod_parts/armor/industrial
	category = list("Pod Armor")
	materials = list(MAT_METAL=15000,MAT_GLASS=5000,MAT_PLASMA=10000,MAT_DIAMOND=5000,MAT_SILVER=7500)

/datum/design/pod_armor_syndicate
	construction_time = 400 //more time than frames, less than pod core
	name = "Pod Armor (syndicate)"
	desc = "Allows for the construction of spacepod armor. This is the syndicate version."
	id = "podarmor_syndicate"
	build_type = PODFAB
	req_tech = list("materials" = 6, "engineering" = 6, "combat" = 6, "syndicate" = 6)
	build_path = /obj/item/pod_parts/armor/syndicate
	category = list("Pod Armor")
	materials = list(MAT_METAL=15000,MAT_GLASS=5000,MAT_PLASMA=10000,MAT_DIAMOND=5000,MAT_SILVER=7500)


/datum/design/pod_armor_gold
	construction_time = 400 //more time than frames, less than pod core
	name = "Pod Armor (golden)"
	desc = "Allows for the construction of spacepod armor. This is the golden version."
	id = "podarmor_gold"
	build_type = PODFAB
	req_tech = list("materials" = 5, "engineering" = 3) //Slightly higher than gold, due to the requirement of getting actual protection from gold.
	build_path = /obj/item/pod_parts/armor/gold
	category = list("Pod Armor")
	materials = list(MAT_METAL=5000,MAT_GLASS=2500,MAT_PLASMA=7500,MAT_GOLD=10000)

//////////////////////////////////////////
//////SPACEPOD GUNS///////////////////////
//////////////////////////////////////////

/datum/design/pod_gun_disabler
	construction_time = 200
	name = "Spacepod Equipment (Disabler)"
	desc = "Allows for the construction of a spacepod mounted disabler."
	id = "podgun_disabler"
	build_type = PODFAB
	req_tech = list("materials" = 2, "combat" = 2)
	build_path = /obj/item/device/spacepod_equipment/weaponry/disabler
	category = list("Pod Weaponry")
	materials = list(MAT_METAL = 15000)

/datum/design/pod_gun_disabler
	construction_time = 200
	name = "Spacepod Equipment (Burst Disabler)"
	desc = "Allows for the construction of a spacepod mounted disabler. This is the burst-fire model."
	id = "podgun_bdisabler"
	build_type = PODFAB
	req_tech = list("materials" = 3, "combat" = 3)
	build_path = /obj/item/device/spacepod_equipment/weaponry/burst_disabler
	category = list("Pod Weaponry")
	materials = list(MAT_METAL = 15000,MAT_PLASMA=2000)

/datum/design/pod_gun_laser
	construction_time = 200
	name = "Spacepod Equipment (Laser)"
	desc = "Allows for the construction of a spacepod mounted laser."
	id = "podgun_laser"
	build_type = PODFAB
	req_tech = list("materials" = 3, "combat" = 3, "plasmatech" = 2)
	build_path = /obj/item/device/spacepod_equipment/weaponry/laser
	category = list("Pod Weaponry")
	materials = list(MAT_METAL=10000,MAT_GLASS=5000,MAT_GOLD=1000,MAT_SILVER=2000)

/datum/design/pod_ka_basic
	construction_time = 200
	name = "Basic Kinetic Accelerator"
	desc = "Allows for the construction of a weak spacepod Kinetic Accelerator"
	id = "pod_ka_basic"
	req_tech = list("materials" = 3, "powerstorage" = 2, "engineering" = 2, "magnets" = 3, "combat" = 2)
	build_type = PODFAB
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000, MAT_SILVER = 2000, MAT_URANIUM = 2000)
	build_path = /obj/item/device/spacepod_equipment/weaponry/basic_pod_ka
	category = list("Pod Weaponry")

/datum/design/pod_ka
	construction_time = 200
	name = "Kinetic Accelerator"
	desc = "Allows for the construction of a spacepod Kinetic Accelerator."
	id = "pod_ka"
	req_tech = list("materials" = 6, "powerstorage" = 6, "engineering" = 5, "magnets" = 6, "combat" = 4)
	build_type = PODFAB
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000, MAT_SILVER = 2000, MAT_GOLD = 2000, MAT_DIAMOND = 2000)
	build_path = /obj/item/device/spacepod_equipment/weaponry/pod_ka
	category = list("Pod Weaponry")


/datum/design/pod_plasma_cutter
	construction_time = 200
	name = "Plasma Cutter"
	desc = "Allows for the construction of a plasma cutter."
	id = "pod_plasma_cutter"
	req_tech = list("materials" = 6, "powerstorage" = 6, "engineering" = 5, "magnets" = 6, "combat" = 4, "plasmatech" = 3)
	build_type = PODFAB
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000, MAT_SILVER = 2000, MAT_GOLD = 2000, MAT_DIAMOND = 2000)
	build_path = /obj/item/device/spacepod_equipment/weaponry/plasma_cutter
	category = list("Pod Weaponry")

/datum/design/pod_adv_plasma_cutter
	construction_time = 200
	name = "Advanced Plasma cutter"
	desc = "Allows for the construction of an advanced plasma cutter."
	id = "pod_adv_plasma_cutter"
	req_tech = list("materials" = 7, "powerstorage" = 6, "engineering" = 5, "magnets" = 6, "combat" = 4, "plasmatech" = 4)
	build_type = PODFAB
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000, MAT_SILVER = 4000, MAT_GOLD = 4000, MAT_DIAMOND = 4000)
	build_path = /obj/item/device/spacepod_equipment/weaponry/plasma_cutter/adv
	category = list("Pod Weaponry")

//////////////////////////////////////////
//////SPACEPOD MISC. ITEMS////////////////
//////////////////////////////////////////

/datum/design/pod_misc_tracker
	construction_time = 100
	name = "Spacepod Tracking Module"
	desc = "Allows for the construction of a Space Pod Tracking Module."
	id = "podmisc_tracker"
	req_tech = list("materials" = 1) //so you don't have a random untracked pod in space
	build_type = PODFAB
	materials = list(MAT_METAL=5000)
	build_path = /obj/item/device/spacepod_equipment/misc/tracker
	category = list("Pod Parts")

//////////////////////////////////////////
//////SPACEPOD CARGO ITEMS////////////////
//////////////////////////////////////////

/datum/design/pod_cargo_ore
	construction_time = 100
	name = "Spacepod Ore Storage Module"
	desc = "Allows for the construction of a Space Pod Ore Storage Module."
	id = "podcargo_ore"
	req_tech = list("materials" = 3, "engineering" = 2)
	build_type = PODFAB
	materials = list(MAT_METAL=20000, MAT_GLASS=2000)
	build_path = /obj/item/device/spacepod_equipment/cargo/ore
	category = list("Pod Cargo")

/datum/design/pod_cargo_crate
	construction_time = 100
	name = "Spacepod Crate Storage Module"
	desc = "Allows the construction of a Space Pod Crate Storage Module."
	id = "podcargo_crate"
	req_tech = list("materials" = 4, "engineering" = 2) //hollowing out this much of the pod without compromising structural integrity is hard
	build_type = PODFAB
	materials = list(MAT_METAL=25000)
	build_path = /obj/item/device/spacepod_equipment/cargo/crate
	category = list("Pod Cargo")

//////////////////////////////////////////
//////SPACEPOD SEC CARGO ITEMS////////////
//////////////////////////////////////////

/datum/design/passenger_seat
	construction_time = 100
	name = "Spacepod Passenger Seat"
	desc = "Allows the construction of a Space Pod Passenger Seat Module."
	id = "podcargo_sec_seat"
	req_tech = list("materials" = 1) // Because rule number one of refactoring
	build_type = PODFAB
	materials = list(MAT_METAL=7500, MAT_GLASS=2500)
	build_path = /obj/item/device/spacepod_equipment/sec_cargo/chair
	category = list("Pod Cargo")

/datum/design/loot_box
	construction_time = 100
	name = "Spacepod Loot Storage Module"
	desc = "Allows the construction of a Space Pod Auxillary Cargo Module."
	id = "podcargo_sec_lootbox"
	req_tech = list("materials" = 1) //it's just a set of shelves, It's not that hard to make
	build_type = PODFAB
	materials = list(MAT_METAL=7500, MAT_GLASS=2500)
	build_path = /obj/item/device/spacepod_equipment/sec_cargo/loot_box
	category = list("Pod Cargo")

//////////////////////////////////////////
//////SPACEPOD LOCK ITEMS////////////////
//////////////////////////////////////////
/datum/design/pod_lock_keyed
	construction_time = 100
	name = "Spacepod Tumbler Lock"
	desc = "Allows for the construction of a tumbler style podlock."
	id = "podlock_keyed"
	req_tech = list("materials" = 1) //The most basic kind of locking system
	build_type = PODFAB
	materials = list(MAT_METAL=4500)
	build_path = /obj/item/device/spacepod_equipment/lock/keyed
	category = list("Pod Parts")

/datum/design/pod_key
	construction_time = 100
	name = "Spacepod Tumbler Lock Key"
	desc = "Allows for the construction of a blank key for a podlock."
	id = "podkey"
	req_tech = list("materials" = 1) //The most basic kind of locking system
	build_type = PODFAB
	materials = list(MAT_METAL=500)
	build_path = /obj/item/device/spacepod_key
	category = list("Pod Parts")