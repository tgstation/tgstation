/mob/living/simple_animal/hostile/illusion
	name = "illusion"
	desc = "It's a fake!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "static"
	icon_living = "static"
	icon_dead = "null"
	melee_damage_lower = 5
	melee_damage_upper = 5
	a_intent = "harm"
	maxHealth = 100
	health = 100
	speed = 0
	faction = list("illusion")
	var/life_span = INFINITY //how long until they despawn
	var/mob/living/parent_mob


/mob/living/simple_animal/hostile/illusion/Life()
	..()
	if(world.time > life_span)
		death()


/mob/living/simple_animal/hostile/illusion/proc/Copy_Parent(mob/living/original, life = 50)
	appearance = original.appearance
	parent_mob = original
	dir = original.dir
	life_span = world.time+life //5 seconds


/mob/living/simple_animal/hostile/illusion/death()
	..()
	visible_message("<span class='warning'>[src] vanishes in a puff of smoke! It was a fake!</span>")
	qdel(src)


/mob/living/simple_animal/hostile/illusion/examine(mob/user)
	if(parent_mob)
		parent_mob.examine(user)
	else
		return ..()


///////Actual Types/////////

/mob/living/simple_animal/hostile/illusion/escape
	retreat_distance = 10
	minimum_distance = 10