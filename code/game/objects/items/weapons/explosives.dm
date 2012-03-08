/obj/item/weapon/plastique/attack_self(mob/user as mob)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10)
	timer = newtime
	user << "Timer set for [timer] seconds."

/obj/item/weapon/plastique/afterattack(atom/target as obj|turf, mob/user as mob, flag)
	if (!flag)
		return
	if (istype(target, /turf/unsimulated) || istype(target, /turf/simulated/shuttle) || istype(target, /obj/item/weapon/storage/) || ismob(target))
		return
	user << "Planting explosives..."
/*	if(ismob(target))
		user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] tried planting [name] on [target:real_name] ([target:ckey])</font>"
		user.visible_message("\red [user.name] is trying to plant some kind of explosive on [target.name]!")	*/
	if(do_after(user, 50) && in_range(user, target))
		user.drop_item()
		target = target
		loc = null
		var/location
		if (isturf(target)) location = target
		if (isobj(target)) location = target.loc
		if (ismob(target))
			target:attack_log += "\[[time_stamp()]\]<font color='orange'> Had the [name] planted on them by [user.real_name] ([user.ckey])</font>"
			user.visible_message("\red [user.name] finished planting an explosive on [target.name]!")
			log_admin("ATTACK: [user] ([user.ckey]) planted [src] on [target] ([target:ckey]).")
			message_admins("ATTACK: [user] ([user.ckey]) planted [src] on [target] ([target:ckey]).")
		target.overlays += image('assemblies.dmi', "plastic-explosive2")
		user << "Bomb has been planted. Timer counting down from [timer]."
		spawn(timer*10)
			if(target)
				explosion(location, -1, -1, 2, 3)
				if (istype(target, /turf/simulated/wall)) target:dismantle_wall(1)
				else target.ex_act(1)
				if (isobj(target))
					if (target)
						del(target)
				if (src)
					del(src)

/obj/item/weapon/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return