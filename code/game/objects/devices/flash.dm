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

	var/times_used = 0 //Number of times it's been used.
	var/broken = 0     //Is the flash burnt out?
	var/last_used = 0 //last world.time it was used.

/obj/item/device/flash/proc/clown_check(var/mob/user)
	if((user.mutations & CLUMSY) && prob(50))
		user << "\red The Flash slips out of your hand."
		user.drop_item()
		return 0
	return 1


/obj/item/device/flash/attack(mob/living/M as mob, mob/user as mob)
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been flashed (attempt) with [src.name]  by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to flash [M.name] ([M.ckey])</font>")

	log_attack("<font color='red'>[user.name] ([user.ckey]) Used the [src.name] to flash [M.name] ([M.ckey])</font>")


	if(!clown_check(user))	return
	if(broken)
		user.show_message("\red The [src.name] is broken", 2)
		return

	//capacitor recharges over time
	for(var/i=0, i<3, i++)
		if(last_used+600 > world.time)
			break
		last_used += 600
		times_used--

	//spamming the flash before it's fully charged (60seconds) increases the chance of it  breaking
	//It will never break on the first use.
	times_used = max(0,round(times_used)) //sanity
	switch(times_used)
		if(0 to 5)
			last_used = world.time
			if(prob(times_used))	//if you use it 5 times in a minute it has a 10% chance to break!
				broken = 1
				user << "\red The bulb has burnt out!"
				icon_state = "flashburnt"
				return
			times_used++
		else	//can only use it  5 times a minute
			user.show_message("\red *click* *click*", 2)
			return
	playsound(src.loc, 'flash.ogg', 100, 1)
	var/flashfail = 0

	if(iscarbon(M))
		var/safety = M:eyecheck()
		if(safety <= 0)
			M.Weaken(10)
			flick("e_flash", M.flash)

			if(ishuman(M) && ishuman(user))
				if(user.mind in ticker.mode.head_revolutionaries)
					var/revsafe = 0
					for(var/obj/item/weapon/implant/loyalty/L in M)
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
		if(!M:flashproof())
			M.Weaken(rand(5,10))
		else
			flashfail++

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

	return


/obj/item/device/flash/attack_self(mob/living/carbon/user as mob, flag = 0, emp = 0)
	if(!emp)
		if (!clown_check(user)) return
	if(broken)
		if(user)
			user.show_message("\red The [src.name] is broken", 2)
		return

	//capacitor recharges over time
	for(var/i=0, i<3, i++)
		if(last_used+600 > world.time)
			break
		last_used += 600
		times_used -= 2
	last_used = world.time

	//spamming the flash before it's fully charged (60seconds) increases the chance of it  breaking
	//It will never break on the first use.
	times_used = max(0,round(times_used)) //sanity
	switch(times_used)
		if(0 to 5)
			if(prob(2*times_used))	//if you use it 5 times in a minute it has a 10% chance to break!
				broken = 1
				user << "\red The bulb has burnt out!"
				icon_state = "flashburnt"
				return
			times_used++
		else	//can only use it  5 times a minute
			user.show_message("\red *click* *click*", 2)
			return
	playsound(src.loc, 'flash.ogg', 100, 1)
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

	return

/obj/item/device/flash/emp_act(severity)
	src.attack_self(null,1,1)
	..()
