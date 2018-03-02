/datum/relic_effect/activate
	var/range = 0
	hogged_signals = list(COMSIG_ITEM_AFTER_ATTACK,COMSIG_ITEM_ATTACK_SELF)

/datum/relic_effect/activate/init()
	..()
	if(prob(30))
		range = rand(1,6)
	if(range)
		hint = list("It has something akin to a pistol trigger.","It appears to have some sort of antennae.")
	else
		hint = list("There's a small button it's back.","It vibrates when touched.")
	hogged_signals = list(range ? COMSIG_ITEM_AFTER_ATTACK : COMSIG_ITEM_ATTACK_SELF)

/datum/relic_effect/activate/apply_to_component(obj/item/A,datum/component/relic/comp)
	if(range)
		comp.RegisterSignal(COMSIG_ITEM_AFTER_ATTACK, CALLBACK(src, .proc/activate, A))
	else
		comp.RegisterSignal(COMSIG_ITEM_ATTACK_SELF, CALLBACK(src, .proc/activate, A, A))

/datum/relic_effect/activate/proc/activate(obj/item/A,atom/target,mob/user)
	if(range && !(target in view(range, get_turf(user))))
		return FALSE
	return use_power(A,user)

/datum/relic_effect/activate/smoke
	weight = 50
	var/radius = 2

/datum/relic_effect/activate/smoke/init()
	..()
	radius = rand(0,8)

/datum/relic_effect/activate/smoke/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(radius, get_turf(target))
	smoke.start()

/datum/relic_effect/activate/flash
	hint = list("Analysis revealed a hidden, high-powered bulb within.")
	weight = 50
	var/radius = 2
	var/ignites = FALSE

/datum/relic_effect/activate/flash/init()
	radius = rand(1,5)
	if(prob(40))
		ignites = TRUE

/datum/relic_effect/activate/flash/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	playsound(A, "sparks", rand(25,50), 1)
	for (var/mob/living/L in viewers(radius, get_turf(target)))
		if(L.flash_act(affect_silicon = 1))
			L.Knockdown(80)
		if(ignites)
			L.IgniteMob()

/datum/relic_effect/activate/flashbang
	hint = list("Analysis revealed a hidden compartment containing riot-suppression gear.")
	weight = 50

/datum/relic_effect/activate/flashbang/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	playsound(A, "sparks", rand(25,50), 1)
	var/obj/item/grenade/flashbang/CB = new(get_turf(target))
	CB.prime()

/datum/relic_effect/activate/clean
	hint = list("Analysis revealed a hidden compartment containing an unknown variant of space cleaner.")
	weight = 50

/datum/relic_effect/activate/clean/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	playsound(A, "sparks", rand(25,50), 1)
	var/obj/item/grenade/chem_grenade/cleaner/CL = new(get_turf(target))
	CL.prime()

/datum/relic_effect/activate/corgi_cannon
	hint = list("Depth-scans conclude that it is filled with orange-white speckled cubes.")
	weight = 20

/datum/relic_effect/activate/corgi_cannon/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	playsound(A, "sparks", rand(25,50), 1)
	var/mob/living/simple_animal/pet/dog/corgi/C = new(get_turf(A))
	if(range)
		C.throw_at(target, 10, rand(3,8))
	else
		C.throw_at(pick(oview(10,get_turf(A))), 10, rand(3,8))

/datum/relic_effect/activate/fix_lights
	weight = 50
	var/radius = 3

/datum/relic_effect/activate/fix_lights/init()
	..()
	radius = rand(1,3)

/datum/relic_effect/activate/fix_lights/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	var/success = FALSE
	for(var/obj/machinery/light/M in view(radius,get_turf(target)))
		M.fix()
		success = TRUE
	if(!success)
		playsound(A, 'sound/machines/deniedbeep.ogg', rand(25,50), 1)
		A.visible_message("[A] flashes its 'OUT OF RANGE' indicator.")
	else
		playsound(A, "sparks", rand(25,50), 1)
		A.visible_message("[A] gleefully fixes the broken lights.")

