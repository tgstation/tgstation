/obj/item/device/flash
	name = "flash"
	desc = "Used for blinding and being an asshole."
	icon_state = "flash"
	item_state = "flash"
	throwforce = 5
	w_class = 1.0
	throw_speed = 4
	throw_range = 10
	flags = FPRINT | TABLEPASS| CONDUCT
	origin_tech = "magnets=2;combat=1"

	var/times_used = 0 //Number of times it's been used.
	var/broken = 0     //Is the flash burnt out?
	var/last_used = 0 //last world.time it was used.

/obj/item/device/flash/proc/clown_check(var/mob/user)
	if(user && (M_CLUMSY in user.mutations) && prob(50))
		user << "\red \The [src] slips out of your hand."
		user.drop_item()
		return 0
	return 1

/obj/item/device/flash/proc/flash_recharge()
	//capacitor recharges over time
	for(var/i=0, i<3, i++)
		if(last_used+600 > world.time)
			break
		last_used += 600
		times_used -= 2
	last_used = world.time
	times_used = max(0,round(times_used)) //sanity


/obj/item/device/flash/attack(mob/living/M as mob, mob/user as mob)
	if(!user || !M) //sanity
		return

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been flashed (attempt) with [src.name] by [key_name(user)]</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to flash [key_name(M)]</font>")

	log_attack("<font color='red'>[key_name(user)] Used the [src.name] to flash [key_name(M)]</font>")

	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	if(!clown_check(user))
		return

	if(broken)
		user << "<span class='warning'>\The [src] is broken.</span>"
		return

	flash_recharge()

	//spamming the flash before it's fully charged (60seconds) increases the chance of it  breaking
	//It will never break on the first use.
	switch(times_used)
		if(0 to 5)
			last_used = world.time
			if(prob(times_used))	//if you use it 5 times in a minute it has a 10% chance to break!
				broken = 1
				user << "<span class='warning'>The bulb has burnt out!</span>"
				icon_state = "flashburnt"
				return
			times_used++
		else	//can only use it  5 times a minute
			user << "<span class='warning'>*click* *click*</span>"
			return

	playsound(get_turf(user), 'sound/weapons/flash.ogg', 100, 1)

	var/flashfail = FALSE

	if(iscarbon(M))
		var/mob/living/carbon/Subject = M
		var/safe = Subject.eyecheck()

		if(safe <= 0)
			Subject.Weaken(10)
			flick("e_flash", Subject.flash)

			if(ishuman(user) && user.mind && user.mind in ticker.mode.head_revolutionaries) // alien revhead when?
				if(ishuman(Subject))
					if(Subject.stat != DEAD)
						Subject.mind_initialize() // give them a mind datum if they don't have one

						var/result = ticker.mode.add_revolutionary(Subject.mind)

						if(result == 1)
							log_admin("[key_name(user)] has converted [key_name(Subject)] to the revolution at [formatLocation(Subject.loc)]")
							Subject.mind.has_been_rev = TRUE
						else if(result == -1 || Subject.mind.has_been_rev) // command positions or has been rev before (according to old code you cannot attempt to rev people that has been deconverted, can be remove)
							user << "<span class=\"warning\">This mind seems resistant to the flash!</span>"
						else if(result == -2) // rev jobbanned
							user << "<span class=\"warning\">This mind seems resistant to the flash! (OOC INFO: REVOLUTIONARY JOBBANNED)</span>"
						else if(result == -3) // loyalty implanted
							user << "<span class=\"warning\">Something seems to be blocking the flash!</span>"
					else
						user << "<span class=\"warning\">This mind is so vacant that it is not susceptible to influence!</span>"
		else
			flashfail = TRUE
	else if(issilicon(M))
		M.Weaken(rand(5, 10))
	else
		flashfail = TRUE

	if(isrobot(user))
		spawn(0)
			var/atom/movable/overlay/animation = new(get_turf(user))
			animation.layer = user.layer + 1
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
			animation.master = user
			flick("blspell", animation)
			sleep(5)
			qdel(animation)

	if(!flashfail)
		flick("flash2", src)

		if(!issilicon(M))
			user.visible_message("<span class=\"disarm\">[user] blinds [M] with the flash!</span>")
		else
			user.visible_message("<span class=\"warning\">[user] overloads [M]'s sensors with the flash!</span>")
	else
		user.visible_message("<span class=\"notice\">[user] fails to blind [M] with the flash!</span>")

/obj/item/device/flash/attack_self(mob/living/carbon/user as mob, flag = 0, emp = 0)
	if(!user || !clown_check(user)) 	return
	if(broken)
		user.show_message("<span class='warning'>The [src.name] is broken</span>", 2)
		return

	flash_recharge()

	//spamming the flash before it's fully charged (60seconds) increases the chance of it  breaking
	//It will never break on the first use.
	switch(times_used)
		if(0 to 5)
			if(prob(2*times_used))	//if you use it 5 times in a minute it has a 10% chance to break!
				broken = 1
				user << "<span class='warning'>The bulb has burnt out!</span>"
				icon_state = "flashburnt"
				return
			times_used++
		else	//can only use it  5 times a minute
			user.show_message("<span class='warning'>*click* *click*</span>", 2)
			return
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1)
	flick("flash2", src)
	if(user && isrobot(user))
		spawn(0)
			var/atom/movable/overlay/animation = new(user.loc)
			animation.layer = user.layer + 1
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
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
		if(M.alpha < 255)
			var/oldalpha = M.alpha
			if(prob(80))
				M.alpha = 255
				M.visible_message("<span class='warning'>[M] suddenly becomes fully visible!</span>",\
								"<span class='warning'>You see a bright flash of light and are suddenly fully visible again.</span>")
				spawn(50)
					M.alpha = oldalpha
		var/safety = M:eyecheck()
		if(!safety)
			if(!M.blinded)
				flick("flash", M.flash)

	return

/obj/item/device/flash/emp_act(severity)
	if(broken)	return
	flash_recharge()
	switch(times_used)
		if(0 to 5)
			if(prob(2*times_used))
				broken = 1
				icon_state = "flashburnt"
				return
			times_used++
			if(istype(loc, /mob/living/carbon))
				var/mob/living/carbon/M = loc
				var/safety = M.eyecheck()
				if(safety <= 0)
					M.Weaken(10)
					flick("e_flash", M.flash)
					for(var/mob/O in viewers(M, null))
						O.show_message("<span class='disarm'>[M] is blinded by the flash!</span>")
	..()

/obj/item/device/flash/synthetic
	name = "synthetic flash"
	desc = "When a problem arises, SCIENCE is the solution."
	icon_state = "sflash"
	origin_tech = "magnets=2;combat=1"
	materials = list("metal"=750,"glass"=750)

/obj/item/device/flash/synthetic/attack(mob/living/M as mob, mob/user as mob)
	..()
	if(!broken)
		broken = 1
		user << "\red The bulb has burnt out!"
		icon_state = "flashburnt"

/obj/item/device/flash/synthetic/attack_self(mob/living/carbon/user as mob, flag = 0, emp = 0)
	..()
	if(!broken)
		broken = 1
		user << "\red The bulb has burnt out!"
		icon_state = "flashburnt"
