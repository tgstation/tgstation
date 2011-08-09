
/obj/grille/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		if(3.0)
			if (prob(25))
				src.health -= 11
				healthcheck()
		else
	return

/obj/grille/blob_act()
	del(src)

/obj/grille/meteorhit(var/obj/M)
	if (M.icon_state == "flaming")
		src.health -= 2
		healthcheck()
	return

/obj/grille/attack_hand(var/obj/M)
	if ((usr.mutations & HULK))
		usr << text("\blue You kick the grille.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] kicks the grille.", usr)
		src.health -= 5
		healthcheck()
		return
	else if(!shock(usr, 70))
		usr << text("\blue You kick the grille.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] kicks the grille.", usr)
		playsound(src.loc, 'grillehit.ogg', 80, 1)
		src.health -= 3
		healthcheck()

/obj/grille/attack_paw(var/obj/M)
	if ((usr.mutations & HULK))
		usr << text("\blue You kick the grille.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] kicks the grille.", usr)
		src.health -= 5
		healthcheck()
		return
	else if(!shock(usr, 70))
		usr << text("\blue You kick the grille.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] kicks the grille.", usr)
		playsound(src.loc, 'grillehit.ogg', 80, 1)
		src.health -= 3

/obj/grille/attack_alien(var/obj/M)
	if (istype(usr, /mob/living/carbon/alien/larva))//Safety check for larva, in case they get attack_alien in the future. /N
		return
	if (!shock(usr, 70))
		usr << text("\green You mangle the grille.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] mangles the grille.", usr)
		playsound(src.loc, 'grillehit.ogg', 80, 1)
		src.health -= 3
		healthcheck()
		return

/obj/grille/attack_metroid(var/obj/M)
	if(!istype(usr, /mob/living/carbon/metroid/adult))
		return

	usr<< text("\green You smash against the grille.")
	for(var/mob/O in oviewers())
		if ((O.client && !( O.blinded )))
			O << text("\red [] smashes against the grille.", usr)
	playsound(src.loc, 'grillehit.ogg', 80, 1)
	src.health -= rand(2,3)
	healthcheck()
	return
	return

/obj/grille/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return 1
	else
		if (istype(mover, /obj/item/projectile))
			return prob(30)
		else
			return !src.density

/obj/grille/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/wirecutters))
		if(!(destroyed))
			if(!shock(user, 100))
				playsound(src.loc, 'Wirecutter.ogg', 100, 1)
				src.health = 0
		else
			playsound(src.loc, 'Wirecutter.ogg', 100, 1)
			src.health = -100

	else if ((istype(W, /obj/item/weapon/screwdriver) && (istype(src.loc, /turf/simulated) || src.anchored)))
		if(!shock(user, 90))
			playsound(src.loc, 'Screwdriver.ogg', 100, 1)
			src.anchored = !( src.anchored )
			user << (src.anchored ? "You have fastened the grille to the floor." : "You have unfastened the grill.")
			for(var/mob/O in oviewers())
				O << text("\red [user] [src.anchored ? "fastens" : "unfastens"] the grille.")
			return
	else if(istype(W, /obj/item/weapon/shard))
		if(ishuman(user)) //Let's check if the guy's wearing electrically insulated gloves --Agourimarkan
			var/mob/living/carbon/human/H = user
			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(istype(G,/obj/item/clothing/gloves/yellow) ) //Business as usual for guys with gloves
					src.health -= W.force * 0.2
				else // Guy has gloves, not electrically insulated ones
					var/outcome = pick(1,2,3)
					switch(outcome) // 3 possible outcomes
						if(1) //Guy gets shocked. If not electrified, cause damage.
							if(shock(user,100))
								return
							else
								src.health -= W.force *0.2
						if(2) //Shard breaks
							user << "<font color='blue'>The shard breaks!</font>"
							del W
							return
						if(3) //You somehow manage to damage the grille. Beefin' up the damage, a bit. Instead of doing 10% damage it now does... 20% of the shard's force? Yeah, 20% sounds good at 66% chance of failure.
							src.health -=W.force *0.2
			else //SHIT SON, GUY DOESN'T HAVE ANY GLOVES
				var/outcome = pick(1,2,3)
				switch(outcome)
					if(1) // Let's see, the guy damages it but takes some damage back
						user << "<font color='red'>You cut yourself with the shard as you hit the grille!</font>"
						src.health -= W.force *0.2
						var/brutedamagetaken = rand(3,6)
						H.take_organ_damage(brutedamagetaken,0)
					if(2) //Guy gets shocked. If not electrified, apply damage
						if(shock(user,100))
							return
						else
							src.health -= W.force *0.2
					if(3) // It breaks in his hands. Ouch.
						user << "<font color='red'>As you smash the grille the shard breaks into smithereens in your palm!</font>"
						src.health -= W.force *0.2
						del(W)
						var/brutedamagetaken = rand(5,8)
						H.take_organ_damage(brutedamagetaken,0)
						return
		else //Alright, he's not a human. Can monkeys or aliens even wear gloves?
			src.health -= W.force *0.1 //10% damage only for non-glorious human master race members

	else						// anything else, chance of a shock
		if(!shock(user, 70))
			playsound(src.loc, 'grillehit.ogg', 80, 1)
			switch(W.damtype)
				if("fire")
					src.health -= W.force
				if("brute")
					src.health -= W.force * 0.1

	src.healthcheck()
	..()
	return

/obj/grille/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.icon_state = "brokengrille"
			src.density = 0
			src.destroyed = 1
			new /obj/item/stack/rods( src.loc )

		else
			if (src.health <= -10.0)
				new /obj/item/stack/rods( src.loc )
				//SN src = null
				del(src)
				return
	return

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/grille/proc/shock(mob/user, prb)

	if(!anchored || destroyed)		// anchored/destroyed grilles are never connected
		return 0

	if(!prob(prb))
		return 0

	var/turf/T = get_turf(src)
	if (electrocute_mob(user, T.get_cable_node(), src))
		var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		return 1
	else
		return 0