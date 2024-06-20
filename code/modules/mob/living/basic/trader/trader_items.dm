///Sale signs
/obj/structure/trader_sign
	name = "holographic store sign"
	desc = "A holographic sign that promises great deals."
	icon = 'icons/obj/trader_signs.dmi'
	icon_state = "faceless"
	anchored = TRUE
	armor_type = /datum/armor/trader_sign
	max_integrity = 15
	layer = FLY_LAYER

/datum/armor/trader_sign
	bullet = 50
	laser = 50
	energy = 50
	fire = 20
	acid = 20

/obj/structure/trader_sign/Initialize(mapload)
	. = ..()
	add_overlay("sign")
	makeHologram()


/obj/structure/trader_sign/mrbones
	icon_state = "mrbones"


///Spawners for outfits
/obj/effect/mob_spawn/corpse/human/skeleton/mrbones
	mob_species = /datum/species/skeleton
	outfit = /datum/outfit/mrbonescorpse

/datum/outfit/mrbonescorpse
	name = "Mr Bones' Corpse"
	head = /obj/item/clothing/head/hats/tophat
