/obj/item/weapon/gun/ballistic/revolver
	fire_sound = 'hippiestation/sound/weapons/gunshot_magnum.ogg'

/obj/item/weapon/gun/ballistic/revolver/attackby(obj/item/A, mob/user, params)
	..()
	if(num_loaded)
		playsound(user, 'hippiestation/sound/weapons/speedload.ogg', 60, 1)
