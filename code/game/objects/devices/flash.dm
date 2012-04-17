/obj/item/device/flash
	name = "flash"
	desc = "Used for blinding and being an asshole."
	icon_state = "flash"
	throwforce = 5
	w_class = 1.0
	throw_speed = 4
	throw_range = 10
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	origin_tech = "magnets=2;combat=1"

	var
		shots_left = 5
		max_shots = 5
		broken = 0

	proc
		clown_check(var/mob/user)
		recharge()




	attack(mob/living/M as mob, mob/user as mob)
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been flashed (attempt) with [src.name]  by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to flash [M.name] ([M.ckey])</font>")
		log_admin("ATTACK: [user] ([user.ckey]) flashed [M] ([M.ckey]) with [src].")
		message_admins("ATTACK: [user] ([user.ckey]) flashed [M] ([M.ckey]) with [src].")
		if(!clown_check(user))	return
		if(broken)
			user.show_message("\red The [src.name] is broken", 2)
			return

		if(shots_left <= 0)
			user.show_message("\red *click* *click*", 2)
			for(var/mob/K in viewers(usr))
				K << 'empty.ogg'
			return

		playsound(src.loc, 'flash.ogg', 100, 1)
		shots_left--
		var/flashfail = 0

		if(iscarbon(M))
			var/safety = M:eyecheck()
			if(safety <= 0)
				M.Weaken(10)
				flick("e_flash", M.flash)

				if(ishuman(M) && ishuman(user))
					if(user.mind in ticker.mode.head_revolutionaries)
						var/revsafe = 0
						for(var/datum/organ/external/O in M.organs)
							for(var/obj/item/weapon/implant/loyalty/L in O.implant)
								if(L && L.implanted)
									revsafe = 1
									break
						if(M.mind.has_been_rev)
							revsafe = 2
						if(!revsafe)
							M.mind.has_been_rev = 1
							ticker.mode.add_revolutionary(M.mind)
						else if(revsafe == 1)
							user << "\red Something seems to be blocking the flash!"
						else
							user << "\red This mind seems resistant to the flash!"
			else
				flashfail = 1

		else if(issilicon(M))
			M.Weaken(rand(5,10))

		if(isrobot(user))
			spawn(0)
				var/atom/movable/overlay/animation = new(user.loc)
				animation.layer = user.layer + 1
				animation.icon_state = "blank"
				animation.icon = 'mob.dmi'
				animation.master = user
				flick("blspell", animation)
				sleep(5)
				del(animation)


		if(!flashfail)
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [] blinds [] with the flash!", user, M))
		else
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\blue [] fails to blind [] with the flash!", user, M))



		if (prob(2))
			broken = 1
			user << "\red The bulb has burnt out!"
			icon_state = "flashburnt"

		spawn(60)
			recharge()

		return


	attack_self(mob/living/carbon/user as mob, flag = 0, emp = 0)
		if(!emp)
			if (!clown_check(user)) return
		if(broken)
			if(user)
				user.show_message("\red The [src.name] is broken", 2)
			return

		if(shots_left <= 0)
			if(user)
				user.show_message("\red *click* *click*", 2)
			return

		playsound(src.loc, 'flash.ogg', 100, 1)
		shots_left--

		flick("flash2", src)
		if(isrobot(user))
			spawn(0)
				var/atom/movable/overlay/animation = new(user.loc)
				animation.layer = user.layer + 1
				animation.icon_state = "blank"
				animation.icon = 'mob.dmi'
				animation.master = user
				flick("blspell", animation)
				sleep(5)
				del(animation)

		for(var/mob/living/carbon/M in oviewers(3, null))
			if(prob(50))
				if (locate(/obj/item/weapon/cloaking_device, M))
					for(var/obj/item/weapon/cloaking_device/S in M)
						S.active = 0
						S.icon_state = "shield0"
			var/safety = M:eyecheck()
			if(!safety)
				flick("flash", M.flash)

		if (prob(2))
			broken = 1
			icon_state = "flashburnt"
			if(user)
				user << "\red The bulb has burnt out!"
			return

		spawn(60)
			recharge()

		return


	emp_act(severity)
		src.attack_self(null,1,1)
		..()


	clown_check(var/mob/user)
		if((user.mutations & CLUMSY) && prob(50))
			user << "\red The Flash slips out of your hand."
			user.drop_item()
			return 0
		return 1


	recharge()
		if(max_shots > shots_left)
			shots_left++
		if(max_shots > shots_left)
			spawn(60)//more or less 10 seconds
				recharge()
		return