/datum/outfit/pirate
	name = "Space Pirate"

	uniform = /obj/item/clothing/under/costume/pirate
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/pirate/armored
	head = /obj/item/clothing/head/bandana/armored
	ears = /obj/item/radio/headset/syndicate
	glasses = /obj/item/clothing/glasses/eyepatch

/datum/outfit/pirate/post_equip(mob/living/carbon/human/equipped)
	equipped.faction |= "pirate"

	var/obj/item/radio/outfit_radio = equipped.ears
	if(outfit_radio)
		outfit_radio.set_frequency(FREQ_SYNDICATE)
		outfit_radio.freqlock = TRUE

	var/obj/item/card/id/outfit_id = equipped.wear_id
	if(outfit_id)
		outfit_id.registered_name = equipped.real_name
		outfit_id.update_label()
		outfit_id.update_icon()

/datum/outfit/pirate/captain
	name = "Space Pirate Captain"

	head = /obj/item/clothing/head/pirate/armored

/datum/outfit/pirate/space
	name = "Space Pirate (EVA)"
	suit = /obj/item/clothing/suit/space/pirate
	head = /obj/item/clothing/head/helmet/space/pirate/bandana
	mask = /obj/item/clothing/mask/breath
	suit_store = /obj/item/tank/internals/oxygen
	id = /obj/item/card/id/advanced

/datum/outfit/pirate/space/captain
	name = "Space Pirate Captain (EVA)"

	head = /obj/item/clothing/head/helmet/space/pirate

/datum/outfit/pirate/silverscale
	name = "Silver Scale Member"

	head = /obj/item/clothing/head/collectable/tophat
	glasses = /obj/item/clothing/glasses/monocle
	uniform = /obj/item/clothing/under/suit/charcoal
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/armor/vest/alt
	gloves = /obj/item/clothing/gloves/color/black
	id_trim = /datum/id_trim/pirate/silverscale
	id = /obj/item/card/id/advanced/silver

/datum/outfit/pirate/silverscale/captain
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	l_pocket = /obj/item/lighter
	head = /obj/item/clothing/head/crown
	id_trim = /datum/id_trim/pirate/silverscale/captain
