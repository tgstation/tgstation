// Foam
// Similar to smoke, but slower and mobs absorb its reagent through their exposed skin.

/obj/effect/particle_effect/foam
	name = "foam"
	icon_state = "foam"
	opacity = 0
	anchored = 1
	density = 0
	layer = WALL_OBJ_LAYER
	mouse_opacity = 0
	var/amount = 3
	animate_movement = 0
	var/metal = 0
	var/lifetime = 40
	var/reagent_divisor = 7
	var/static/list/blacklisted_turfs = typecacheof(list(
	/turf/open/space/transit,
	/turf/open/chasm,
	/turf/open/floor/plating/lava))


/obj/effect/particle_effect/foam/metal
	name = "aluminium foam"
	metal = 1
	icon_state = "mfoam"


/obj/effect/particle_effect/foam/metal/iron
	name = "iron foam"
	metal = 2


/obj/effect/particle_effect/foam/New(loc)
	..(loc)
	create_reagents(1000) //limited by the size of the reagent holder anyway.
	START_PROCESSING(SSfastprocess, src)
	playsound(src, 'sound/effects/bubbles2.ogg', 80, 1, -3)

/obj/effect/particle_effect/foam/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()


/obj/effect/particle_effect/foam/proc/kill_foam()
	STOP_PROCESSING(SSfastprocess, src)
	switch(metal)
		if(1)
			new /obj/structure/foamedmetal(src.loc)
		if(2)
			new /obj/structure/foamedmetal/iron(src.loc)
	flick("[icon_state]-disolve", src)
	QDEL_IN(src, 5)

/obj/effect/particle_effect/foam/process()
	lifetime--
	if(lifetime < 1)
		kill_foam()
		return

	var/fraction = 1/initial(reagent_divisor)
	for(var/obj/O in range(0,src))
		if(O.type == src.type)
			continue
		if(isturf(O.loc))
			var/turf/T = O.loc
			if(T.intact && O.level == 1) //hidden under the floor
				continue
		if(lifetime % reagent_divisor)
			reagents.reaction(O, VAPOR, fraction)
	var/hit = 0
	for(var/mob/living/L in range(0,src))
		hit += foam_mob(L)
	if(hit)
		lifetime++ //this is so the decrease from mobs hit and the natural decrease don't cumulate.
	var/T = get_turf(src)
	if(lifetime % reagent_divisor)
		reagents.reaction(T, VAPOR, fraction)

	if(--amount < 0)
		return
	spread_foam()

/obj/effect/particle_effect/foam/proc/foam_mob(mob/living/L)
	if(lifetime<1)
		return 0
	if(!istype(L))
		return 0
	var/fraction = 1/initial(reagent_divisor)
	if(lifetime % reagent_divisor)
		reagents.reaction(L, VAPOR, fraction)
	lifetime--
	return 1

/obj/effect/particle_effect/foam/Crossed(atom/movable/AM)
	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		M.slip(5, 2, src)

/obj/effect/particle_effect/foam/metal/Crossed(atom/movable/AM)
	return


/obj/effect/particle_effect/foam/proc/spread_foam()
	var/turf/t_loc = get_turf(src)
	for(var/turf/T in t_loc.GetAtmosAdjacentTurfs())
		var/obj/effect/particle_effect/foam/foundfoam = locate() in T //Don't spread foam where there's already foam!
		if(foundfoam)
			continue

		if(is_type_in_typecache(T, blacklisted_turfs))
			continue

		for(var/mob/living/L in T)
			foam_mob(L)
		var/obj/effect/particle_effect/foam/F = PoolOrNew(src.type, T)
		F.amount = amount
		reagents.copy_to(F, (reagents.total_volume))
		F.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
		F.metal = metal


/obj/effect/particle_effect/foam/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 475))) //foam dissolves when heated
		kill_foam()


/obj/effect/particle_effect/foam/metal/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return


///////////////////////////////////////////////
//FOAM EFFECT DATUM
/datum/effect_system/foam_spread
	var/amount = 10		// the size of the foam spread.
	var/obj/chemholder
	effect_type = /obj/effect/particle_effect/foam
	var/metal = 0


/datum/effect_system/foam_spread/metal
	effect_type = /obj/effect/particle_effect/foam/metal


/datum/effect_system/foam_spread/New()
	..()
	chemholder = PoolOrNew(/obj)
	var/datum/reagents/R = new/datum/reagents(1000)
	chemholder.reagents = R
	R.my_atom = chemholder

/datum/effect_system/foam_spread/Destroy()
	qdel(chemholder)
	chemholder = null
	return ..()

/datum/effect_system/foam_spread/set_up(amt=5, loca, datum/reagents/carry = null)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)

	amount = round(sqrt(amt / 2), 1)
	carry.copy_to(chemholder, 4*carry.total_volume) //The foam holds 4 times the total reagents volume for balance purposes.

/datum/effect_system/foam_spread/metal/set_up(amt=5, loca, datum/reagents/carry = null, metaltype)
	..()
	metal = metaltype

/datum/effect_system/foam_spread/start()
	var/obj/effect/particle_effect/foam/foundfoam = locate() in location
	if(foundfoam)//If there was already foam where we start, we add our foaminess to it.
		foundfoam.amount += amount
	else
		var/obj/effect/particle_effect/foam/F = PoolOrNew(effect_type, location)
		var/foamcolor = mix_color_from_reagents(chemholder.reagents.reagent_list)
		chemholder.reagents.copy_to(F, chemholder.reagents.total_volume/amount)
		F.add_atom_colour(foamcolor, FIXED_COLOUR_PRIORITY)
		F.amount = amount
		F.metal = metal


//////////////////////////////////////////////////////////
// FOAM STRUCTURE. Formed by metal foams. Dense and opaque, but easy to break
/obj/structure/foamedmetal
	icon = 'icons/effects/effects.dmi'
	icon_state = "metalfoam"
	density = 1
	opacity = 1 	// changed in New()
	anchored = 1
	resistance_flags = FIRE_PROOF | ACID_PROOF
	name = "foamed metal"
	desc = "A lightweight foamed metal wall."
	gender = PLURAL
	obj_integrity = 20
	max_integrity = 20
	CanAtmosPass = ATMOS_PASS_DENSITY

/obj/structure/foamedmetal/New()
	..()
	air_update_turf(1)


/obj/structure/foamedmetal/Destroy()
	density = 0
	air_update_turf(1)
	return ..()

/obj/structure/foamedmetal/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/foamedmetal/attack_paw(mob/user)
	attack_hand(user)

/obj/structure/foamedmetal/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src.loc, 'sound/weapons/tap.ogg', 100, 1)

/obj/structure/foamedmetal/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	user << "<span class='warning'>You hit the metal foam but bounce off it!</span>"
	playsound(src.loc, 'sound/weapons/tap.ogg', 100, 1)

/obj/structure/foamedmetal/CanPass(atom/movable/mover, turf/target, height=1.5)
	return !density

/obj/structure/foamedmetal/iron
	obj_integrity = 50
	max_integrity = 50
	icon_state = "ironfoam"
