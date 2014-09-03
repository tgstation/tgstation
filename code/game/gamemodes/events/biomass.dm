/**
 * Biomass (note that this code is very similar to Space Vine code)
 */
/obj/effect/biomass
	name = "biomass"
	desc = "Space barf from another dimension. It just keeps spreading!"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "stage1"
	anchored = 1
	density = 0
	layer = 5
	pass_flags = PASSTABLE | PASSGRILLE
	var/energy = 0
	var/obj/effect/biomass_controller/master = null

/obj/effect/biomass/Destroy()
	unreferenceMaster()
	..()

/obj/effect/biomass/proc/unreferenceMaster()
	if(master)
		master.growth_queue -= src
		master.vines -= src
		master = null

/obj/effect/biomass/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (!W || !user || !W.type)
		return

	switch(W.type)
		if(/obj/item/weapon/circular_saw)
			qdel(src)
		if(/obj/item/weapon/kitchen/utensil/knife)
			qdel(src)
		if(/obj/item/weapon/scalpel)
			qdel(src)
		if(/obj/item/weapon/twohanded/fireaxe)
			qdel(src)
		if(/obj/item/weapon/hatchet)
			qdel(src)
		if(/obj/item/weapon/melee/energy)
			qdel(src)

		// less effective weapons
		if(/obj/item/weapon/wirecutters)
			if(prob(25))
				qdel(src)
		if(/obj/item/weapon/shard)
			if(prob(25))
				qdel(src)

		else // weapons with subtypes
			if(istype(W, /obj/item/weapon/melee/energy/sword))
				qdel(src)
			else if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WeldingTool = W

				if(WeldingTool.remove_fuel(0, user))
					qdel(src)
			else
				return

	..()

/obj/effect/biomass/proc/grow()
	if(energy <= 0)
		icon_state = "stage2"
		energy = 1
	else
		icon_state = "stage3"
		density = 1
		energy = 2

/obj/effect/biomass/proc/spread()
	var/location = get_step_rand(src)

	if(istype(location, /turf/simulated/floor))
		var/turf/simulated/floor/Floor = location

		if(isnull(locate(/obj/effect/biomass) in Floor))
			if(Floor.Enter(src, loc))
				if(master)
					master.spawn_biomass_piece(Floor)
					return 1
	return 0

/obj/effect/biomass/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(90))
				qdel(src)
		if(3.0)
			if(prob(50))
				qdel(src)

/obj/effect/biomass/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume) //hotspots kill biomass
	qdel(src)

/obj/effect/biomass_controller
	invisibility = 60 // ghost only

	var/list/obj/effect/biomass/vines = new
	var/list/growth_queue = new

	// what this does is that instead of having the grow minimum of 1,
	// required to start growing, the minimum will be 0,
	// meaning if you get the biomasssss..s' size to something less than 20 plots,
	// it won't grow anymore.
	var/reached_collapse_size = FALSE
	var/reached_slowdown_size = FALSE

/obj/effect/biomass_controller/New(loc)
	..(loc)

	if(!istype(loc, /turf/simulated/floor))
		qdel(src)

	spawn_biomass_piece(loc)
	processing_objects += src

/obj/effect/biomass_controller/Destroy() // controller is kill, no!!!111
	if(vines && vines.len > 0)
		for(var/obj/effect/biomass/Biomass in vines)
			Biomass.unreferenceMaster()

	processing_objects -= src
	..()

/obj/effect/biomass_controller/proc/spawn_biomass_piece(var/turf/location)
	var/obj/effect/biomass/Biomass = new(location)
	Biomass.master = src
	vines += Biomass
	growth_queue += Biomass

/obj/effect/biomass_controller/process()
	if(isnull(vines) || vines.len == 0) // sanity and existing biomass check
		qdel(src)
		return

	if(isnull(growth_queue)) // sanity check
		qdel(src)
		return

	if(vines.len >= 250 && !reached_collapse_size)
		reached_collapse_size = TRUE

	if(vines.len >= 30 && !reached_slowdown_size)
		reached_slowdown_size = TRUE

	var/maxgrowth = 0

	if(reached_collapse_size)
		maxgrowth = 0
	else if(reached_slowdown_size)
		if(prob(25))
			maxgrowth = 1
		else
			maxgrowth = 0
	else
		maxgrowth = 4

	var/length = min(30, vines.len / 5)
	var/i = 0
	var/growth = 0
	var/list/obj/effect/biomass/queue_end = new

	for(var/obj/effect/biomass/Biomass in growth_queue)
		i++
		growth_queue -= Biomass
		queue_end += Biomass

		if(Biomass.energy < 2) // if biomass isn't fully grown
			if(prob(20))
				Biomass.grow()

		if(Biomass.spread())
			growth++

			if(growth >= maxgrowth)
				break

		if(i >= length)
			break

	growth_queue = growth_queue + queue_end

/proc/biomass_infestation()
	set waitfor = 0

	// list of all the empty floor turfs in the hallway areas
	var/list/turf/simulated/floor/Floors = new

	for(var/type in typesof(/area/hallway))
		var/area/Hallway = locate(type)

		for(var/area/Related in Hallway.related)
			for(var/turf/simulated/floor/Floor in Related.contents)
				if(Floor.contents.len <= 0)
					Floors += Floor

	if(Floors.len) // pick a floor to spawn at
		var/turf/simulated/floor/Floor = pick(Floors)
		new/obj/effect/biomass_controller(Floor) // spawn a controller at floor
		message_admins("<span class='notice'>Event: Biomass spawned at [Floor.loc] ([Floor.x].[Floor.y].[Floor.z])</span>")
