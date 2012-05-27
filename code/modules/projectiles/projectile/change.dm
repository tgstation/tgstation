/obj/item/projectile/change
	name = "\improper Bolt of Change"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"

	on_hit(var/atom/change)
		wabbajack(change)


	/*Bump(atom/change)
		if(istype(change, /mob/living))
			wabbajack(change)
		else
			del(src)*/



/obj/item/projectile/change/proc/wabbajack (mob/M as mob in world)
	if(istype(M, /mob/living) && M.stat != 2)
		for(var/obj/item/W in M)
			if (istype(M, /mob/living/silicon/robot)||istype(W, /obj/item/weapon/implant))
				del (W)
			M.drop_from_slot(W)
		var/randomize = pick("monkey","robot","metroid","alien","human")
		switch(randomize)
			if("monkey")
				if (M.monkeyizing)
					return
				if(istype(M,/mob/living/carbon/human))
					M:monkeyize()
			if("robot")
				if (M.monkeyizing)
					return
				if(istype(M,/mob/living/carbon/human))
					M:Robotize()
			if("metroid")
				if (M.monkeyizing)
					return
				if(istype(M,/mob/living/carbon/human))
					M:Metroidize()
			if("alien")
				if (M.monkeyizing)
					return
				if(istype(M,/mob/living/carbon/human))
					M:Alienize()
			if("human")
				if (M.monkeyizing)
					return
		return

