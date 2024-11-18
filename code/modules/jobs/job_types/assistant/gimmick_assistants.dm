// This file contains the louadouts for the assistant gimmicks station trait! When active, gives assistants random stupid gear

/// Parent type of gimmick loadouts for assistants for the functional assistant station traits
/datum/outfit/job/assistant/gimmick
	name = "Gimmick Assistant"
	/// The weight of the outfit to be picked
	var/outfit_weight = 0


/datum/outfit/job/assistant/gimmick/give_jumpsuit(mob/living/carbon/human/target)
	return //dont do colorized and stuff, it messes with our uniforms

/datum/outfit/job/assistant/gimmick/bee
	name = "Gimmick Assistant - Bee"
	suit = /obj/item/clothing/suit/hooded/bee_costume
	uniform = /obj/item/clothing/under/color/yellow

	l_pocket = /obj/item/coupon/bee

	outfit_weight = 2

/obj/item/coupon/bee
	desc = "BEEEES???? AT AN AFFORDAbLE PORICE?!!!" //wordcoders seething

	discounted_pack = /datum/supply_pack/organic/hydroponics/beekeeping_fullkit
	discount_pct_off = 0.7

/datum/outfit/job/assistant/gimmick/chicken
	name = "Gimmick Assistant - Chicken"
	suit = /obj/item/clothing/suit/costume/chickensuit
	head = /obj/item/clothing/head/costume/chicken

	l_hand = /obj/item/storage/fancy/egg_box/fertile

	outfit_weight = 2

/datum/outfit/job/assistant/gimmick/cyborg
	name = "Gimmick Assistant - Cardborg"
	suit = /obj/item/clothing/suit/costume/cardborg
	head = /obj/item/clothing/head/costume/cardborg
	uniform = /obj/item/clothing/under/color/black

	r_hand = /obj/item/weldingtool/largetank
	l_hand = /obj/item/stack/cable_coil/five

	uniform = /obj/item/clothing/under/color/black

	outfit_weight = 2

/datum/outfit/job/assistant/gimmick/cyborg/post_equip(mob/living/carbon/human/equipped, visuals_only)
	. = ..()
	var/obj/item/organ/tongue/robot/robotongue = new ()
	robotongue.Insert(equipped, movement_flags = DELETE_IF_REPLACED)

/datum/outfit/job/assistant/gimmick/skater
	name = "Gimmick Assistant - Skater"
	head = /obj/item/clothing/head/helmet/taghelm/red
	suit = /obj/item/clothing/suit/redtag

	l_hand = /obj/item/melee/skateboard

	uniform = /obj/item/clothing/under/color/orange

	outfit_weight = 6

/datum/outfit/job/assistant/gimmick/rollerskater
	name = "Gimmick Assistant - Rollerskater"
	head = /obj/item/clothing/head/helmet/taghelm/blue
	suit = /obj/item/clothing/suit/bluetag

	shoes = /obj/item/clothing/shoes/wheelys/rollerskates

	uniform = /obj/item/clothing/under/color/darkblue

	outfit_weight = 6

/datum/outfit/job/assistant/gimmick/fisher
	name = "Gimmick Assistant - Fisher"
	suit = /obj/item/clothing/suit/jacket/puffer/vest
	uniform = /obj/item/clothing/under/color/blue

	r_hand = /obj/item/storage/toolbox/fishing

	outfit_weight = 3

/datum/outfit/job/assistant/gimmick/patient
	name = "Gimmick Assistant - Patient"
	suit = /obj/item/clothing/suit/apron/surgical

	l_pocket = /obj/item/storage/pill_bottle/multiver
	r_pocket = /obj/item/storage/pill_bottle/mutadone

	uniform = /obj/item/clothing/under/color/white

	outfit_weight = 3

/datum/outfit/job/assistant/gimmick/mopper
	name = "Gimmick Assistant - Mopper"
	suit = /obj/item/clothing/suit/caution
	uniform = /obj/item/clothing/under/color/lightpurple

	l_hand = /obj/item/mop

	outfit_weight = 5

