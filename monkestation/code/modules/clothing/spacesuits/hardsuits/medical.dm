//Medical hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort, but does not protect the eyes from intense light."
	icon_state = "hardsuit0-medical"
	hardsuit_type = "medical"
	flash_protect = FLASH_PROTECTION_NONE
	armor_type = /datum/armor/hardsuit/medical
	clothing_traits = list(TRAIT_REAGENT_SCANNER)
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT

/obj/item/clothing/suit/space/hardsuit/medical
	name = "medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Built with lightweight materials for easier movement."
	icon_state = "hardsuit-medical"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/medkit, /obj/item/healthanalyzer, /obj/item/stack/medical)
	armor_type = /datum/armor/hardsuit/medical
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/medical
	slowdown = 0.5
