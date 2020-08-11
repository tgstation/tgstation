///Ter13's edge slide code converted to /tg/ code standards
/// link: http://www.byond.com/developer/Ter13/EdgeSlideDemo
/atom/movable/collider/slider
	density = 1
	var/atom/movable/proxy
	can_sidestep = FALSE


/atom/movable/collider/slider/Destroy(force)
	proxy = null
	. = ..()

/atom/movable/collider/slider/proc/slide(atom/movable/self,Dir=0,step_x=0,step_y=0)
	//might be a depth call, so store old data
	var/old_bound_width = bound_width
	var/old_bound_height = bound_height
	var/old_self = proxy
	var/old_loc = loc
	var/old_sx = step_x
	var/old_sy = step_y

	proxy = self //used for advanced collision detection

	if(Dir & Dir - 1)
		//perform diagonal sliding
		bound_width = self.bound_width
		bound_height = self.bound_height

		//resize and relocate src to the correct position
		var/d = turn(Dir,-45)
		locate_corner(self,Dir)

		//test the first direction
		. = step(src,d,2)
		if(!.)
			//if failed, check the second (No need to move, already in position)
			d = turn(Dir,45)

			. = step(src,d,2)
			if(.)
				//return the slide direction
				. = d
		else
			//return the slide direction
			. = d
	else
		//perform linear sliding
		bound_width = self.bound_width/2
		bound_height = self.bound_height/2

		var/d = turn(Dir,-90)
		//move the bounding box to the correct corner
		locate_corner(self,Dir|d)

		//check if we can step
		. = step(src,Dir,2)
		if(!.)
			//if we can't step, try the opposite corner
			d = turn(Dir,90)
			locate_corner(self,Dir|d)

			//check if we can step
			. = step(src,Dir,2)
			if(.)
				//if successful, return the slide direction
				. = d
		else
			//if successful, return the slide direction
			. = d

	//restore old data
	proxy = old_self
	step_x = old_sx
	step_y = old_sy
	loc = old_loc
	bound_width = old_bound_width
	bound_height = old_bound_height

//this will position the slider over the calling mob in the correct position
/atom/movable/collider/slider/proc/locate_corner(atom/movable/self,corner)
	//gather the directional components and get their angles
	var/d1 = corner & corner - 1
	var/d2 = dir2angle(corner ^ d1)
	d1 = dir2angle(d1)

	//set up the position based on the bounding coverage so that the slider is on the correct corner of the movable caller
	var/nx = (self.bound_width - bound_width) * max(sin(d1),0) + (self.x - 1) * PIXEL_TILE_SIZE + self.step_x + self.bound_x
	var/ny = (self.bound_height - bound_height) * max(cos(d2),0) + (self.y - 1) * PIXEL_TILE_SIZE + self.step_y + self.bound_y

	//correct positioning
	step_x = nx % PIXEL_TILE_SIZE
	step_y = ny % PIXEL_TILE_SIZE
	loc = locate(round(nx/PIXEL_TILE_SIZE) + 1, round(ny/PIXEL_TILE_SIZE) + 1, self.z)
