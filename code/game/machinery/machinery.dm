/obj/machinery/New()
	..()
	machines.Add(src)

/obj/machinery/Del()
	machines.Remove(src)
	..()

/obj/machinery/proc/process()
	return

/obj/machinery/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(25))
				del(src)
				return
		else
	return

/obj/machinery/blob_act()
	if(prob(50))
		del(src)

/obj/machinery/proc/auto_use_power()
	if(!powered(power_channel))
		return 0
	if(src.use_power == 1)
		use_power(idle_power_usage,power_channel)
	else if(src.use_power >= 2)
		use_power(active_power_usage,power_channel)
	return 1

/obj/machinery/Topic(href, href_list)
	..()
	if(stat & (NOPOWER|BROKEN))
		return 1
	if(usr.restrained() || usr.lying || usr.stat)
		return 1
	if ( ! (istype(usr, /mob/living/carbon/human) || \
			istype(usr, /mob/living/silicon) || \
			istype(usr, /mob/living/carbon/monkey) && ticker && ticker.mode.name == "monkey") )
		usr << "\red You don't have the dexterity to do this!"
		return 1
	if ((!in_range(src, usr) || !istype(src.loc, /turf)) && !istype(usr, /mob/living/silicon))
		return 1
	src.add_fingerprint(usr)
	return 0

/obj/machinery/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN|MAINT))
		return 1
	if(user.lying || user.stat)
		return 1
	if ( ! (istype(usr, /mob/living/carbon/human) || \
			istype(usr, /mob/living/silicon) || \
			istype(usr, /mob/living/carbon/monkey) && ticker && ticker.mode.name == "monkey") )
		usr << "\red You don't have the dexterity to do this!"
		return 1
	if ((get_dist(src, user) > 1 || !istype(src.loc, /turf)) && !istype(user, /mob/living/silicon))
		return 1
	if (ishuman(user))
		if(user.brainloss >= 60)
			for(var/mob/M in viewers(src, null))
				M << "\red [user] stares cluelessly at [src] and drools."
			return 1
		else if(prob(user.brainloss))
			user << "\red You momentarily forget how to use [src]."
			return 1

	src.add_fingerprint(user)
	return 0