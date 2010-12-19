/obj/item/weapon/plastique/attack_self(mob/user as mob)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10)
	src.timer = newtime
	user << "Timer set for [src.timer] seconds."

/obj/item/weapon/plastique/afterattack(atom/target as obj|turf, mob/user as mob)
	user << "Planting explosives..."
	if(do_after(user, 50))
		user.drop_item()
		src.target = target
		src.loc = null
		var/location
		if (isturf(target)) location = target
		if (isobj(target)) location = target.loc
		target.overlays += image('assemblies.dmi', "timer-igniter-tank2")
		user << "Bomb has been planted. Timer counting down from [src.timer]."
		spawn(src.timer*10)
			explosion(location, -1, -1, 2, 3)
			if (istype(src.target, /turf/simulated/wall)) src.target:dismantle_wall(1)
			else src.target.ex_act(1)
			if (isobj(src.target))
				if (src.target)
					del(src.target)
			if (src)
				del(src)

/obj/item/weapon/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return