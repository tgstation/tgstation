/datum/relic_effect/targeted
	var/range = 0
	var/min_range = 1
	var/max_range = 6
	var/ranged_chance = 30 //Chance for this to be ranged
	var/affects_humans = TRUE
	var/affects_turfs = TRUE
	var/affects_global = TRUE

/datum/relic_effect/targeted/init()
	..()
	if(prob(ranged_chance))
		range = rand(min_range,max_range)

/datum/relic_effect/targeted/proc/activate(obj/item/A,atom/target,mob/user)
	if(range && !(target in view(range, get_turf(A))))
		return FALSE
	return use_power(A,user)

/datum/relic_effect/targeted/smoke
	weight = 50
	var/radius = 2

/datum/relic_effect/targeted/smoke/init()
	..()
	radius = rand(0,8)

/datum/relic_effect/targeted/smoke/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(radius, get_turf(target))
	smoke.start()

/datum/relic_effect/targeted/flash
	hint = list("Analysis revealed a hidden, high-powered bulb within.")
	weight = 50
	var/radius = 2
	var/ignites = FALSE

/datum/relic_effect/targeted/flash/init()
	radius = rand(1,5)
	if(prob(40))
		ignites = TRUE

/datum/relic_effect/targeted/flash/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	playsound(A, "sparks", rand(25,50), 1)
	for (var/mob/living/L in viewers(radius, get_turf(target)))
		if(L.flash_act(affect_silicon = 1))
			L.Knockdown(80)
		if(ignites)
			L.IgniteMob()

/datum/relic_effect/targeted/grenade
	var/grenade_type

/datum/relic_effect/targeted/grenade/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	playsound(A, "sparks", rand(25,50), 1)
	var/obj/item/grenade/CB = new grenade_type(get_turf(target))
	CB.prime()

/datum/relic_effect/targeted/grenade/flashbang
	hint = list("Analysis revealed a hidden compartment containing riot-suppression gear.")
	weight = 50
	grenade_type = /obj/item/grenade/flashbang

/datum/relic_effect/targeted/grenade/clean
	hint = list("Analysis revealed a hidden compartment containing an unknown variant of space cleaner.")
	weight = 50
	grenade_type = /obj/item/grenade/chem_grenade/cleaner

/datum/relic_effect/targeted/corgi_cannon
	hint = list("Depth-scans conclude that it is filled with orange-white speckled cubes.")
	weight = 20

/datum/relic_effect/targeted/corgi_cannon/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	playsound(A, "sparks", rand(25,50), 1)
	var/mob/living/simple_animal/pet/dog/corgi/C = new(get_turf(A))
	C.throw_at(target, 10, rand(3,8))

/datum/relic_effect/targeted/fix_lights
	weight = 50

/datum/relic_effect/targeted/fix_lights/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	for(var/obj/machinery/light/M in get_turf(target))
		M.fix()
		playsound(target, "sparks", rand(25,50), 1)
		M.visible_message("<span class='notice'>[M] is instantly repaired.</span>")

/datum/relic_effect/targeted/icer
	hint = list("There's a small nozzle on it.","It's filled with cold gas.")
	weight = 40

/datum/relic_effect/targeted/icer/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	var/turf/open/T = get_turf(target)
	playsound(T, 'sound/effects/smoke.ogg', 50, 1, -3)
	if(istype(T))
		T.MakeSlippery(TURF_WET_PERMAFROST, 5)
	for(var/mob/living/L in T)
		if(L == user)
			continue
		L.apply_status_effect(/datum/status_effect/freon)
		L.ExtinguishMob()
	var/obj/effect/particle_effect/smoke/S = new(T) //It's not nanofrost i promise
	S.color = "#B2FFFF"
	S.opaque = 0

//Thrown ala grenade launchers
/datum/relic_effect/targeted/thrown
	var/spread = 7
	var/item_type

/datum/relic_effect/targeted/thrown/init()
	..()
	spread = rand(2,7) //1 is stacked thrower circuit tier

/datum/relic_effect/targeted/thrown/activate(obj/item/A,atom/target,mob/user)
	A.audible_message("[A] emits a loud pop!")
	playsound(A, 'sound/effects/bang.ogg', rand(25,50), 1)
	var/obj/R = create_item(A)
	R.throw_at(pick(oview(spread,get_turf(target))),10,1)

