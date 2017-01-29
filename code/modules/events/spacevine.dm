/datum/round_event_control/spacevine
	name = "Spacevine"
	typepath = /datum/round_event/spacevine
	weight = 15
	max_occurrences = 3
	min_players = 10

/datum/round_event/spacevine/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas

	var/obj/structure/spacevine/SV = new()

	for(var/area/hallway/A in world)
		for(var/turf/F in A)
			if(F.Enter(SV))
				turfs += F

	qdel(SV)

	if(turfs.len) //Pick a turf to spawn at if we can
		var/turf/T = pick(turfs)
		new/obj/effect/spacevine_controller(T) //spawn a controller at turf


/datum/spacevine_mutation
	var/name = ""
	var/severity = 1
	var/hue
	var/quality

/datum/spacevine_mutation/proc/add_mutation_to_vinepiece(obj/structure/spacevine/holder)
	holder.mutations |= src
	holder.add_atom_colour(hue, FIXED_COLOUR_PRIORITY)

/datum/spacevine_mutation/proc/process_mutation(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/process_temperature(obj/structure/spacevine/holder, temp, volume)
	return

/datum/spacevine_mutation/proc/on_birth(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_grow(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_death(obj/structure/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/I, expected_damage)
	. = expected_damage

/datum/spacevine_mutation/proc/on_cross(obj/structure/spacevine/holder, mob/crosser)
	return

/datum/spacevine_mutation/proc/on_chem(obj/structure/spacevine/holder, datum/reagent/R)
	return

/datum/spacevine_mutation/proc/on_eat(obj/structure/spacevine/holder, mob/living/eater)
	return

/datum/spacevine_mutation/proc/on_spread(obj/structure/spacevine/holder, turf/target)
	return

/datum/spacevine_mutation/proc/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
	return

/datum/spacevine_mutation/proc/on_explosion(severity, target, obj/structure/spacevine/holder)
	return


/datum/spacevine_mutation/space_covering
	name = "space covering"
	hue = "#aa77aa"
	quality = POSITIVE

/datum/spacevine_mutation/space_covering
	var/static/list/coverable_turfs

/datum/spacevine_mutation/space_covering/New()
	. = ..()
	if(!coverable_turfs)
		coverable_turfs = typecacheof(list(
			/turf/open/space
		))
		coverable_turfs -= typecacheof(list(
			/turf/open/space/transit
		))

/datum/spacevine_mutation/space_covering/on_grow(obj/structure/spacevine/holder)
	process_mutation(holder)

/datum/spacevine_mutation/space_covering/process_mutation(obj/structure/spacevine/holder)
	var/turf/T = get_turf(holder)
	if(is_type_in_typecache(T, coverable_turfs))
		var/currtype = T.type
		T.ChangeTurf(/turf/open/floor/vines)
		T.baseturf = currtype

/datum/spacevine_mutation/space_covering/on_death(obj/structure/spacevine/holder)
	var/turf/T = get_turf(holder)
	if(istype(T, /turf/open/floor/vines))
		T.ChangeTurf(T.baseturf)

/datum/spacevine_mutation/light
	name = "light"
	hue = "#ffff00"
	quality = POSITIVE
	severity = 4

/datum/spacevine_mutation/light/on_grow(obj/structure/spacevine/holder)
	if(holder.growth_stage)
		holder.SetLuminosity(severity, 3)

/datum/spacevine_mutation/toxicity
	name = "toxic"
	hue = "#ff00ff"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/toxicity/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(issilicon(crosser))
		return
	if(prob(severity) && istype(crosser) && !isvineimmune(crosser))
		crosser << "<span class='alert'>You accidently touch the vine and feel a strange sensation.</span>"
		crosser.adjustToxLoss(5)

/datum/spacevine_mutation/toxicity/on_eat(obj/structure/spacevine/holder, mob/living/eater)
	if(!isvineimmune(eater))
		eater.adjustToxLoss(5)

/datum/spacevine_mutation/explosive  //OH SHIT IT CAN CHAINREACT RUN!!!
	name = "explosive"
	hue = "#ff0000"
	quality = NEGATIVE
	severity = 2

/datum/spacevine_mutation/explosive/on_explosion(explosion_severity, target, obj/structure/spacevine/holder)
	if(explosion_severity < 3)
		qdel(src)
	else
		. = 1
		QDEL_IN(src, 5)

/datum/spacevine_mutation/explosive/on_death(obj/structure/spacevine/holder, mob/hitter, obj/item/I)
	if(prob(30))
		explosion(holder.loc, 0, 0, severity, 0, 0)

/datum/spacevine_mutation/fire_proof
	name = "fire proof"
	hue = "#ff8888"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/fire_proof/process_temperature(obj/structure/spacevine/holder, temp, volume)
	return 1

/datum/spacevine_mutation/fire_proof/on_hit(obj/structure/spacevine/holder, mob/hitter, obj/item/I, expected_damage)
	if(I && I.damtype == "fire")
		. = 0
	else
		. = expected_damage

/datum/spacevine_mutation/vine_eating
	name = "vine eating"
	hue = "#ff7700"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/vine_eating/on_spread(obj/structure/spacevine/holder, turf/target)
	var/obj/structure/spacevine/prey = locate() in target
	if(prey && !prey.mutations.Find(src))  //Eat all vines that are not of the same origin
		qdel(prey)

/datum/spacevine_mutation/aggressive_spread  //very OP, but im out of other ideas currently
	name = "aggressive spreading"
	hue = "#333333"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/aggressive_spread/on_spread(obj/structure/spacevine/holder, turf/target)
	target.ex_act(severity, null, src) // vine immunity handled at /mob/ex_act

/datum/spacevine_mutation/aggressive_spread/on_buckle(obj/structure/spacevine/holder, mob/living/buckled)
	buckled.ex_act(severity, null, src)

/datum/spacevine_mutation/transparency
	name = "transparent"
	hue = ""
	quality = POSITIVE

/datum/spacevine_mutation/transparency/on_grow(obj/structure/spacevine/holder)
	holder.SetOpacity(0)
	holder.alpha = 125

/datum/spacevine_mutation/oxy_eater
	name = "oxygen consuming"
	hue = "#ffff88"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/oxy_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		if(!GM.gases["o2"])
			return
		GM.gases["o2"][MOLES] -= severity * holder.growth_stage
		GM.garbage_collect()

/datum/spacevine_mutation/oxy_emitter
	name = "oxygen emitting"
	hue = "#ffff88"
	severity = 3
	quality = POSITIVE

/datum/spacevine_mutation/oxy_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		if(GM.return_pressure() < ONE_ATMOSPHERE)
			T.atmos_spawn_air("o2=[severity * holder.growth_stage]")

/datum/spacevine_mutation/plasma_eater
	name = "plasma consuming"
	hue = "#ffbbff"
	severity = 3
	quality = POSITIVE

/datum/spacevine_mutation/plasma_eater/process_mutation(obj/structure/spacevine/holder)
	var/turf/open/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		if(!GM.gases["plasma"])
			return
		GM.gases["plasma"][MOLES] -= severity * holder.growth_stage
		GM.garbage_collect()

/datum/spacevine_mutation/thorns
	name = "thorny"
	hue = "#666666"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/thorns/on_cross(obj/structure/spacevine/holder, mob/living/crosser)
	if(prob(severity) && istype(crosser) && !isvineimmune(holder) && crosser.can_inject(target_zone = "chest"))
		var/mob/living/M = crosser
		M.adjustBruteLoss(5)
		M << "<span class='alert'>You cut yourself on the thorny vines.</span>"

/datum/spacevine_mutation/thorns/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/I, expected_damage)
	if(prob(severity) && istype(hitter) && !isvineimmune(holder))
		var/mob/living/M = hitter
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.gloves || (H.dna && (PIERCEIMMUNE in H.dna.species.species_traits)))
				return
		M.adjustBruteLoss(5)
		M << "<span class='alert'>You cut yourself on the thorny vines.</span>"
	. =	expected_damage

/datum/spacevine_mutation/woodening
	name = "hardened"
	hue = "#997700"
	quality = NEGATIVE

/datum/spacevine_mutation/woodening/on_grow(obj/structure/spacevine/holder)
	if(holder.growth_stage)
		holder.density = 1
	holder.max_integrity = 100
	holder.obj_integrity = holder.max_integrity

/datum/spacevine_mutation/woodening/on_hit(obj/structure/spacevine/holder, mob/living/hitter, obj/item/I, expected_damage)
	if(I.is_sharp())
		. = expected_damage * 0.5
	else
		. = expected_damage

/datum/spacevine_mutation/woodening/on_death(obj/structure/spacevine/holder, mob/hitter, obj/item/I)
	if(holder.growth_stage == 2 && prob(50))
		new /obj/item/stack/sheet/mineral/wood(get_turf(holder),1)


// SPACE VINES (Note that this code is very similar to Biomass code)
/obj/structure/spacevine
	name = "space vines"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	anchored = 1
	density = 0
	layer = SPACEVINE_LAYER
	pass_flags = PASSTABLE | PASSGRILLE
	obj_integrity = 50
	max_integrity = 50
	var/growth_stage = 0
	var/obj/effect/spacevine_controller/master = null
	var/list/mutations = list()

/obj/structure/spacevine/New()
	..()
	add_atom_colour("#ffffff", FIXED_COLOUR_PRIORITY)

/obj/structure/spacevine/examine(mob/user)
	..()
	var/text = "This one is a"
	if(mutations.len)
		for(var/A in mutations)
			var/datum/spacevine_mutation/SM = A
			text += " [SM.name]"
	else
		text += " normal"
	text += " vine."
	user << text

/obj/structure/spacevine/Destroy()
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_death(src)
	if(master)
		master.vines -= src
		if(!master.vines.len)
			var/obj/item/seeds/kudzu/KZ = new(loc)
			KZ.mutations |= mutations
			KZ.potency = Clamp(master.mutation_chance * 10, 0, 100)
			KZ.production = Clamp(5 / master.spread_chance, 1, 10)
			KZ.yield = Clamp(master.spread_cap / 10, 1, 10)
			KZ.endurance = Clamp(2 * master.vine_health - 100, 10, 100)
	mutations = list()
	SetOpacity(0)
	if(has_buckled_mobs())
		unbuckle_all_mobs(force=1)
	return ..()

/obj/structure/spacevine/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover, /obj/item/projectile)) //projectiles are blocked by vines, so they can be fought with non-direct shooting
		return 0
	else
		return !density

