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

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/cast(list/targets,mob/user = usr) //magnets, so mostly hardcoded
	playsound(get_turf(user), 'sound/magic/Ethereal_Enter.ogg', 50, 1, -1)
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
				target.buckled.unbuckle_mob(target,force=1)
			if(target.pulledby)
				target.pulledby.stop_pulling()
			target.stop_pulling()
			if(target.buckled_mobs.len)
				target.unbuckle_all_mobs(force=1)
			jaunt_disappear(animation, target)
			target.loc = holder
			target.reset_perspective(holder)
			target.notransform=0 //mob is safely inside holder now, no need for protection.
			jaunt_steam(mobloc)

			mute(target)
			sleep(jaunt_duration)
			unmute(target)

			if(target.loc != holder) //mob warped out of the warp
				qdel(holder)
				return
			mobloc = get_turf(target.loc)
			animation.loc = mobloc
			jaunt_steam(mobloc)
			target.canmove = 0
			holder.reappearing = 1
			playsound(get_turf(user), 'sound/magic/Ethereal_Exit.ogg', 50, 1, -1)
			sleep(20)
			if(!qdeleted(target))
				jaunt_reappear(animation, target)
			sleep(5)
			qdel(animation)
			qdel(holder)
			if(!qdeleted(target))
				if(mobloc.density)
					for(var/direction in list(1,2,4,8,5,6,9,10))
						var/turf/T = get_step(mobloc, direction)
						if(T)
							if(target.Move(T))
								break
				target.canmove = 1

//Silence wizard during jaunt so they cannot spell cast while invisible
/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/proc/mute(target)
	if(!istype(target, /mob/living/carbon))
		return FALSE

	var/mob/living/carbon/mob_to_mute = target
	if(!mob_to_mute.dna)
		return FALSE
	
	mob_to_mute.dna.add_mutation(MUT_MUTE)
	return TRUE

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/proc/unmute(target)
	if(!istype(target, /mob/living/carbon))
		return FALSE

	var/mob/living/carbon/mob_to_mute = target
	if(!mob_to_mute.dna)
		return FALSE
	
	mob_to_mute.dna.remove_mutation(MUT_MUTE)
	return TRUE

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/proc/jaunt_disappear(atom/movable/overlay/animation, mob/living/target)
	animation.icon_state = "liquify"
	flick("liquify",animation)


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/proc/jaunt_reappear(atom/movable/overlay/animation, mob/living/target)
	flick("reappear",animation)


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/proc/jaunt_steam(mobloc)
	var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread()
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
	burn_state = LAVA_PROOF

/obj/effect/dummy/spell_jaunt/Destroy()
	// Eject contents if deleted somehow
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	return ..()

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
