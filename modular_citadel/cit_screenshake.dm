//we vlambeer now

/obj/proc/shake_camera(mob/M, duration, strength=1)//byond's wonky with this shit
	if(!M || !M.client || duration <= 0)
		return
	var/client/C = M.client
	if (C.prefs.screenshake==0)
		return
	var/oldx = C.pixel_x
	var/oldy = C.pixel_y
	var/clientscreenshake = (C.prefs.screenshake * 0.01)
	var/max = (strength*clientscreenshake) * world.icon_size
	var/min = -((strength*clientscreenshake) * world.icon_size)

	for(var/i in 0 to duration-1)
		if (i == 0)
			animate(C, pixel_x=rand(min,max), pixel_y=rand(min,max), time=1)
		else
			animate(pixel_x=rand(min,max), pixel_y=rand(min,max), time=1)
	animate(pixel_x=oldx, pixel_y=oldy, time=1)

/obj/item/gun/energy
	recoil = 0.1

/obj/item/gun/energy/kinetic_accelerator
	recoil = 0.5

/obj/item/gun/ballistic
	recoil = 0.25

/obj/item/gun/ballistic/shotgun
	recoil = 1

/obj/item/gun/ballistic/revolver
	recoil = 0.5

/obj/item/gun/ballistic/revolver/doublebarrel
	recoil = 1

/obj/item/gun/syringe
	recoil = 0.1

/obj/item/pneumatic_cannon/fire_items(turf/target, mob/user)
	. = ..()
	shake_camera(user, (pressureSetting * 0.75 + 1), (pressureSetting * 0.75))

/obj/item/attack(mob/living/M, mob/living/user)
	. = ..()
	if(force >= 15)
		shake_camera(user, ((force - 10) * 0.01 + 1), ((force - 10) * 0.01))
		if(M.client)
			switch (M.client.prefs.damagescreenshake)
				if (1)
					shake_camera(M, ((force - 10) * 0.015 + 1), ((force - 10) * 0.015))
				if (2)
					if (!M.canmove)
						shake_camera(M, ((force - 10) * 0.015 + 1), ((force - 10) * 0.015))

/obj/item/attack_obj(obj/O, mob/living/user)
	. = ..()
	if(force >= 20)
		shake_camera(user, ((force - 15) * 0.01 + 1), ((force - 15) * 0.01))