/obj/structure/spacevine/proc/on_chem_effect(datum/reagent/R)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_chem(src, R)
	if(!override && istype(R, /datum/reagent/toxin/plantbgone))
		if(prob(50))
			qdel(src)

/obj/structure/spacevine/proc/eat(mob/eater)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_eat(src, eater)
	if(!override)
		if(prob(10))
			eater.say("Nom")
		qdel(src)

/obj/structure/spacevine/attackby(obj/item/weapon/W, mob/user, params)

	if(istype(W, /obj/item/weapon/scythe))
		user.changeNext_move(CLICK_CD_MELEE)
		for(var/obj/structure/spacevine/B in orange(1,src))
			B.take_damage(W.force * 4, BRUTE, "melee", 1)
		return
	else
		return ..()


/obj/structure/spacevine/attacked_by(obj/item/I, mob/living/user)
	var/damage_dealt = I.force
	if(I.is_sharp())
		damage_dealt *= 4
	if(I.damtype == BURN)
		damage_dealt *= 4

	for(var/datum/spacevine_mutation/SM in mutations)
		damage_dealt = SM.on_hit(src, user, I, damage_dealt) //on_hit now takes override damage as arg and returns new value for other mutations to permutate further
	take_damage(damage_dealt, I.damtype, "melee", 1)

