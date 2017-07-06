/obj/structure/russian_command_post
	icon = 'icons/mob/russians.dmi'
	icon_state = "command_post"

	obj_integrity = 200
	max_integrity = 200

	name = "Russian Command Post"
	desc = "Critical for proper communist support."

/obj/structure/russian_command_post/Destroy()
	new /obj/item/weapon/gun/ballistic/revolver/mateba(get_turf(src))
	new /obj/item/weapon/gun/ballistic/revolver/mateba(get_turf(src))
	new /obj/item/weapon/gun/ballistic/revolver/mateba(get_turf(src))
	new /obj/item/ammo_box/a357(get_turf(src))
	new /obj/item/ammo_box/a357(get_turf(src))
	new /obj/item/ammo_box/a357(get_turf(src))
	new /obj/item/ammo_box/a357(get_turf(src))
	new /obj/item/ammo_box/a357(get_turf(src))
	new /obj/item/ammo_box/a357(get_turf(src))
	new /obj/item/ammo_box/a357(get_turf(src))
	new /obj/item/ammo_box/a357(get_turf(src))
	new /obj/item/ammo_box/a357(get_turf(src))
	..()

/obj/item/russian_reload
	icon = 'icons/mob/russians.dmi'
	icon_state = "ammo_box"

	name = "Russian Ammunition"
	desc = "Resupplies any nearby soldiers."