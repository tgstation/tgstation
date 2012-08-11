/obj/item/weapon/grenade
	var/det_time = 50
	desc = "It is set to detonate in 5 seconds."
	name = "grenade"
	w_class = 2.0
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	item_state = "grenade"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	var/active = 0

	proc/clown_check(var/mob/living/user)
		if((CLUMSY in user.mutations) && prob(50))
			user << "\red Huh? How does this thing work?!"
			src.active = 1
			src.icon_state = initial(icon_state) + "_active"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn(5)
				src.prime()
			return 0
		return 1

/*	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (istype(target, /obj/item/weapon/storage)) return ..() // Trying to put it in a full container
		if (istype(target, /obj/item/weapon/gun/grenadelauncher)) return ..()
		if((user.get_active_hand() == src) && (!active) && (clown_check(user)) && target.loc != src.loc)
			user << "\red You prime the [name]! [det_time/10] seconds!"
			src.active = 1
			src.icon_state = initial(icon_state) + "_active"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn(src.det_time)
				src.prime()
				return
			user.dir = get_dir(user, target)
			user.drop_item()
			var/t = (isturf(target) ? target : target.loc)
			walk_towards(src, t, 3)
		return*/


	attack_self(mob/user as mob)
		if(!active)
			if(clown_check(user))
				user << "\red You prime the [name]! [det_time/10] seconds!"
				src.active = 1
				src.icon_state = initial(icon_state) + "_active"
				add_fingerprint(user)
				if(iscarbon(user))
					var/mob/living/carbon/C = user
					C.throw_mode_on()
				spawn(src.det_time)
					src.prime()
					return
		return


	proc/prime()
		playsound(src.loc, 'Welder2.ogg', 25, 1)
		var/turf/T = get_turf(src)
		if(T)
			T.hotspot_expose(700,125)


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (isscrewdriver(W))
			switch(src.det_time)
				if ("1")
					src.det_time = 30
					user.show_message("\blue You set the [name] for 3 second detonation time.")
				if ("30")
					src.det_time = 100
					user.show_message("\blue You set the [name] for 10 second detonation time.")
				if ("100")
					src.det_time = 1
					user.show_message("\blue You set the [name] for instant detonation.")
			src.add_fingerprint(user)
			src.desc = "It is set to detonate [det_time-1 ? "in [det_time/10] seconds." : "instantly."]"
		..()
		return

	attack_hand()
		walk(src, null, null)
		..()
		return

	attack_paw(mob/user as mob)
		return src.attack_hand(user)
