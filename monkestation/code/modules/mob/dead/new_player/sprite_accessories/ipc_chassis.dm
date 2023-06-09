/datum/sprite_accessory/ipc_chassis // Used for changing limb icons, doesn't need to hold the actual icon. That's handled in ipc.dm
	icon = null
	icon_state = "blegh" // In order to pull the chassis correctly, we need AN icon_state(see line 36-39). It doesn't have to be useful, because it isn't used.
	color_src = FALSE

/datum/sprite_accessory/ipc_chassis/mcgreyscale
	name = "Morpheus Cyberkinetics (Custom)"
	color_src = MUTCOLORS
	icon_state = "mcgipc"

/datum/sprite_accessory/ipc_chassis/bishop_cyberkinetics
	name = "Bishop Cyberkinetics"
	icon_state = "bshipc"

/datum/sprite_accessory/ipc_chassis/bishop_cyberkinetics_2
	name = "Bishop Cyberkinetics 2.0"
	icon_state = "bs2ipc"

/datum/sprite_accessory/ipc_chassis/hephaestuss_industries
	name = "Hephaestus Industries"
	icon_state = "hsiipc"

/datum/sprite_accessory/ipc_chassis/hephaestuss_industries_2
	name = "Hephaestus Industries 2.0"
	icon_state = "hi2ipc"

/datum/sprite_accessory/ipc_chassis/shellguard_munitions
	name = "Shellguard Munitions Standard Series"
	icon_state = "sgmipc"

/datum/sprite_accessory/ipc_chassis/ward_takahashi_manufacturing
	name = "Ward-Takahashi Manufacturing"
	icon_state = "wtmipc"

/datum/sprite_accessory/ipc_chassis/xion_manufacturing_group
	name = "Xion Manufacturing Group"
	icon_state = "xmgipc"

/datum/sprite_accessory/ipc_chassis/xion_manufacturing_group_2
	name = "Xion Manufacturing Group 2.0"
	icon_state = "zhpipc"

/datum/sprite_accessory/ipc_chassis/zeng_hu_pharmaceuticals
	name = "Zeng-Hu Pharmaceuticals"
	icon_state = "zhpipc"

// MONKESTATION CHANGE: Adds staripc chassis by MilkForever
/datum/sprite_accessory/ipc_chassis/star_industrial
	name = "Star Industrial"
	icon_state = "staripc"