/datum/outfit/job/assistant/gimmick/mopper/post_equip(mob/living/carbon/human/equipped, visuals_only)
	. = ..()

	for(var/turf/turf in range(1, equipped))
		if(turf.is_blocked_turf())
			continue
		var/obj/structure/mop_bucket/bucket = new /obj/structure/mop_bucket(turf)
		equipped.start_pulling(bucket)
		break

/datum/outfit/job/assistant/gimmick/broomer
	name = "Gimmick Assistant - Broomer"
	suit = /obj/item/clothing/suit/caution
	uniform = /obj/item/clothing/under/color/lightpurple

	l_hand = /obj/item/pushbroom
	r_hand = /obj/item/storage/bag/trash

	outfit_weight = 5

/datum/outfit/job/assistant/gimmick/hall_monitor
	name = "Gimmick Assistant - Hall Monitor"
	head = /obj/item/clothing/head/collectable/police
	mask = /obj/item/clothing/mask/whistle
	uniform = /obj/item/clothing/under/color/red

	neck = /obj/item/camera

	outfit_weight = 2

/datum/outfit/job/assistant/gimmick/monkey
	name = "Gimmick Assistant - Monkey"
	suit = /obj/item/clothing/suit/costume/monkeysuit
	mask = /obj/item/clothing/mask/gas/monkeymask
	l_pocket = /obj/item/food/monkeycube
	r_pocket = /obj/item/food/monkeycube

	outfit_weight = 1

/datum/outfit/job/assistant/gimmick/flesh
	name = "Gimmick Assistant - Fleshy"
	suit = /obj/item/clothing/suit/hooded/bloated_human
	r_hand = /obj/item/toy/foamblade

	outfit_weight = 1

/datum/outfit/job/assistant/gimmick/lightbringer
	name = "Gimmick Assistant - Lightbringer"
	uniform = /obj/item/clothing/under/color/yellow
	head = /obj/item/clothing/head/costume/cueball
	gloves = /obj/item/clothing/gloves/color/black

	l_pocket = /obj/item/flashlight/lantern
	r_pocket = /obj/item/lightreplacer

	outfit_weight = 3

/datum/outfit/job/assistant/gimmick/handyman
	name = "Gimmick Assistant - Handyman"

	suit = /obj/item/clothing/suit/hazardvest
	belt = /obj/item/storage/belt/utility/full
	head = /obj/item/clothing/head/utility/hardhat
	uniform = /obj/item/clothing/under/color/yellow
	l_pocket = /obj/item/modular_computer/pda/assistant

	outfit_weight = 6

/datum/outfit/job/assistant/gimmick/magician
	name = "Gimmick Assistant - Magician"

	head = /obj/item/clothing/head/hats/tophat
	uniform = /obj/item/clothing/under/color/lightpurple

	l_hand = /obj/item/gun/magic/wand/nothing

	outfit_weight = 2

/datum/outfit/job/assistant/gimmick/firefighter
	name = "Gimmick Assistant - Firefighter"

	head = /obj/item/clothing/head/utility/hardhat/red
	suit = /obj/item/clothing/suit/hazardvest
	uniform = /obj/item/clothing/under/color/red

	l_pocket = /obj/item/stack/medical/ointment
	r_pocket = /obj/item/extinguisher/mini

	outfit_weight = 3

/datum/outfit/job/assistant/gimmick/gardener
	name = "Gimmick Assistant - Gardener"
	uniform = /obj/item/clothing/under/color/green
	skillchips = list(/obj/item/skillchip/bonsai)

	l_pocket = /obj/item/knife/plastic
	l_hand = /obj/item/kirbyplants/random

	outfit_weight = 3

/datum/outfit/job/assistant/gimmick/artist
	name = "Gimmick Assistant - Artist"
	uniform = /obj/item/clothing/under/color/rainbow

	backpack_contents = list(/obj/item/storage/crayons)

	outfit_weight = 3
