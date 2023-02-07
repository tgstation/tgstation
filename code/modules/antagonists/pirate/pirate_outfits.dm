/datum/outfit/pirate
	name = "Space Pirate"

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/pirate
	uniform = /obj/item/clothing/under/costume/pirate
	suit = /obj/item/clothing/suit/costume/pirate/armored
	ears = /obj/item/radio/headset/syndicate
	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/costume/pirate/bandana/armored
	shoes = /obj/item/clothing/shoes/sneakers/brown

/datum/outfit/pirate/post_equip(mob/living/carbon/human/equipped)
	equipped.faction |= "pirate"

	var/obj/item/radio/outfit_radio = equipped.ears
	if(outfit_radio)
		outfit_radio.set_frequency(FREQ_SYNDICATE)
		outfit_radio.freqlock = RADIO_FREQENCY_LOCKED

	var/obj/item/card/id/outfit_id = equipped.wear_id
	if(outfit_id)
		outfit_id.registered_name = equipped.real_name
		outfit_id.update_label()
		outfit_id.update_icon()

	var/obj/item/clothing/under/pirate_uniform = equipped.w_uniform
	if(pirate_uniform)
		pirate_uniform.has_sensor = NO_SENSORS
		pirate_uniform.sensor_mode = SENSOR_OFF
		equipped.update_suit_sensors()

/datum/outfit/pirate/captain
	name = "Space Pirate Captain"

	id_trim = /datum/id_trim/pirate/captain
	head = /obj/item/clothing/head/costume/pirate/armored

/datum/outfit/pirate/space
	name = "Space Pirate (EVA)"

	suit = /obj/item/clothing/suit/space/pirate
	suit_store = /obj/item/tank/internals/oxygen
	head = /obj/item/clothing/head/helmet/space/pirate/bandana
	mask = /obj/item/clothing/mask/breath

/datum/outfit/pirate/space/captain
	name = "Space Pirate Captain (EVA)"

	head = /obj/item/clothing/head/helmet/space/pirate

/datum/outfit/pirate/silverscale
	name = "Silver Scale Member"

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/pirate/silverscale
	uniform = /obj/item/clothing/under/syndicate/sniper
	suit = /obj/item/clothing/suit/armor/vest/alt
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/collectable/tophat
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/pirate/silverscale/captain
	name = "Silver Scale Captain"

	id_trim = /datum/id_trim/pirate/captain/silverscale
	head = /obj/item/clothing/head/costume/crown
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	l_pocket = /obj/item/lighter

/datum/outfit/pirate/psyker
	name = "Psyker-gang Member"

	glasses = null
	head = null
	ears = /obj/item/radio/headset/syndicate/alt/psyker
	uniform = /obj/item/clothing/under/pants/track
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/gore
	r_pocket = /obj/item/reagent_containers/hypospray/medipen/gore

	id_trim = /datum/id_trim/pirate/psykers

/datum/outfit/pirate/psyker/post_equip(mob/living/carbon/human/equipped)
	. = ..()
	equipped.psykerize()

/datum/outfit/pirate/psyker/captain
	name = "Psyker-gang Leader"

	id_trim = /datum/id_trim/pirate/captain/psykers
	suit = /obj/item/clothing/suit/armor/reactive/psykerboost
	uniform = /obj/item/clothing/under/pants/camo
