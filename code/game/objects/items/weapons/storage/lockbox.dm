//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

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
	var/locked = 1
	var/broken = 0
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"


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
			broken = 1
			locked = 0
			desc = "It appears to be broken."
			icon_state = src.icon_broken
			if(istype(W, /obj/item/weapon/melee/energy/blade))
				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0, src.loc)
				spark_system.start()
				playsound(get_turf(src), 'sound/weapons/blade1.ogg', 50, 1)
				playsound(get_turf(src), "sparks", 50, 1)
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

	bullet_act(var/obj/item/projectile/Proj)
		// WHY MUST WE DO THIS
		// WHY
		if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
			if(!istype(Proj ,/obj/item/projectile/beam/lastertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
				health -= Proj.damage
		..()
		if(health <= 0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
			del(src)
		return

	ex_act(severity)
		var/newsev = max(3,severity+1)
		for(var/atom/movable/A as mob|obj in src)//pulls everything out of the locker and hits it with an explosion
			A.loc = src.loc
			A.ex_act(newsev)
		newsev=4-severity
		if(prob(newsev*25)+25) // 1=100, 2=75, 3=50
			qdel(src)

/obj/item/weapon/storage/lockbox/emp_act(severity)
	..()
	if(!broken)
		switch(severity)
			if(1)
				if(prob(80))
					locked = !locked
					src.update_icon()
			if(2)
				if(prob(50))
					locked = !locked
					src.update_icon()
			if(3)
				if(prob(25))
					locked = !locked
					src.update_icon()

/obj/item/weapon/storage/lockbox/update_icon()
	..()
	if (broken)
		icon_state = src.icon_broken
	else if(locked)
		icon_state = src.icon_locked
	else
		icon_state = src.icon_closed
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

/obj/item/weapon/storage/lockbox/tracking
	name = "Lockbox (Tracking Implants)"
	req_access = list(access_security)

	New()
		..()
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implantcase/tracking(src)
		new /obj/item/weapon/implantpad(src)
		new /obj/item/weapon/implanter(src)

/obj/item/weapon/storage/lockbox/chem
	name = "Lockbox (Chemical Implants)"
	req_access = list(access_security)

	New()
		..()
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/implantcase/chem(src)
		new /obj/item/weapon/reagent_containers/syringe(src)
		new /obj/item/weapon/implanter(src)

/obj/item/weapon/storage/lockbox/clusterbang
	name = "lockbox (clusterbang)"
	desc = "You have a bad feeling about opening this."
	req_access = list(access_security)

	New()
		..()
		new /obj/item/weapon/grenade/flashbang/clusterbang(src)
