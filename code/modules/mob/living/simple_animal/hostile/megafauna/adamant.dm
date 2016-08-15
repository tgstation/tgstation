#define MEDAL_PREFIX "Adamant"
#define STATE_NORMAL 0
#define STATE_ATTACKING 1
#define STATE_FREEZE 2

/*

ADAMANT

ADAMANT spawns as part of a rare ruin. It is a statue like walker of unknown origin.

It acts as a ranged creature, firing at targets with directed bolts of energy, while occasionally summoning reinforcements to aid it.

ADAMANT will regularly fire blasts of energy at targets, requiring you to keep moving to avoid being hit.
It will also occasionally fire off a volley of rocket like energy bolts, which arc up high before raining down on all those unlucky enough to be within reach.
The adamantine armour is utterly impenetrable, you will have to break it off somehow to expose the more vulnerable layers beneath.
The machine may also teleport if you get too far out of range. This will temporarily freeze it, presenting an idea time to break off some of its armour.
When weakened, ADAMANT will deploy mobs to support it.

When ADAMANT is destroyed, it leaves behind a chest that can contain X things:
 -
 -
 -

Additionally, when its armour is weakened, adamantine armour plates will be dropped. These can be used to construct an extremely heavy suit of armour. If only you had something sturdy enough to attach the plates to...

Difficulty: Insane

*/

/mob/living/simple_animal/hostile/megafauna/adamant
	name = "ADAMANT"
	desc = "A living hulk of solid adamantine, somehow brought to life."
	health = 2500
	maxHealth = 2500
	attacktext = "pummels"
	attack_sound = 'sound/magic/clockwork/ratvar_attack.ogg'
	icon_state = "adamant"
	icon_living = "adamant"
	icon_dead = "adamant_dead"
	friendly = "stares down"
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	faction = list("mining")
	weather_immunities = list("lava","ash")
	speak_emote = list("bellows")
	density = 1
	armour_penetration = 0
	melee_damage_lower = 60
	melee_damage_upper = 60
	speed = 1
	move_to_delay = 10
	wander = 0
	ranged = 1
	flying = 1
	mob_size = MOB_SIZE_LARGE
	pixel_x = -32
	aggro_vision_range = 18
	idle_vision_range = 5
	del_on_death = 0
	medal_type = MEDAL_PREFIX
	score_type = ADAMANT_SCORE

	deathmessage = "collapses into a heap of twisted metal."
	death_sound = 'sound/magic/demon_dies.ogg'
	damage_coeff = list(BRUTE = 0, BURN = 0, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)

	var/state = STATE_NORMAL
	var/obj/item/device/gps/internal
	var/struck = 0


/obj/item/device/gps/internal/colossus
	icon_state = null
	gpstag = "Hardened Signal"
	desc = "It's a signal, how can it be hard?"
	invisibility = 100

/mob/living/simple_animal/hostile/megafauna/adamant/AttackingTarget()
	if(state == STATE_FREEZE)
		return 0
	..()


/mob/living/simple_animal/hostile/megafauna/adamant/OpenFire()
	if(state)
		return

	state = STATE_ATTACKING
	if(get_dist(src, target) < 7)
		if(prob(70))
			projectile_burst()
		else
			bolt_volley()
		state = STATE_NORMAL
	else
		telefrag(target)


/mob/living/simple_animal/hostile/megafauna/adamant/proc/shoot_projectile(turf/marker)
	if(!marker)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/adamant(startloc)
	P.current = startloc
	P.starting = startloc
	P.firer = src
	P.yo = marker.y - startloc.y
	P.xo = marker.x - startloc.x
	if(target)
		P.original = target
	else
		P.original = marker
	P.fire()


/obj/item/projectile/adamant
	name ="energy bolt"
	icon_state= "chronobolt"
	damage = 25
	armour_penetration = 100
	speed = 2
	eyeblur = 0
	damage_type = BURN
	pass_flags = PASSTABLE


/obj/item/projectile/adamant/on_hit(atom/target, blocked = 0)
	..()
	explosion(target, 0, 1, 2)
	return 1


/mob/living/simple_animal/hostile/megafauna/adamant/Move()
	if(state == STATE_FREEZE)
		return 0
	if(!stat)
		playsound(src.loc, 'sound/effects/meteorimpact.ogg', 200, 1)
	..()


