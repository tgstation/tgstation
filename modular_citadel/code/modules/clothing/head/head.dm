/*/////////////////////////////////////////////////////////////////////////////////
///////																		///////
///////			Cit's exclusive hats, helmets, etc. go here			///////
///////																		///////
*//////////////////////////////////////////////////////////////////////////////////

/obj/item/clothing/head/flakhelm	//Actually the M1 Helmet
	name = "flak helmet"
	icon = 'modular_citadel/icons/obj/clothing/space_nam.dmi'
	alternate_worn_icon = 'modular_citadel/icons/mob/clothing/space_nam.dmi'
	icon_state = "m1helm"
	item_state = "helmet"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0.1, "bio" = 0, "rad" = 0, "fire" = -10, "acid" = -15)
	desc = "A dilapidated helmet used in ancient wars. This one is brittle and essentially useless. An ace of spades is tucked into the band around the outer shell."
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/tiny/spacenam	//So you can stuff other things in the elastic band instead of it simply being a fluff thing.

//The "pocket" for the M1 helmet so you can tuck things into the elastic band

/datum/component/storage/concrete/pockets/tiny/spacenam
	attack_hand_interact = TRUE		//So you can actually see what you stuff in there