/obj/item/weapon/secstorage/sbriefcase
	name = "secure briefcase"
	icon = 'icons/obj/storage.dmi'
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

	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

	log_admin("ATTACK: [user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])")
	msg_admin_attack("ATTACK: [user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])") //BS12 EDIT ALG

	var/t = user:zone_sel.selecting
	if (t == "head")

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if (H.stat < 2 && H.health < 50 && prob(90))
			// ******* Check
				if (istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80))
					H << "\red The helmet protects you from being hit hard in the head!"
					return
				var/time = rand(2, 6)
				if (prob(75))
					H.Paralyse(time)
				else
					H.Stun(time)
				if(H.stat != 2)	H.stat = 1
				for(var/mob/O in viewers(H, null))
					O.show_message(text("\red <B>[] has been knocked unconscious!</B>", H), 1, "\red You hear someone fall.", 2)
			else
				H << text("\red [] tried to knock you unconcious!",user)
				H.eye_blurry += 3

	return
