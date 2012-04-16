/obj/item/weapon/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = 4
	max_w_class = 3
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 4
	req_access = list(access_armory)
	var
		locked = 1
		broken = 0
		icon_locked = "lockbox+l"
		icon_closed = "lockbox"
		icon_broken = "lockbox+b"


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/card/id))
			if(src.broken)
				user << "\red It appears to be broken."
				return
			if(src.allowed(user))
				src.locked = !( src.locked )
				if(src.locked)
					src.icon_state = src.icon_locked
					user << "\red You lock the [src.name]!"
					return
				else
					src.icon_state = src.icon_closed
					user << "\red You unlock the [src.name]!"
					return
			else
				user << "\red Access Denied"
		else if((istype(W, /obj/item/weapon/card/emag)||istype(W, /obj/item/weapon/melee/energy/blade)) && !src.broken)
			if(istype(W, /obj/item/weapon/card/emag))
				var/obj/item/weapon/card/emag/E = W
				if(E.uses)
					E.uses--
				else
					return
			broken = 1
			locked = 0
			desc = "It appears to be broken."
			icon_state = src.icon_broken
			if(istype(W, /obj/item/weapon/melee/energy/blade))
				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0, src.loc)
				spark_system.start()
				playsound(src.loc, 'blade1.ogg', 50, 1)
				playsound(src.loc, "sparks", 50, 1)
				for(var/mob/O in viewers(user, 3))
					O.show_message(text("\blue The locker has been sliced open by [] with an energy blade!", user), 1, text("\red You hear metal being sliced and sparks flying."), 2)
			else
				for(var/mob/O in viewers(user, 3))
					O.show_message(text("\blue The locker has been broken by [] with an electromagnetic card!", user), 1, text("You hear a faint electrical spark."), 2)

		if(!locked)
			..()
		else
			user << "\red Its locked!"
		return


	show_to(mob/user as mob)
		if(locked)
			user << "\red Its locked!"
		else
			..()
		return


/obj/item/weapon/storage/lockbox/loyalty
	name = "Lockbox (Loyalty Implants)"
	req_access = list(access_security)

	New()
		..()
		new /obj/item/weapon/implantcase/loyalty(src)
		new /obj/item/weapon/implantcase/loyalty(src)
		new /obj/item/weapon/implantcase/loyalty(src)
		new /obj/item/weapon/implanter/loyalty(src)


/obj/item/weapon/storage/lockbox/clusterbang
	name = "lockbox (clusterbang)"
	desc = "You have a bad feeling about opening this."
	req_access = list(access_security)

	New()
		..()
		new /obj/item/weapon/flashbang/clusterbang(src)