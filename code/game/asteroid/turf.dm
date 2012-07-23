/turf/simulated/wall/asteroid
	name = "asteroid"
	icon = 'icons/turf/walls.dmi'
	icon_state = "asteroid"
	opacity = 1
	density = 1
	oxygen = 0
	nitrogen = 0
	temperature = TCMB
	var/contains = null
	var/max_amount = 1
	var/min_amount = 0

/turf/simulated/wall/asteroid/iron
	icon_state = "asteroid_i"
	contains = /obj/item/stack/sheet/metal
	max_amount = 3
	min_amount = 1

/turf/simulated/wall/asteroid/silicon
	icon_state = "asteroid_i"
	contains = /obj/item/stack/sheet/glass
	max_amount = 3
	min_amount = 1

/turf/simulated/wall/asteroid/facehugger
	icon_state = "asteroid_i"
	contains = /obj/item/clothing/mask/facehugger
	max_amount = 1
	min_amount = 0

/*
/turf/simulated/wall/asteroid/frozen_gas
	name="frozen gas"
	icon = 'icons/obj/atmos.dmi'

/turf/simulated/wall/asteroid/frozen_gas/oxygen
	icon_state = "blue"

	New()
		src.oxygen = rand(40,200)
		..()

/turf/simulated/wall/asteroid/frozen_gas/nitrogen
	icon_state = "red"

	New()
		src.nitrogen = rand(40,200)
		..()

/turf/simulated/wall/asteroid/frozen_gas/toxins
	icon_state = "orange"

	New()
		src.toxins = rand(40,200)
		..()

/turf/simulated/wall/asteroid/frozen_gas/carbon_dioxide
	icon_state = "black"

	New()
		src.carbon_dioxide = rand(40,200)
		..()

*/


/turf/simulated/wall/asteroid/dismantle_wall(devastated=0)
	if(contains && ispath(contains))
		var/iterations = 0
		if(!devastated)
			iterations = max_amount
		else
			iterations = min_amount
		for(var/i=0 to iterations)
			new contains(src)
	ReplaceWithSpace()


/turf/simulated/wall/asteroid/attackby(obj/item/weapon/W as obj, mob/user as mob)//TODO
	return attack_hand(user)


/turf/simulated/wall/asteroid/relativewall()//TODO.
	return
