/obj/item/weapon/secstorage/sbriefcase
	name = "secure briefcase"
	icon = 'storage.dmi'
	icon_state = "secure"
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system."
	flags = FPRINT | TABLEPASS
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0

/obj/item/weapon/secstorage/sbriefcase/New()
	..()
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/pen(src)

/obj/item/weapon/secstorage/sbriefcase/attack(mob/M as mob, mob/living/user as mob)
	if ((CLUMSY in user.mutations) && prob(50))
		user << "\red The [src] slips out of your hand and hits your head."
		user.take_organ_damage(10)
		user.Paralyse(2)
		return


	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	log_admin("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	message_admins("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

	var/t = user:zone_sel.selecting
	if (t == "head")
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
