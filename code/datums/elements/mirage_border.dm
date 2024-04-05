/**
 * Creates a mirage effect allowing you to see around the world border, by adding the opposite side to its vis_contents.
 */
/datum/element/mirage_border

/datum/element/mirage_border/Attach(datum/target, turf/target_turf, direction, range=world.view)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE
	#ifdef TESTING
	// This is a highly used proc, and these error states never occur, so limit it to testing.
	// If something goes wrong it will runtime anyway.
	if(!target_turf || !istype(target_turf) || !direction)
		stack_trace("[type] improperly attached with the following args: target=\[[target_turf]\], direction=\[[direction]\], range=\[[range]\]")
		return ELEMENT_INCOMPATIBLE
	#endif
	var/turf/owning_turf = target

	var/atom/movable/mirage_holder/holder = new(owning_turf)
	// This is an optimization to avoid needing to check for mirage partners to pass along depth info
	// We just assert that mirages display all the levels their partner ever could
	var/our_offset = GET_Z_PLANE_OFFSET(owning_turf.z)
	var/their_offset = GET_Z_PLANE_OFFSET(target_turf.z)
	var/our_lowest = GET_LOWEST_STACK_OFFSET(owning_turf.z)
	var/their_lowest = GET_LOWEST_STACK_OFFSET(target_turf.z)
	// If our spans are different mark er down
	var/list/depths = list()
	if(our_offset != their_offset || our_lowest != their_lowest)
		for(var/depth in their_offset to their_lowest)
			depths += depth + 1

	var/x = target_turf.x
	var/y = target_turf.y
	var/z = clamp(target_turf.z, 1, world.maxz)
	var/turf/southwest = locate(clamp(x - (direction & WEST ? range : 0), 1, world.maxx), clamp(y - (direction & SOUTH ? range : 0), 1, world.maxy), z)
	var/turf/northeast = locate(clamp(x + (direction & EAST ? range : 0), 1, world.maxx), clamp(y + (direction & NORTH ? range : 0), 1, world.maxy), z)
	for(var/turf/in_block as anything in block(southwest, northeast))
		// We'll never remove these because mirage holders are not reliable. Sorry
		in_block.add_plane_visibilities(depths)
		holder.vis_contents += in_block 
	if(direction & SOUTH)
		holder.pixel_y -= world.icon_size * range
	if(direction & WEST)
		holder.pixel_x -= world.icon_size * range

/datum/element/mirage_border/Detach(atom/movable/target)
	. = ..()
	var/atom/movable/mirage_holder/held = locate() in target.contents
	if(held)
		qdel(held)

INITIALIZE_IMMEDIATE(/atom/movable/mirage_holder)
// Using /atom/movable because this is a heavily used path
/atom/movable/mirage_holder
	name = "Mirage holder"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
