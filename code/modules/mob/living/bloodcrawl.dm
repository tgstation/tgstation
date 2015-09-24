#define BLOODCRAWL 1
#define BLOODCRAWL_EAT 2

/obj/effect/dummy/slaughter //Can't use the wizard one, blocked by jaunt/slow
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = 0
	anchored = 1
	invisibility = 60

obj/effect/dummy/slaughter/relaymove(mob/user, direction)
	if (!src.canmove || !direction) return
	var/turf/newLoc = get_step(src,direction)
	loc = newLoc
	src.canmove = 0
	spawn(1)
		src.canmove = 1

/obj/effect/dummy/slaughter/ex_act(blah)
	return
/obj/effect/dummy/slaughter/bullet_act(blah)
	return

/obj/effect/dummy/slaughter/singularity_act(blah)
	return

/obj/effect/dummy/slaughter/Destroy()
	return QDEL_HINT_PUTINPOOL


/mob/living/proc/phaseout(obj/effect/decal/cleanable/B)
	var/mob/living/kidnapped = null
	var/turf/mobloc = get_turf(src.loc)
	src.notransform = TRUE
	spawn(0)
		src.visible_message("[src] sinks into the pool of blood.")
		playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 100, 1, -1)
		var/obj/effect/dummy/slaughter/holder = PoolOrNew(/obj/effect/dummy/slaughter,mobloc)
		src.ExtinguishMob()
		if(src.buckled)
			src.buckled.unbuckle_mob()
		if(src.pulling && src.bloodcrawl == BLOODCRAWL_EAT)
			if(istype(src.pulling, /mob/living))
				var/mob/living/victim = src.pulling
				if(victim.stat == CONSCIOUS)
					src.visible_message("[victim] kicks free of the [src] at the last second!")
				else
					victim.loc = holder
					src.visible_message("<span class='warning'><B>The [src] drags [victim] into the pool of blood!</B>")
					kidnapped = victim
		src.loc = holder
		src.holder = holder
		if(kidnapped)
			src << "<B>You begin to feast on [kidnapped]. You can not move while you are doing this.</B>"
			playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
			sleep(30)
			playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
			sleep(30)
			playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
			sleep(30)
			if(kidnapped)
				src << "<B>You devour [kidnapped]. Your health is fully restored.</B>"
				src.adjustBruteLoss(-1000)
				src.adjustFireLoss(-1000)
				src.adjustOxyLoss(-1000)
				src.adjustToxLoss(-1000)
				kidnapped.ghostize()
				qdel(kidnapped)
			else
				src << "<B>You happily devour...nothing? Your meal vanished at some point!</B>"
		src.notransform = 0

/mob/living/proc/phasein(obj/effect/decal/cleanable/B)
	if(src.notransform)
		src << "<B>Finish eating first!</B>"
		return 0

	src.loc = B.loc
	src.client.eye = src
	src.visible_message("<span class='warning'><B>The [src] rises out of the pool of blood!</B>")
	playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 100, 1, -1)
	qdel(src.holder)
	src.holder = null
	return 1