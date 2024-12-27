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
	//Chance for the wearer to have their height increased. This is repeated three times for maximum height.
	var/taller_chance = 50

/datum/outfit/basketball/post_equip(mob/living/carbon/human/human_to_equip, visuals_only=FALSE)
	if(visuals_only)
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

	var/list/taller_list = list(HUMAN_HEIGHT_TALL, HUMAN_HEIGHT_TALLER, HUMAN_HEIGHT_TALLEST)
	var/tall_index = 0
	for(var/i in 1 to 3)
		if(!prob(taller_chance))
			break
		tall_index++

	if(tall_index)
		human_to_equip.set_mob_height(taller_list[tall_index])

/datum/outfit/basketball/referee
	name = "Basketball Referee"
	uniform = /obj/item/clothing/under/costume/referee
	shoes = /obj/item/clothing/shoes/laceup
	mask = /obj/item/clothing/mask/whistle/minigame
	gloves = /obj/item/clothing/gloves/latex
	head = /obj/item/clothing/head/soft/black
	taller_chance = 15

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

/datum/outfit/basketball/lusty_xenomorphs/post_equip(mob/living/carbon/human/human_to_equip, visuals_only=FALSE)
	. = ..()

	var/obj/item/card/id/idcard = human_to_equip.wear_id
	var/hive_num = rand(1, 1000)
	idcard.registered_name = "Alien ([hive_num])"
	idcard.update_label()
	idcard.update_icon()

/datum/outfit/basketball/ass_blast_usa
	name = "Basketball Ass Blast USA"
	uniform = /obj/item/clothing/under/misc/patriotsuit
	shoes = /obj/item/clothing/shoes/sneakers/red
	neck = /obj/item/bedsheet/patriot

/datum/outfit/basketball/soviet_bears
	name = "Basketball Soviet Bears"
	uniform = /obj/item/clothing/under/costume/soviet
	shoes = /obj/item/clothing/shoes/winterboots
	head = /obj/item/clothing/head/costume/ushanka
	gloves = /obj/item/clothing/gloves/color/brown

/datum/outfit/basketball/ash_gladiators
	name = "Basketball Ash Gladiators"
	head = /obj/item/clothing/head/helmet/gladiator
	uniform = /obj/item/clothing/under/costume/gladiator/ash_walker
	back = /obj/item/spear
	shoes = null

/datum/outfit/basketball/beach_bums
	name = "Basketball Beach Bums"
	undershirt = /datum/sprite_accessory/undershirt/nude
	underwear = /datum/sprite_accessory/underwear/nude
	socks = /datum/sprite_accessory/socks/nude
	uniform = /obj/item/clothing/under/shorts/red
	glasses = /obj/item/clothing/glasses/sunglasses
	shoes = /obj/item/clothing/shoes/sandal
