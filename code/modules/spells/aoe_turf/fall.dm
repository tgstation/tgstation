
/spell/aoe_turf/fall
	name = "Mass Sleep"
	desc = "This spell puts any organic being to sleep for a short period in a large radius around you."

	spell_flags = NEEDSCLOTHES

	selection_type = "range"
	school = "transmutation"
	charge_max = 600 // now 2min
	invocation = "OMNIA RUINAM"
	invocation_type = SpI_SHOUT
	range = 7
	cooldown_min = 300
	cooldown_reduc = 100
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 3, Sp_POWER = 0)
	hud_state = "wiz_sleep"
	var/image/aoe_underlay
	var/list/oureffects = list()


/spell/aoe_turf/fall/New()
	..()
	buildimage()

/spell/aoe_turf/fall/proc/buildimage()
	aoe_underlay = image(icon = 'icons/effects/640x640.dmi', icon_state = "fall", layer = 2.1)
	aoe_underlay.transform /= 50
	aoe_underlay.pixel_x = -304
	aoe_underlay.pixel_y = -304
	aoe_underlay.mouse_opacity = 0

/spell/aoe_turf/fall/cast(list/targets)
	/*spawn(120)
		del(aoe_underlay)
		buildimage()*/
	spawn()
		var/turf/T = get_turf(usr)
		for(var/client/C in clients)
			if(C.mob)
				C.mob.see_fall(T)
		//animate(aoe_underlay, transform = null, time = 2)
	playsound(usr, 'sound/effects/fall.ogg', 100, 0, 0, 0, 0)
	spawn(3)
		var/sleepfor = world.time + 100
		for(var/turf/T in targets)
			oureffects += getFromPool(/obj/effect/sleeping, T, sleepfor, usr:mind)
			for(var/mob/living/L in T)
				spawn()
					if(L == usr) continue
					L.playsound_local(L, 'sound/effects/fall2.ogg', 100, 0, 0, 0, 0)
					L.Paralyse(5)
		return

/spell/aoe_turf/fall/after_cast(list/targets)
	spawn(100)
		//animate(aoe_underlay, transform = aoe_underlay.transform / 50, time = 2)
		for(var/client/C in clients)
			if(C.mob)
				C.mob.see_fall()
		for(var/obj/effect/sleeping/S in oureffects)
			returnToPool(S)
			oureffects -= S
	return

/mob/var/image/fallimage

/mob/proc/see_fall(var/turf/T)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/proc/see_rift() called tick#: [world.time]")
	var/turf/T_mob = get_turf(src)
	if(!T && fallimage)
		animate(fallimage, transform = fallimage.transform / 50, time = 2)
		sleep(2)
		del(fallimage)
		return
	if((T.z == T_mob.z) && (get_dist(T,T_mob) <= 15))// &&!(T in view(T_mob)))
		if(!fallimage)
			fallimage = image(icon = 'icons/effects/640x640.dmi', icon_state = "fall", layer = 2.1)
			fallimage.transform /= 50
			fallimage.mouse_opacity = 0

		var/new_x = 32 * (T.x - T_mob.x) - 304
		var/new_y = 32 * (T.y - T_mob.y) - 304
		fallimage.pixel_x = new_x
		fallimage.pixel_y = new_y
		fallimage.loc = T_mob

		src << fallimage
		animate(fallimage, transform = null, time = 2)