/obj/item/projectile/bullet/reusable
	name = "reusable bullet"
	desc = "How do you even reuse a bullet?"
	var/obj/item/ammo_casing/caseless/ammo_type = /obj/item/ammo_casing/caseless/

/obj/item/projectile/bullet/reusable/on_hit(var/atom/target, var/blocked = 0)
	if(!proj_hit)
		proj_hit = 1
		if (src.contents.len)
			var/obj/content
			for(content in src.contents)
				content.loc = src.loc
		else
			new ammo_type(src.loc)
	..()

/obj/item/projectile/bullet/reusable/on_range()
	if(!proj_hit)
		if (src.contents.len)
			var/obj/content
			for(content in src.contents)
				content.loc = src.loc
		else
			new ammo_type(src.loc)
		..()

/obj/item/projectile/bullet/reusable/magspear
	name = "magnetic spear"
	desc = "WHITE WHALE, HOLY GRAIL"
	damage = 30 //takes 3 spears to kill a mega carp, one to kill a normal carp
	icon_state = "magspear"
	ammo_type = /obj/item/ammo_casing/caseless/magspear

/obj/item/projectile/bullet/reusable/foam_dart
	name = "foam dart"
	desc = "I hope you're wearing eye protection."
	damage = 0 // It's a damn toy.
	damage_type = OXY
	nodamage = 1
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foamdart"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	range = 10

/obj/item/projectile/bullet/reusable/foam_dart/riot
	name = "riot foam dart"
	icon_state = "foamdart_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	stamina = 25