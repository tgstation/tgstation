/obj/item/weapon
	name = "weapon"
	icon = 'icons/obj/items_and_weapons.dmi'

/obj/item/Initialize()
	. = ..()
	if(!hitsound)
		if(damtype == "fire")
			hitsound = 'sound/items/welder.ogg'
		if(damtype == "brute")
			hitsound = "swing_hit"
