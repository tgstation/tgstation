#define GRASS_SPONTANEOUS 		2
#define GRASS_WEIGHT 			4
#define LUSH_PLANT_SPAWN_LIST list(/obj/structure/flora/grass/wasteland = 10, /obj/structure/flora/wasteplant/wild_broc = 7, /obj/structure/flora/wasteplant/wild_feracactus = 5, /obj/structure/flora/wasteplant/wild_mutfruit = 5, /obj/structure/flora/wasteplant/wild_xander = 5, /obj/structure/flora/wasteplant/wild_agave = 5, /obj/structure/flora/tree/joshua = 3, /obj/structure/flora/tree/cactus = 2, /obj/structure/flora/tree/wasteland = 2)
#define DESOLATE_PLANT_SPAWN_LIST list(/obj/structure/flora/grass/wasteland = 1)

//A plating that can't be destroyed but can have stuff like floor tiles slapped on for construction

/turf/open/floor/plating/ground
	name = "ground"
	desc = "Some really hard ground. Looks like you can't destroy this for sure."
	baseturfs = /turf/open/floor/plating/ground
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	attachment_holes = FALSE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/floor/plating/ground/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ground/break_tile()
	return //unbreakable

/turf/open/floor/plating/ground/burn_tile()
	return //unburnable

/turf/open/floor/plating/ground/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/floor/plating/ground/MakeDry()
	return

//Some desert
/turf/open/floor/plating/ground/desert
	name = "\proper desert"
	desc = "A stretch of desert."
	baseturfs = /turf/open/floor/plating/ground/desert
	icon_state = "wasteland1"
	icon = 'fallout/icons/turf/ground.dmi'
	slowdown = 1
	var/obj/structure/flora/turfPlant = null
	var/digResult = /obj/item/stack/ore/glass
	var/dug = FALSE

/turf/open/floor/plating/ground/desert/Initialize()
	. = ..()
	icon_state = "wasteland[rand(1,31)]"
	//If no fences, machines (soil patches are machines), etc. try to plant grass
	if(!((locate(/obj/structure) in src) || (locate(/obj/machinery) in src)))
		plantGrass()

/turf/open/floor/plating/ground/desert/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(!.)
		if(!digResult)
			return
		if(W.tool_behaviour == TOOL_SHOVEL || W.tool_behaviour == TOOL_MINING)
			if(dug)
				to_chat(user, "<span class='notice'>Looks like someone has dug here already.</span>")
				return TRUE

			if(!isturf(user.loc))
				return

			to_chat(user, "<span class='notice'>You start digging...</span>")

			if(W.use_tool(src, user, 40, volume=50))
				to_chat(user, "<span class='notice'>You dig a hole.</span>")
				getDug()
				SSblackbox.record_feedback("tally", "pick_used_mining", 1, W.type)
				return TRUE
		else if(istype(W, /obj/item/storage/bag/ore))
			for(var/obj/item/stack/ore/O in src)
				SEND_SIGNAL(W, COMSIG_PARENT_ATTACKBY, O)

/turf/open/floor/plating/ground/desert/proc/getDug()
	new digResult(src, 5)
	icon_state = "[icon_state]_dug"
	dug = TRUE

//Pass PlantForce for admin stuff I guess?
/turf/open/floor/plating/ground/desert/proc/plantGrass(Plantforce = FALSE)
	var/Weight = 0
	var/randPlant = null

	//spontaneously spawn grass
	if(Plantforce || prob(GRASS_SPONTANEOUS))
		randPlant = pickweight(LUSH_PLANT_SPAWN_LIST) //Create a new grass object at this location, and assign var
		turfPlant = new randPlant(src)
		. = TRUE //in case we ever need this to return if we spawned
		return .

	//loop through neighbouring desert turfs, if they have grass, then increase weight
	for(var/turf/open/floor/plating/ground/desert/T in RANGE_TURFS(2, src))
		if(T.turfPlant)
			Weight += GRASS_WEIGHT

	//use weight to try to spawn grass
	if(prob(Weight))

		//If surrounded on 5+ sides, pick from lush
		if(Weight == (5 * GRASS_WEIGHT))
			randPlant = pickweight(LUSH_PLANT_SPAWN_LIST)
		else
			randPlant = pickweight(DESOLATE_PLANT_SPAWN_LIST)
		turfPlant = new randPlant(src)
		. = TRUE

//Make sure we delete the plant if we ever change turfs
/turf/open/floor/plating/ground/desert/ChangeTurf(path, new_baseturf, flags)
	if(turfPlant)
		qdel(turfPlant)
	. =  ..()

#define SHROOM_SPAWN	1

/turf/open/floor/plating/ground/mountain
	name = "mountain"
	desc = "Damp cave flooring."
	baseturfs = /turf/open/floor/plating/ground/mountain
	icon = 'fallout/icons/turf/f13floors2.dmi'
	icon_state = "mountain0"
	var/obj/structure/flora/turfPlant = null
	slowdown = 1

/turf/open/floor/plating/ground/mountain/Initialize()
	. = ..()
	icon_state = "mountain[rand(0,10)]"
	//If no fences, machines, etc. try to plant mushrooms
	if(!(\
			(locate(/obj/structure) in src) || \
			(locate(/obj/machinery) in src) ))
		plantShrooms()

/turf/open/floor/plating/ground/mountain/proc/plantShrooms()
	if(prob(SHROOM_SPAWN))
		turfPlant = new /obj/structure/flora/wasteplant/wild_fungus(src)
		. = TRUE //in case we ever need this to return if we spawned
		return .

/turf/open/floor/plating/ground/road
	name = "\proper road"
	desc = "A stretch of road."
	baseturfs = /turf/open/floor/plating/ground/desert
	icon = 'fallout/icons/turf/f13road.dmi'
	icon_state = "outermiddle"
