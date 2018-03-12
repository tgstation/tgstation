//Maid Cafe!
/obj/effect/mob_spawn/human/maidcafe
	name = "Maid cafe maid"
	roundstart = FALSE
	death = FALSE
	instant = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	flavour_text = "<span class='big bold'>You are a maid of this maid cafe! Don't stray too far from it without a good reason to, and your service to your customers and your cafe comes above all else!</span>"
	assignedrole = "Maid Cafe Maid"
	outfit = /datum/outfit/maidcafe
	additional_ghost_info = "Your current character slot will be completely copied into the new mob, however the name will be randomized based on your species."

/datum/outfit/maidcafe
	name = "Maid Cafe Maid"

	uniform = /obj/item/clothing/under/maid
	suit = /obj/item/clothing/suit/apron/purple_bartender
	back = /obj/item/storage/backpack/satchel/leather/withwallet
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/beret
	neck = /obj/item/clothing/neck/stripedredscarf
	ears = /obj/item/clothing/ears/headphones
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/card/id
	backpack_contents = list(/obj/item/storage/box/survival = 1, /obj/item/reagent_containers/spray/cleaner = 1, /obj/item/mop/advanced = 1)
	accessory = /obj/item/clothing/accessory/maidapron

/datum/outfit/maidcafe/post_equip(mob/living/carbon/human/H)
	. = ..()
	if(H && H.client && H.client.prefs)
		H.client.prefs.copy_to(H, TRUE)
	H.set_species(/datum/species/human)
	H.fully_replace_character_name(H.real_name, H.dna.species.random_name(H.gender, TRUE))

/obj/item/device/gps/internal/maidcafe
	gpstag = "Servicing Signal"
