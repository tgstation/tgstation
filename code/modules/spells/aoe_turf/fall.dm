
/spell/aoe_turf/fall
	name = "Time Stop"
	desc = "This spell stops time for "

	spell_flags = NEEDSCLOTHES

	selection_type = "range"
	school = "transmutation"
	charge_max = 600 // now 2min
	invocation = "OMNIA RUINAM"
	invocation_type = SpI_SHOUT
	range = 8
	cooldown_min = 300
	cooldown_reduc = 100
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 3, Sp_POWER = 0)
	hud_state = "wiz_timestop"
	var/image/aoe_underlay
	var/list/oureffects = list()
	var/list/affected = list()


/spell/aoe_turf/fall/New()
	..()
	buildimage()

/spell/aoe_turf/fall/proc/buildimage()
	aoe_underlay = image(icon = 'icons/effects/640x640.dmi', icon_state = "fall", layer = 2.1)
	aoe_underlay.transform /= 50
	aoe_underlay.pixel_x = -304
	aoe_underlay.pixel_y = -304
	aoe_underlay.mouse_opacity = 0
/proc/CircleCoords(var/c_x, var/c_y, var/r)
	. = list()
	var/r_sqr = r*r
	var/x
	var/y
	var/i

	for(y = -r, y <= r, y++)
		x = round(sqrt(r_sqr - y*y))
		for(i = -x, i <= x, i++)
			. += "[x],[y]"

/spell/aoe_turf/fall/perform(mob/user = usr, skipcharge = 0) //if recharge is started is important for the trigger spells
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/spell/proc/perform() called tick#: [world.time]")
	if(!holder)
		holder = user //just in case
	if(!cast_check(skipcharge, user))
		return
	if(cast_delay && !spell_do_after(user, cast_delay))
		return
	var/list/targets = choose_targets(user)
	if(targets && targets.len)
		if(prob(15)) invocation = "ZA WARUDO"
		invocation(user, targets)
		take_charge(user, skipcharge)

		before_cast(targets) //applies any overlays and effects
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>[user.real_name] ([user.ckey]) cast the spell [name].</font>")
		if(prob(critfailchance))
			critfail(targets, user)
		else
			cast(targets, user)
		after_cast(targets) //generates the sparks, smoke, target messages etc.
		invocation = initial(invocation)

/spell/aoe_turf/fall/cast(list/targets)
	var/turf/ourturf = get_turf(usr)

	targets = circlerangeturfs(usr, range)
	/*spawn(120)
		del(aoe_underlay)
		buildimage()*/
	spawn()
		for(var/client/C in clients)
			if(C.mob)
				C.mob.see_fall(ourturf)
		spawn(10)
		for(var/client/C in clients)
			if(C.mob)
				C.mob.see_fall()

		//animate(aoe_underlay, transform = null, time = 2)
	var/oursound = (invocation == "ZA WARUDO" ? 'sound/effects/theworld.ogg' :'sound/effects/fall.ogg')
	playsound(usr, oursound, 100, 0, 0, 0, 0)

	var/sleepfor = world.time + 100
	for(var/turf/T in targets)
		//world << "Starting [T]"
		oureffects += getFromPool(/obj/effect/stop/sleeping, T, sleepfor, usr:mind, src, invocation == "ZA WARUDO")
		for(var/atom/movable/everything in T)
			//world << "[T] doing [everything]"
			if(isliving(everything))
				//world << "[everything] is living"
				var/mob/living/L = everything
				if(L == holder) continue
				//world << "[everything] is not holder"
				//world << "paralyzing [everything]"
				affected += L
				invertcolor(L)
				L.Paralyse(5)
				L.update_canmove()
				//world << "done"
				L.playsound_local(L, invocation == "ZA WARUDO" ? 'sound/effects/theworld2.ogg' : 'sound/effects/fall2.ogg', 100, 0, 0, 0, 0)
			//world << "checking for color invertion"
			else
				if(everything.ignoreinvert)
					//world << "[everything] is ignoring inverts."
					continue
				//world << "Inverting [everything] [everything.type] [everything.forceinvertredraw ? "forcing redraw" : ""]"
				invertcolor(everything)
				//world << "Done"
				affected += everything

		//world << "inverting [T]"
		invertcolor(T)
		//world << "Done"
		/*var/icon/I = T.tempoverlay

		if(!istype(I))
			I = icon(T.icon, T.icon_state, T.dir)
			I.MapColors(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1)
		//else
			//if(T.icon_state != initial(T.icon_state))
				//I = icon(I, T.icon_state, T.dir)
		T.tempoverlay = I
		T.overlays += I*/


		affected += T
	return

/spell/aoe_turf/fall/after_cast(list/targets)
	spawn(100)
		//animate(aoe_underlay, transform = aoe_underlay.transform / 50, time = 2)
		for(var/obj/effect/stop/sleeping/S in oureffects)
			returnToPool(S)
			oureffects -= S
		for(var/atom/everything in affected)
			var/icon/I = everything.tempoverlay
			everything.overlays.Remove(I)
			everything.ignoreinvert = initial(everything.ignoreinvert)
		affected.len = 0

	return

/mob/var/image/fallimage

/mob/proc/see_fall(var/turf/T)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/proc/see_rift() called tick#: [world.time]")
	var/turf/T_mob = get_turf(src)
	if((!T || isnull(T)) && fallimage)
		animate(fallimage, transform = fallimage.transform / 50, time = 2)
		sleep(2)
		del(fallimage)
		return
	else if(T && T_mob && (T.z == T_mob.z) && (get_dist(T,T_mob) <= 15))// &&!(T in view(T_mob)))
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
		animate(fallimage, transform = null, time = 3)

/proc/invertcolor(atom/A)
	//world << "invert color start"
	if(A.ignoreinvert) return
	//world << "not ignoring"
	if(A.forceinvertredraw)
		//world << "force redraw"
		var/icon/I = icon(A.icon, A.icon_state, A.dir)
		//world << "got \icon[I]"
		if(!istype(I) || ishuman(A))
			//world << "[ishuman(A) ? "we're human so getting flat icon" : "our icon is not good enough, getting flat icon"]"
			I = getFlatIcon(A, A.dir, cache = 2)
			//world << "get flat icon done"
		//world << "starting color mapping"
		I.MapColors(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1)
		if(iscarbon(A))
			var/mob/living/carbon/C = A
			if(C.lying || C.weakened || C.stat || C.sleeping || C.paralysis)
				I.Turn(-90)
		//world << "color mapping done"
				//world << "done turning"
		//world << "setting vars"
		A.tempoverlay = I
		A.overlays += I
		//world << "done setting vars"
	else
		//world << "not being forced"
		var/icon/I = A.tempoverlay
		//if(everything.icon_state != initial(everything.icon_state))
			//I = icon(I, everything.icon_state, everything.dir)
		//world << "setting vars"
		A.overlays += I
		A.tempoverlay = I
		//world << "done settings vars"
	A.ignoreinvert = 1
	//world << "invertcolor return"