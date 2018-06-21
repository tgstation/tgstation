/datum/relic_effect/activate/shockwave
	weight = 30
	var/radius = 1

/datum/relic_effect/activate/shockwave/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	var/turf/T = get_turf(A)
	for(var/mob/living/L in view(radius,T))
		if(L == user)
			continue
		var/throw_dir = get_dir(T,L)
		var/throw_range = rand(1,4)
		var/turf/throw_at = get_ranged_target_turf(L, throw_dir, throw_range)
		L.throw_at(throw_at, throw_range, EXPLOSION_THROW_SPEED)
	new/obj/effect/explosion(T)
	playsound(A, 'sound/effects/explosion_distant.ogg', rand(25,50), 1)

/datum/relic_effect/activate/bomb
	weight = 10

/datum/relic_effect/activate/bomb
	firstname = list("exploding","fragmenting","fulminating","thermic","blast","nitro")
	lastname = list("bomb","surprise","explodinator","destructor","obliteration")
	hint = list("There is a large red button on the back with a cover over it.")
	var/light = 0
	var/heavy = 0
	var/devastation = 0
	var/flash = 0
	var/fire = 0
	var/reusable = FALSE
	var/timer = 0

/datum/relic_effect/activate/bomb/init()
	..()
	reusable = prob(5) //Yeah no you only get this rarely my friend and you better hope it's useful
	light = rand(0,5)
	heavy = rand(0,5)
	if(!reusable)
		devastation = rand(0,5)
	flash = rand(0,5)
	fire = rand(0,5)
	timer = rand(50,300)
	if(prob(10))
		timer = timer ** 2 //some bombs take extremely long to trigger

/datum/relic_effect/activate/bomb/apply(obj/item/A)
	if(reusable)
		A.resistance_flags |= INDESTRUCTIBLE

/datum/relic_effect/activate/bomb/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	if(user)
		to_chat(user, "<span class='danger'>[A] begins to heat up!</span>")
	playsound(A, 'sound/machines/engine_alert1.ogg', rand(25,50), 1)
	addtimer(CALLBACK(src, .proc/detonate, A), timer)

/datum/relic_effect/activate/bomb/proc/detonate(obj/item/A)
	A.visible_message("<span class='notice'>\The [A]'s top opens, releasing a powerful blast!</span>")
	explosion(A, devastation, heavy, light, flash, flame_range = fire)
	if(!reusable)
		qdel(A)
	else
		playsound(A, 'sound/magic/clockwork/ark_activation.ogg', rand(25,50), 1) //CUCKOO CUCKOO CUCKOO

/datum/relic_effect/activate/teleport
	weight = 30
	var/radius = 8
	var/timer = 0

/datum/relic_effect/activate/teleport/init()
	..()
	radius = rand(1,5)
	if(prob(20))
		radius = radius ** 2
	timer = rand(10,120)

/datum/relic_effect/activate/teleport/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	if(user)
		to_chat(user, "<span class='notice'>[A] begins to vibrate!</span>")
	playsound(A, "sparks", rand(25,50), 1)
	addtimer(CALLBACK(src, .proc/teleport, A, user), timer)

/datum/relic_effect/activate/teleport/proc/teleport(obj/item/A,mob/user)
	var/atom/movable/teleporter = A
	if(A.loc == user)
		teleporter = user
	A.visible_message("<span class='notice'>[A] twists and bends, relocating itself!</span>")
	do_teleport(teleporter, get_turf(teleporter), radius, asoundin = 'sound/effects/phasein.ogg')

/datum/relic_effect/activate/animal_spam
	hint = list("The sounds coming from within have been identified as gorilla mating calls.")
	weight = 30

/datum/relic_effect/activate/animal_spam
	firstname = list("summoning","animal attracting","pet")
	lastname = list("zoo","subspace cage","carrier")
	var/timer = 0
	var/list/sounds = list('sound/magic/pighead_curse.ogg','sound/magic/cowhead_curse.ogg','sound/magic/horsehead_curse.ogg','sound/creatures/gorilla.ogg')

/datum/relic_effect/activate/animal_spam/init()
	..()
	timer = rand(10,120)

/datum/relic_effect/activate/animal_spam/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	A.visible_message("<span class='danger'>[A] begins to shake, and in the distance the sound of rampaging animals arises!</span>")
	playsound(A, pick(sounds), rand(25,50), 1)
	addtimer(CALLBACK(src, .proc/spawn_animals, A), timer)

/datum/relic_effect/activate/animal_spam/proc/spawn_animals(obj/item/A)
	var/turf/T = get_turf(A)
	var/animals = rand(1,25)
	var/list/valid_animals = list(/mob/living/simple_animal/parrot, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/pet/cat, /mob/living/simple_animal/pet/dog/corgi, /mob/living/simple_animal/crab, /mob/living/simple_animal/pet/fox, /mob/living/simple_animal/hostile/lizard, /mob/living/simple_animal/mouse, /mob/living/simple_animal/pet/dog/pug, /mob/living/simple_animal/hostile/bear, /mob/living/simple_animal/hostile/poison/bees, /mob/living/simple_animal/hostile/carp)
	for(var/counter in 1 to animals)
		var/mob_type = pick(valid_animals)
		new mob_type(T)
	if(prob(60))
		A.visible_message("<span class='warning'>[A] falls apart!</span>")
		qdel(A)