/datum/relic_effect/activate/icer
	hint = list("There's a small nozzle on it.","It's filled with cold gas.")
	weight = 40

/datum/relic_effect/activate/icer/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	if(target == A)
		target = pick(oview(8,get_turf(A)))
	A.visible_message("[A] fires a stream of cold air at [target]!")
	playsound(A, 'sound/effects/smoke.ogg', 50, 1, -3)
	for(var/turf/open/T in getline(get_turf(A),target))
		for(var/mob/living/L in T)
			if(L == user)
				continue
			L.apply_status_effect(/datum/status_effect/freon)
			L.ExtinguishMob()
		T.MakeSlippery(TURF_WET_PERMAFROST, 5)
		var/obj/effect/particle_effect/smoke/S = new(T) //It's not nanofrost i promise
		S.color = "#B2FFFF"
		S.opaque = 0
		sleep(1)

/datum/relic_effect/activate/shockwave
	weight = 60
	var/radius = 1

/datum/relic_effect/activate/shockwave/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	for(var/mob/living/L in view(radius,target))
		if(L == user)
			continue
		var/throw_dir = get_dir(A,L)
		var/throw_range = rand(1,4)
		var/turf/throw_at = get_ranged_target_turf(L, throw_dir, throw_range)
		L.throw_at(throw_at, throw_range, EXPLOSION_THROW_SPEED)
	new/obj/effect/explosion(get_turf(target))
	playsound(A, 'sound/effects/explosion_distant.ogg', rand(25,50), 1)

/datum/relic_effect/activate/rapid_dupe
	weight = 20

/datum/relic_effect/activate/rapid_dupe
	firstname = list("annoying","multiplying","duplicating","numerifying","dumb","fragmenting")
	lastname = list("duplicator","fissionator","spliterator")
	var/spread = 7

/datum/relic_effect/activate/rapid_dupe/init()
	..()
	spread = rand(2,7) //1 is stacked thrower circuit tier

/datum/relic_effect/activate/rapid_dupe/activate(obj/item/A,atom/target,mob/user)
	A.audible_message("[A] emits a loud pop!")
	playsound(A, 'sound/effects/bang.ogg', rand(25,50), 1)
	var/list/dupes = list()
	var/max = rand(5,10)
	for(var/counter in 1 to max)
		var/obj/item/R = new(get_turf(A))
		R.appearance = A.appearance
		R.throwforce = A.throwforce //Yeah ok actually this will have a use as an object gun
		dupes += R
		R.throw_at(pick(oview(spread,get_turf(target))),10,1)
	QDEL_LIST_IN(dupes, rand(10, 100))

/datum/relic_effect/activate/bomb
	weight = 40

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

/datum/relic_effect/activate/bomb/init()
	..()
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
		qdel(src)
	else
		playsound(A, 'sound/magic/clockwork/ark_activation.ogg', rand(25,50), 1) //CUCKOO CUCKOO CUCKOO

/datum/relic_effect/activate/teleport
	weight = 40
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
		qdel(src)

/datum/relic_effect/activate/rcd
	firstname = list("rapid construction")
	lastname = list("builder")
	var/delay = 0

/datum/relic_effect/activate/rcd/init()
	..()
	delay = rand(1,15)

/datum/relic_effect/activate/rcd/activate(obj/item/A,atom/target,mob/user)
	if(!delay || (user && do_after(user, delay, target)))
		if(!..())
			return
		rcd_act(A,target,user)

/datum/relic_effect/activate/rcd/proc/rcd_act(obj/item/A,atom/target,mob/user)

/datum/relic_effect/activate/rcd/wall_and_floor
	var/turf/open/placed_floor = /turf/open/floor/plasteel
	var/turf/closed/placed_wall = /turf/closed/wall

