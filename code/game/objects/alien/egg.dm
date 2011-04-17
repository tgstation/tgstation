/obj/alien/egg/New()
	if(aliens_allowed)
		src.density = 0 // Aliens use resin walls to block paths now. I am lazy and didn't feel like going to the define. -- TLE
		spawn(1800)
			src.open()
	else
		del(src)

/obj/alien/egg/proc/open()
	spawn(10)
		src.density = 0
		src.icon_state = "egg_hatched"
		new /obj/alien/facehugger(src.loc)

/obj/alien/egg/bullet_act(flag)
	switch(flag)
		if (PROJECTILE_BULLET)
			health -= 35
		if (PROJECTILE_PULSE)
			health -= 50
		if (PROJECTILE_LASER)
			health -= 10
	healthcheck()
	return

/obj/alien/egg/attackby(var/obj/item/weapon/W, var/mob/user)
	if(health <= 0)
		return
	src.visible_message("\red <B>\The [src] has been attacked with \the [W][(user ? " by [user]." : ".")]")
	var/damage = W.force / 4.0

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.welding)
			damage = 15
			playsound(src.loc, 'Welder.ogg', 100, 1)

	src.health -= damage
	src.healthcheck()


/obj/alien/egg/proc/healthcheck()
	if(health <= 0)
		if(prob(15))
			open()
		else
			src.icon_state = "egg_hatched"


/obj/alien/egg/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 500)
		health -= 5
		healthcheck()