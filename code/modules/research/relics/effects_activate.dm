/datum/relic_effect/activate
	var/range = 0
	hogged_signals = list(COMSIG_ITEM_AFTER_ATTACK,COMSIG_ITEM_ATTACK_SELF)

/datum/relic_effect/activate/apply_to_component(obj/item/A,datum/component/relic/comp)
	if(range)
		comp.RegisterSignal(COMSIG_ITEM_AFTER_ATTACK, CALLBACK(src, .proc/activate, A))
	else
		comp.RegisterSignal(COMSIG_ITEM_ATTACK_SELF, CALLBACK(src, .proc/activate, A, A))

/datum/relic_effect/activate/proc/activate(obj/item/A,atom/target,mob/user)
	if(!(target in view(range, get_turf(user))))
		return FALSE
	return use_power(A,user)

/datum/relic_effect/activate/smoke
	var/radius = 2

/datum/relic_effect/activate/smoke/apply()
	radius = rand(0,8)
	..()

/datum/relic_effect/activate/smoke/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(radius, get_turf(target))
	smoke.start()

/datum/relic_effect/activate/flash/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	playsound(A, "sparks", rand(25,50), 1)
	var/obj/item/grenade/flashbang/CB = new(get_turf(target))
	CB.prime()

/datum/relic_effect/activate/clean/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	playsound(A, "sparks", rand(25,50), 1)
	var/obj/item/grenade/chem_grenade/cleaner/CL = new(get_turf(target))
	CL.prime()

/datum/relic_effect/activate/corgi_cannon/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	playsound(A, "sparks", rand(25,50), 1)
	var/mob/living/simple_animal/pet/dog/corgi/C = new(get_turf(A))
	if(range)
		C.throw_at(target, 10, rand(3,8))
	else
		C.throw_at(pick(oview(10,user)), 10, rand(3,8))

/datum/relic_effect/activate/fix_lights
	var/radius = 3

/datum/relic_effect/activate/fix_lights/apply()
	radius = rand(1,3)
	..()

/datum/relic_effect/activate/fix_lights/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	for(var/obj/machinery/light/M in view(radius,get_turf(target)))
		M.fix()

/datum/relic_effect/activate/rapid_dupe
	firstname = list("annoying","multiplying","duplicating","numerifying","dumb","fragmenting")
	lastname = list("duplicator","fissionator","spliterator")
	var/spread = 7

/datum/relic_effect/activate/rapid_dupe/apply()
	spread = rand(2,7) //1 is stacked thrower circuit tier
	..()

/datum/relic_effect/activate/rapid_dupe/activate(obj/item/A,atom/target,mob/user)
	A.audible_message("[A] emits a loud pop!")
	var/list/dupes = list()
	var/max = rand(5,10)
	for(var/counter in 1 to max)
		var/obj/item/R = new(get_turf(A))
		R.appearance = A.appearance
		dupes += R
		R.throw_at(pick(oview(spread,get_turf(target))),10,1)
	QDEL_LIST_IN(dupes, rand(10, 100))

/datum/relic_effect/activate/bomb
	firstname = list("exploding","fragmenting","fulminating","thermic","blast","nitro")
	lastname = list("bomb","surprise","explodinator","destructor","obliteration")
	var/light = 0
	var/heavy = 0
	var/devastation = 0
	var/flash = 0
	var/fire = 0
	var/reusable = FALSE
	var/timer = 0

/datum/relic_effect/activate/bomb/apply()
	reusable = prob(10) //Yeah no you only get this rarely my friend and you better hope it's useful
	light = rand(0,5)
	heavy = rand(0,5)
	if(!reusable)
		devastation = rand(0,5)
	flash = rand(0,5)
	fire = rand(0,5)
	timer = rand(10,120)
	if(prob(10))
		timer = timer ** 2 //some bombs take extremely long to trigger
	..()

/datum/relic_effect/activate/bomb/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	to_chat(user, "<span class='danger'>[A] begins to heat up!</span>")
	addtimer(CALLBACK(src, .proc/detonate, A), timer)