/datum/relic_effect/targeted/thrown/proc/create_item(obj/item/A) //Use this to setup an item to throw at people
	return new item_type(get_turf(A))

/datum/relic_effect/targeted/thrown/rapid_dupe
	firstname = list("annoying","multiplying","duplicating","numerifying","dumb","fragmenting")
	lastname = list("duplicator","fissionator","spliterator")
	weight = 20

/datum/relic_effect/targeted/thrown/rapid_dupe/create_item(obj/item/A)
	var/obj/item/R = new(get_turf(A))
	R.appearance = A.appearance
	R.throwforce = A.throwforce //Yeah ok actually this will have a use as an object gun
	QDEL_IN(R, rand(10, 100))

/datum/relic_effect/targeted/thrown/grenade/create_item(obj/item/A)
	var/obj/item/grenade/G = new item_type(get_turf(A))
	G.active = TRUE
	addtimer(CALLBACK(G,/obj/item/grenade/proc/prime),rand(10,100))

/datum/relic_effect/targeted/thrown/grenade/cleaner
	weight = 50
	item_type = /obj/item/grenade/chem_grenade/cleaner

/datum/relic_effect/targeted/thrown/grenade/flashbang
	weight = 50
	item_type = /obj/item/grenade/flashbang

/datum/relic_effect/targeted/thrown/grenade/antiweed
	weight = 50
	item_type = /obj/item/grenade/chem_grenade/antiweed

/datum/relic_effect/targeted/thrown/soap
	weight = 50
	item_type = /obj/item/soap

/datum/relic_effect/targeted/thrown/banana
	weight = 50
	item_type = /obj/item/grown/bananapeel

/datum/relic_effect/targeted/thrown/tomato
	weight = 50
	item_type = /obj/item/reagent_containers/food/snacks/grown/tomato

//Hunger
/datum/relic_effect/targeted/hunger
	weight = 50

/datum/relic_effect/targeted/hunger/activate(obj/item/A,mob/target,mob/user)
	if(istype(target))
		target.nutrition -= 50
		to_chat(target,"<span class='danger'>You feel famished!</span>")

/datum/relic_effect/targeted/hallucination
	weight = 50
	var/list/hallucinations = list(/datum/hallucination/hudscrew,/datum/hallucination/xeno_attack,/datum/hallucination/delusion)

/datum/relic_effect/targeted/hallucination/activate(obj/item/A,mob/target,mob/user)
	if(istype(target))
		var/hallucination = pick(hallucinations)
		new hallucination(target,TRUE)

/datum/relic_effect/targeted/rust/activate(obj/item/A,atom/target,mob/user)
	var/turf/T = get_turf(target)
	if(T.type == /turf/closed/wall/r_wall)
		T.ChangeTurf(/turf/closed/wall/r_wall/rust)
	else if(T.type == /turf/closed/wall)
		T.ChangeTurf(/turf/closed/wall/rust)

/datum/relic_effect/targeted/grass/activate(obj/item/A,atom/target,mob/user)
	var/turf/T = get_turf(target)
	if(isfloorturf(T))
		T.ChangeTurf(/turf/open/floor/grass)

/datum/relic_effect/targeted/lube/activate(obj/item/A,atom/target,mob/user)
	var/turf/T = get_turf(target)
	if(isfloorturf(T))
		var/turf/open/floor/T2
		T2.MakeSlippery(TURF_WET_LUBE)

/datum/relic_effect/targeted/repair_robot
	weight = 20
	hint = list("Analysis revealed a full set of 80 different diagnostic tools. Only 7 could be identified.")
	var/healed_brute = 10
	var/healed_burn = 10
	var/list/affected_types

/datum/relic_effect/targeted/repair_robot/init()
	affected_types = typecacheof(/mob/living/silicon) + typecacheof(/mob/living/simple_animal/bot) + typecacheof(/mob/living/simple_animal/drone)
	healed_brute = rand(5,20)
	healed_burn = rand(5,20)
	if(prob(30)) //Damage converter
		healed_brute *= pick(-1,1)
		healed_burn *= SIGN(-healed_brute)

/datum/relic_effect/targeted/repair_robot/activate(obj/item/A,mob/living/target,mob/user)
	if(affected_types[target.type])
		target.adjustBruteLoss(-healed_brute)
		target.adjustFireLoss(-healed_burn)

