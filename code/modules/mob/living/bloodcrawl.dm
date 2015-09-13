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
		src.visible_message("<span class='warning'>[src] sinks into the pool of blood!</span>")
		playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 100, 1, -1)
		var/obj/effect/dummy/slaughter/holder = PoolOrNew(/obj/effect/dummy/slaughter,mobloc)
		src.ExtinguishMob()
		if(src.buckled)
			src.buckled.unbuckle_mob()
		if(src.pulling && src.bloodcrawl == BLOODCRAWL_EAT)
			if(istype(src.pulling, /mob/living))
				var/mob/living/victim = src.pulling
				if(victim.stat == CONSCIOUS)
					src.visible_message("<span class='warning'>[victim] kicks free of the blood pool just before entering it!</span>")
				else
					victim.loc = holder
					victim.emote("scream")
					src.visible_message("<span class='warning'><b>[src] drags [victim] into the pool of blood!</b></span>")
					kidnapped = victim
		src.loc = holder
		src.holder = holder
		if(kidnapped)
			src << "<span class='danger'>You begin to feast on [kidnapped]. You can not move while you are doing this.</span>"
			for(var/i = 3; i > 0; i--)
				playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
				sleep(30)
			if(kidnapped)
				src << "<span class='danger'>You devour [kidnapped]. Your health is fully restored.</span>"
				src.adjustBruteLoss(-1000)
				src.adjustFireLoss(-1000)
				src.adjustOxyLoss(-1000)
				src.adjustToxLoss(-1000)
				if(istype(src, /mob/living/simple_animal/slaughter))
					var/mob/living/simple_animal/slaughter/S = src
					kidnapped << "<span class='userdanger'>You feel teeth sink into your flesh, and the--</span>"
					kidnapped.adjustBruteLoss(1000)
					kidnapped.loc = src
					S.consumed_mobs.Add(kidnapped)
				else
					kidnapped.ghostize()
					qdel(kidnapped)
			else
				src << "<span class='danger'>You happily devour... nothing? Your meal vanished at some point!</span>"
		src.notransform = 0

/mob/living/proc/phasein(obj/effect/decal/cleanable/B)
	if(src.notransform)
		src << "<span class='warning'>Finish eating first!</span>"
		return 0
	B.visible_message("<span class='warning'>[B] starts to bubble...</span>")
	if(!do_after(src, 20, target = B))
		return
	if(!B)
		return
	src.loc = B.loc
	src.client.eye = src
	src.visible_message("<span class='warning'><B>[src] rises out of the pool of blood!</B>")
	playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 100, 1, -1)
	qdel(src.holder)
	src.holder = null
	return 1