/datum/relic_effect/activate/bomb/proc/detonate(obj/item/A)
	A.visible_message("<span class='notice'>\The [A]'s top opens, releasing a powerful blast!</span>")
	explosion(A, devastation, heavy, light, flash, flame_range = fire)
	if(!reusable)
		qdel(src)

/datum/relic_effect/activate/teleport
	var/radius = 8
	var/timer = 0

/datum/relic_effect/activate/teleport/apply()
	radius = rand(1,5)
	if(prob(20))
		radius = radius ** 2
	timer = rand(10,120)
	..()

/datum/relic_effect/activate/teleport/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	to_chat(user, "<span class='notice'>[A] begins to vibrate!</span>")
	addtimer(CALLBACK(src, .proc/teleport, A, user), timer)

/datum/relic_effect/activate/teleport/proc/teleport(obj/item/A,mob/user)
	var/atom/movable/teleporter = A
	if(A.loc == user)
		teleporter = user
	A.visible_message("<span class='notice'>[A] twists and bends, relocating itself!</span>")
	do_teleport(teleporter, get_turf(teleporter), radius, asoundin = 'sound/effects/phasein.ogg')

/datum/relic_effect/activate/animal_spam
	firstname = list("summoning","animal attracting","pet")
	lastname = list("zoo","subspace cage","carrier")
	var/timer = 0

/datum/relic_effect/activate/animal_spam/apply()
	timer = rand(10,120)
	..()

/datum/relic_effect/activate/animal_spam/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	A.visible_message("<span class='danger'>[A] begins to shake, and in the distance the sound of rampaging animals arises!</span>")
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
		qdel(src)

/datum/relic_effect/activate/rcd
	firstname = list("rapid construction")
	lastname = list("builder")
	var/delay = 0

/datum/relic_effect/activate/rcd/apply()
	delay = rand(1,15)
	..()

/datum/relic_effect/activate/rcd/activate(obj/item/A,atom/target,mob/user)
	if(!delay || A.do_after(user, delay, target))
		if(!..())
			return
		rcd_act(A,target,user)

/datum/relic_effect/activate/rcd/proc/rcd_act(obj/item/A,atom/target,mob/user)

/datum/relic_effect/activate/rcd/wall_and_floor
	var/turf/open/placed_floor = /turf/open/floor/plasteel
	var/turf/closed/placed_wall = /turf/closed/wall

/datum/relic_effect/activate/rcd/wall_and_floor/apply()
	placed_floor = pick(subtypesof(/turf/open/floor) - typesof(/turf/open/floor/plating) - typesof(/turf/open/floor/holofloor) - /turf/open/floor/mineral)
	placed_floor = pick(typesof(/turf/closed/wall) - subtypesof(/turf/closed/wall/mineral/titanium) - subtypesof(/turf/closed/wall/mineral/plastitanium) - /turf/closed/wall/mineral)
	..()

/datum/relic_effect/activate/rcd/wall_and_floor/rcd_act(obj/item/A,atom/target,mob/user)
	var/turf/T = get_turf(target)
	if(is_type(T,/turf/open/space))
		T.PlaceOnTop(placed_floor)
	else if(is_type(T,/turf/open) && !is_type(T,/turf/open/indestructible))
		T.PlaceOnTop(placed_wall)

/datum/relic_effect/activate/rcd/replace_floor
	var/turf/open/placed_floor

/datum/relic_effect/activate/rcd/replace_floor/apply()
	placed_floor = pick(subtypesof(/turf/open/floor) - typesof(/turf/open/floor/plating) - typesof(/turf/open/floor/holofloor) - /turf/open/floor/mineral)
	..()

/datum/relic_effect/activate/rcd/replace_floor/rcd_act(obj/item/A,atom/target,mob/user)
	var/turf/T = get_turf(target)
	if(is_type(T,/turf/open/floor))
		T.remove_tile(user,silent = TRUE)
		T.ChangeTurf(placed_floor)