// This represents a level we can carve up as we please, and hand out
// chunks of to whatever requests it
/datum/space_level/heap
	name = "Heap level #ERROR"
	var/datum/space_chunk/top

/datum/space_level/heap/New(zlev, linkage, traits = list())
	if(linkage != UNAFFECTED)
		stack_trace("[type] created with linkage [linkage]")
		linkage = UNAFFECTED	//fuck you i won't do what you tell me
	..()
	top = new(1, 1, zpos, world.maxx, world.maxy)

// free a zlevel
/datum/space_level/heap/proc/Destroy()
	qdel(top, TRUE)
	return ..()

// Returns whether this zlevel has room for the given amount of space
/datum/space_level/heap/proc/request(width, height)
	return top.can_fit_space(width, height)

// Returns a space chunk datum for some nerd to work with - tells them what's safe to write into, and such
// Call request() first to sanity check that the space CAN be allocated
/datum/space_level/heap/proc/allocate(width, height)
	var/datum/space_chunk/C = top.get_optimal_chunk(width, height)
	if(!C)
		return
	C.ClearChildren() // Either way we will be redoing the children of the chunk
	
	if(!(C.width == width && C.height == height && C.is_empty)) // This chunk isn't a perfect fit
		// Split the chunk into 4 pieces, takes the top left
		C = C.Split(width, height)
	C.set_occupied(TRUE)
	return C
