/* In this file:
 *
 * Plating
 * Airless
 * Airless plating
 * Engine floor
 */
// note that plating and engine floor do not call their parent attackby, unlike other flooring
// this is done in order to avoid inheriting the crowbar attackby

/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = 0
	broken_states = list("platingdmg1", "platingdmg2", "platingdmg3")
	burnt_states = list("panelscorched")

/turf/simulated/floor/plating/New()
	..()
	icon_plating = icon_state

/turf/simulated/floor/plating/update_icon()
	if(!..())
		return
	if(!broken && !burnt)
		icon_state = icon_plating //Because asteroids are 'platings' too.

/turf/simulated/floor/plating/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/stack/rods))
		if(broken || burnt)
			user << "<span class='warning'>Repair the plating first!</span>"
			return
		var/obj/item/stack/rods/R = C
		if (R.get_amount() < 2)
			user << "<span class='warning'>You need two rods to make a reinforced floor!</span>"
			return
		else
			user << "<span class='notice'>You begin reinforcing the floor...</span>"
			if(do_after(user, 30, target = src))
				if (R.get_amount() >= 2 && !istype(src, /turf/simulated/floor/engine))
					ChangeTurf(/turf/simulated/floor/engine)
					playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
					R.use(2)
					user << "<span class='notice'>You reinforce the floor.</span>"
				return
	else if(istype(C, /obj/item/stack/tile))
		if(!broken && !burnt)
			var/obj/item/stack/tile/W = C
			if(!W.use(1))
				return
			var/turf/simulated/floor/T = ChangeTurf(W.turf_type)
			if(istype(W,/obj/item/stack/tile/light)) //TODO: get rid of this ugly check somehow
				var/obj/item/stack/tile/light/L = W
				var/turf/simulated/floor/light/F = T
				F.state = L.state
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
		else
			user << "<span class='warning'>This section is too damaged to support a tile! Use a welder to fix the damage.</span>"
	else if(istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/welder = C
		if( welder.isOn() && (broken || burnt) )
			if(welder.remove_fuel(0,user))
				user << "<span class='danger'>You fix some dents on the broken plating.</span>"
				playsound(src, 'sound/items/Welder.ogg', 80, 1)
				icon_state = icon_plating
				burnt = 0
				broken = 0

/turf/simulated/floor/plating/airless
	icon_state = "plating"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = INFINITY
	floor_tile = /obj/item/stack/rods

/turf/simulated/floor/engine/break_tile()
	return //unbreakable

/turf/simulated/floor/engine/burn_tile()
	return //unburnable

/turf/simulated/floor/engine/make_plating(force = 0)
	if(force)
		..()
	return //unplateable

/turf/simulated/floor/engine/attackby(obj/item/weapon/C, mob/user, params)
	if(!C || !user)
		return
	if(istype(C, /obj/item/weapon/wrench))
		user << "<span class='notice'>You begin removing rods...</span>"
		playsound(src, 'sound/items/Ratchet.ogg', 80, 1)
		if(do_after(user, 30/C.toolspeed, target = src))
			if(!istype(src, /turf/simulated/floor/engine))
				return
			new /obj/item/stack/rods(src, 2)
			ChangeTurf(/turf/simulated/floor/plating)
			return


/turf/simulated/floor/engine/ex_act(severity,target)
	switch(severity)
		if(1)
			if(prob(80))
				ReplaceWithLattice()
			else if(prob(50))
				qdel(src)
			else
				make_plating(1)
		if(2)
			if(prob(50))
				make_plating(1)

/turf/simulated/floor/engine/n2o
	name = "n2o floor"

/turf/simulated/floor/engine/n2o/New()
	..()

	var/datum/gas_mixture/adding = new
	adding.assert_gas("n2o")
	adding.gases["n2o"][MOLES] = 6000
	adding.temperature = T20C

	assume_air(adding)

/turf/simulated/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"

/turf/simulated/floor/engine/cult/New()
	PoolOrNew(/obj/effect/overlay/temp/cult/turf/floor, src)
	..()

/turf/simulated/floor/engine/cult/narsie_act()
	return

/turf/simulated/floor/engine/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(builtin_tile)
			if(prob(30))
				builtin_tile.loc = src
				make_plating()
		else if(prob(30))
			ReplaceWithLattice()

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/plasteel/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/plating/abductor
	name = "alien floor"
	icon_state = "alienpod1"

/turf/simulated/floor/plating/abductor/New()
	..()
	icon_state = "alienpod[rand(1,9)]"

///LAVA

/turf/simulated/floor/plating/lava
	name = "lava"
	icon_state = "lava"
	baseturf = /turf/simulated/floor/plating/lava //lava all the way down
	slowdown = 2
	var/processing = 0
	luminosity = 1

/turf/simulated/floor/plating/lava/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/plating/lava/Entered(atom/movable/AM)
	burn_stuff()
	if(!processing)
		processing = 1
		SSobj.processing |= src

/turf/simulated/floor/plating/lava/process()
	if(!burn_stuff())
		processing = 0
		SSobj.processing.Remove(src)


/turf/simulated/floor/plating/lava/proc/burn_stuff()
	. = 0
	for(var/thing in contents)
		if(istype(thing, /obj))
			var/obj/O = thing
			if(istype(O, /obj/effect/decal/cleanable/ash)) //So we don't get stuck burning the same ash pile forever
				qdel(O)
				continue
			. = 1
			if(O.burn_state == FIRE_PROOF)
				O.burn_state = FLAMMABLE //Even fireproof things burn up in lava

			O.fire_act()


		else if (istype(thing, /mob/living))
			. = 1
			var/mob/living/L = thing
			if("mining" in L.faction)
				continue
			L.adjustFireLoss(20)
			if(L) //mobs turning into object corpses could get deleted here.
				L.adjust_fire_stacks(20)
				L.IgniteMob()


/turf/simulated/floor/plating/lava/attackby(obj/item/C, mob/user, params) //Lava isn't a good foundation to build on
	return

/turf/simulated/floor/plating/lava/break_tile()
	return

/turf/simulated/floor/plating/lava/burn_tile()
	return

/turf/simulated/floor/plating/lava/attackby(obj/item/C, mob/user, params) //Lava isn't a good foundation to build on
	return

/turf/simulated/floor/plating/lava/smooth
	name = "lava"
	baseturf = /turf/simulated/floor/plating/lava/smooth
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "unsmooth"
//	smooth = SMOOTH_BORDER | SMOOTH_TRUE
	canSmoothWith = list(/turf/simulated/wall, /turf/simulated/mineral, /turf/simulated/floor/plating/lava/smooth, /turf/simulated/floor/plating/lava/smooth/lava_land_surface
	)

/turf/simulated/floor/plating/lava/smooth/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB
