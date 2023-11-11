GLOBAL_LIST_INIT(store_glasses, generate_store_items(/datum/store_item/glasses))

/datum/store_item/glasses
	category = LOADOUT_ITEM_GLASSES

/datum/store_item/glasses/prescription_glasses
	name = "Glasses"
	item_path = /obj/item/clothing/glasses/regular
	item_cost = 3000

/datum/store_item/glasses/prescription_glasses/circle_glasses
	name = "Circle Glasses"
	item_path = /obj/item/clothing/glasses/regular/circle

/datum/store_item/glasses/prescription_glasses/hipster_glasses
	name = "Hipster Glasses"
	item_path = /obj/item/clothing/glasses/regular/hipster

/datum/store_item/glasses/prescription_glasses/jamjar_glasses
	name = "Jamjar Glasses"
	item_path = /obj/item/clothing/glasses/regular/jamjar

/*
*	COSMETIC GLASSES
*/

/datum/store_item/glasses/cold_glasses
	name = "Cold Glasses"
	item_path = /obj/item/clothing/glasses/cold
	item_cost = 4000

/datum/store_item/glasses/heat_glasses
	name = "Heat Glasses"
	item_path = /obj/item/clothing/glasses/heat
	item_cost = 4000

/datum/store_item/glasses/geist_glasses
	name = "Geist Gazers"
	item_path = /obj/item/clothing/glasses/geist_gazers
	item_cost = 4000

/datum/store_item/glasses/orange_glasses
	name = "Orange Glasses"
	item_path = /obj/item/clothing/glasses/orange

/datum/store_item/glasses/psych_glasses
	name = "Psych Glasses"
	item_path = /obj/item/clothing/glasses/psych
	item_cost = 4000

/datum/store_item/glasses/red_glasses
	name = "Red Glasses"
	item_path = /obj/item/clothing/glasses/red

/*
*	MISC
*/

/datum/store_item/glasses/eyepatch
	name = "Eyepatch"
	item_path = /obj/item/clothing/glasses/eyepatch

/datum/store_item/glasses/eyepatch_medical
	name = "Medical Eyepatch"
	item_path = /obj/item/clothing/glasses/eyepatch/medical

/datum/store_item/glasses/blindfold
	name = "Blindfold"
	item_path = /obj/item/clothing/glasses/blindfold

/datum/store_item/glasses/fakeblindfold
	name = "Fake Blindfold"
	item_path = /obj/item/clothing/glasses/trickblindfold

/datum/store_item/glasses/monocle
	name = "Monocle"
	item_path = /obj/item/clothing/glasses/monocle

/*
*	JOB-LOCKED
*/

/datum/store_item/glasses/sechud
	name = "Security HUD"
	item_path = /obj/item/clothing/glasses/hud/security
	item_cost = 5000

/*
*	FAMILIES
*/

/datum/store_item/glasses/osi
	name = "OSI Glasses"
	item_path = /obj/item/clothing/glasses/osi
	item_cost = 7500

/datum/store_item/glasses/phantom
	name = "Phantom Glasses"
	item_path = /obj/item/clothing/glasses/phantom
	item_cost = 7500