/datum/relic_effect/activate/rcd/wall_and_floor/init()
	..()
	placed_floor = pick(subtypesof(/turf/open/floor) - typesof(/turf/open/floor/plating) - typesof(/turf/open/floor/holofloor) - /turf/open/floor/mineral)
	placed_wall = pick(typesof(/turf/closed/wall) - subtypesof(/turf/closed/wall/mineral/titanium) - subtypesof(/turf/closed/wall/mineral/plastitanium) - /turf/closed/wall/mineral)

/datum/relic_effect/activate/rcd/wall_and_floor/rcd_act(obj/item/A,atom/target,mob/user)
	var/turf/T = get_turf(target)
	if(istype(T,/turf/open/space))
		T.PlaceOnTop(placed_floor)
	else if(istype(T,/turf/open) && !istype(T,/turf/open/indestructible))
		T.PlaceOnTop(placed_wall)

/datum/relic_effect/activate/rcd/replace_floor
	var/turf/open/placed_floor

/datum/relic_effect/activate/rcd/replace_floor/init()
	..()
	placed_floor = pick(subtypesof(/turf/open/floor) - typesof(/turf/open/floor/plating) - typesof(/turf/open/floor/holofloor) - /turf/open/floor/mineral)

/datum/relic_effect/activate/rcd/replace_floor/rcd_act(obj/item/A,atom/target,mob/user)
	var/turf/open/floor/T = get_turf(target)
	if(istype(T) && !istype(T,placed_floor))
		T.remove_tile(user,silent = TRUE)
		T.ChangeTurf(placed_floor)

/datum/relic_effect/activate/loot
	hint = list("It contains something unknown.")
	weight = 40

/datum/relic_effect/activate/loot/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	var/obj/item/a_gift/anything/lootbox = new()
	var/gift_type = lootbox.get_gift_type()
	new gift_type(get_turf(A))
	A.visible_message("<span class='warning'>[A] pops open!</span>")
	qdel(lootbox)
	qdel(A)

/datum/relic_effect/activate/reagent
	var/chem_amt = 10
	var/chem_multiplier = 1

/datum/relic_effect/activate/reagent/smoke/init()
	..()
	chem_amt = rand(1,400) //goofball seal of quality
	if(prob(20))
		chem_multiplier = rand(1,4) //with added spicy

/datum/relic_effect/activate/reagent/smoke
	weight = 50
	var/radius = 2

/datum/relic_effect/activate/reagent/smoke/init()
	..()
	radius = rand(0,8)

/datum/relic_effect/activate/reagent/smoke/activate(obj/item/A,atom/target,mob/user)
	if(!A.reagents || !A.reagents.total_volume || !..())
		return
	var/datum/reagents/holder = new(chem_amt)
	holder.set_reacting(FALSE)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(holder, radius, get_turf(target), silent = 1)
	playsound(A, 'sound/effects/smoke.ogg', 50, 1, -3)
	smoke.start()
	qdel(holder)

/datum/relic_effect/activate/reagent/foamer
	weight = 50
	var/radius = 2

/datum/relic_effect/activate/reagent/foamer/init()
	..()
	radius = rand(0,5)

/datum/relic_effect/activate/reagent/foamer/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	if(target == A)
		target = pick(oview(8,get_turf(A)))
	A.visible_message("[A] fires a stream of foam at [target]!")
	playsound(A, 'sound/effects/smoke.ogg', 50, 1, -3)
	var/datum/reagents/holder = new(chem_amt)
	holder.set_reacting(FALSE)
	for(var/turf/open/T in getline(get_turf(A),target))
		A.reagents.copy_to(holder,chem_amt,chem_multiplier)
		var/datum/effect_system/foam_spread/foam = new
		foam.set_up(radius, T, holder)
		foam.start()
		sleep(1)
	A.reagents.remove_any(chem_amt)
	qdel(holder)