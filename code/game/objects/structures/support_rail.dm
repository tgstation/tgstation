/obj/structure/support_rail
	desc = "A metal bar used to secure one's self. It has a label on the side that reads: 'Maximum Safe Capacity: 1, Enforceable by Space Law'. It looks pretty serious."
	name = "support rail"
	icon = 'icons/obj/objects.dmi'
	icon_state = "rail"
	density = 0
	anchored = 1
	flags = FPRINT | CONDUCT
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = 2.1
	explosion_resistance = 5
	var/health = 10
	var/destroyed = 0
	var/mob/living/supported_mob

/obj/structure/support_rail/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/metal(src.loc)
		del(src)
	return


/obj/structure/support_rail/Destroy()
	letgo()
	..()
	return

/obj/structure/support_rail/letgo()
	supported_mob.update_canmove()
	supported_mob.shoes.flags &= ~NOSLIP
	src.supported_mob = null
	return

/obj/structure/support_rail/attack_hand(mob/user as mob)
	if(supported_mob) //Anyone can force you to let go
		letgo()
		supported_mob.visible_message(\
					"\blue [supported_mob.name] let go.")
		add_fingerprint(user)
	else
		supported_mob = user //should this be src.supported_mob = user?
		user.visible_message(\
					"\blue [supported_mob.name] grabbed the rail.")
		user.shoes.flags |= NOSLIP
		user.loc = src.loc
		user.dir = src.dir
		user.update_canmove()
		add_fingerprint(user)
	return