// Base chasm, defaults to oblivion but can be overridden
/turf/open/chasm
	name = "chasm"
	desc = "Watch your step."
	baseturf = /turf/open/chasm
	smooth = SMOOTH_TRUE | SMOOTH_BORDER | SMOOTH_MORE
	icon = 'icons/turf/floors/chasms.dmi'
	icon_state = "smooth"
	canSmoothWith = list(/turf/open/floor/fakepit, /turf/open/chasm)
	density = TRUE //This will prevent hostile mobs from pathing into chasms, while the canpass override will still let it function like an open turf

/turf/open/chasm/Initialize()
	. = ..()
	AddComponent(/datum/component/chasm, null)

/turf/open/chasm/proc/set_target(turf/target)
	GET_COMPONENT(chasm_component, /datum/component/chasm)
	chasm_component.target_turf = target

/turf/open/chasm/proc/drop(atom/movable/AM)
	GET_COMPONENT(chasm_component, /datum/component/chasm)
	chasm_component.drop(AM)

/turf/open/chasm/MakeSlippery(wet_setting = TURF_WET_WATER, min_wet_time = 0, wet_time_to_add = 0)
	return

/turf/open/chasm/MakeDry(wet_setting = TURF_WET_WATER)
	return

/turf/open/chasm/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/open/chasm/attackby(obj/item/C, mob/user, params, area/area_restriction)
	..()
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(!L)
			if(R.use(1))
				to_chat(user, "<span class='notice'>You construct a lattice.</span>")
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				// Create a lattice, without reverting to our baseturf
				new /obj/structure/lattice(src)
			else
				to_chat(user, "<span class='warning'>You need one rod to build a lattice.</span>")
			return
	if(istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You build a floor.</span>")
				// Create a floor, which has this chasm underneath it
				ChangeTurf(/turf/open/floor/plating, type)
			else
				to_chat(user, "<span class='warning'>You need one floor tile to build a floor!</span>")
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support! Place metal rods first.</span>")

/turf/open/chasm/CanPass(atom/movable/mover, turf/target)
	return 1


// Naive "down" which just subtracts a z-level
/turf/open/chasm/straight_down
	baseturf = /turf/open/chasm/straight_down

/turf/open/chasm/straight_down/Initialize()
	. = ..()
	set_target(locate(x, y, z - 1))


// Chasms for Lavaland, with planetary atmos and lava glow
/turf/open/chasm/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturf = /turf/open/chasm/lavaland
	light_range = 1.9 //slightly less range than lava
	light_power = 0.65 //less bright, too
	light_color = LIGHT_COLOR_LAVA //let's just say you're falling into lava, that makes sense right


// Chasms for the jungle, with planetary atmos and a different icon
/turf/open/chasm/jungle
	icon = 'icons/turf/floors/junglechasm.dmi'
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturf = /turf/open/chasm/jungle

/turf/open/chasm/jungle/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "dirt"
	return TRUE

/turf/open/chasm/jungle/straight_down
	baseturf = /turf/open/chasm/jungle/straight_down

/turf/open/chasm/jungle/straight_down/Initialize(mapload)
	. = ..()
	set_target(locate(x, y, z - 1))