/datum/relic_effect/targeted/close_wounds/activate(obj/item/A,mob/living/carbon/human/target,mob/user)
	if(istype(target))
		if(target.bleed_rate)
			to_chat(target,"<span class='notice'>Thin bandages appear over your wounds.</span>")
		target.suppress_bloodloss(600)

/datum/relic_effect/targeted/tame
	var/faction = "neutral"

/datum/relic_effect/targeted/tame/activate(obj/item/A,mob/living/target,mob/user)
	if(istype(target) && !(faction in target.faction))
		target.faction |= faction
		to_chat(target,"<span class='notice'>You feel tame.</span>")

/datum/relic_effect/targeted/fireworks/activate(obj/item/A,atom/target,mob/user)
	var/turf/T = get_turf(target)
	var/obj/effect/particle_effect/sparks/S = new(T)
	S.color = pick("#C73232","#5998FF","#2A9C3B")

/datum/relic_effect/targeted/growth/activate(obj/item/A,atom/target,mob/user)
	var/turf/T = get_turf(target)
	for(var/obj/machinery/hydroponics/H in T)
		H.adjustWater(100)
		H.adjustNutri(10)
		H.update_icon()

/datum/relic_effect/targeted/bolt_door/activate(obj/item/A,atom/target,mob/user)
	var/turf/T = get_turf(target)
	for(var/obj/machinery/door/airlock/D in T)
		D.bolt()

/datum/relic_effect/targeted/zombify/activate(obj/item/A,mob/living/carbon/human/target,mob/user)
	if(istype(target) && target.stat == DEAD)
		var/mob/living/simple_animal/hostile/blob/blobspore/B = new(target.loc)
		B.Zombify(target)
		B.name = "zombie"
		B.desc = "A shambling corpse animated by technology."

/datum/relic_effect/targeted/drop_hat/activate(obj/item/A,mob/living/carbon/human/target,mob/user)
	if(istype(target) && target.head && target.dropItemToGround(target.head))
		to_chat(target,"<span class='notice'>Your hat falls off!</span>")

/datum/relic_effect/targeted/equip_mask
	var/mask_type = /obj/item/clothing/mask/gas
	var/location_string = "on your face"

/datum/relic_effect/targeted/equip_mask/activate(obj/item/A,mob/living/carbon/human/target,mob/user)
	if(istype(target) && !target.wear_mask)
		var/obj/item/clothing/mask/I = new mask_type()
		if(target.equip_to_slot_or_del(I,SLOT_WEAR_MASK))
			to_chat(target,"<span class='warning'>Suddenly [I] appears [location_string]!</span>")

/datum/relic_effect/targeted/equip_mask/cigar
	mask_type = /obj/item/clothing/mask/cigarette/cigar
	location_string = "in your mouth"

/datum/relic_effect/targeted/equip_mask/cigarette
	mask_type = /obj/item/clothing/mask/cigarette
	location_string = "in your mouth"

/datum/relic_effect/targeted/equip_mask/cigarette
	mask_type = /obj/item/clothing/mask/cigarette
	location_string = "in your mouth"

/datum/relic_effect/targeted/power_machine/activate(obj/item/A,atom/target,mob/user)
	var/turf/T = get_turf(target)
	for(var/obj/machinery/M in T)
		var/obj/item/stock_parts/cell/C = M.get_cell()
		if(istype(C))
			C.give(1000)

/datum/relic_effect/targeted/mine_ore/activate(obj/item/A,atom/target,mob/user)
	var/turf/closed/mineral/T = get_turf(target)
	if(istype(T))
		T.gets_drilled()

/datum/relic_effect/targeted/break_windows/activate(obj/item/A,atom/target,mob/user)
	var/turf/T = get_turf(target)
	for(var/obj/structure/window/W in T)
		W.take_damage(50)

/datum/relic_effect/targeted/reagent
	var/chem_amt = 10
	var/chem_multiplier = 1

/datum/relic_effect/targeted/reagent/init()
	..()
	chem_amt = rand(1,400) //goofball seal of quality
	if(prob(20))
		chem_multiplier = rand(1,4) //with added spicy

/datum/relic_effect/targeted/reagent/smoke
	weight = 50
	var/radius = 2

