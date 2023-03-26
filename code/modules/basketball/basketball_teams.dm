// GENERIC TEAM
/datum/outfit/basketball
	name = "Basketball Team Uniform"
	uniform = /obj/item/clothing/under/color/black
	shoes = /obj/item/clothing/shoes/sneakers/white
	id = /obj/item/card/id/away
	///Do they get an ID?
	var/has_card = FALSE
	///Which slots to apply TRAIT_NODROP to the items in
	var/list/nodrop_slots = list(
		ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET,
		ITEM_SLOT_ICLOTHING, ITEM_SLOT_EARS, ITEM_SLOT_BELT,
		ITEM_SLOT_MASK, ITEM_SLOT_EYES, ITEM_SLOT_ID,
		ITEM_SLOT_HEAD, ITEM_SLOT_BACK, ITEM_SLOT_NECK,
	)

/datum/outfit/basketball/post_equip(mob/living/carbon/human/human_to_equip, visualsOnly=FALSE)
	if(visualsOnly)
		return
	var/list/no_drops = list()

	if(has_card)
		var/obj/item/card/id/idcard = human_to_equip.wear_id
		no_drops += idcard
		idcard.registered_name = human_to_equip.real_name
		idcard.update_label()
		idcard.update_icon()

	// Make clothing in the specified slots NODROP
	for(var/slot in nodrop_slots)
		no_drops += human_to_equip.get_item_by_slot(slot)
	// Make items in the hands NODROP
	for(var/obj/item/held_item in human_to_equip.held_items)
		no_drops += held_item
	list_clear_nulls(no_drops) // For any slots we didn't have filled
	// Apply TRAIT_NODROP to everything
	for(var/obj/item/item_to_nodrop as anything in no_drops)
		ADD_TRAIT(item_to_nodrop, TRAIT_NODROP, BASKETBALL_MINIGAME_TRAIT)

	human_to_equip.dna.species.stunmod = 0

/datum/outfit/basketball/referee
	name = "Basketball Referee"
	uniform = /obj/item/clothing/under/costume/referee
	shoes = /obj/item/clothing/shoes/laceup
	mask = /obj/item/clothing/mask/whistle/minigame
	gloves = /obj/item/clothing/gloves/latex
	head = /obj/item/clothing/head/soft/black

/datum/outfit/basketball/nanotrasen
	name = "Basketball NT Team"
	undershirt = /datum/sprite_accessory/undershirt/bluejersey
	uniform = /obj/item/clothing/under/shorts/blue
	suit = /obj/item/clothing/suit/jacket/letterman_nanotrasen
	shoes = /obj/item/clothing/shoes/sneakers/black

/datum/outfit/basketball/greytide_worldwide
	name = "Basketball Greytide Worldwide"
	uniform = /obj/item/clothing/under/color/grey/ancient
	shoes = /obj/item/clothing/shoes/sneakers/brown
	mask = /obj/item/clothing/mask/gas/prop
	gloves = /obj/item/clothing/gloves/color/fyellow
	belt = /obj/item/storage/belt/utility
	// assistants should be random unknowns so no id card
	has_card = FALSE

// No slowdown for these uniforms
/obj/item/clothing/suit/space/basketball
	slowdown = 0

/obj/item/clothing/shoes/magboots/basketball
	slowdown_active = 0

/datum/outfit/basketball/space_surfers
	name = "Basketball Space Surfers"
	shoes = /obj/item/clothing/shoes/magboots/basketball
	suit = /obj/item/clothing/suit/space/basketball
	head = /obj/item/clothing/head/helmet/space
	mask = /obj/item/clothing/mask/breath
	neck = /obj/item/bedsheet/cosmos

/datum/outfit/basketball/lusty_xenomorphs
	name = "Basketball Lusty Xenomorphs"
	suit = /obj/item/clothing/suit/costume/xenos
	head = /obj/item/clothing/head/costume/xenos
	mask = /obj/item/clothing/mask/chameleon

/datum/outfit/basketball/lusty_xenomorphs/post_equip(mob/living/carbon/human/human_to_equip, visualsOnly=FALSE)
	. = ..()

	var/obj/item/card/id/idcard = human_to_equip.wear_id
	var/hive_num = rand(1, 1000)
	idcard.registered_name = "Alien ([hive_num])"
	idcard.update_label()
	idcard.update_icon()
