/obj/effect/proc_holder/spell/targeted/ethereal_jaunt
	name = "Ethereal Jaunt"
	desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."

	school = "transmutation"
	charge_max = 300
	clothes_req = 1
	invocation = "none"
	invocation_type = "none"
	range = -1
	cooldown_min = 100 //50 deciseconds reduction per rank
	include_user = 1
	centcom_cancast = 0 //Prevent people from getting to centcom
	nonabstract_req = 1
	var/jaunt_duration = 50 //in deciseconds
	action_icon_state = "jaunt"

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/cast(list/targets) //magnets, so mostly hardcoded
	playsound(get_turf(usr), 'sound/magic/Ethereal_Enter.ogg', 50, 1, -1)
	for(var/mob/living/target in targets)
		target.notransform = 1 //protects the mob from being transformed (replaced) midjaunt and getting stuck in bluespace
		spawn(0)
			var/turf/mobloc = get_turf(target.loc)
			var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt( mobloc )
			var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
			animation.name = "water"
			animation.density = 0
			animation.anchored = 1
			animation.icon = 'icons/mob/mob.dmi'
			animation.layer = 5
			animation.master = holder
			target.ExtinguishMob()
			if(target.buckled)
				target.buckled.unbuckle_mob()
			jaunt_disappear(animation, target)
			target.loc = holder
			target.notransform=0 //mob is safely inside holder now, no need for protection.
			jaunt_steam(mobloc)
			sleep(jaunt_duration)
			if(target.loc != holder) //mob warped out of the warp
				qdel(holder)
				return
			mobloc = get_turf(target.loc)
			animation.loc = mobloc
			jaunt_steam(mobloc)
			target.canmove = 0
			holder.reappearing = 1
			playsound(get_turf(usr), 'sound/magic/Ethereal_Exit.ogg', 50, 1, -1)
			sleep(20)
			jaunt_reappear(animation, target)
			sleep(5)
			if(mobloc.density)
				for(var/direction in list(1,2,4,8,5,6,9,10))
					var/turf/T = get_step(mobloc, direction)
					if(T)
						if(target.Move(T))
							break
			target.canmove = 1
			target.client.eye = target
			qdel(animation)
			qdel(holder)

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/proc/jaunt_disappear(atom/movable/overlay/animation, mob/living/target)
	animation.icon_state = "liquify"
	flick("liquify",animation)


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/proc/jaunt_reappear(atom/movable/overlay/animation, mob/living/target)
	flick("reappear",animation)


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/proc/jaunt_steam(mobloc)
	var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
	steam.set_up(10, 0, mobloc)
	steam.start()

/obj/effect/dummy/spell_jaunt
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	var/reappearing = 0
	density = 0
	anchored = 1
	invisibility = 60

/obj/effect/dummy/spell_jaunt/Destroy()
	// Eject contents if deleted somehow
	for(var/atom/movable/AM in src)
		AM.loc = get_turf(src)
	..()

/obj/effect/dummy/spell_jaunt/relaymove(var/mob/user, direction)
	if (!src.canmove || reappearing || !direction) return
	var/turf/newLoc = get_step(src,direction)
	if(!(newLoc.flags & NOJAUNT))
		loc = newLoc
	else
		user << "<span class='warning'>Some strange aura is blocking the way!</span>"
	src.canmove = 0
	spawn(2) src.canmove = 1

/obj/effect/dummy/spell_jaunt/ex_act(blah)
	return
/obj/effect/dummy/spell_jaunt/bullet_act(blah)
	return