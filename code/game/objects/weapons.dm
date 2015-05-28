/obj/item/weapon/
	name = "weapon"
	icon = 'icons/obj/weapons.dmi'
	var/no_hitsound = 0 //Make this 1 if you want no hitsounds

/obj/item/weapon/New()
	..()
	if(!hitsound && !no_hitsound)
		if(damtype == "fire")
			hitsound = 'sound/items/welder.ogg'
		if(damtype == "brute")
			hitsound = "swing_hit"

/obj/item/weapon/Bump(mob/M as mob)
	spawn(0)
		..()
	return