/datum/relic_effect/targeted/reagent/smoke/init()
	..()
	radius = rand(0,8)

/datum/relic_effect/targeted/reagent/smoke/activate(obj/item/A,atom/target,mob/user)
	if(!A.reagents || !A.reagents.total_volume || !..())
		return
	var/datum/reagents/holder = new(chem_amt)
	holder.set_reacting(FALSE)
	A.reagents.copy_to(holder,chem_amt,chem_multiplier)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(holder, radius, get_turf(target), silent = 1)
	playsound(A, 'sound/effects/smoke.ogg', 50, 1, -3)
	smoke.start()
	qdel(holder)

/datum/relic_effect/targeted/reagent/foamer
	weight = 50
	var/radius = 2

/datum/relic_effect/targeted/reagent/foamer/init()
	..()
	radius = rand(0,5)

/datum/relic_effect/targeted/reagent/foamer/activate(obj/item/A,atom/target,mob/user)
	if(!..())
		return
	var/datum/reagents/holder = new(chem_amt)
	holder.set_reacting(FALSE)
	var/turf/open/T = get_turf(target)
	if(istype(T))
		A.reagents.copy_to(holder,chem_amt,chem_multiplier)
		var/datum/effect_system/foam_spread/foam = new
		foam.set_up(radius, T, holder)
		foam.start()
	A.reagents.remove_any(chem_amt)
	qdel(holder)

/datum/relic_effect/targeted/reagent/inject
	weight = 20
	hint = list("It's covered in small needles.")
	var/piercing = FALSE

/datum/relic_effect/targeted/reagent/inject/init()
	..()
	if(prob(30))
		piercing = TRUE

/datum/relic_effect/targeted/reagent/inject/activate(obj/item/A, mob/living/target, mob/living/user)
	if(A.reagents && target.reagents && target.can_inject(user, FALSE, penetrate_thick = piercing))
		A.reagents.trans_to(target,chem_amt,chem_multiplier)

/datum/relic_effect/targeted/ignite
	weight = 20
	hint = list("It is covered in a smooth film of unidentified high-performance fuel.")
	firstname = list("burning","nova","blazing","pyro","thermonuclear","fusic","hydrazine","gas","superheated","plasmic","tritium")
	lastname = list("igniter","flare","burninator","cyclotorch","brumane","incinerator","fulgurite")
	var/apply_stacks = 1
	var/max_stacks = 10

/datum/relic_effect/targeted/ignite/init()
	apply_stacks = rand(1,5)
	max_stacks = rand(1,12)
	if(prob(40))
		apply_stacks *= rand(1,3)
	if(prob(10)) //contains superfuel
		max_stacks *= rand(1,5)
	..()

/datum/relic_effect/targeted/ignite/activate(obj/item/A, mob/living/target, mob/living/user)
	if(istype(target))
		if(target.fire_stacks < max_stacks)
			target.adjust_fire_stacks(apply_stacks)
		target.IgniteMob()
	else
		target.fire_act(apply_stacks*1000,max_stacks) //sensible. very sensible.

/datum/relic_target
	var/power_multiplier = 1
	var/cooldown_multiplier = 1
	var/select_per_pass = 1 //This is specifically for effects that sleep during the loop, things like crowfoot are spliced lists and per pass we have to pick several targets

/datum/relic_target/proc/get_targets(obj/item/A, atom/target)
	return list(get_turf(A))

/datum/relic_target/ranged
	var/distance = 1

/datum/relic_target/ranged/short
	distance = 2

/datum/relic_target/ranged/long
	distance = 5

/datum/relic_target/ranged/get_targets(obj/item/A, atom/target)
	. = list()
	if(target in oview(distance,get_turf(A)))
		. += get_turf(target)

/datum/relic_target/ranged/line
	distance = 5

/datum/relic_target/ranged/line/get_targets(obj/item/A, atom/target)
	. = list()
	if(target in getline(distance,get_turf(A)))
		. += get_turf(target)

/datum/relic_target/ranged/crowfoot
	distance = 5
	var/feet = 3
	var/spread = 10

/datum/relic_target/ranged/crowfoot/get_targets(obj/item/A, atom/target)
	. = list()
	if(target in oview(distance,get_turf(A)))
		. += get_turf(target)
