/obj/item/weapon/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	max_w_class = 3
	max_combined_w_class = 16

/obj/item/weapon/storage/briefcase/suicide_act(mob/user)
	viewers(user) << "\red <b>[user] is smashing \his head inside the [src.name]! It looks like \he's  trying to commit suicide!</b>"
	return (BRUTELOSS)


/obj/item/weapon/storage/briefcase/New()
	new /obj/item/weapon/paper/demotion_key(src)
	new /obj/item/weapon/paper/commendation_key(src)
	..()

/obj/item/weapon/storage/briefcase/attack(mob/living/M as mob, mob/living/user as mob)
	//..()

	if ((M_CLUMSY in user.mutations) && prob(50))
		user << "\red The [src] slips out of your hand and hits your head."
		user.take_organ_damage(10)
		user.Paralyse(2)
		return


	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>)")
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	if (M.stat < 2 && M.health < 50 && prob(90))
		var/mob/H = M
		// ******* Check
		if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
			M << "\red The helmet protects you from being hit hard in the head!"
			return
		var/time = rand(2, 6)
		if (prob(75))
			M.Paralyse(time)
		else
			M.Stun(time)
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] has been knocked unconscious!</B>", M), 1, "\red You hear someone fall.", 2)
	else
		M << text("\red [] tried to knock you unconcious!",user)
		M.eye_blurry += 3

	return

/obj/item/weapon/storage/briefcase/false_bottomed
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. This one feels a bit heavier than normal for how much fits in it."
	icon_state = "briefcase"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 8.0
	throw_speed = 1
	throw_range = 3
	w_class = 4.0
	max_w_class = 2
	max_combined_w_class = 10

	var/bottom_open = 0 //is the false bottom open?
	var/obj/item/stored_item //what's in the false bottom. If it's a gun, we can fire it

/obj/item/weapon/storage/briefcase/false_bottomed/afterattack(var/atom/A, mob/user)
	..()
	if(stored_item && istype(stored_item, /obj/item/weapon/gun) && get_dist(A, user) > 1)
		var/obj/item/weapon/gun/stored_gun = stored_item
		stored_gun.Fire(A, user)
	return

/obj/item/weapon/storage/briefcase/false_bottomed/attackby(var/obj/item/item, mob/user)
	if(istype(item, /obj/item/weapon/screwdriver))
		switch(bottom_open)
			if(0)
				user << "You begin to hunt around the rim of \the [src]..."
				if(do_after(user, 20))
					user << "You pry open the false bottom!"
					if(stored_item)
						stored_item.loc = get_turf(user)
						stored_item = null
					max_w_class = initial(max_w_class)
					bottom_open = 1
			if(1)
				user << "You push the false bottom down and close it with a click[stored_item ? ", with \the [stored_item] snugly inside." : "."]"
				bottom_open = 0
	else if(bottom_open && item.w_class <= 3.0)
		stored_item = item
		user.drop_item(item)
		max_w_class = 3.0 - stored_item.w_class
		item.loc = null //null space here we go - to stop it showing up in the briefcase
		user << "You place \the [item] into the false bottom of the briefcase."
	else
		return ..()

/obj/item/weapon/storage/briefcase/false_bottomed/attack_hand(mob/user)
	if(bottom_open && stored_item)
		user.put_in_hands(stored_item)
		user << "You pull out \the [stored_item] from \the [src]'s false bottom."
		stored_item = null
		max_w_class = initial(max_w_class)
	else
		return ..()


/obj/item/weapon/storage/briefcase/false_bottomed/smg


/obj/item/weapon/storage/briefcase/false_bottomed/smg/New()
	..()
	var/obj/item/weapon/gun/projectile/automatic/SMG = new
	SMG.gun_flags &= ~AUTOMAGDROP //dont want to drop mags in null space, do we?
	stored_item = SMG