/obj/structure/spacevine/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/slash.ogg', 50, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)

/obj/structure/spacevine/Crossed(mob/crosser)
	if(isliving(crosser))
		for(var/datum/spacevine_mutation/SM in mutations)
			SM.on_cross(src, crosser)

/obj/structure/spacevine/attack_hand(mob/user)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_hit(src, user)
	user_unbuckle_mob(user, user)


/obj/structure/spacevine/attack_paw(mob/living/user)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_hit(src, user)
	user_unbuckle_mob(user,user)

/obj/structure/spacevine/attack_alien(mob/living/user)
	eat(user)

/obj/structure/spacevine/proc/grow()
	if(!growth_stage)
		src.icon_state = pick("Med1", "Med2", "Med3")
		growth_stage = 1
		SetOpacity(1)
	else
		src.icon_state = pick("Hvy1", "Hvy2", "Hvy3")
		growth_stage = 2

	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_grow(src)

/obj/structure/spacevine/proc/entangle_mob()
	if(!has_buckled_mobs() && prob(25))
		for(var/mob/living/V in src.loc)
			if(has_buckled_mobs())
				break //only capture one mob at a time
			entangle(V)


/obj/structure/spacevine/proc/entangle(mob/living/V)
	if(!V || isvineimmune(V))
		return
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_buckle(src, V)
	if((V.stat != DEAD) && (V.buckled != src)) //not dead or captured
		V << "<span class='danger'>The vines [pick("wind", "tangle", "tighten")] around you!</span>"
		buckle_mob(V, 1)

