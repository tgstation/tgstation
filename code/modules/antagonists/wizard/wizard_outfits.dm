
/datum/outfit/wizard
	name = "Blue Wizard"

	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	shoes = /obj/item/clothing/shoes/sandal/magic
	ears = /obj/item/radio/headset
	head = /obj/item/clothing/head/wizard
	r_pocket = /obj/item/teleportation_scroll
	r_hand = /obj/item/spellbook
	l_hand = /obj/item/staff
	back = /obj/item/storage/backpack
	backpack_contents = list(/obj/item/storage/box/survival=1)

/datum/outfit/wizard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/spellbook/S = locate() in H.held_items
	if(S)
		S.owner = H

/datum/outfit/wizard/apprentice
	name = "Wizard Apprentice"
	r_hand = null
	l_hand = null
	r_pocket = /obj/item/teleportation_scroll/apprentice

/datum/outfit/wizard/red
	name = "Red Wizard"

	suit = /obj/item/clothing/suit/wizrobe/red
	head = /obj/item/clothing/head/wizard/red

/datum/outfit/wizard/weeb
	name = "Marisa Wizard"

	suit = /obj/item/clothing/suit/wizrobe/marisa
	shoes = /obj/item/clothing/shoes/sandal/marisa
	head = /obj/item/clothing/head/wizard/marisa
