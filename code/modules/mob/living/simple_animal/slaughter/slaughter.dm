//////////////////The Monster

/mob/living/simple_animal/slaughter
	name = "Slaughter Demon"
	real_name = "Slaughter Demon"
	desc = "You should run."
	speak_emote = list("gurgles")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	speed = 0
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("slaughter")
	attacktext = "wildly tears into"
	maxHealth = 250
	health = 250
	environment_smash = 1
	melee_damage_lower = 30
	melee_damage_upper = 30
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	var/devoured = 0
	var/phased = FALSE
	var/holder = null
	var/eating = FALSE
	var/mob/living/kidnapped = null
	var/playstyle_string = "<B>You are the Slaughter Demon, a terible creature from another existence. You have a single desire: To kill.  \
						You may Ctrl+Click on blood pools to travel through them, appearing and dissaapearing from the station at will. \
						Pulling a dead or critical mob while you enter a pool will pull them in with you, allowing you to feast. </B>"


/mob/living/simple_animal/slaughter/death()
	..(1)
	new /obj/effect/decal/cleanable/blood (src.loc)
	new /obj/item/weapon/demonheart (src.loc)
	playsound(get_turf(src),'sound/magic/demon_dies.ogg', 200, 1)
	visible_message("<span class='danger'>The [src] screams in anger as its form collapes into a pool of viscera.</span>")
	ghostize()
	qdel(src)
	return



////////////////////The Powers

/mob/living/simple_animal/slaughter/proc/phaseout(var/obj/effect/decal/cleanable/B)
	var/turf/mobloc = get_turf(src.loc)
	var/turf/bloodloc = get_turf(B.loc)
	if(Adjacent(bloodloc))
		src.notransform = TRUE
		spawn(0)
			src.visible_message("The [src] sinks into the pool of blood.")
			playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 100, 1, -1)
			var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter( mobloc )
			src.ExtinguishMob()
			if(src.buckled)
				src.buckled.unbuckle_mob()
			if(src.pulling)
				if(istype(src.pulling, /mob/living))
					var/mob/living/victim = src.pulling
					if(victim.stat == CONSCIOUS)
						src.visible_message("[victim] kicks free of the [src] at the last second!")
					else
						victim.loc = holder
						src.visible_message("<span class='warning'><B>The [src] drags [victim] into the pool of blood!</B>")
						src.kidnapped = victim
			src.loc = holder
			src.phased = TRUE
			src.holder = holder
			if(src.kidnapped)
				src << "<B>You being to feast on [kidnapped]. You can not move while you are doing this.</B>"
				src.eating = TRUE
				playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
				sleep(30)
				playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
				sleep(30)
				playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
				sleep(30)
				src << "<B>You devour [kidnapped]. Your health is fully restored.</B>"
				src.adjustBruteLoss(-1000)
				kidnapped.ghostize()
				qdel(kidnapped)
				src.devoured++
				src.kidnapped = null
				src.eating = FALSE
			src.notransform = 0

/mob/living/simple_animal/slaughter/proc/phasein(var/obj/effect/decal/cleanable/B)
	if(src.eating)
		src << "<B>Finish eating first!</B>"
	else
		src.loc = B.loc
		src.phased = FALSE
		src.client.eye = src
		src.visible_message("<span class='warning'><B>The [src] rises out of the pool of blood!</B>")
		playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 100, 1, -1)
		qdel(src.holder)

/obj/effect/decal/cleanable/blood/CtrlClick(var/mob/user)
	..()
	if(istype(user, /mob/living/simple_animal/slaughter))
		var/mob/living/simple_animal/slaughter/S = user
		if(S.phased)
			S.phasein(src)
		else
			S.phaseout(src)


/obj/effect/decal/cleanable/trail_holder/CtrlClick(var/mob/user)
	..()
	if(istype(user, /mob/living/simple_animal/slaughter))
		var/mob/living/simple_animal/slaughter/S = user
		if(S.phased)
			S.phasein(src)
		else
			S.phaseout(src)



/turf/CtrlClick(var/mob/user)
	..()
	if(istype(user, /mob/living/simple_animal/slaughter))
		var/mob/living/simple_animal/slaughter/S = user
		for(var/obj/effect/decal/cleanable/B in src.contents)
			if(istype(B, /obj/effect/decal/cleanable/blood) || istype(B, /obj/effect/decal/cleanable/trail_holder))
				if(S.phased)
					S.phasein(B)
					break
				else
					S.phaseout(B)
					break

/obj/effect/dummy/slaughter //Can't use the wizard one, blocked by jaunt/slow
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = 0
	anchored = 1
	invisibility = 60

obj/effect/dummy/slaughter/relaymove(var/mob/user, direction)
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


//////////The Loot

/obj/item/weapon/demonheart
	name = "demon's heart"
	desc = "It's still faintly beating with rage"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "heart-on"
	origin_tech = "combat=5;biotech=8"