/obj/structure/spacevine/proc/spread()
	var/direction = pick(cardinal)
	var/turf/stepturf = get_step(src,direction)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_spread(src, stepturf)
		stepturf = get_step(src,direction) //in case turf changes, to make sure no runtimes happen
	if(!locate(/obj/structure/spacevine, stepturf))
		if(stepturf.Enter(src))
			if(master)
				master.spawn_spacevine_piece(stepturf, src)

/obj/structure/spacevine/ex_act(severity, target)
	if(istype(target, type)) //don't self-explode with aggresive spread
		return
	var/i
	for(var/datum/spacevine_mutation/SM in mutations)
		i += SM.on_explosion(severity, target, src)
	if(!i && prob(100/severity))
		qdel(src)

/obj/structure/spacevine/temperature_expose(null, temp, volume)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.process_temperature(src, temp, volume)
	if(!override)
		qdel(src)

/obj/structure/spacevine/CanPass(atom/movable/mover, turf/target, height=0)
	if(isvineimmune(mover))
		. = TRUE
	else
		. = ..()


//////////////
//CONTROLLER//
//////////////
/obj/effect/spacevine_controller
	invisibility = INVISIBILITY_ABSTRACT
	var/list/obj/structure/spacevine/vines = list()
	var/spread_chance
	var/spread_cap
	var/list/mutations_list = list()
	var/mutation_chance
	var/vine_health

/obj/effect/spacevine_controller/New(loc, list/muts, potency = 20, production = 5, yield = 3, endurance = 50)
	add_atom_colour("#ffffff", FIXED_COLOUR_PRIORITY)
	spawn_spacevine_piece(loc, , muts)
	START_PROCESSING(SSobj, src)
	init_subtypes(/datum/spacevine_mutation/, mutations_list)

	mutation_chance = potency / 10 //0-10% mutation chance -- 2% default

	spread_chance = 20 / production //2-20% chance of spreading OR growing -- 10% default

	vine_health = 25 + (endurance / 2) //30-75 life -- 50 default

	spread_cap = max(10, yield * 10) //10-100 max vines per controller -- 30 default

	..()

/obj/effect/spacevine_controller/ex_act() //only killing all vines will end this suffering
	return

/obj/effect/spacevine_controller/singularity_act()
	return

/obj/effect/spacevine_controller/singularity_pull()
	return

/obj/effect/spacevine_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/spacevine_controller/proc/spawn_spacevine_piece(turf/location, obj/structure/spacevine/parent, list/muts)
	var/obj/structure/spacevine/SV = new(location)
	vines += SV
	SV.master = src
	if(muts && muts.len)
		for(var/datum/spacevine_mutation/M in muts)
			M.add_mutation_to_vinepiece(SV)
		return
	if(parent)
		SV.mutations |= parent.mutations
		SV.obj_integrity = vine_health
		SV.max_integrity = vine_health
		var/parentcolor = parent.atom_colours[FIXED_COLOUR_PRIORITY]
		SV.add_atom_colour(parentcolor, FIXED_COLOUR_PRIORITY)
		if(prob(mutation_chance))
			var/datum/spacevine_mutation/randmut = pick(mutations_list - SV.mutations)
			randmut.add_mutation_to_vinepiece(SV)

	for(var/datum/spacevine_mutation/SM in SV.mutations)
		SM.on_birth(SV)

/obj/effect/spacevine_controller/process()
	if(!vines)
		qdel(src) //space vines exterminated. Remove the controller
		return

	var/spread_count = 0 //only spread a few vines per tick, so if it grows too big it can still be fought
	var/max_spread = rand(1,3) //1-3 vines per tick

	for(var/obj/structure/spacevine/SV in vines)
		if(qdeleted(SV))
			continue

		for(var/datum/spacevine_mutation/SM in SV.mutations)
			SM.process_mutation(SV)

		//Try to grow or spread
		if(prob(spread_chance))
			if(prob(50))
				if(SV.growth_stage < 2) //If tile isn't fully grown
					SV.grow()
				else //If tile is fully grown
					SV.entangle_mob()
			else
				if(spread_count >= max_spread || vines.len < spread_cap)
					SV.spread()
					spread_count++

/proc/isvineimmune(atom/A)
	. = FALSE
	if(isliving(A))
		var/mob/living/M = A
		if(("vines" in M.faction) || ("plants" in M.faction))
			. = TRUE
