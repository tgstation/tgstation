/datum/design/spacepod_main
	name = "Circuit Design (Space Pod Mainboard)"
	desc = "Allows for the construction of a Space Pod mainboard."
	id = "spacepod_main"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = "Misc"
	build_path = /obj/item/weapon/circuitboard/mecha/pod

/datum/design/pod_core
	name = "Spacepod Core"
	desc = "Allows for the construction of a spacepod core system, made up of the engine and life support systems."
	id = "podcore"
	build_type = PODFAB
	req_tech = list("materials" = 4, "engineering" = 3, "plasmatech" = 3, "bluespace" = 2)
	build_path = /obj/item/pod_parts/core
	category = "Pod_Parts"
	materials = list(MAT_IRON=5000,MAT_URANIUM=1000,MAT_PLASMA=5000)

//POD ARMOUR

/datum/design/pod_armor_civ
	name = "Pod Armor (civilian)"
	desc = "Allows for the construction of spacepod armor. This is the civilian version."
	id = "podarmor_civ"
	build_type = PODFAB
	req_tech = list("materials" = 3, "plasmatech" = 3)
	build_path = /obj/item/pod_parts/armor
	category = "Pod_Armor"
	materials = list(MAT_IRON=15000,MAT_GLASS=5000,MAT_PLASMA=10000)

//FRAME PARTS.

/datum/design/podframe_fp
	name = "Fore port pod frame"
	desc = "Allows for the construction of spacepod frames. This is the fore port component."
	id = "podframefp"
	build_type = PODFAB
	req_tech = list("materials" = 3, "engineering" = 2)
	build_path = /obj/item/pod_parts/pod_frame/fore_port
	category = "Pod_Frame"
	materials = list(MAT_IRON=15000,MAT_GLASS=5000)

/datum/design/podframe_ap
	name = "Aft port pod frame"
	desc = "Allows for the construction of spacepod frames. This is the aft port component."
	id = "podframeap"
	build_type = PODFAB
	req_tech = list("materials" = 3, "engineering" = 2)
	build_path = /obj/item/pod_parts/pod_frame/aft_port
	category = "Pod_Frame"
	materials = list(MAT_IRON=15000,MAT_GLASS=5000)

/datum/design/podframe_fs
	name = "Fore starboard pod frame"
	desc = "Allows for the construction of spacepod frames. This is the fore starboard component."
	id = "podframefs"
	build_type = PODFAB
	req_tech = list("materials" = 3, "engineering" = 2)
	build_path = /obj/item/pod_parts/pod_frame/fore_starboard
	category = "Pod_Frame"
	materials = list(MAT_IRON=15000,MAT_GLASS=5000)

/datum/design/podframe_as
	name = "Aft starboard pod frame"
	desc = "Allows for the construction of spacepod frames. This is the aft starboard component."
	id = "podframeas"
	build_type = PODFAB
	req_tech = list("materials" = 3, "engineering" = 2)
	build_path = /obj/item/pod_parts/pod_frame/aft_starboard
	category = "Pod_Frame"
	materials = list(MAT_IRON=15000,MAT_GLASS=5000)

