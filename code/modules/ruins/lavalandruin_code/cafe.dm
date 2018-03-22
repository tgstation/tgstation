//Lavaland Cafe!
/obj/effect/mob_spawn/human/cafe
	name = "Cafe Staff"
	roundstart = FALSE
	death = FALSE
	instant = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	flavour_text = "<span class='big bold'>You are a staffmember of this cafe! Don't stray too far from it without a good reason to, and your service to your customers and your cafe comes above all else!</span>"
	assignedrole = "Cafe Staff"
	outfit = /datum/outfit/cafe_staff
	additional_ghost_info = "Your current character slot will be completely copied into the new mob, however the name will be randomized based on your species."

/datum/outfit/cafe_staff
	name = "Cafe Staff"

	uniform = /obj/item/clothing/under/rank/bartender
	back = /obj/item/storage/backpack/satchel/leather/withwallet
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/beret
	neck = /obj/item/clothing/neck/stripedbluescarf
	ears = /obj/item/clothing/ears/headphones
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/card/id
	backpack_contents = list(/obj/item/storage/box/survival = 1, /obj/item/reagent_containers/spray/cleaner = 1, /obj/item/mop/advanced = 1)

/datum/outfit/cafe_staff/post_equip(mob/living/carbon/human/H)
	. = ..()
	if(H && H.client && H.client.prefs)
		H.client.prefs.copy_to(H, TRUE)
	H.set_species(/datum/species/human)
	H.fully_replace_character_name(H.real_name, H.dna.species.random_name(H.gender, TRUE))
	var/obj/item/card/id/C = H.wear_id
	if(istype(C))
		C.access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
		shuffle_inplace(C.access) // Shuffle access list to make NTNet passkeys less predictable
		C.registered_name = H.real_name
		C.assignment = "Cafe Staff"
		C.update_label()
		H.sec_hud_set_ID()

/obj/item/device/gps/internal/cafe
	gpstag = "Servicing Signal"
