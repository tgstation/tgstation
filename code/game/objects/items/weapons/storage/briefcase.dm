/obj/item/weapon/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	flags = FPRINT
	siemens_coefficient = 1
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	max_w_class = 3
	max_combined_w_class = 16
	var/empty = 0

/obj/item/weapon/storage/briefcase/empty
	empty = 1

/obj/item/weapon/storage/briefcase/biogen
	empty = 1
	desc = "Smells faintly of potato."

/obj/item/weapon/storage/briefcase/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'><b>[user] is smashing \his head inside the [src.name]! It looks like \he's  trying to commit suicide!</b></span>")
	return (BRUTELOSS)

/obj/item/weapon/storage/briefcase/New()
	..()
	if (empty) return
	new /obj/item/weapon/paper/demotion_key(src)
	new /obj/item/weapon/paper/commendation_key(src)

/obj/item/weapon/storage/briefcase/attack(mob/living/M as mob, mob/living/user as mob)
	//..()

	if ((M_CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>The [src] slips out of your hand and hits your head.</span>")
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
			to_chat(M, "<span class='warning'>The helmet protects you from being hit hard in the head!</span>")
			return
		var/time = rand(2, 6)
		if (prob(75))
			M.Paralyse(time)
		else
			M.Stun(time)
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			O.show_message(text("<span class='danger'>[] has been knocked unconscious!</span>", M), 1, "<span class='warning'>You hear someone fall.</span>", 2)
	else
		to_chat(M, text("<span class='warning'>[] tried to knock you unconcious!</span>",user))
		M.eye_blurry += 3

	return

/obj/item/weapon/storage/briefcase/false_bottomed
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. This one feels a bit heavier than normal for how much fits in it."
	icon_state = "briefcase"
	force = 8.0
	throw_speed = 1
	throw_range = 3
	w_class = 4.0
	max_w_class = 2
	max_combined_w_class = 10

	var/busy_hunting = 0
	var/bottom_open = 0 //is the false bottom open?
	var/obj/item/stored_item = null //what's in the false bottom. If it's a gun, we can fire it

/obj/item/weapon/storage/briefcase/false_bottomed/Destroy()
	if(stored_item)//since the stored_item isn't in the briefcase' contents we gotta remind the game to delete it here.
		qdel(stored_item)
		stored_item = null
	..()

/obj/item/weapon/storage/briefcase/false_bottomed/afterattack(var/atom/A, mob/user)
	..()
	if(stored_item && istype(stored_item, /obj/item/weapon/gun) && get_dist(A, user) > 1)
		var/obj/item/weapon/gun/stored_gun = stored_item
		stored_gun.Fire(A, user)
	return

/obj/item/weapon/storage/briefcase/false_bottomed/attackby(var/obj/item/item, mob/user)
	if(istype(item, /obj/item/weapon/screwdriver))
		if(!bottom_open && !busy_hunting)
			to_chat(user, "You begin to hunt around the rim of \the [src]...")
			busy_hunting = 1
			if(do_after(user, src, 20))
				if(user)
					to_chat(user, "You pry open the false bottom!")
				bottom_open = 1
			busy_hunting = 0
		else if(bottom_open)
			to_chat(user, "You push the false bottom down and close it with a click[stored_item ? ", with \the [stored_item] snugly inside." : "."]")
			bottom_open = 0
	else if(bottom_open)
		if(stored_item)
			to_chat(user, "<span class='warning'>There's already something in the false bottom!</span>")
			return
		if(item.w_class > 3.0)
			to_chat(user, "<span class='warning'>\The [item] is too big to fit in the false bottom!</span>")
			return
		stored_item = item
		user.drop_item(item)
		max_w_class = 3.0 - stored_item.w_class
		item.loc = null //null space here we go - to stop it showing up in the briefcase
		to_chat(user, "You place \the [item] into the false bottom of the briefcase.")
	else
		return ..()

/obj/item/weapon/storage/briefcase/false_bottomed/attack_hand(mob/user)
	if(bottom_open && stored_item)
		user.put_in_hands(stored_item)
		to_chat(user, "You pull out \the [stored_item] from \the [src]'s false bottom.")
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
