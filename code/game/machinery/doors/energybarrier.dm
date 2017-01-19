/obj/structure/energybarrier
	name = "energy barrier"
	desc = "A a repulsive energy field that only allows pods to pass."
	icon = 'icons/effects/beam.dmi'
	icon_state = "field"
	var/id = 1.0
	density = 0
	anchored = 1
	resistance_flags = UNACIDABLE
	req_access = list( access_energy_barrier )

/obj/structure/energybarrier/New() //set the turf below the barrier to block air
	var/turf/T = get_turf(loc)

	//Cakey - Figure out lights
	//light_color = "#66FFFF"
	//light_range = 3

	if(T)
		T.blocks_air = 1
	..()

/obj/structure/energybarrier/Destroy() //lazy hack to set the turf to allow air to pass if it's a simulated floor
	var/turf/T = get_turf(loc)
	if(T)
		if(istype(T, /turf/open/floor))
			T.blocks_air = 0
	..()



/obj/structure/energybarrier/CanPass(atom/A, turf/T)
	if( allowed( A ))
		return 1

	return 0

