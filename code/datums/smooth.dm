/atom/var/smooth = 0
/atom/var/datum/tile_smoother/smoother = null
/atom/var/del_suppress_resmoothing = 0
/atom/var/list/canSmoothWith=list() // TYPE PATHS I CAN SMOOTH WITH~~~~~

/datum/tile_smoother
	var/image/top_right
	var/image/top_left
	var/image/bottom_left
	var/image/bottom_right
	var/atom/holder
	var/cardinal_adj
	var/list/diagonal_adj
	var/list/siblings

/datum/tile_smoother/New(var/a_holder, var/s_list=null)
	holder = a_holder
	PoolOrNew(/image)
	top_left = image(holder.icon, "1-i")
	top_right = image(holder.icon, "2-i")
	bottom_left = image(holder.icon, "3-i")
	bottom_right = image(holder.icon, "4-i")
	PlaceInPool(top_left)
	PlaceInPool(top_right)
	PlaceInPool(bottom_left)
	PlaceInPool(bottom_right)
	siblings = s_list

/datum/tile_smoother/proc/update_adjacencies()
	cardinal_adj = 0
	diagonal_adj = list()
	for(var/direction in cardinal)
		if(find_type_in_direction(holder, direction, siblings))
			cardinal_adj |= direction
	for(var/direction in diagonals)
		if(find_type_in_direction(holder, direction, siblings))
			diagonal_adj |= direction

/datum/tile_smoother/proc/smooth(direction)
	spawn(1)
		update_adjacencies()
		make_nw_corner()
		make_ne_corner()
		make_sw_corner()
		make_se_corner()
		holder.overlays.Cut()
		holder.overlays += top_left
		holder.overlays += top_right
		holder.overlays += bottom_right
		holder.overlays += bottom_left


/datum/tile_smoother/proc/make_nw_corner()
	var/sdir = ""
	if((cardinal_adj & NORTH) && (cardinal_adj & WEST))
		if(NORTHWEST in diagonal_adj)
			sdir = "f"
		else
			sdir = "nw"
	else
		if(cardinal_adj & NORTH)
			sdir = "n"
		else if(cardinal_adj & WEST)
			sdir = "w"
		else
			sdir = "i"
	top_left = GetFromPool(top_left,list(holder.icon, "1-[sdir]"))
	if(!top_left)
		top_left = image(holder.icon, "1-[sdir]")

/datum/tile_smoother/proc/make_ne_corner()
	var/sdir = ""
	if((cardinal_adj & NORTH) && (cardinal_adj & EAST))
		if(NORTHEAST in diagonal_adj)
			sdir = "f"
		else
			sdir = "ne"
	else
		if(cardinal_adj & NORTH)
			sdir = "n"
		else if(cardinal_adj & EAST)
			sdir = "e"
		else
			sdir = "i"
	top_right = GetFromPool(top_right,list(holder.icon, "2-[sdir]"))
	if(!top_right)
		top_right = image(holder.icon, "2-[sdir]")

/datum/tile_smoother/proc/make_sw_corner()
	var/sdir = ""
	if((cardinal_adj & SOUTH) && (cardinal_adj & WEST))
		if(SOUTHWEST in diagonal_adj)
			sdir = "f"
		else
			sdir = "sw"
	else
		if(cardinal_adj & SOUTH)
			sdir = "s"
		else if(cardinal_adj & WEST)
			sdir = "w"
		else
			sdir = "i"
	bottom_left = GetFromPool(bottom_left,list(holder.icon, "3-[sdir]"))
	if(!bottom_left)
		bottom_left = image(holder.icon, "3-[sdir]")

/datum/tile_smoother/proc/make_se_corner()
	var/sdir = ""
	if((cardinal_adj & SOUTH) && (cardinal_adj & EAST))
		if(SOUTHEAST in diagonal_adj)
			sdir = "f"
		else
			sdir = "se"
	else
		if(cardinal_adj & SOUTH)
			sdir = "s"
		else
			if(cardinal_adj & EAST)
				sdir = "e"
			else
				sdir = "i"
	bottom_right = GetFromPool(bottom_right,list(holder.icon, "4-[sdir]"))
	if(!bottom_right)
		bottom_right = image(holder.icon, "4-[sdir]")


/proc/find_type_in_direction(atom/source, direction, list/siblings=null, range=1)
//	if(!source || !type || !direction || range < 1)
//		return null

	var/x_offset = 0
	var/y_offset = 0

	if(direction & NORTH)
		y_offset = range
	else if(direction & SOUTH)
		y_offset -= range

	if(direction & EAST)
		x_offset = range
	else if(direction & WEST)
		x_offset -= range

	if(istype(source, /turf))
		if(siblings)
			for(var/atom/A in siblings)
				if(istype(locate(source.x + x_offset, source.y + y_offset, source.z),A.type))
					return 1
			return 0
		var/turf/T = locate(source.x + x_offset, source.y + y_offset, source.z)
		return T.type == source.type

	if(siblings)
		for(var/atom/A in siblings)
			if(locate(A.type) in locate(source.x + x_offset, source.y + y_offset, source.z))
				return 1
		return 0
	var/atom/A = locate(source.type) in locate(source.x + x_offset, source.y + y_offset, source.z)
	return A.type == source.type
