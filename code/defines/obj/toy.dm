/obj/item/toy/ammo/gun
	icon = 'ammo.dmi'
	flags = FPRINT | TABLEPASS| CONDUCT
	m_amt = 100
	throwforce = 2
	w_class = 1.0
	throw_speed = 4
	throw_range = 20
	desc = "There are 7 caps left!"
	name = "ammo-caps"
	icon_state = "357-7"
	var/amount_left = 7.0

/obj/item/toy/ammo/crossbow
	icon = 'toy.dmi'
	flags = FPRINT | TABLEPASS
	m_amt = 100
	throwforce = 2
	w_class = 1.0
	throw_speed = 4
	throw_range = 20
	desc = "its nerf or nothing!"
	name = "foam dart"
	icon_state = "foamdart"

/obj/foam_dart_dummy
	name = ""
	desc = ""
	icon = 'toy.dmi'
	icon_state = "null"
	anchored = 1
	density = 0

/obj/item/toy/gun
	name = "cap gun"
	icon = 'gun.dmi'
	flags =  FPRINT | TABLEPASS | CONDUCT | ONBELT | USEDELAY
	throwforce = 5
	throw_speed = 4
	throw_range = 10
	desc = "There are 0 caps left. Looks just like the real thing!"
	icon_state = "revolver"
	item_state = "gun"
	var/bullets = 7.0
	w_class = 3.0
	force = 0.0
	m_amt = 100

/obj/item/toy/crossbow
	name = "foam dart crossbow"
	icon = 'gun.dmi'
	desc = "A weapon favored by many overactive children."
	icon_state = "crossbow"
	flags = FPRINT | TABLEPASS | USEDELAY
	w_class = 2.0
	item_state = "crossbow"
	force = 0.0
	throw_speed = 2
	throw_range = 10
	var/bullets = 5
	m_amt = 100

	examine()
		set src in view(2)
		..()
		if (bullets)
			usr << "\blue It is loaded with [bullets] foam darts!"

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I, /obj/item/toy/ammo/crossbow))
			if(bullets <= 4)
				user.drop_item()
				del(I)
				bullets++
				user << "\blue You load the foam dart into the crossbow."
			else
				usr << "\red It's already fully loaded."


obj/item/toy/crossbow/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if(!isturf(target.loc) || target == user) return
	if(flag) return

	if (locate (/obj/table, src.loc))
		return
	else if (bullets)
		var/turf/trg = get_turf(target)
		var/obj/foam_dart_dummy/D = new/obj/foam_dart_dummy(get_turf(src))
		bullets--
		D.icon_state = "foamdart"
		D.name = "foam dart"
		playsound(user.loc, 'syringeproj.ogg', 50, 1)

		for(var/i=0, i<6, i++)
			if(D.loc == trg) break
			step_towards(D,trg)

			for(var/mob/living/carbon/M in D.loc)
				if(!istype(M,/mob/living/carbon)) continue
				if(M == user) continue
				for(var/mob/O in viewers(world.view, D))
					O.show_message(text("\red [] was hit by the foam dart!", M), 1)
				new /obj/item/toy/ammo/crossbow(M.loc)
				del(D)
				return

			for(var/atom/A in D.loc)
				if(A == user) continue
				if(A.density)
					new /obj/item/toy/ammo/crossbow(A.loc)
					del(D)

			sleep(1)

		spawn(10)
			new /obj/item/toy/ammo/crossbow(D.loc)
			del(D)

		return

obj/item/toy/crossbow/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)

// ******* Check

	if (src.bullets > 0 && M.lying)

		for(var/mob/O in viewers(M, null))
			if(O.client)
				O.show_message(text("\red <B>[] casually lines up a shot with []'s head and pulls the trigger!</B>", user, M), 1, "\red You hear the sound of foam against skull", 2)
				playsound(user.loc, 'syringeproj.ogg', 50, 1)
				O.show_message(text("\red [] was hit in the head by the foam dart!", M), 1)
				new /obj/item/toy/ammo/crossbow(M.loc)
				src.bullets--
	else if (M.lying && !src.bullets)
		for(var/mob/O in viewers(M, null))
			if (O.client)	O.show_message(text("\red <B>[] casually lines up a shot with []'s head, then realizes they are out of ammo!</B>", user, M), 1, "\red You hear nothing", 2)
	return

/obj/item/toy/ammo/gun/proc/update_icon()
	src.icon_state = text("357-[]", src.amount_left)
	src.desc = text("There are [] caps\s left!", src.amount_left)
	return

/obj/item/toy/gun/examine()
	set src in usr

	src.desc = text("There are [] caps\s left. Looks just like the real thing!", src.bullets)
	..()
	return

obj/item/toy/gun/attackby(obj/item/toy/ammo/gun/A as obj, mob/user as mob)

	if (istype(A, /obj/item/toy/ammo/gun))
		if (src.bullets >= 7)
			user << "\blue It's already fully loaded!"
			return 1
		if (A.amount_left <= 0)
			user << "\red There is no more caps!"
			return 1
		if (A.amount_left < (7 - src.bullets))
			src.bullets += A.amount_left
			user << text("\red You reload [] caps\s!", A.amount_left)
			A.amount_left = 0
		else
			user << text("\red You reload [] caps\s!", 7 - src.bullets)
			A.amount_left -= 7 - src.bullets
			src.bullets = 7
		A.update_icon()
		return 1
	return

obj/item/toy/gun/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if (flag)
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	src.add_fingerprint(user)
	if (src.bullets < 1)
		user.show_message("\red *click* *click*", 2)
		return
	playsound(user, 'Gunshot.ogg', 100, 1)
	src.bullets--
	for(var/mob/O in viewers(user, null))
		O.show_message(text("\red <B>[] fires a cap gun at []!</B>", user, target), 1, "\red You hear a gunshot", 2)


