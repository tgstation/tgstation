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

/datum/relic_effect/activate/fix_lights/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	for(var/obj/machinery/light/M in view(radius,get_turf(target)))
		M.fix()

/datum/relic_effect/activate/bomb
	var/light = 0
	var/heavy = 0
	var/devastation = 0
	var/flash = 0
	var/fire = 0
	var/reusable = FALSE
	var/timer = 0

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
	var/timer = 0

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
