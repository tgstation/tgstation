//dir 1 = north
//dir 2 = south
//dir 8 = west
//dir 4 = east

/obj/structure/reflector
	name = "reflector"
	icon_state = "reflector"
	desc = "An angled mirror for reflecting lasers."
	anchored = 1
	density = 1
	layer = 2

/obj/structure/reflector/bullet_act(obj/item/projectile/P)
	var/reflect_x = 0
	var/reflect_y = 0
	var/new_dir = 0
	var/turf/reflect_turf = get_turf(src)
	if(istype(P, /obj/item/projectile/beam))
		switch(P.dir) //Is the projectile heading in a direction that would hit a reflective panel?
			if(NORTH)
				switch(src.dir)
					if(SOUTH)
						new_dir = EAST
					if(WEST)
						new_dir = WEST
			if(SOUTH)
				switch(src.dir)
					if(NORTH)
						new_dir = WEST
					if(EAST)
						new_dir = EAST
			if(WEST)
				switch(src.dir)
					if(SOUTH)
						new_dir = SOUTH
					if(EAST)
						new_dir = NORTH
			if(EAST)
				switch(src.dir)
					if(NORTH)
						new_dir = NORTH
					if(WEST)
						new_dir = SOUTH

		switch(new_dir) //Setting a new target based on the reflection direction
			if(NORTH)
				reflect_x = src.x
				reflect_y = src.y+2
			if(SOUTH)
				reflect_x = src.x
				reflect_y = src.y-2
			if(EAST)
				reflect_x = src.x+2
				reflect_y = src.y
			if(WEST)
				reflect_x = src.x-2
				reflect_y = src.y
			else //If it didnt hit a panel and a new_dir wasn't set
				visible_message("<span class='notice'>[src] is hit by the [P]!</span>")
				return ..() //Hits as normal, explodes or emps or whatever

		visible_message("<span class='notice'>[P] bounces off of the [src]</span>")
		P.original = locate(reflect_x, reflect_y, P.z)
		P.starting = reflect_turf
		P.current = reflect_turf
		P.yo = reflect_y - reflect_turf.y
		P.xo = reflect_x - reflect_turf.x
		P.kill_count = 50 //Keep the projectile healthy as long as its bouncing off things
		return - 1
	return ..()