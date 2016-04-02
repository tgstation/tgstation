/obj/effect/dummy/slaughter //Can't use the wizard one, blocked by jaunt/slow
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = 0
	anchored = 1
	invisibility = 60
	burn_state = LAVA_PROOF

/obj/effect/dummy/slaughter/relaymove(mob/user, direction)
	forceMove(get_step(src,direction))

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
			buckled.unbuckle_mob(src,force=1)
		if(buckled_mobs.len)
			unbuckle_all_mobs(force=1)
		if(pulledby)
			pulledby.stop_pulling()
		if(src.pulling && src.bloodcrawl == BLOODCRAWL_EAT)
			if(istype(src.pulling, /mob/living))
				var/mob/living/victim = src.pulling
				if(victim.stat == CONSCIOUS)
					src.visible_message("<span class='warning'>[victim] kicks free of the blood pool just before entering it!</span>")
				else if(victim.reagents && victim.reagents.has_reagent("demonsblood"))
					visible_message("<span class='warning'>Something prevents [victim] from entering the pool!</span>", "<span class='warning'>A strange force is blocking [victim] from entering!</span>")
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
				if(kidnapped.reagents && kidnapped.reagents.has_reagent("devilskiss"))
					src << "<span class='warning'><b>AAH! THEIR FLESH! IT BURNS!</b></span>"
					adjustBruteLoss(25) //I can't use adjustHealth() here because bloodcrawl affects /mob/living and adjustHealth() only affects simple mobs
					kidnapped.loc = get_turf(B)
					kidnapped.visible_message("<span class='warning'>[B] violently expels [kidnapped]!</span>")
				else
					src << "<span class='danger'>You devour [kidnapped]. Your health is fully restored.</span>"
					src.adjustBruteLoss(-1000)
					src.adjustFireLoss(-1000)
					src.adjustOxyLoss(-1000)
					src.adjustToxLoss(-1000)
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
