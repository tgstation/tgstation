/mob/living/simple_animal/hostile/humanoid/jackal
	name = "jackal"
	desc = "An undead creature with the body of a human and the head of a jackal."

	icon = 'icons/mob/hostile_humanoid.dmi'
	icon_state = "jackal"

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	health = 100
	maxHealth = 100

	move_to_delay = 4
	speed = 1

	melee_damage_lower = 5
	melee_damage_upper = 7
	attacktext = "claws"

	stat_attack = UNCONSCIOUS
	heat_damage_per_tick = 0

	faction = "mummy"
	corpse = null

/mob/living/simple_animal/hostile/humanoid/jackal/Die()
	visible_message("<span class='danger'>\The [src] crumbles to dust!</span>")

	..()
	//qdel(src) is called in the parent

/mob/living/simple_animal/hostile/humanoid/jackal/adjustFireLoss() //Immune to fire
	return

/mob/living/simple_animal/hostile/humanoid/jackal/embalmer
	name = "jackal embalmer"
	desc = "An undead humanoid with the head of a jackal. It possesses the ability to raise corpses from the dead - as mummies under its service."

	icon_state = "embalmer"

	stat_attack = DEAD
	stat_exclusive = 1 //ONLY attack dead

	melee_damage_lower = 40
	melee_damage_upper = 50

/mob/living/simple_animal/hostile/humanoid/jackal/embalmer/AttackingTarget()
	if(!ismob(target)) return

	visible_message("<span class='danger'>\The [src] performs a ritual over \the [target]'s body.</span>")

	if(prob(15))
		var/mob/living/L = target

		var/mob/living/simple_animal/hostile/humanoid/mummy/M = new(get_turf(L))

		M.ckey = ckey(L.key)
		M.mind = L.mind
		if(M.mind)
			M.mind.current = M

		to_chat(M, "<span class='danger'>You are a mummy under the service of \the [src]. Protect your master and destroy any invaders that dare step foot into this place.</span>")

		L.dust()
		target = null

/mob/living/simple_animal/hostile/humanoid/jackal/firebreather
	name = "jackal firebreather"
	desc = "An undead humanoid with the head of a jackal. It possesses the ability to breathe fire."

	icon_state = "firebreather"

	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/fire_breath
	projectilesound = 'sound/weapons/flamethrower.ogg'

	ranged_message = "breathes fire"

/mob/living/simple_animal/hostile/humanoid/jackal/firebreather/pyromaniac
	name = "jackal pyromaniac"
	desc = "An undead pyromaniac with the head of a jackal."

	icon_state = "pyromaniac"

	rapid = 1

	health = 125
	maxHealth = 125


/mob/living/simple_animal/hostile/humanoid/jackal/firebreather/pyromaniac/New()
	..()

	overlays.Add(image(icon = icon, icon_state = "pyromaniac_eyes", layer = LIGHTING_LAYER + 1))

/mob/living/simple_animal/hostile/humanoid/jackal/firebreather/pyromaniac/Shoot()
	var/old_target = src.target

	target = get_step(target, pick(alldirs))

	..()

	target = old_target
