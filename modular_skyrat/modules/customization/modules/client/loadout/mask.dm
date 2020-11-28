/datum/loadout_item/mask
	category = LOADOUT_CATEGORY_MASK

//MISC
/datum/loadout_item/mask/balaclava
	name = "Balaclava"
	path = /obj/item/clothing/mask/balaclava

/datum/loadout_item/mask/moustache
	name = "Fake moustache"
	path = /obj/item/clothing/mask/fakemoustache

/datum/loadout_item/mask/bandana_red
	name = "Red Bandana"
	path = /obj/item/clothing/mask/bandana/red

/datum/loadout_item/mask/bandana_blue
	name = "Blue Bandana"
	path = /obj/item/clothing/mask/bandana/blue

/datum/loadout_item/mask/bandana_green
	name = "Green Bandana"
	path = /obj/item/clothing/mask/bandana/green

/datum/loadout_item/mask/bandana_gold
	name = "Gold Bandana"
	path = /obj/item/clothing/mask/bandana/gold

/datum/loadout_item/mask/bandana_black
	name = "Black Bandana"
	path = /obj/item/clothing/mask/bandana/black

/datum/loadout_item/mask/bandana_skull
	name = "Skull Bandana"
	path = /obj/item/clothing/mask/bandana/skull

/datum/loadout_item/mask/gas_glass
	name = "Glass Gas Mask"
	path = /obj/item/clothing/mask/gas/glass

//JOB RELATED
/datum/loadout_item/mask/job
	subcategory = LOADOUT_SUBCATEGORY_JOB

/datum/loadout_item/mask/job/surgical
	name = "Sterile Mask"
	path = /obj/item/clothing/mask/surgical
	restricted_roles = list("Chief Medical Officer", "Medical Doctor", "Virologist", "Chemist", "Geneticist", "Paramedic", "Psychologist")
	restricted_desc = "Medical"
