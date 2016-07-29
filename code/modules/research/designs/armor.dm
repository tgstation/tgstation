/datum/design/xcomsquaddiearmor
	name = "Squaddie Armor"
	desc = "A set of armor good against ballistics and laser weaponry.."
	id = "xcomsquaddiearmor"
	req_tech = list("materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1000)
	category = "Armor"
	build_path = /obj/item/clothing/suit/armor/xcomsquaddie

/datum/design/xcomoriginalarmor
	name = "Original Armor"
	desc = "A set of armor good against ballistics and laser weaponry.."
	id = "xcomoriginalarmor"
	req_tech = list("materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1000)
	category = "Armor"
	build_path = /obj/item/clothing/suit/armor/xcomarmor

/*
/datum/design/security_hud
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "security_hud"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/security
	category = "Armor"
	locked = 1
*/

/datum/design/sechud_sunglass
	name = "HUDSunglasses"
	desc = "Sunglasses with a heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "sechud_sunglass"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 50, MAT_GLASS = 50)
	category = "Armor"
	build_path = /obj/item/clothing/glasses/sunglasses/sechud
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/ablative_armor_vest
	name = "Ablative Armor Vest"
	desc = "A vest that excels in protecting the wearer against energy projectiles."
	id = "ablative vest"
	req_tech = list("combat" = 4, "materials" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_IRON = 1500, MAT_GLASS = 2500, MAT_DIAMOND = 3750, MAT_SILVER = 1000, MAT_URANIUM = 500)
	category = "Armor"
	build_path = /obj/item/clothing/suit/armor/laserproof
	locked = 1
	req_lock_access = list(access_armory)

/datum/design/advancedeod
	name = "Advanced EOD Suit"
	desc = "An advanced EOD suit that affords great protection at the cost of mobility."
	id = "advanced eod suit"
	req_tech = list("combat" = 5, "materials" = 5, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 10000, MAT_GLASS = 2500, MAT_GOLD = 3750, MAT_SILVER = 1000)
	category = "Armor"
	build_path = /obj/item/clothing/suit/advancedeod

/datum/design/advancedeod_helmet
	name = "Advanced EOD Helmet"
	desc = "An advanced EOD helmet that affords great protection at the cost of mobility."
	id = "advanced eod helmet"
	req_tech = list("combat" = 5, "materials" = 5, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list (MAT_IRON = 3750, MAT_GLASS = 2500, MAT_GOLD = 3750, MAT_SILVER = 1000)
	category = "Armor"
	build_path = /obj/item/clothing/head/advancedeod_helmet

/datum/design/reactive_teleport_armor
	name = "Reactive Teleport Armor"
	desc = "Someone seperated our Research Director from his own head!"
	id = "reactive_teleport_armor"
	req_tech = list("bluespace" = 4, "materials" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 2000, MAT_IRON = 3000, MAT_URANIUM = 3750)
	category = "Armor"
	build_path = /obj/item/clothing/suit/armor/reactive
