/obj/item/ammo_casing/rocket
	name = "\improper Dardo HE rocket"
	desc = "An 84mm High Explosive rocket. Fire at people and pray."
	caliber = CALIBER_84MM
	icon_state = "srm-8"
	base_icon_state = "srm-8"
	projectile_type = /obj/projectile/bullet/rocket

/obj/item/ammo_casing/rocket/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/rocket/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]"

/obj/item/ammo_casing/rocket/heap
	name = "\improper Dardo HE-AP rocket"
	desc = "An 84mm High Explosive All Purpose rocket. For when you just need something to not exist anymore."
	icon_state = "84mm-heap"
	base_icon_state = "84mm-heap"
	projectile_type = /obj/projectile/bullet/rocket/heap

/obj/item/ammo_casing/rocket/weak
	name = "\improper Dardo HE Low-Yield rocket"
	desc = "An 84mm High Explosive rocket. This one isn't quite as devastating."
	icon_state = "low_yield_rocket"
	base_icon_state = "low_yield_rocket"
	projectile_type = /obj/projectile/bullet/rocket/weak

/obj/item/ammo_casing/rocket/reverse
	projectile_type = /obj/projectile/bullet/rocket/reverse

/obj/item/ammo_casing/a75
	desc = "A .75 bullet casing."
	caliber = CALIBER_75
	icon_state = "s-casing-live"
	base_icon_state = "s-casing-live"
	projectile_type = /obj/projectile/bullet/gyro

/obj/item/ammo_casing/a75/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/a75/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]"
