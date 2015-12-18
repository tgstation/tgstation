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
	burn_state = LAVA_PROOF


obj/effect/dummy/slaughter/relaymove(mob/user, direction)
	if (!src.canmove || !direction) return
	var/turf/newLoc = get_step(src,direction)
	loc = newLoc
	src.canmove = 0
	spawn(1)
		src.canmove = 1

/obj/effect/dummy/slaughter/ex_act()
	return
/obj/effect/dummy/slaughter/bullet_act()
	return

/obj/effect/dummy/slaughter/singularity_act()
	return

/obj/effect/dummy/slaughter/Destroy()
	..()
	return QDEL_HINT_PUTINPOOL


/mob/living/proc/phaseout(obj/effect/decal/cleanable/B)
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		if(C.l_hand || C.r_hand)
			C << "<span class='warning'>You may not hold items while blood crawling!</span>"
			return 0
		var/obj/item/weapon/bloodcrawl/B1 = new(C)
		var/obj/item/weapon/bloodcrawl/B2 = new(C)
		B1.icon_state = "bloodhand_left"
		B2.icon_state = "bloodhand_right"
		C.put_in_hands(B1)
		C.put_in_hands(B2)
		C.regenerate_icons()
	var/mob/living/kidnapped = null
	var/turf/mobloc = get_turf(src.loc)
	src.notransform = TRUE
	spawn(0)
		src.visible_message("<span class='warning'>[src] sinks into the pool of blood!</span>")
		playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 100, 1, -1)
		var/obj/effect/dummy/slaughter/holder = PoolOrNew(/obj/effect/dummy/slaughter,mobloc)
		src.ExtinguishMob()
		if(buckled)
			buckled.unbuckle_mob(force=1)
		if(buckled_mob)
			unbuckle_mob(force=1)
		if(pulledby)
			pulledby.stop_pulling()
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
	return 1

/obj/item/weapon/bloodcrawl
	name = "blood crawl"
	desc = "You are unable to hold anything while in this form."
	icon = 'icons/effects/blood.dmi'
	flags = NODROP|ABSTRACT

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
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		for(var/obj/item/weapon/bloodcrawl/BC in C)
			BC.flags = null
			C.unEquip(BC)
			qdel(BC)
	var/oldcolor = src.color
	if(istype(B, /obj/effect/decal/cleanable/xenoblood)) //Makes the mob have the color of the blood pool it came out of for a few seconds
		src.color = rgb(43, 186, 0)
	else
		src.color = rgb(149, 10, 10)
	qdel(src.holder)
	src.holder = null
	spawn(30)
		src.color = oldcolor
	return 1
