/obj/effect/sliding_puzzle
	name = "Sliding puzzle generator"
	icon = 'icons/obj/items_and_weapons.dmi' //mapping
	icon_state = "syndballoon"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	var/list/elements
	var/floor_type = /turf/open/floor/vault
	var/finished = FALSE
	var/reward_type = /obj/item/reagent_containers/food/snacks/cookie
	var/auto_setup = TRUE
	var/empty_tile_id

//Gets the turf where the tile with given id should be
/obj/effect/sliding_puzzle/proc/get_turf_for_id(id)
	var/turf/center = get_turf(src)
	switch(id)
		if(1)
			return get_step(center,NORTHWEST)
		if(2)
			return get_step(center,NORTH)
		if(3)
			return get_step(center,NORTHEAST)
		if(4)
			return get_step(center,WEST)
		if(5)
			return center
		if(6)
			return get_step(center,EAST)
		if(7)
			return get_step(center,SOUTHWEST)
		if(8)
			return get_step(center,SOUTH)
		if(9)
			return get_step(center,SOUTHEAST)
		
/obj/effect/sliding_puzzle/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/sliding_puzzle/LateInitialize()
	if(auto_setup)
		setup()

/obj/effect/sliding_puzzle/proc/validate()
	if(finished)
		return
	
	if(elements.len < 8) //Someone broke it
		qdel(src)

	//Check if everything is in place
	for(var/id in 1 to 9)
		var/target_turf = get_turf_for_id(id)
		var/obj/structure/puzzle_element/unwanted = locate() in target_turf
		if(id == empty_tile_id && !unwanted)
			continue
		if(!unwanted || unwanted.id != id) //wrong tile or no tile at all
			return
	//Ding ding
	finish()

/obj/effect/sliding_puzzle/Destroy()
	if(LAZYLEN(elements))
		for(var/obj/structure/puzzle_element/E in elements)
			E.source = null
		elements.Cut()
	return ..()

#define COLLAPSE_DURATION 7

/obj/effect/sliding_puzzle/proc/finish()
	finished = TRUE
	for(var/mob/M in range(7,src))
		shake_camera(M, COLLAPSE_DURATION , 1)
	for(var/obj/structure/puzzle_element/E in elements)
		E.collapse()
	//TODO : Some kinda visual here ? 
	new reward_type(get_turf(src))

/obj/effect/sliding_puzzle/proc/is_solvable()
	var/list/current_ordering = list()
	for(var/obj/structure/puzzle_element/E in elements_in_order())
		current_ordering += E.id

	var/swap_tally = 0
	for(var/i in 1 to current_ordering.len)
		var/checked_value = current_ordering[i]
		for(var/j in i to current_ordering.len)
			if(current_ordering[j] < checked_value)
				swap_tally++
	
	return swap_tally % 2 == 0

//swap two tiles in same row
/obj/effect/sliding_puzzle/proc/make_solvable()
	var/first_tile_id = 1
	var/other_tile_id = 2
	if(empty_tile_id == 1 || empty_tile_id == 2) //Can't swap with empty one so just grab some in second row
		first_tile_id = 4
		other_tile_id = 5
	
	var/turf/T1 = get_turf_for_id(first_tile_id)
	var/turf/T2 = get_turf_for_id(other_tile_id)
	
	var/obj/structure/puzzle_element/E1 = locate() in T1
	var/obj/structure/puzzle_element/E2 = locate() in T2
	
	E1.forceMove(T2)
	E2.forceMove(T1)

/proc/cmp_xy_desc(atom/movable/A,atom/movable/B)
	if(A.y > B.y)
		return -1
	if(A.y < B.y)
		return 1
	if(A.x > B.x)
		return 1
	if(A.x < B.x)
		return -1
	return 0

/obj/effect/sliding_puzzle/proc/elements_in_order()
	return sortTim(elements,cmp=/proc/cmp_xy_desc)

/obj/effect/sliding_puzzle/proc/get_base_icon()
	var/icon/I = new('icons/obj/puzzle.dmi')
	var/list/puzzles = icon_states(I)
	var/puzzle_state = pick(puzzles)
	var/icon/P = new('icons/obj/puzzle.dmi',puzzle_state)
	return P

/obj/effect/sliding_puzzle/proc/setup()
	//First we slice the 96x96 icon into 32x32 pieces
	var/list/puzzle_pieces = list() //id -> icon list

	var/width = 3
	var/height = 3
	var/list/left_ids = list()
	var/tile_count = width * height

	//Generate per tile icons
	for(var/id in 1 to tile_count)
		var/y = width - round((id - 1) / width)
		var/x = ((id - 1) % width) + 1

		var/x_start = 1 + (x - 1) * world.icon_size
		var/x_end = x_start + world.icon_size - 1
		var/y_start = 1 + ((y - 1) * world.icon_size)
		var/y_end = y_start + world.icon_size - 1

		var/icon/T = get_base_icon()
		T.Crop(x_start,y_start,x_end,y_end)
		puzzle_pieces["[id]"] = T
		left_ids += id

	//Setup random empty tile
	empty_tile_id = pick_n_take(left_ids)
	var/turf/empty_tile_turf = get_turf_for_id(empty_tile_id)
	empty_tile_turf.PlaceOnTop(floor_type,null,CHANGETURF_INHERIT_AIR)
	var/mutable_appearance/MA = new(puzzle_pieces["[empty_tile_id]"])
	MA.layer = empty_tile_turf.layer + 0.1
	empty_tile_turf.add_overlay(MA)

	elements = list()
	var/list/empty_spots = left_ids.Copy()
	for(var/spot_id in empty_spots)
		var/turf/T = get_turf_for_id(spot_id)
		T = T.PlaceOnTop(floor_type,null,CHANGETURF_INHERIT_AIR)
		var/obj/structure/puzzle_element/E = new(T)
		elements += E
		var/chosen_id = pick_n_take(left_ids)
		E.puzzle_icon = puzzle_pieces["[chosen_id]"]
		E.source = src
		E.id = chosen_id
		E.set_puzzle_icon()

	if(!is_solvable())
		make_solvable()

/obj/structure/puzzle_element
	name = "mysterious pillar"
	desc = "puzzling..."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "puzzle_pillar"
	anchored = FALSE
	density = TRUE
	var/id = 0
	var/obj/effect/sliding_puzzle/source
	var/icon/puzzle_icon

/obj/structure/puzzle_element/Move(nloc, dir)
	if(!isturf(nloc) ||  moving_diagonally || get_dist(get_step(src,dir),get_turf(source)) > 1)
		return 0
	else
		return ..()

/obj/structure/puzzle_element/proc/set_puzzle_icon()
	cut_overlays()
	if(puzzle_icon)
		//Need to scale it down a bit to fit the static border
		var/icon/C = new(puzzle_icon)
		C.Scale(19,19)
		var/mutable_appearance/puzzle_small = new(C)
		puzzle_small.pixel_x = 7
		puzzle_small.pixel_y = 7
		add_overlay(puzzle_small)

/obj/structure/puzzle_element/Destroy()
	if(source)
		source.elements -= src
		source.validate()
	return ..()

//Set the full image on the turf and delete yourself
/obj/structure/puzzle_element/proc/collapse()
	var/turf/T = get_turf(src)
	var/mutable_appearance/MA = new(puzzle_icon)
	MA.layer = T.layer + 0.1
	T.add_overlay(MA)
	//Some basic shaking animation
	for(var/i in 1 to COLLAPSE_DURATION)
		animate(src, pixel_x=rand(-5,5), pixel_y=rand(-2,2), time=1)
	QDEL_IN(src,COLLAPSE_DURATION)

/obj/structure/puzzle_element/Moved()
	. = ..()
	source.validate()

//Admin abuse version so you can pick the icon before it sets up
/obj/effect/sliding_puzzle/admin
	auto_setup = FALSE
	var/icon/puzzle_icon
	var/puzzle_state

/obj/effect/sliding_puzzle/admin/get_base_icon()
	var/icon/I = new(puzzle_icon,puzzle_state)
	return I

//Ruin version
/obj/effect/sliding_puzzle/lavaland
	reward_type = /obj/structure/closet/crate/necropolis/puzzle