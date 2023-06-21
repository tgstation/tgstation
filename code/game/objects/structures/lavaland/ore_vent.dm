/obj/structure/ore_vent
	name = "untapped ore vent"
	icon = 'icons/obj/lavaland/terrain.dmi' /// note to self, new sprites. get on it
	icon_state = "geyser"

	/// Has this vent been tapped to produce boulders? Cannot be untapped.
	var/tapped = FALSE
	/// A weighted list of what minerals are contained in this vent, with weight determining how likely each mineral is to be picked in produced boulders.
	var/list/mineral_breakdown = list(
		/datum/material/iron = 50,
		/datum/material/glass = 35,
		/datum/material/silver = 5,
		/datum/material/gold = 5,
		/datum/material/plasma = 1,
	)
	/// How many rolls on the mineral_breakdown list are made per boulder produced? EG: 3 rolls means 3 minerals per boulder, with order determining percentage.
	var/minerals_per_boulder = 3

	/// What size boulders does this vent produce?
	var/boulder_size = BOULDER_SIZE_SMALL

	/// Percent chance that this vent will produce an artifact as well.
	// var/artifact_chance = 0


/obj/structure/ore_vent/Initialize(mapload)
	. = ..()
	///This is the part where we start processing to produce a new boulder over time.

/obj/structure/ore_vent/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(istype(attacking_item, /obj/item/t_scanner/adv_mining_scanner))
		///This is where we start spitting out boulders.
		var/obj/item/boulder/new_rock = new (loc)
		var/list/mats_list = create_mineral_contents()
		new_rock.set_custom_materials(mats_list)

/**
 * Picks n types materials to pack into a boulder created by this ore vent, where n is this vent's minerals_per_boulder.
 * Then assigns custom_materials based on boulder_size, assigned via the ore_quantity_function
 */
/obj/structure/ore_vent/proc/create_mineral_contents()
	var/list/refined_list = list()
	// say("hiii")
	say(pick_weight(mineral_breakdown))
	for(var/iteration in 1 to minerals_per_boulder)
		var/picked_mat = pick_weight(mineral_breakdown) // Material should be picked, weighed by random weights.
		var/sheets_worth_of_minerals = ore_quantity_function(iteration)
		var/list/quantity_list = list()
		quantity_list[picked_mat] = sheets_worth_of_minerals
		refined_list.Insert(refined_list.len, quantity_list)
	return refined_list

/**
 * Returns the quantity of mineral sheets in each ore's boulder contents roll. First roll can produce the most ore, with subsequent rolls scaling lower logarithmically.
 */
/obj/structure/ore_vent/proc/ore_quantity_function(ore_floor)
	var/mineral_count = boulder_size * (log(rand(1+ore_floor, 4+ore_floor))**-1)
	mineral_count = SHEET_MATERIAL_AMOUNT * round(mineral_count)
	say(mineral_count)
	return mineral_count

/obj/item/boulder
	name = "boulder"
	desc = "This rocks."
	icon_state = "ore"
	icon = 'icons/obj/ore.dmi'
