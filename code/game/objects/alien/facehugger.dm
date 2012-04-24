var/const
	MIN_IMPREGNATION_TIME = 100 //time it takes to impregnate someone
	MAX_IMPREGNATION_TIME = 150

	MIN_ACTIVE_TIME = 300 //time between being dropped and going idle
	MAX_ACTIVE_TIME = 600

/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = 1 //note: can be picked up by aliens unlike most other items of w_class below 4
	flags = FPRINT|TABLEPASS|MASKCOVERSMOUTH|MASKCOVERSEYES

	var/stat = UNCONSCIOUS //UNCONSCIOUS is the idle state in this case

	var/sterile = 0

	var/strength = 5

	attack_paw(user as mob) //can be picked up by aliens
		if(isalien(user))
			attack_hand(user)
			return
		else
			..()
			return

	attack_hand(user as mob)
		if(stat == CONSCIOUS && !isalien(user))
			Attach(user)
			return
		else
			..()
			return

	attack(mob/living/M as mob, mob/user as mob)
		..()
		Attach(M)

	New()
		if(aliens_allowed)
			..()
		else
			del(src)

	examine()
		..()
		switch(stat)
			if(DEAD,UNCONSCIOUS)
				usr << "\red \b [src] is not moving."
			if(CONSCIOUS)
				usr << "\red \b [src] seems to be active."
		if (sterile)
			usr << "\red \b It looks like the proboscis has been removed."
		return

	attackby()
		Die()
		return

	bullet_act()
		Die()
		return

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		if(exposed_temperature > 300)
			Die()
		return


	HasEntered(atom/target)
		Attach(target)
		return

	dropped()
		..()
		GoActive()
		return

	throw_impact(atom/hit_atom)
		Attach(hit_atom)
		return

	proc/Attach(M as mob)
		if(!isliving(M) || isalien(M))
			return

		var/mob/living/L = M //just so I don't need to use :

		if(stat != CONSCIOUS)
			return

		if(!sterile) L.take_organ_damage(strength,0) //done here so that even borgs and humans in helmets take damage

		loc = L.loc

		if(issilicon(L))
			for(var/mob/O in viewers(src, null))
				O.show_message("\red \b [src] smashes against [L]'s frame!", 1)
			Die()
			return

		var/mob/living/carbon/target = L

		for(var/mob/O in viewers(target, null))
			O.show_message("\red \b [src] leaps at [target]'s face!", 1)

		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.head && H.head.flags & HEADCOVERSMOUTH)
				for(var/mob/O in viewers(H, null))
					O.show_message("\red \b [src] smashes against [H]'s [H.head]!", 1)
				Die()
				return

		if(target.wear_mask)
			var/obj/item/clothing/W = target.wear_mask

			if(!W.canremove)
				return

			target.u_equip(W)
			if (target.client)
				target.client.screen -= W
			W.loc = target.loc
			W.dropped(target)
			W.layer = initial(W.layer)
			for(var/mob/O in viewers(target, null))
				O.show_message("\red \b [src] tears [W] off of [target]'s face!", 1)

		if(istype(loc,/mob/living/carbon/alien)) //just taking it off from the alien's UI
			var/mob/living/carbon/alien/host = loc
			host.u_equip(src)
			if (host.client)
				host.client.screen -= src
			add_fingerprint(host)

		loc = target
		layer = 20
		target.wear_mask = src

		target.update_clothing()

		GoIdle() //so it doesn't jump the people that tear it off

		if(!sterile) target.Paralyse(MAX_IMPREGNATION_TIME/6) //something like 25 ticks = 20 seconds with the default settings

		spawn(rand(MIN_IMPREGNATION_TIME,MAX_IMPREGNATION_TIME))
			Impregnate(target)

		return

	proc/Impregnate(mob/living/carbon/target as mob)
		if(target.wear_mask != src) //was taken off or something
			return

		if(!sterile)
			target.contract_disease(new /datum/disease/alien_embryo(0)) //so infection chance is same as virus infection chance
			for(var/datum/disease/alien_embryo/A in target.viruses)
				target.alien_egg_flag = max(1,target.alien_egg_flag)

			for(var/mob/O in viewers(target,null))
				O.show_message("\red \b [src] falls limp after violating [target]'s face!", 1)

			Die()
		else
			for(var/mob/O in viewers(target,null))
				O.show_message("\red \b [src] violates [target]'s face!", 1)

		return

	proc/GoActive()
		if(stat == DEAD || stat == CONSCIOUS)
			return

		stat = CONSCIOUS

		for(var/mob/living/carbon/alien/alien in world)
			var/image/activeIndicator = image('alien.dmi', loc = src, icon_state = "facehugger_active")
			activeIndicator.override = 1
			alien.client.images += activeIndicator

		spawn(rand(MIN_ACTIVE_TIME,MAX_ACTIVE_TIME))
			GoIdle()

		return

	proc/GoIdle()
		if(stat == DEAD || stat == UNCONSCIOUS)
			return

		RemoveActiveIndicators()

		stat = UNCONSCIOUS

		return

	proc/Die()
		if(stat == DEAD)
			return

		RemoveActiveIndicators()

		icon_state = "facehugger_dead"
		stat = DEAD

		for(var/mob/O in viewers(src, null))
			O.show_message("\red \b[src] curls up into a ball!", 1)

		return

	proc/RemoveActiveIndicators() //removes the "active" facehugger indicator from all aliens in the world for this hugger
		for(var/mob/living/carbon/alien/alien in world)
			if(alien.client)
				for(var/image/image in alien.client.images)
					if(image.icon_state == "facehugger_active" && image.loc == src)
						del(image)

		return

