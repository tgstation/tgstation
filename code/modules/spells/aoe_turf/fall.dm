
/spell/aoe_turf/fall
	name = "Time Stop"
	desc = "This spell stops time for "

	spell_flags = NEEDSCLOTHES

	selection_type = "range"
	school = "transmutation"
	charge_max = 900 // now 2min
	invocation = "OMNIA RUINAM"
	invocation_type = SpI_SHOUT
	range = 4
	cooldown_min = 600
	cooldown_reduc = 100
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 3, Sp_POWER = 3)
	hud_state = "wiz_timestop"
	var/image/aoe_underlay
	var/list/oureffects = list()
	var/list/affected = list()
	var/sleepfor
	var/the_world_chance = 30
	var/sleeptime = 30

/spell/aoe_turf/fall/empower_spell()
	if(!can_improve(Sp_POWER))
		return 0
	spell_levels[Sp_POWER]++
	var/temp = ""
	range++
	sleeptime += 10
	switch(level_max[Sp_POWER] - spell_levels[Sp_POWER])
		if(2)
			temp = "Your control over time strengthens, you can now stop time for [sleeptime/10] second\s and in a radius of [range*2] meter\s."

	return temp

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
	if(!holder)
		holder = user //just in case
	if(!cast_check(skipcharge, user))
		return
	if(cast_delay && !spell_do_after(user, cast_delay))
		return
	var/list/targets = choose_targets(user)
	if(targets && targets.len)
		if(prob(the_world_chance)) invocation = "ZA WARUDO"
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

	var/list/potentials = circlerangeturfs(usr, range)
	if(istype(potentials) && potentials.len)
		targets = potentials
	/*spawn(120)
		del(aoe_underlay)
		buildimage()*/
	spawn()
		for(var/client/C in clients)
			if(C.mob)
				C.mob.see_fall(ourturf, range)
		spawn(10)
		for(var/client/C in clients)
			if(C.mob)
				C.mob.see_fall()

		//animate(aoe_underlay, transform = null, time = 2)
	var/oursound = (invocation == "ZA WARUDO" ? 'sound/effects/theworld.ogg' :'sound/effects/fall.ogg')
	playsound(usr, oursound, 100, 0, 0, 0, 0)

	sleepfor = world.time + sleeptime
	for(var/turf/T in targets)
//		to_chat(world, "Starting [T]")
		oureffects += getFromPool(/obj/effect/stop/sleeping, T, sleepfor, usr:mind, src, invocation == "ZA WARUDO")
		for(var/atom/movable/everything in T)
//			to_chat(world, "[T] doing [everything]")
			if(isliving(everything))
//				to_chat(world, "[everything] is living")
				var/mob/living/L = everything
				if(L == holder) continue
//				to_chat(world, "[everything] is not holder")
//				to_chat(world, "paralyzing [everything]")
				affected += L
				invertcolor(L)
				spawn() recursive_timestop(L)
				//L.Paralyse(5)
				//L.update_canmove()
//				to_chat(world, "done")
				L.playsound_local(L, invocation == "ZA WARUDO" ? 'sound/effects/theworld2.ogg' : 'sound/effects/fall2.ogg', 100, 0, 0, 0, 0)
//			to_chat(world, "checking for color invertion")
			else
				spawn() recursive_timestop(everything)
				if(everything.ignoreinvert)
//					to_chat(world, "[everything] is ignoring inverts.")
					continue
//				to_chat(world, "Inverting [everything] [everything.type] [everything.forceinvertredraw ? "forcing redraw" : ""]")
				invertcolor(everything)
//				to_chat(world, "Done")
				affected += everything
			everything.timestopped = 1
//		to_chat(world, "inverting [T]")
		invertcolor(T)
		T.timestopped = 1
//		to_chat(world, "Done")
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
/spell/aoe_turf/fall/proc/recursive_timestop(var/atom/O)
	var/list/processing_list = list(O)
	var/list/processed_list = new/list()


	while (processing_list.len)
		var/atom/A = processing_list[1]
		affected |= A
		A.timestopped = 1

		for (var/atom/B in A)
			if (!processed_list[B])
				processing_list |= B

		processing_list.Cut(1, 2)
		processed_list[A] = A

/spell/aoe_turf/fall/after_cast(list/targets)
	while(world.time < sleepfor)
		sleep(1)
	//animate(aoe_underlay, transform = aoe_underlay.transform / 50, time = 2)
	for(var/obj/effect/stop/sleeping/S in oureffects)
		returnToPool(S)
		oureffects -= S
	for(var/atom/everything in affected)
		if(!istype(everything)) continue
		var/icon/I = everything.tempoverlay
		everything.overlays.Remove(I)
		everything.ignoreinvert = initial(everything.ignoreinvert)
		everything.timestopped = 0
	affected.len = 0

	return

/mob/var/image/fallimage

/mob/proc/see_fall(var/turf/T, range = 8)
	var/turf/T_mob = get_turf(src)
	if((!T || isnull(T)) && fallimage)
		animate(fallimage, transform = fallimage.transform / 50, time = 2)
		sleep(2)
		del(fallimage)
		return
	else if(T && T_mob && (T.z == T_mob.z) && (get_dist(T,T_mob) <= 15))// &&!(T in view(T_mob)))
		var/matrix/original
		if(!fallimage)
			fallimage = image(icon = 'icons/effects/640x640.dmi', icon_state = "fall", layer = 2.1)
			original = fallimage.transform
			fallimage.transform /= 50
			fallimage.mouse_opacity = 0
		var/new_x = 32 * (T.x - T_mob.x) - 304
		var/new_y = 32 * (T.y - T_mob.y) - 304
		fallimage.pixel_x = new_x
		fallimage.pixel_y = new_y
		fallimage.loc = T_mob

		to_chat(src, fallimage)
		animate(fallimage, transform = original / (8/range), time = 3)

/proc/invertcolor(atom/A)
//	to_chat(world, "invert color start")
	if(A.ignoreinvert) return
//	to_chat(world, "not ignoring")
	if(A.forceinvertredraw)
//		to_chat(world, "force redraw")
		var/icon/I = icon(A.icon, A.icon_state, A.dir)
//		to_chat(world, "got \icon[I]")
		if(!istype(I) || ishuman(A))
//			to_chat(world, "[ishuman(A) ? "we're human so getting flat icon" : "our icon is not good enough, getting flat icon"]")
			I = getFlatIcon(A, A.dir, cache = 2)
//			to_chat(world, "get flat icon done")
//		to_chat(world, "starting color mapping")
		I.MapColors(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1)
		if(iscarbon(A))
			var/mob/living/carbon/C = A
			if(C.lying || C.weakened || C.stat || C.sleeping || C.paralysis)
				I.Turn(-90)
//		to_chat(world, "color mapping done")
//				to_chat(world, "done turning")
//		to_chat(world, "setting vars")
		A.tempoverlay = I
		A.overlays += I
//		to_chat(world, "done setting vars")
	else
//		to_chat(world, "not being forced")
		var/icon/I = A.tempoverlay
		//if(everything.icon_state != initial(everything.icon_state))
			//I = icon(I, everything.icon_state, everything.dir)
//		to_chat(world, "setting vars")
		A.overlays += I
		A.tempoverlay = I
//		to_chat(world, "done settings vars")
	A.ignoreinvert = 1
//	to_chat(world, "invertcolor return")
