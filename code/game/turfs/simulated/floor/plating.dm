/* In this file:
 *
 * Plating
 * Airless
 * Airless plating
 * Engine floor
 */
// note that plating and engine floor do not call their parent attackby, unlike other flooring
// this is done in order to avoid inheriting the crowbar attackby

/turf/open/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = 0
	broken_states = list("platingdmg1", "platingdmg2", "platingdmg3")
	burnt_states = list("panelscorched")

/turf/open/floor/plating/New()
	..()
	icon_plating = icon_state

/turf/open/floor/plating/update_icon()
	if(!..())
		return
	if(!broken && !burnt)
		icon_state = icon_plating //Because asteroids are 'platings' too.

/turf/open/floor/plating/attackby(obj/item/C, mob/user, params)
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
				if (R.get_amount() >= 2 && !istype(src, /turf/open/floor/engine))
					ChangeTurf(/turf/open/floor/engine)
					playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)
					R.use(2)
					user << "<span class='notice'>You reinforce the floor.</span>"
				return
	else if(istype(C, /obj/item/stack/tile))
		if(!broken && !burnt)
			var/obj/item/stack/tile/W = C
			if(!W.use(1))
				return
			var/turf/open/floor/T = ChangeTurf(W.turf_type)
			if(istype(W,/obj/item/stack/tile/light)) //TODO: get rid of this ugly check somehow
				var/obj/item/stack/tile/light/L = W
				var/turf/open/floor/light/F = T
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

/turf/open/floor/plating/airless
	icon_state = "plating"
	initial_gas_mix = "o2=0;n2=0;TEMP=2.7"

/turf/open/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = INFINITY
	floor_tile = /obj/item/stack/rods

/turf/open/floor/engine/break_tile()
	return //unbreakable

/turf/open/floor/engine/burn_tile()
	return //unburnable

/turf/open/floor/engine/make_plating(force = 0)
	if(force)
		..()
	return //unplateable

/turf/open/floor/engine/attackby(obj/item/weapon/C, mob/user, params)
	if(!C || !user)
		return
	if(istype(C, /obj/item/weapon/wrench))
		user << "<span class='notice'>You begin removing rods...</span>"
		playsound(src, 'sound/items/Ratchet.ogg', 80, 1)
		if(do_after(user, 30/C.toolspeed, target = src))
			if(!istype(src, /turf/open/floor/engine))
				return
			new /obj/item/stack/rods(src, 2)
			ChangeTurf(/turf/open/floor/plating)
			return


/turf/open/floor/engine/ex_act(severity,target)
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

//air filled floors; used in atmos pressure chambers

/turf/open/floor/engine/n2o
	name = "n2o floor"
	initial_gas_mix = "n2o=6000;TEMP=293.15"

/turf/open/floor/engine/co2
	name = "co2 floor"
	initial_gas_mix = "co2=50000;TEMP=293.15"

/turf/open/floor/engine/plasma
	name = "plasma floor"
	initial_gas_mix = "plasma=70000;TEMP=293.15"

/turf/open/floor/engine/o2
	name = "o2 floor"
	initial_gas_mix = "o2=100000;TEMP=293.15"

/turf/open/floor/engine/n2
	name = "n2 floor"
	initial_gas_mix = "n2=100000;TEMP=293.15"

/turf/open/floor/engine/air
	name = "air floor"
	initial_gas_mix = "o2=2644;n2=10580;TEMP=293.15"



/turf/open/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"

/turf/open/floor/engine/cult/New()
	PoolOrNew(/obj/effect/overlay/temp/cult/turf/open/floor, src)
	..()

/turf/open/floor/engine/cult/narsie_act()
	return

/turf/open/floor/engine/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(builtin_tile)
			if(prob(30))
				builtin_tile.loc = src
				make_plating()
		else if(prob(30))
			ReplaceWithLattice()

/turf/open/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	initial_gas_mix = "o2=0;n2=0;TEMP=2.7"

/turf/open/floor/plasteel/airless
	initial_gas_mix = "o2=0;n2=0;TEMP=2.7"

/turf/open/floor/plating/abductor
	name = "alien floor"
	icon_state = "alienpod1"

/turf/open/floor/plating/abductor/New()
	..()
	icon_state = "alienpod[rand(1,9)]"

///LAVA

/turf/open/floor/plating/lava
	name = "lava"
	icon_state = "lava"
	baseturf = /turf/open/floor/plating/lava //lava all the way down
	slowdown = 2
	var/processing = 0
	luminosity = 1

/turf/open/floor/plating/lava/airless
	initial_gas_mix = "o2=0;n2=0;TEMP=2.7"

/turf/open/floor/plating/lava/Entered(atom/movable/AM)
	burn_stuff()
	if(!processing)
		processing = 1
		SSobj.processing |= src

/turf/open/floor/plating/lava/process()
	if(!burn_stuff())
		processing = 0
		SSobj.processing.Remove(src)


/turf/open/floor/plating/lava/proc/burn_stuff()
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


/turf/open/floor/plating/lava/attackby(obj/item/C, mob/user, params) //Lava isn't a good foundation to build on
	return

/turf/open/floor/plating/lava/break_tile()
	return

/turf/open/floor/plating/lava/burn_tile()
	return

/turf/open/floor/plating/lava/attackby(obj/item/C, mob/user, params) //Lava isn't a good foundation to build on
	return

/turf/open/floor/plating/lava/smooth
	name = "lava"
	baseturf = /turf/open/floor/plating/lava/smooth
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "unsmooth"
	canSmoothWith = list(/turf/closed/wall, /turf/closed/mineral, /turf/open/floor/plating/lava/smooth, /turf/open/floor/plating/lava/smooth/lava_land_surface
	)
/turf/open/floor/plating/lava/smooth/airless
	initial_gas_mix = "o2=0;n2=0;TEMP=2.7"