/mob/living/simple_animal/hostile/megafauna/adamant/devour(mob/living/L)
	visible_message(
		"<span class='danger'>[src] burns [L] to ash!</span>",
		"<span class='userdanger'>You burn [L] to ash, restoring your health!</span>")
	adjustBruteLoss(-L.maxHealth/2)
	L.dust()


/mob/living/simple_animal/hostile/megafauna/adamant/proc/projectile_burst()
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 200, 1, 2)
	for(var/turf/T in range(2, target))
		if(prob(30))
			shoot_projectile(T)
	sleep(20)


/mob/living/simple_animal/hostile/megafauna/adamant/proc/telefrag(mob/living/target)
	var/matrix/ntransform = matrix(transform)
	animate(src, transform=ntransform.Scale(10), alpha=0, 10)
	density = 0
	sleep(50)
	forceMove(get_turf(target))
	animate(src, transform=ntransform.Scale(0.1), alpha=255, 10)
	sleep(10)
	density = 1
	for(var/mob/living/M in get_turf(src))
		M.gib()
	freeze()


/mob/living/simple_animal/hostile/megafauna/adamant/proc/freeze()
	state = STATE_FREEZE
	animate(src, icon_state="adamant_freeze", 5)
	sleep(50)
	animate(src, icon_state="adamant", 5)
	struck = 0
	state = STATE_NORMAL


/mob/living/simple_animal/hostile/megafauna/adamant/proc/bolt_storm()
	visible_message("<span class='adamant'>\"<b>TREMBLE</b>\"</span>")
	flick("adamant_storm", src)
	for(var/turf/T in range(12,get_turf(src)))
		if(prob(10))
			PoolOrNew(/obj/effect/overlay/temp/target/adamant, T)
	sleep(20)


/mob/living/simple_animal/hostile/megafauna/adamant/proc/bolt_volley()
	visible_message("<span class='adamant'>\"<b>There is no escape.</b>\"</span>")
	flick("adamant_storm", src)
	var/list/locked = list()
	for(var/mob/living/M in range(12,get_turf(src)))
		if(!faction_check(M))
			locked += M
	for(var/i in 1 to rand(4,8))
		for(var/mob/living/M in locked)
			PoolOrNew(/obj/effect/overlay/temp/target/adamant, get_turf(M))
			if(M.stat == DEAD)
				locked -= M
		sleep(15)


/mob/living/simple_animal/hostile/megafauna/adamant/proc/break_armour()
	if(damage_coeff[BRUTE] < 1)
		damage_coeff[BRUTE] += 0.1
	if(damage_coeff[BURN] < 0.5)
		damage_coeff[BURN] += 0.05
	struck = 1

	bolt_storm()
	sleep(15)
	spawn_minions(damage_coeff[BRUTE]*10)


/mob/living/simple_animal/hostile/megafauna/adamant/proc/spawn_minions(num)
	var/list/target_turfs = list()
	for(var/turf/T in view(4))
		target_turfs += T
	for(var/i in 1 to num)
		var/mob/living/simple_animal/hostile/asteroid/livingmetal/M = new(loc)
		M.GiveTarget(target)
		M.friends = friends
		M.faction = faction
		M.throw_at(pick(target_turfs), 5)


/mob/living/simple_animal/hostile/megafauna/adamant/attackby(obj/item/weapon/W, mob/user, params)
	if((W.force > 20) && (state == STATE_FREEZE) && struck == 0)
		visible_message("<span class='userdanger'>Shards of armour fly off of ADAMANT!</span>")
		break_armour()
	..()


/obj/effect/overlay/temp/target/adamant/fall()
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/Fireball.ogg', 200, 1)
	PoolOrNew(/obj/effect/overlay/temp/fireball/adamant,T)
	sleep(12)
	explosion(T, 0, 1, 2, 0, 0, 0, 1)


/obj/effect/overlay/temp/fireball/adamant
	color = "#ffff00"


/mob/living/simple_animal/hostile/asteroid/livingmetal
	vision_range = 10
	name = "living metal"
	desc = "A lump of animated adamantine."
	icon_state = "livingmetal"
	icon_living = "livingmetal"
	del_on_death = 1
	speak_chance = 0
	turns_per_move = 5
	response_help = "polishes"
	response_disarm = "rolls over"
	response_harm = "hits"
	emote_taunt = list("clangs")
	taunt_chance = 30
	speed = 2
	maxHealth = 50
	health = 50

	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "slams"
	attack_sound = 'sound/weapons/bite.ogg'

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY



#undef MEDAL_PREFIX
#undef STATE_NORMAL
#undef STATE_FREEZE
