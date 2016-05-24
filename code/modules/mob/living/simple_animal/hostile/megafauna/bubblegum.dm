/mob/living/simple_animal/hostile/megafauna/bubblegum
	name = "bubblegum"
	desc = "In what passes for a heirarchy among slaughter demons, this one is king."
	health = 2000
	maxHealth = 2000
	attacktext = "rends"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	icon_state = "bubblegum"
	icon_living = "bubblegum"
	icon_dead = ""
	friendly = "stares down"
	icon = 'icons/mob/lavaland/mech.dmi'
	faction = list("mining")
	weather_immunities = list("lava","ash")
	speak_emote = list("gurgles")
	armour_penetration = 40
	melee_damage_lower = 30
	melee_damage_upper = 30
	speed = 0
	move_to_delay = 10
	ranged = 1
	flying = 1
	mob_size = MOB_SIZE_LARGE
	pixel_x = -32
	del_on_death = 1
	aggro_vision_range = 18
	idle_vision_range = 5
	loot = list(/obj/structure/closet/crate/necropolis/dragon)
	butcher_results = list(/obj/item/weapon/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/animalhide/ashdrake = 10, /obj/item/stack/sheet/bone = 30)
	var/charging = 0

	deathmessage = "crashes to the ground."
	death_sound = 'sound/magic/demon_dies.ogg'


/mob/living/simple_animal/hostile/megafauna/bubblegum/Life()
	..()
/*	if(!charging)
		blood_warp()*/
	move_to_delay = Clamp(round((health/maxHealth) * 10), 3, 10)

/mob/living/simple_animal/hostile/megafauna/bubblegum/OpenFire()
	var/anger_modifier = Clamp(((maxHealth - health)/50),0,20)
	ranged_cooldown = world.time + ranged_cooldown_time

	if(!charging)
		blood_warp()

	if(prob(25))
		blood_spray()

	else if(prob(5+anger_modifier/2))
		slaughterlings()
	else if(prob(5+anger_modifier/2))

		if(health > maxHealth/2 && !client && !charging)
			charge()
		else
			charge()
			sleep(10)
			charge()
			sleep(10)


/mob/living/simple_animal/hostile/megafauna/bubblegum/New()
	..()
	var/obj/effect/proc_holder/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)
	if(istype(loc, /obj/effect/dummy/slaughter))
		bloodspell.phased = 1

/mob/living/simple_animal/hostile/megafauna/bubblegum/AttackingTarget()
	if(charging)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/Move()
	if(!stat)
		playsound(src.loc, 'sound/effects/meteorimpact.ogg', 200, 1)
	if(charging)
		PoolOrNew(/obj/effect/overlay/temp/decoy, list(loc,src))
		for(var/turf/T in range(src, 1))
			T.singularity_pull(src, 5)
	. = ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/charge()
	var/turf/T = get_step_away(target, src)
	charging = 1
	new/obj/effect/overlay/temp/dragon_swoop(T)
	sleep(5)
	throw_at(T, 7, 1, src, 0)
	charging = 0

/mob/living/simple_animal/hostile/megafauna/bubblegum/throw_impact(atom/A)
	if(!charging)
		return ..()

	else if(A)
		if(isliving(A))
			var/mob/living/L = A
			L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] slams into you!</span>")
			L.apply_damage(40, BRUTE)
			playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, 1)
			shake_camera(L, 4, 3)
			shake_camera(src, 2, 3)
			var/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
			L.throw_at_fast(throwtarget)


	charging = 0


/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_warp()
//	if(blood_warp_cooldown > world.time)
//		return
	var/found_bloodpool = FALSE
	for(var/obj/effect/decal/cleanable/blood/nearby in view(src,2))
		found_bloodpool = TRUE
	if(found_bloodpool)
		for(var/obj/effect/decal/cleanable/blood/H in view(target,2))
			visible_message("<span class='danger'>[src] sinks into the blood...</span>")
			playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 100, 1, -1)
			forceMove(get_turf(H))
			playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 100, 1, -1)
			visible_message("<span class='danger'>And springs back out!</span>")
			break


/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_spray()
	visible_message("<span class='danger'>[src] sprays a stream of gore!</span>")
	spawn(0)
		var/turf/E = get_edge_target_turf(src, src.dir)
		var/range = 10
		for(var/turf/open/J in getline(src,E))
			if(!range)
				break
			playsound(J,'sound/effects/splat.ogg', 100, 1, -1)
			new /obj/effect/decal/cleanable/blood(J)
			range--
			sleep(1)

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/slaughterlings()
	visible_message("<span class='danger'>[src] summons a shoal of slaughterlings!</span>")
	for(var/obj/effect/decal/cleanable/blood/H in range(src, 10))
		if(prob(25))
			new /mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/slaughter(H.loc)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/slaughter
	name = "slaughterling"
	desc = "Though not yet strong enough to create a true physical form, it's nonetheless determined to murder you."
	faction = list("mining")
	weather_immunities = list("lava","ash")