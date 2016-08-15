#define MEDAL_PREFIX "Bubblegum"

/*

BUBBLEGUM

Bubblegum spawns randomly wherever a lavaland creature is able to spawn. It is the most powerful slaughter demon in existence.
Bubblegum's footsteps are heralded by shaking booms, proving its tremendous size.

It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power that increase as it takes damage.

It often charges, dealing massive damage to anything unfortunate enough to be standing where it's aiming.
Whenever it isn't chasing something down, it will sink into nearby blood pools (if possible) and springs out of the closest one to its target.
To make this possible, it sprays streams of blood at random.
From these blood pools Bubblegum may summon slaughterlings - weak, low-damage minions designed to impede the target's progress.

When Bubblegum dies, it leaves behind a chest that can contain three things:
 1. A slaughter demon spawner
 2. A bottle that, when activated, drives everyone nearby into a frenzy
 3. A contract that marks for death the chosen target

Difficulty: Hard

*/

/mob/living/simple_animal/hostile/megafauna/bubblegum
	name = "bubblegum"
	desc = "In what passes for a heirarchy among slaughter demons, this one is king."
	health = 2500
	maxHealth = 2500
	attacktext = "rends"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	icon_state = "bubblegum"
	icon_living = "bubblegum"
	icon_dead = ""
	friendly = "stares down"
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	faction = list("mining")
	weather_immunities = list("lava","ash")
	speak_emote = list("gurgles")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 1
	move_to_delay = 10
	ranged = 1
	flying = 1
	mob_size = MOB_SIZE_LARGE
	pixel_x = -32
	del_on_death = 1
	aggro_vision_range = 18
	idle_vision_range = 5
	loot = list(/obj/structure/closet/crate/necropolis/bubblegum)
	var/charging = 0
	medal_type = MEDAL_PREFIX
	score_type = BUBBLEGUM_SCORE
	deathmessage = "sinks into a pool of blood, fleeing the battle. You've won, for now... "
	death_sound = 'sound/magic/enter_blood.ogg'

/obj/item/device/gps/internal/bubblegum
	icon_state = null
	gpstag = "Bloody Signal"
	desc = "You're not quite sure how a signal can be bloody."
	invisibility = 100

/mob/living/simple_animal/hostile/megafauna/bubblegum/Life()
	..()
	move_to_delay = Clamp(round((health/maxHealth) * 10), 5, 10)

/mob/living/simple_animal/hostile/megafauna/bubblegum/OpenFire()
	var/anger_modifier = Clamp(((maxHealth - health)/50),0,20)
	if(charging)
		return
	ranged_cooldown = world.time + ranged_cooldown_time

	blood_warp()

	if(prob(25))
		addtimer(src, "blood_spray", 0)

	else if(prob(5+anger_modifier/2))
		slaughterlings()
	else
		if(health > maxHealth/2 && !client)
			addtimer(src, "charge", 0)
		else
			addtimer(src, "triple_charge", 0)


/mob/living/simple_animal/hostile/megafauna/bubblegum/New()
	..()
	for(var/mob/living/simple_animal/hostile/megafauna/bubblegum/B in mob_list)
		if(B != src)
			qdel(src) //There can be only one
			break
	var/obj/effect/proc_holder/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)
	if(istype(loc, /obj/effect/dummy/slaughter))
		bloodspell.phased = 1
	new/obj/item/device/gps/internal/bubblegum(src)

/mob/living/simple_animal/hostile/megafauna/bubblegum/do_attack_animation(atom/A)
	if(charging)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/AttackingTarget()
	if(charging)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/Goto(target, delay, minimum_distance)
	if(charging)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/Move()
	if(!stat)
		playsound(src.loc, 'sound/effects/meteorimpact.ogg', 200, 1)
	if(charging)
		PoolOrNew(/obj/effect/overlay/temp/decoy, list(loc,src))
		DestroySurroundings()
	. = ..()
	if(charging)
		DestroySurroundings()

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/triple_charge()
	charge()
	sleep(10)
	charge()
	sleep(10)
	charge()

/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/charge()
	var/turf/T = get_step_away(target, src)
	charging = 1
	DestroySurroundings()
	PoolOrNew(/obj/effect/overlay/temp/dragon_swoop, T)
	sleep(5)
	throw_at(T, 7, 1, src, 0)
	charging = 0


/mob/living/simple_animal/hostile/megafauna/bubblegum/Bump(atom/A)
	if(charging)
		if(istype(A, /turf) || istype(A, /obj) && A.density)
			A.ex_act(2)
		DestroySurroundings()
	..()

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
	var/obj/effect/decal/cleanable/blood/found_bloodpool
	var/list/pools = list()
	var/can_jaunt = FALSE
	for(var/obj/effect/decal/cleanable/blood/nearby in view(src,2))
		can_jaunt = TRUE
		break
	if(!can_jaunt)
		return
	for(var/obj/effect/decal/cleanable/blood/nearby in view(get_turf(target),2))
		pools += nearby
	if(pools.len)
		shuffle(pools)
		found_bloodpool = pick(pools)
	if(found_bloodpool)
		visible_message("<span class='danger'>[src] sinks into the blood...</span>")
		playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 100, 1, -1)
		forceMove(get_turf(found_bloodpool))
		playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 100, 1, -1)
		visible_message("<span class='danger'>And springs back out!</span>")


/mob/living/simple_animal/hostile/megafauna/bubblegum/proc/blood_spray()
	visible_message("<span class='danger'>[src] sprays a stream of gore!</span>")
	var/turf/E = get_edge_target_turf(src, src.dir)
	var/range = 10
	var/turf/previousturf = get_turf(src)
	for(var/turf/J in getline(src,E))
		if(!range)
			break
		PoolOrNew(/obj/effect/overlay/temp/bloodsplatter, list(previousturf, get_dir(previousturf, J)))
		if(!previousturf.CanAtmosPass(J))
			break
		playsound(J,'sound/effects/splat.ogg', 100, 1, -1)
		new /obj/effect/decal/cleanable/blood(J)
		range--
		previousturf = J
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

#undef MEDAL_PREFIX