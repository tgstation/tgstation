/spell/lightning
	name = "Lightning"
	charge_max = 200
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 0, Sp_POWER = 3) //each level of power grants 1 additional target.

	spell_flags = NEEDSCLOTHES
	charge_type = Sp_RECHARGE
	invocation = "ZAP MUTHA FUH KA"
	invocation_type = SpI_SHOUT
	hud_state = "wiz_zap"

	var/chargedkey
	var/basedamage = 40
	var/bounces = 0
	var/bounce_range = 6
	var/image/chargeoverlay
	var/last_active_sound

/spell/lightning/New()
	..()
	chargeoverlay = image("icon" = 'icons/mob/mob.dmi', "icon_state" = "sithlord")

/spell/lightning/can_improve(var/upgrade_type)
	if(upgrade_type == "speed") return 0
	return ..()

/spell/lightning/empower_spell()
	if(!can_improve(Sp_POWER))
		return 0
	spell_levels[Sp_POWER]++
	var/temp = ""
	switch(level_max[Sp_POWER] - spell_levels[Sp_POWER])
		if(2)
			temp = "You have improved [name] into Chain Lightning it will arc to one additional target."
			name = "Chain Lightning"
			bounces++
		if(1)
			temp = "You have improved [name] into Powerful Chain Lightning it will arc to up to 3 targets."
			name = "Powerful Chain Lightning"
			bounces+=2
		if(0)
			temp = "You have improved [name] into Zeus' Own Chain Lightning it will arc to up to 5 targets."
			name = "Zeus' Own Chain Lightning"
			bounces+=2
	connected_button.name = name
	return temp

/spell/lightning/process()
	if(chargedkey) return //do not charge while we are gonna zap
	..()

/spell/lightning/perform(mob/user = usr, skipcharge = 0)
	if(!holder)
		holder = user //just in case
	if(!chargedkey)
		if(!cast_check(skipcharge, user))
			return
		chargedkey = user.on_uattack.Add(src, "charged_click")
		connected_button.name = "(Ready) [name]"
		user.overlays += chargeoverlay
		if(world.time >= last_active_sound + 50)
			playsound(get_turf(user), 'sound/effects/chainlightning_activate.ogg', 100, 1, "vary" = 0)

		//give user overlay
	else
		//remove overlay
		connected_button.name = name
		var/event/E = user.on_uattack
		E.handlers.Remove(chargedkey)
		chargedkey = null
		charge_counter = charge_max
		user.overlays -= chargeoverlay
	return



// Listener for /atom/movable/on_moved
/spell/lightning/proc/charged_click(var/list/args)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/effect/beam/proc/target_moved() called tick#: [world.time]")
	var/event/E = args["event"]
	if(!chargedkey)
		E.handlers.Remove("\ref[src]:charged_click")
		return

	var/atom/A = args["atom"]

	if(E.holder != holder)
		E.handlers.Remove("\ref[src]:charged_click")
		return
	if(isliving(A))
		usr.overlays -= chargeoverlay
		var/mob/living/L = A
		invocation(holder)
		take_charge(holder, 0)
		E.handlers.Remove(chargedkey)
		chargedkey = null
		connected_button.name = name
		spawn()
			zapmuthafucka(holder, L, bounces)
		src.process()

/spell/lightning/proc/zapmuthafucka(var/mob/user, var/mob/target, var/chained = bounces, var/list/zapped = list())
	zapped.Add(target)
	var/turf/T = get_turf(user)
	var/turf/U = get_turf(target)
	var/obj/item/projectile/beam/lightning/spell/L = getFromPool(/obj/item/projectile/beam/lightning/spell, T)
	L.stun = 2
	L.weaken = 1
	L.basedamage = basedamage
	playsound(get_turf(user), 'sound/effects/chainlightning.ogg', 75, 1)
	L.tang = adjustAngle(get_angle(U,T))
	L.icon = midicon
	L.icon_state = "[L.tang]"
	L.firer = user
	L.def_zone = "chest"
	L.original = user
	L.current = U
	L.starting = U
	L.yo = U.y - T.y
	L.xo = U.x - T.x
	spawn L.process()
	if(chained)
		//DO IT AGAIN
		var/mob/next_target
		var/currdist = -1
		for(var/mob/living/M in view(target,bounce_range))
			if((M != holder && M != usr) && M != user && !(M in zapped))
				var/dist = get_dist(M, holder)
				if(currdist == -1)
					currdist = dist
					next_target = M
				else if(dist < currdist)
					next_target = M
					currdist = dist

		if(!next_target) return //bail out bail out!
		zapmuthafucka("user" = target, "target" = next_target, "chained" = chained-1, "zapped" = zapped)