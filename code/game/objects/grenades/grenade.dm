/obj/item/weapon/grenade
	name = "grenade"
	desc = "A hand held grenade, with an adjustable timer."
	w_class = 2.0
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	item_state = "grenade"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	var/active = 0
	var/det_time = 50

/obj/item/weapon/grenade/proc/clown_check(var/mob/living/user)
	if((CLUMSY in user.mutations) && prob(50))
		user << "<span class='warning'>Huh? How does this thing work?</span>"
		active = 1
		icon_state = initial(icon_state) + "_active"
		playsound(loc, 'armbomb.ogg', 75, 1, -3)
		spawn(5)
			if(user)
				user.drop_item()
			prime()
		return 0
	return 1


/*/obj/item/weapon/grenade/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if (istype(target, /obj/item/weapon/storage)) return ..() // Trying to put it in a full container
	if (istype(target, /obj/item/weapon/gun/grenadelauncher)) return ..()
	if((user.get_active_hand() == src) && (!active) && (clown_check(user)) && target.loc != src.loc)
		user << "<span class='warning'>You prime the [name]! [det_time/10] seconds!</span>"
		active = 1
		icon_state = initial(icon_state) + "_active"
		playsound(loc, 'armbomb.ogg', 75, 1, -3)
		spawn(det_time)
			prime()
			return
		user.dir = get_dir(user, target)
		user.drop_item()
		var/t = (isturf(target) ? target : target.loc)
		walk_towards(src, t, 3)
	return*/


/obj/item/weapon/grenade/examine()
	set src in usr
	usr << desc
	if(det_time > 1)
		usr << "The timer is set to [det_time/10] seconds."
		return
	usr << "\The [src] is set for instant detonation."


/obj/item/weapon/grenade/attack_self(mob/user as mob)
	if(!active)
		if(clown_check(user))
			user << "<span class='warning'>You prime the [name]! [det_time/10] seconds!</span>"
			active = 1
			icon_state = initial(icon_state) + "_active"
			add_fingerprint(user)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
			spawn(det_time)
				if(user)
					user.drop_item()
				prime()
				return
	return


/obj/item/weapon/grenade/proc/prime()
	playsound(loc, 'Welder2.ogg', 25, 1)
	var/turf/T = get_turf(src)
	if(T)
		T.hotspot_expose(700,125)


/obj/item/weapon/grenade/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(isscrewdriver(W))
		switch(det_time)
			if ("1")
				det_time = 30
				user << "<span class='notice'>You set the [name] for 3 second detonation time.</span>"
			if ("30")
				det_time = 100
				user << "<span class='notice'>You set the [name] for 10 second detonation time.</span>"
			if ("100")
				det_time = 1
				user << "<span class='notice'>You set the [name] for instant detonation.</span>"
		add_fingerprint(user)
	..()
	return

/obj/item/weapon/grenade/attack_hand()
	walk(src, null, null)
	..()
	return

/obj/item/weapon/grenade/attack_paw(mob/user as mob)
	return attack_hand(user)
