/obj/item/weapon
	name = "weapon"
	icon = 'icons/obj/weapons.dmi'

/obj/item/weapon/Initialize()
	. = ..()
	if(!hitsound)
		if(damtype == "fire")
			hitsound = 'sound/items/welder.ogg'
		if(damtype == "brute")
			hitsound = "swing_hit"
