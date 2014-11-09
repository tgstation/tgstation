/turf/simulated/floor/airless
	icon_state = "floor"
	name = "airless floor"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

	New()
		..()
		name = "floor"



/turf/simulated/floor/plating/vox
	icon_state = "plating"
	name = "vox plating"
	//icon = 'icons/turf/shuttle-debug.dmi'
	oxygen=0 // BIRDS HATE OXYGEN FOR SOME REASON
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure

	New()
		..()
		name = "plating"

/turf/simulated/floor/vox
	icon_state = "floor"
	name = "vox floor"
	//icon = 'icons/turf/shuttle-debug.dmi'
	oxygen=0 // BIRDS HATE OXYGEN FOR SOME REASON
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure

	New()
		..()
		name = "floor"

/turf/simulated/floor/vox/wood
	name = "floor"
	icon_state = "wood"
	floor_tile = new/obj/item/stack/tile/wood

	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 10
	soot_type = null
	melt_temperature = 0 // Doesn't melt.

/turf/simulated/floor/light
	name = "Light floor"
	luminosity = 5
	icon_state = "light_on"
	floor_tile = new/obj/item/stack/tile/light

	New()
		floor_tile.New() //I guess New() isn't run on objects spawned without the definition of a turf to house them, ah well.
		var/n = name //just in case commands rename it in the ..() call
		..()
		spawn(4)
			if(src)
				update_icon()
				name = n

/turf/simulated/floor/wood
	name = "floor"
	icon_state = "wood"
	floor_tile = new/obj/item/stack/tile/wood

	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 10
	soot_type = null
	melt_temperature = 0 // Doesn't melt.

/turf/simulated/floor/vault
	icon_state = "rockvault"

	New(location,type)
		..()
		icon_state = "[type]vault"

/turf/simulated/wall/vault
	icon_state = "rockvault"

	New(location,type)
		..()
		icon_state = "[type]vault"

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000

	soot_type = null
	melt_temperature = 0 // Doesn't melt.

/turf/simulated/floor/engine/attackby(obj/item/weapon/C as obj, mob/user as mob)
	if(!C)
		return
	if(!user)
		return
	if(istype(C, /obj/item/weapon/wrench))
		user << "\blue Removing rods..."
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 80, 1)
		if(do_after(user, 30))
			new /obj/item/stack/rods(src, 2)
			ChangeTurf(/turf/simulated/floor)
			var/turf/simulated/floor/F = src
			F.make_plating()
			return

/turf/simulated/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"

/turf/simulated/floor/engine/cult/cultify()
	return


/turf/simulated/floor/engine/n20
	New()
		..()
		if(src.air)
			// EXACTLY the same code as fucking roomfillers.  If this doesn't work, something's fucked.
			var/datum/gas/sleeping_agent/trace_gas = new
			air.trace_gases += trace_gas
			trace_gas.moles = 9*4000
			air.update_values()

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0.001
	temperature = TCMB

/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	floor_tile = null
	intact = 0

/turf/simulated/floor/plating/airless
	icon_state = "plating"
	name = "airless plating"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

	New()
		..()
		name = "plating"

/turf/simulated/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/simulated/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"


/turf/simulated/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0
	layer = 2

	soot_type = null
	melt_temperature = 0 // Doesn't melt.

/turf/simulated/shuttle/wall
	name = "wall"
	icon_state = "wall1"
	opacity = 1
	density = 1
	blocks_air = 1

/turf/simulated/shuttle/wall/cultify()
	ChangeTurf(/turf/simulated/wall/cult)
	cultification()
	return

/turf/simulated/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/simulated/shuttle/floor/cultify()
	if((icon_state != "cult")&&(icon_state != "cult-narsie"))
		name = "engraved floor"
		icon_state = "cult"
		cultification()
	return

/turf/simulated/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"

/turf/simulated/shuttle/floor4 // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "Brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"

/turf/simulated/shuttle/floor4/cultify()
	if((icon_state != "cult")&&(icon_state != "cult-narsie"))
		name = "engraved floor"
		icon_state = "cult"
		cultification()
	return

/turf/simulated/floor/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'
	soot_type = null
	melt_temperature = 0 // Doesn't melt.

/turf/simulated/floor/beach/sand
	name = "Sand"
	icon_state = "sand"

