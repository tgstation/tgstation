/datum/outfit/ctf/medisim
	name = "Redfield Castle Knight"
	icon_state = "medisim_knight"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/plate/red
	suit = /obj/item/clothing/suit/armor/riot/knight/red
	gloves = /obj/item/clothing/gloves/plate/red
	head = /obj/item/clothing/head/helmet/knight/red
	l_hand = /obj/item/claymore

	ears = null
	id = null
	belt = null
	l_pocket = null
	r_pocket = null

	has_radio = FALSE
	has_card = FALSE

	nodrop_slots = list(ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_EARS, ITEM_SLOT_BELT, ITEM_SLOT_HEAD)

	class_description = "Melee class. Armed with a claymore."

/datum/outfit/ctf/medisim/archer
	name = "Redfield Castle Archer"
	icon_state = "medisim_archer"

	belt = /obj/item/storage/bag/quiver/full
	suit = /obj/item/clothing/suit/armor/vest/cuirass
	l_hand = /obj/item/gun/ballistic/bow

	class_description = "Ranged class. Armed with a bow and arrows."

/datum/outfit/ctf/medisim/blue
	name = "Bluesworth Hold Knight"

	uniform = /obj/item/clothing/under/color/blue
	shoes = /obj/item/clothing/shoes/plate/blue
	suit = /obj/item/clothing/suit/armor/riot/knight/blue
	gloves = /obj/item/clothing/gloves/plate/blue
	head = /obj/item/clothing/head/helmet/knight/blue

/datum/outfit/ctf/medisim/archer/blue
	name = "Bluesworth Hold Archer"

	uniform = /obj/item/clothing/under/color/blue
	shoes = /obj/item/clothing/shoes/plate/blue
	gloves = /obj/item/clothing/gloves/plate/blue
	head = /obj/item/clothing/head/helmet/knight/blue
