
/spell/aoe_turf/fall
	name = "Mass Sleep"
	desc = "This spell puts any organic being to sleep for a short period in a large radius around you."

	spell_flags = NEEDSCLOTHES

	selection_type = "range"
	school = "transmutation"
	charge_max = 2100 // 3.5min
	invocation = "OMNIA RUINAM"
	invocation_type = SpI_WHISPER
	range = 7
	cooldown_min = 2100
	cooldown_reduc = 0
	level_max = list(Sp_TOTAL = 0, Sp_SPEED = 0, Sp_POWER = 0)
	hud_state = "wiz_sleep"
	var/image/aoe_underlay

/spell/aoe_turf/fall/New()
	..()
	aoe_underlay = image(icon = 'icons/effects/640x640.dmi', icon_state = "fall", layer = 2.1)
	aoe_underlay.transform /= 50
	aoe_underlay.pixel_x = -304
	aoe_underlay.pixel_y = -304
	aoe_underlay.mouse_opacity = 0

/spell/aoe_turf/fall/cast(list/targets)
	spawn()
		aoe_underlay.loc = get_turf(usr)
		for(var/client/C in clients)
			C.images += aoe_underlay
			spawn(220)
				C.images -= aoe_underlay
		animate(aoe_underlay, transform = null, time = 2)
	playsound(usr, 'sound/effects/fall.ogg', 100, 0, 0, 0, 0)
	spawn(3)
		var/sleepfor = world.time + 100
		for(var/turf/T in targets)
			T.sleeping = sleepfor
			for(var/mob/living/L in T)
				spawn()
					if(L == usr) continue
					L.playsound_local(L, 'sound/effects/fall2.ogg', 100, 0, 0, 0, 0)
					L.Paralyse(5)
		return

/spell/aoe_turf/fall/after_cast(list/targets)
	spawn(100)
		animate(aoe_underlay, transform = aoe_underlay.transform / 50, time = 2)
		sleep(2)
		aoe_underlay.loc = src
	return