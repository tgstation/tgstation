// Foam
// Similar to smoke, but slower and mobs absorb its reagent through their exposed skin.

/obj/effect/particle_effect/foam
	name = "foam"
	icon_state = "foam"
	opacity = 0
	anchored = 1
	density = 0
	layer = MOB_LAYER + 0.5
	mouse_opacity = 0
	var/amount = 3
	animate_movement = 0
	var/metal = 0
	var/lifetime = 40


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
	SSfastprocess.processing |= src
	playsound(src, 'sound/effects/bubbles2.ogg', 80, 1, -3)

/obj/effect/particle_effect/foam/Destroy()
	SSfastprocess.processing.Remove(src)
	return ..()


/obj/effect/particle_effect/foam/proc/kill_foam()
	SSfastprocess.processing.Remove(src)
	if(metal)
		var/obj/structure/foamedmetal/M = new(src.loc)
		M.metal = metal
		M.updateicon()
	flick("[icon_state]-disolve", src)
	spawn(5)
		qdel(src)


/obj/effect/particle_effect/foam/process()
	lifetime--
	if(lifetime < 1)
		kill_foam()
		return

	var/fraction = 1/initial(lifetime)
	for(var/obj/O in range(0,src))
		if(O.type == src.type)
			continue
		reagents.reaction(O, VAPOR, fraction)
	var/hit = 0
	for(var/mob/living/L in range(0,src))
		hit += foam_mob(L)
	if(hit)
		lifetime++ //this is so the decrease from mobs hit and the natural decrease don't cumulate.
	var/T = get_turf(src)
	reagents.reaction(T, VAPOR, fraction)

	if(--amount < 0)
		return
	spread_foam()

/obj/effect/particle_effect/foam/proc/foam_mob(mob/living/L)
	if(lifetime<1)
		return 0
	if(!istype(L))
		return 0
	var/fraction = 1/initial(lifetime)
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

		for(var/mob/living/L in T)
			foam_mob(L)
		var/obj/effect/particle_effect/foam/F = PoolOrNew(src.type, T)
		F.amount = amount
		reagents.copy_to(F, (reagents.total_volume))
		F.color = color
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
	if(istype(loca, /turf/))
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
		F.color = foamcolor
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
	unacidable = 1
	name = "foamed metal"
	desc = "A lightweight foamed metal wall."
	gender = PLURAL
	var/metal = 1		// 1=aluminium, 2=iron

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


/obj/structure/foamedmetal/proc/updateicon()
	if(metal == 1)
		icon_state = "metalfoam"
	else
		icon_state = "ironfoam"


/obj/structure/foamedmetal/ex_act(severity, target)
	qdel(src)


/obj/structure/foamedmetal/blob_act()
	qdel(src)


/obj/structure/foamedmetal/bullet_act()
	..()
	if(metal==1 || prob(50))
		qdel(src)


/obj/structure/foamedmetal/attack_paw(mob/user)
	attack_hand(user)
	return


/obj/structure/foamedmetal/attack_animal(mob/living/simple_animal/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(user.environment_smash >= 1)
		user.do_attack_animation(src)
		user << "<span class='notice'>You smash apart the foam wall.</span>"
		qdel(src)
		return


/obj/structure/foamedmetal/attack_hulk(mob/living/carbon/human/user)
	..(user, 1)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(prob(75 - metal*25))
		user.visible_message("<span class='danger'>[user] smashes through the foamed metal!</span>", \
						"<span class='danger'>You smash through the metal foam wall!</span>")
		qdel(src)
	return 1

/obj/structure/foamedmetal/attack_alien(mob/living/carbon/alien/humanoid/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(prob(75 - metal*25))
		user.visible_message("<span class='danger'>[user] smashes through the foamed metal!</span>", \
						"<span class='danger'>You smash through the metal foam wall!</span>")
		qdel(src)

/obj/structure/foamedmetal/attack_slime(mob/living/simple_animal/slime/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(!user.is_adult)
		attack_hand(user)
		return
	if(prob(75 - metal*25))
		user.visible_message("<span class='danger'>[user] smashes through the foamed metal!</span>", \
						"<span class='danger'>You smash through the metal foam wall!</span>")
		qdel(src)

/obj/structure/foamedmetal/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	user << "<span class='warning'>You hit the metal foam but bounce off it!</span>"


/obj/structure/foamedmetal/attackby(obj/item/I, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)

	if(prob(I.force*20 - metal*25))
		user.visible_message("<span class='danger'>[user] smashes through the foamed metal!</span>", \
						"<span class='danger'>You smash through the foamed metal with \the [I]!</span>")
		qdel(src)
	else
		user << "<span class='warning'>You hit the metal foam to no effect!</span>"


/obj/structure/foamedmetal/CanPass(atom/movable/mover, turf/target, height=1.5)
	return !density


/obj/structure/foamedmetal/CanAtmosPass()
	return !density