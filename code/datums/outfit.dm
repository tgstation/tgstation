/datum/outfit
	var/name = "Naked"

	var/uniform = null
	var/suit = null
	var/back = null
	var/belt = null
	var/gloves = null
	var/shoes = null
	var/head = null
	var/mask = null
	var/ears = null
	var/glasses = null
	var/id = null
	var/l_pocket = null
	var/r_pocket = null
	var/suit_store = null
	var/r_hand = null
	var/l_hand = null
	var/list/backpack_contents = null // In the list(path=count,otherpath=count) format

/datum/outfit/proc/post_equip(mob/living/carbon/human/H)
	//to be overriden for toggling internals, id binding, access etc
	return

/datum/outfit/proc/equip(mob/living/carbon/human/H)
	//Start with uniform,suit,backpack for additional slots
	if(uniform)
		H.equip_to_slot_or_del(new uniform(H),slot_w_uniform)
	if(suit)
		H.equip_to_slot_or_del(new suit(H),slot_wear_suit)
	if(back)
		H.equip_to_slot_or_del(new back(H),slot_back)
	if(belt)
		H.equip_to_slot_or_del(new belt(H),slot_belt)
	if(gloves)
		H.equip_to_slot_or_del(new gloves(H),slot_gloves)
	if(shoes)
		H.equip_to_slot_or_del(new shoes(H),slot_shoes)
	if(head)
		H.equip_to_slot_or_del(new head(H),slot_head)
	if(mask)
		H.equip_to_slot_or_del(new mask(H),slot_wear_mask)
	if(ears)
		H.equip_to_slot_or_del(new ears(H),slot_ears)
	if(glasses)
		H.equip_to_slot_or_del(new glasses(H),slot_glasses)
	if(id)
		H.equip_to_slot_or_del(new id(H),slot_wear_id)
	if(l_pocket)
		H.equip_to_slot_or_del(new l_pocket(H),slot_l_store)
	if(r_pocket)
		H.equip_to_slot_or_del(new r_pocket(H),slot_r_store)
	if(suit_store)
		H.equip_to_slot_or_del(new suit_store(H),slot_s_store)

	if(l_hand)
		H.put_in_l_hand(new l_hand(H))
	if(r_hand)
		H.put_in_r_hand(new r_hand(H))

	for(var/path in backpack_contents)
		var/number = backpack_contents[path]
		for(var/i=0,i<number,i++)
			H.equip_to_slot_or_del(new path(H),slot_in_backpack)

	post_equip(H)

	return 1
//Example
/datum/outfit/test
	name = "Test Outfit"

	uniform = /obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/space
	shoes = /obj/item/clothing/shoes/sneakers/black
	head = /obj/item/clothing/head/helmet/space
	back = /obj/item/weapon/storage/backpack
	mask = /obj/item/clothing/mask/breath
	backpack_contents = list(/obj/item/weapon/c4=5,/obj/item/weapon/kitchen/knife=1)
	r_hand = /obj/item/weapon/c4

/datum/outfit/test/post_equip(mob/living/carbon/human/H)
	H.say("I love bombs!")