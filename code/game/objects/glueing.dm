//like buckling, but for objects
/atom/movable/var/list/glued_objects = list()
/atom/movable/var/atom/movable/glued_to = null

/atom/movable/proc/glue_object(var/atom/movable/AM)
	if(!istype(AM))
		return
	glued_objects |= AM
	AM.glued_to = src

/atom/movable/proc/unglue_object(var/atom/movable/AM)
	if(!istype(AM))
		return
	glued_objects -= AM
	AM.glued_to = null

/atom/movable/proc/glued_move(atom/movable/AM)
	if(AM)
		loc = AM.loc
		last_move = AM.last_move
		inertia_dir = last_move
	else if(glued_to)
		loc = glued_to.loc
		last_move = glued_to.last_move
		inertia_dir = last_move
	else
		return
	for(var/V in glued_objects)
		var/atom/movable/B = V
		B.glued_move()

/atom/movable/Move(atom/newloc, direct = 0)
	. = ..()
	if(.)
		if(glued_to)
			glued_to.glued_move(src)
		for(var/V in glued_objects)
			var/atom/movable/AM = V
			AM.glued_move()

/atom/movable/Destroy()
	for(var/V in glued_objects)
		var/atom/movable/AM = V
		AM.glued_to = null
	if(glued_to)
		glued_to.unglue_object(src)
	return ..()