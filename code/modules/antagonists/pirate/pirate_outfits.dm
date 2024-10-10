/datum/outfit/pirate
	name = "Space Pirate"

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/pirate
	uniform = /obj/item/clothing/under/costume/pirate
	suit = /obj/item/clothing/suit/costume/pirate/armored
	ears = /obj/item/radio/headset/syndicate
	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/costume/pirate/bandana/armored
	shoes = /obj/item/clothing/shoes/pirate/armored

/datum/outfit/pirate/post_equip(mob/living/carbon/human/equipped)
	equipped.faction |= FACTION_PIRATE

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

/datum/outfit/pirate/captain/skeleton
	name = "Space Pirate Captain (Skeleton)"

	belt = /obj/item/gun/magic/midas_hand
	l_pocket = /obj/item/coin/gold/doubloon

/datum/outfit/pirate/space
	name = "Space Pirate (EVA)"

	suit = /obj/item/clothing/suit/space/pirate
	suit_store = /obj/item/tank/internals/oxygen
	head = /obj/item/clothing/head/helmet/space/pirate/bandana
	mask = /obj/item/clothing/mask/breath

/datum/outfit/pirate/space/captain
	name = "Space Pirate Captain (EVA)"

	head = /obj/item/clothing/head/helmet/space/pirate

	id_trim = /datum/id_trim/pirate/captain

/datum/outfit/pirate/silverscale
	name = "Silver Scale Member"

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/pirate/silverscale
	uniform = /obj/item/clothing/under/syndicate/sniper
	suit = /obj/item/clothing/suit/armor/vest/alt
	back = /obj/item/storage/backpack/satchel
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/collectable/tophat
	shoes = /obj/item/clothing/shoes/laceup
	implants = list(/obj/item/implant/explosive)

/datum/outfit/pirate/silverscale/captain
	name = "Silver Scale Captain"

	id_trim = /datum/id_trim/pirate/captain/silverscale
	head = /obj/item/clothing/head/costume/crown
	mask = /obj/item/cigarette/cigar/havana
	l_pocket = /obj/item/lighter

/datum/outfit/pirate/interdyne
	name = "Ex-Interdyne Pharmacist"

	id = /obj/item/card/id/advanced/black
	id_trim = /datum/id_trim/syndicom/Interdyne/pharmacist
	uniform = /obj/item/clothing/under/rank/medical/scrubs/coroner
	suit = /obj/item/clothing/suit/toggle/labcoat
	back = /obj/item/storage/backpack/satchel/med
	glasses = /obj/item/clothing/glasses/hud/health/night
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/utility/surgerycap/black
	shoes = /obj/item/clothing/shoes/sneakers/white
	l_pocket = /obj/item/card/emag/doorjack

/datum/outfit/pirate/interdyne/captain
	name = "Ex-Interdyne Senior Resident"

	id_trim = /datum/id_trim/syndicom/Interdyne/pharmacist_director

/datum/outfit/pirate/grey
	name = "The Grey Tide"

	id = /obj/item/card/id/advanced/chameleon
	uniform = /obj/item/clothing/under/color/grey/ancient
	suit = null
	back = /obj/item/storage/backpack/satchel
	mask = /obj/item/clothing/mask/chameleon
	glasses = null
	head = null
	shoes = /obj/item/clothing/shoes/sneakers/black
	l_pocket = /obj/item/reagent_containers/cup/glass/coffee
	r_pocket = /obj/item/tank/internals/emergency_oxygen

/datum/outfit/pirate/irs
	name = "IRS Agent Outfit"
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/syndicom/irs
	uniform = /obj/item/clothing/under/costume/buttondown/slacks
	suit = /obj/item/clothing/suit/costume/irs
	back = null
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = null
	head = /obj/item/clothing/head/costume/irs
	shoes = /obj/item/clothing/shoes/laceup
	ears = /obj/item/radio/headset/syndicate/alt

/datum/outfit/pirate/irs/auditor
	name = "IRS Head Auditor"
	id_trim = /datum/id_trim/syndicom/irs/auditor
	uniform = /obj/item/clothing/under/suit/charcoal
	neck = /obj/item/clothing/neck/tie/red/tied
	suit = null
	ears = /obj/item/radio/headset/syndicate/alt/leader
	head = null
	belt = /obj/item/storage/belt/holster/detective/full/ert

/datum/outfit/pirate/lustrous
	name = "Lustrous Scintillant"

	id = /obj/item/card/id/advanced/black
	uniform = /obj/item/clothing/under/ethereal_tunic
	suit = /obj/item/clothing/suit/hooded/ethereal_raincoat
	back = /obj/item/storage/backpack/satchel
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/bhop
	l_pocket = /obj/item/switchblade

/datum/outfit/pirate/lustrous/captain
	name = "Lustrous Radiant"

	glasses = null
	suit = /obj/item/clothing/suit/jacket/oversized
	head = /obj/item/clothing/head/costume/crown

	id_trim = /datum/id_trim/pirate/captain

/datum/outfit/pirate/medieval
	name = "Medieval Warmonger"

	id = null
	glasses = null
	uniform = /obj/item/clothing/under/costume/gamberson/military
	suit = /obj/item/clothing/suit/armor/vest/military
	suit_store = /obj/item/spear/military
	back = /obj/item/storage/backpack/satchel/leather
	gloves = /obj/item/clothing/gloves/color/brown
	head = /obj/item/clothing/head/helmet/military
	mask = /obj/item/clothing/mask/balaclava
	shoes = /obj/item/clothing/shoes/workboots
	belt = /obj/item/claymore/shortsword
	l_pocket = /obj/item/flashlight/flare/torch

/datum/outfit/pirate/medieval/warlord
	name = "Medieval Warlord"

	neck = /obj/item/bedsheet/pirate
	suit = /obj/item/clothing/suit/armor/riot/knight/warlord
	suit_store = null
	back = /obj/item/fireaxe/boardingaxe
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/helmet/knight/warlord
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/bronze
	belt = /obj/item/gun/magic/hook
	l_pocket = /obj/item/tank/internals/emergency_oxygen
	r_pocket = /obj/item/flashlight/lantern


	skillchips = list(/obj/item/skillchip/big_pointer) //they don't have an id, so this is needed
