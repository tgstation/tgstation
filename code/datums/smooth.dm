/atom/var/smooth = 0
/atom/var/datum/tile_smoother/smoother = null
/atom/var/list/canSmoothWith=list() // TYPE PATHS I CAN SMOOTH WITH~~~~~

//generic (by snowflake) tile smoothing datum; smooth your icons with this!
/*
	Each tile is divided in 4 corners, each corner has an image associated to it; the tile is then overlayed by these 4 images
	To use this, just set your atom's 'smooth' var to 1. If your atom can't be moved/unanchored, set its 'can_be_unanchored' var to 0.
	If you don't want your atom's icon to smooth with anything but atoms of the same type, set the list 'canSmoothWith' to null;
	Otherwise, put all types you want the atom icon to smooth with in 'canSmoothWith' INCLUDING THE TYPE OF THE ATOM ITSELF.

	Each atom has its own icon file with all the possible corner states. See 'smooth_wall.dmi' for a template.
*/
/datum/tile_smoother
	var/image/top_right
	var/image/top_left
	var/image/bottom_left
	var/image/bottom_right
	var/atom/holder
	var/cardinal_adj
	var/list/diagonal_adj
	var/list/siblings
	var/movable
	var/enabled = 1

/datum/tile_smoother/New(var/a_holder, var/list/s_list=null, movable_b = 0)
	holder = a_holder
	top_left = image(holder.icon, "1-i")
	top_right = image(holder.icon, "2-i")
	bottom_left = image(holder.icon, "3-i")
	bottom_right = image(holder.icon, "4-i")
	if(s_list && s_list.len == 0)
		siblings = null
	else
		siblings = s_list
	movable = movable_b

/datum/tile_smoother/proc/update_adjacencies()
	cardinal_adj = 0
	diagonal_adj = list()
	if(movable)
		var/atom/movable/A = holder
		if(!A.anchored)
			cardinal_adj = 0
			diagonal_adj = list()
			return
		for(var/direction in cardinal)
			var/atom/movable/AM = find_type_in_direction(holder, direction, siblings)
			if(AM)
				if(AM.anchored)
					cardinal_adj |= direction
		for(var/direction in diagonals)
			if(find_type_in_direction(holder, direction, siblings))
				diagonal_adj |= direction
	else
		for(var/direction in cardinal)
			if(find_type_in_direction(holder, direction, siblings))
				cardinal_adj |= direction
		for(var/direction in diagonals)
			if(find_type_in_direction(holder, direction, siblings))
				diagonal_adj |= direction

/datum/tile_smoother/proc/smooth()
	if(!enabled)	return
	spawn(2)
		if(holder && holder.smooth)
			holder.overlays -= top_left
			holder.overlays -= top_right
			holder.overlays -= bottom_right
			holder.overlays -= bottom_left

			update_adjacencies()
			make_nw_corner()
			make_ne_corner()
			make_sw_corner()
			make_se_corner()

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
	top_left = "1-[sdir]"

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
	top_right = "2-[sdir]"

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
	bottom_left = "3-[sdir]"

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
	bottom_right = "4-[sdir]"

/datum/tile_smoother/proc/update_neighbors()
	for(var/atom/A in orange(1,holder))
		if(A.smoother)
			A.smoother.smooth()

/proc/find_type_in_direction(atom/source, direction, list/siblings=null, range=1)
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
			for(var/a_type in siblings)
				if(ispath(a_type, /obj))
					var/atom/A = locate(a_type) in locate(source.x + x_offset, source.y + y_offset, source.z)
					if(A && A.type == a_type)
						return A
				else
					var/turf/T = locate(source.x + x_offset, source.y + y_offset, source.z)
					if(T.type == a_type)
						return T
			return null
		var/turf/T = locate(source.x + x_offset, source.y + y_offset, source.z)
		return T.type == source.type ? T : null

	if(siblings)
		for(var/a_type in siblings)
			if(ispath(a_type, /turf))
				var/turf/T = locate(source.x + x_offset, source.y + y_offset, source.z)
				if(T.type == a_type)
					return T
			else
				var/atom/A = locate(a_type) in locate(source.x + x_offset, source.y + y_offset, source.z)
				if(A && A.type == a_type)
					return A
		return null
	var/atom/A = locate(source.type) in locate(source.x + x_offset, source.y + y_offset, source.z)
	return A && A.type == source.type ? A : null

/datum/tile_smoother/proc/enable_smoothing(enable = 1)
	if(!enable)
		enabled = 0
		holder.overlays -= top_left
		holder.overlays -= top_right
		holder.overlays -= bottom_right
		holder.overlays -= bottom_left
	else
		enabled = 1
		smooth()

var/list/TileCornerImages = list()

/proc/GetTileCornerImage(icon_file, corner)
	var/key = "[icon_file][corner]"
	if(TileCornerImages[key])
		return TileCornerImages[key]
	TileCornerImages[key] = image(icon_file, corner)
	return TileCornerImages[key]