/obj/effect/proc_holder/spell/targeted/ethereal_jaunt
	name = "Ethereal Jaunt"
	desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."

	school = "transmutation"
	charge_max = 300
	clothes_req = 1
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1


	var phaseshift = 0
	var/jaunt_duration = 50 //in deciseconds

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/cast(list/targets) //magnets, so mostly hardcoded
	for(var/mob/target in targets)
		spawn(0)
			var/mobloc = get_turf(target.loc)
			var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt( mobloc )
			var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
			animation.name = "water"
			animation.density = 0
			animation.anchored = 1
			animation.icon = 'mob.dmi'
			animation.icon_state = "liquify"
			animation.layer = 5
			animation.master = holder
			if(phaseshift == 1)
				animation.dir = target.dir
				flick("phase_shift",animation)
				target.loc = holder
				target.client.eye = holder
				sleep(jaunt_duration)
				mobloc = get_turf(target.loc)
				animation.loc = mobloc
				target.canmove = 0
				sleep(20)
				animation.dir = target.dir
				flick("phase_shift2",animation)
				sleep(5)
				target.loc = mobloc
				target.canmove = 1
				target.client.eye = target
				del(animation)
				del(holder)
			else
				flick("liquify",animation)
				target.loc = holder
				target.client.eye = holder
				var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
				steam.set_up(10, 0, mobloc)
				steam.start()
				sleep(jaunt_duration)
				mobloc = get_turf(target.loc)
				animation.loc = mobloc
				steam.location = mobloc
				steam.start()
				target.canmove = 0
				sleep(20)
				flick("reappear",animation)
				sleep(5)
				target.loc = mobloc
				target.canmove = 1
				target.client.eye = target
				del(animation)
				del(holder)

/obj/effect/dummy/spell_jaunt
	name = "water"
	icon = 'effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = 0
	anchored = 1

/obj/effect/dummy/spell_jaunt/relaymove(var/mob/user, direction)
	if (!src.canmove) return
	var/turf/newLoc = get_step(src,direction)
	if(!(newLoc.flags & NOJAUNT))
		loc = newLoc
/*
	switch(direction)
		if(NORTH)
			src.y++
		if(SOUTH)
			src.y--
		if(EAST)
			src.x++
		if(WEST)
			src.x--
		if(NORTHEAST)
			src.y++
			src.x++
		if(NORTHWEST)
			src.y++
			src.x--
		if(SOUTHEAST)
			src.y--
			src.x++
		if(SOUTHWEST)
			src.y--
			src.x-- */
	src.canmove = 0
	spawn(2) src.canmove = 1

/obj/effect/dummy/spell_jaunt/ex_act(blah)
	return
/obj/effect/dummy/spell_jaunt/bullet_act(blah)
	return