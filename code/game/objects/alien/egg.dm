/var/const //for the status var
	BURST = 0
	GROWING = 1
	GROWN = 2

	MIN_GROWTH_TIME = 1800 //time it takes to grow a hugger
	MAX_GROWTH_TIME = 3000

/obj/effect/alien/egg
	desc = "It looks like a weird egg"
	name = "egg"
	icon_state = "egg_growing"
	density = 0
	anchored = 1

	var/health = 100
	var/status = GROWING //can be GROWING, GROWN or BURST; all mutually exclusive

	New()
		if(aliens_allowed)
			..()
			spawn(rand(MIN_GROWTH_TIME,MAX_GROWTH_TIME))
				Grow()
		else
			del(src)

	attack_paw(user as mob)
		if(isalien(user))
			switch(status)
				if(BURST)
					user << "\red The child is already gone."
					return
				if(GROWING)
					user << "\red The child is not developed yet."
					return
				if(GROWN)
					user << "\red You retrieve the child."
					loc.contents += GetFacehugger()//need to write the code for giving it to the alien later
					Burst()
					return
		else
			return attack_hand(user)

	attack_hand(user as mob)
		user << "It feels slimy."
		return

	proc/GetFacehugger()
		return locate(/obj/item/clothing/mask/facehugger) in contents

	proc/Grow()
		icon_state = "egg"
		status = GROWN
		new /obj/item/clothing/mask/facehugger(src)
		return

	proc/Burst() //drops and kills the hugger if any is remaining
		var/obj/item/clothing/mask/facehugger/child = GetFacehugger()

		if(child)
			loc.contents += child
			child.Die()

		icon_state = "egg_hatched"
		status = BURST
		return

/obj/effect/alien/egg/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return



/obj/effect/alien/egg/attackby(var/obj/item/weapon/W, var/mob/user)
	if(health <= 0)
		return
	if(W.attack_verb.len)
		src.visible_message("\red <B>\The [src] has been [pick(W.attack_verb)] with \the [W][(user ? " by [user]." : ".")]")
	else
		src.visible_message("\red <B>\The [src] has been attacked with \the [W][(user ? " by [user]." : ".")]")
	var/damage = W.force / 4.0

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

	src.health -= damage
	src.healthcheck()


/obj/effect/alien/egg/proc/healthcheck()
	if(health <= 0)
		Burst()

/obj/effect/alien/egg/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 500)
		health -= 5
		healthcheck()