/turf/simulated/floor/beach/coastline
	name = "Coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/simulated/floor/beach/water
	name = "Water"
	icon_state = "water"

/turf/simulated/floor/beach/water/New()
	..()
	overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=MOB_LAYER+0.1)

/turf/simulated/floor/grass
	name = "Grass patch"
	icon_state = "grass1"
	floor_tile = new/obj/item/stack/tile/grass

	New()
		floor_tile.New() //I guess New() isn't ran on objects spawned without the definition of a turf to house them, ah well.
		icon_state = "grass[pick("1","2","3","4")]"
		..()
		spawn(4)
			if(src)
				update_icon()
				for(var/direction in cardinal)
					if(istype(get_step(src,direction),/turf/simulated/floor))
						var/turf/simulated/floor/FF = get_step(src,direction)
						FF.update_icon() //so siding get updated properly

/turf/simulated/floor/carpet
	name = "Carpet"
	icon_state = "carpet"
	floor_tile = new/obj/item/stack/tile/carpet
	var/has_siding=1
	New()
		floor_tile.New() //I guess New() isn't ran on objects spawned without the definition of a turf to house them, ah well.
		if(!icon_state)
			icon_state = initial(icon_state)
		..()
		if(has_siding)
			spawn(4)
				if(src)
					update_icon()
					for(var/direction in list(1,2,4,8,5,6,9,10))
						if(istype(get_step(src,direction),/turf/simulated/floor))
							var/turf/simulated/floor/FF = get_step(src,direction)
							FF.update_icon() //so siding get updated properly

/turf/simulated/floor/carpet/cultify()
	return

/turf/simulated/floor/carpet/arcade
	name = "Arcade Carpet"
	icon_state = "arcadecarpet"
	has_siding=0


/turf/simulated/floor/plating/ironsand/New()
	..()
	name = "Iron Sand"
	icon_state = "ironsand[rand(1,15)]"

/turf/simulated/floor/plating/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/simulated/floor/plating/snow/concrete
	name = "concrete"
	icon = 'icons/turf/floors.dmi'
	icon_state = "concrete"

/turf/simulated/floor/plating/snow/ex_act(severity)
	return

// VOX SHUTTLE SHIT
/turf/simulated/shuttle/floor/vox
	oxygen=0 // BIRDS HATE OXYGEN FOR SOME REASON
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure
	//icon = 'icons/turf/shuttle-debug.dmi'

/turf/simulated/shuttle/plating/vox
	oxygen=0 // BIRDS HATE OXYGEN FOR SOME REASON
	nitrogen = MOLES_O2STANDARD+MOLES_N2STANDARD // So it totals to the same pressure
	//icon = 'icons/turf/shuttle-debug.dmi'


// CATWALKS
// Space and plating, all in one buggy fucking turf!
/turf/simulated/floor/plating/airless/catwalk
	icon = 'icons/turf/catwalks.dmi'
	icon_state = "catwalk0"
	name = "catwalk"
	desc = "Cats really don't like these things."

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

	lighting_lumcount = 4		//starlight

	intact = 0

	soot_type = null
	melt_temperature = 0 // Doesn't melt.

	New()
		..()
		// Fucking cockshit dickfuck shitslut
		name = "catwalk"
		update_icon(1)

	update_icon(var/propogate=1)
		underlays.Cut()
		underlays += new /icon('icons/turf/space.dmi',"[((x + y) ^ ~(x * y) + z) % 25]")

		var/dirs = 0
		for(var/direction in cardinal)
			var/turf/T = get_step(src,direction)
			if(T.is_catwalk())
				var/turf/simulated/floor/plating/airless/catwalk/C=T
				dirs |= direction
				if(propogate)
					C.update_icon(0)
		icon_state="catwalk[dirs]"


	attackby(obj/item/C as obj, mob/user as mob)
		if(!C || !user)
			return 0
		if(istype(C, /obj/item/weapon/screwdriver))
			playsound(src, 'sound/items/Screwdriver.ogg', 80, 1)
			if(do_after(user, 30))
				new /obj/item/stack/rods(src, 2)
				ReplaceWithLattice()
			return

		if(istype(C, /obj/item/weapon/cable_coil))
			var/obj/item/weapon/cable_coil/coil = C
			coil.turf_place(src, user)

	is_catwalk()
		return 1