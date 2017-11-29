/datum/space_chunk
	var/x
	var/y
	var/z
	var/width
	var/height
	// Whether this chunk has been dedicated for use or not
	var/occupied = FALSE
	// Whether this chunk contains children that are dedicated for use or not
	var/is_empty = TRUE
	var/list/children
	var/datum/space_chunk/parent

/datum/space_chunk/New(new_x, new_y, w, h, z_or_parent)
	x = new_x
	y = new_y
	if(isnum(z))
		z = z_or_parent
	else
		if(!width || !height)
			//small split, don't do anything, just let us GC
			return
		parent = z_or_parent
		z = parent.z
		LAZYADD(parent.children, src)
	width = w
	height = h

/datum/space_chunk/Destroy(force)
	set_occupied(FALSE)
	if(parent)
		LAZYREMOVE(parent.children, src)
	ClearChildren(force)
	parent = null
	if(force)
		SSmapping.CleanTurfs(return_turfs())
	return ..()

/datum/space_chunk/proc/ClearChildren()
	QDEL_LIST(children)

/datum/space_chunk/proc/can_fit_space(w, h)
	if(w > width || h > height)
		return FALSE
	if(occupied)
		return FALSE
	if(is_empty)
		return TRUE
	for(var/I in children)
		var/datum/space_chunk/C = I
		if(C.can_fit_space(w, h))
			return TRUE
	return FALSE

// This algorithm recursively goes down the tree and picks the most efficient
// chunk, which is the chunk that is the closest to the desired size
/datum/space_chunk/proc/get_optimal_chunk(w, h)
	if(w > width || h > height)
		return null
	if(occupied)
		return null
	if(is_empty)
		return src
	var/datum/space_chunk/optimal_chunk
	var/optimal_chunk_optimalness = 99999
	for(var/I in children)
		var/datum/space_chunk/C = I
		var/datum/space_chunk/C2 = C.get_optimal_chunk(w, h)
		if(!C2)
			continue
		var/optimalness = C2.width+C2.height-w-h
		if(optimalness < optimal_chunk_optimalness)
			optimal_chunk_optimalness = optimalness
			optimal_chunk = C2
	return optimal_chunk

/datum/space_chunk/proc/Split(req_width, req_height)
	if(LAZYLEN(children))
		CRASH("Tried to split a space_chunk with children")
	var/x_coord = x + req_width
	var/y_coord = y + req_height
	var/_x = x
	var/_y = y
	var/_width = width
	var/_height = height
	//TL
	. = new /datum/space_chunk(\
		_x,\
		_y,\
		req_width,\
		req_height,\
	src)
	//BL
	new /datum/space_chunk(\
		_x,\
		_y + y_coord,\
		req_width,\
		height - req_height,\
	src)	//may GC
	//TR
	new /datum/space_chunk(\
		_x + _width,\
		_y,\
		width - req_width,\
		req_height,\
	src)	//may GC
	//BR
	new /datum/space_chunk(\
		_x + x_coord,\
		_y + y_coord,\
		_width - req_width,\
		_height - req_height,\
	src)

/datum/space_chunk/proc/set_occupied(new_occupied)
	if(new_occupied)
		occupied = TRUE
		var/datum/space_chunk/C = parent
		while(C)
			C.is_empty = FALSE
			C = C.parent
	else
		occupied = FALSE
		var/datum/space_chunk/C = parent
		while(C)
			var/is_children_empty = TRUE
			for(var/datum/space_chunk/C2 in C.children)
				if(!C2.is_empty || C2.occupied)
					is_children_empty = FALSE
			if(!is_children_empty)
				break
			C.is_empty = TRUE
			C = C.parent

/datum/space_chunk/proc/return_turfs()
	return block(top_left(), bottom_right())

/datum/space_chunk/proc/top_left()
	return locate(x, y, z)

/datum/space_chunk/proc/bottom_right()
	return locate(x + width, y + width, z)
