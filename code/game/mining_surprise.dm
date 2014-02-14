#define CONTIGUOUS_WALLS  1
#define CONTIGUOUS_FLOORS 2


var/global/list/mining_surprises = typesof(/mining_surprise)-/mining_surprise

/surprise_room
	var/list/floors[0]
	var/list/walls[0]

	var/size_x=0
	var/size_y=0

/mining_surprise
	var/name = "Hidden Complex"

	//: Types of floor to use
	var/list/floortypes[0]
	var/list/walltypes[0]
	var/list/spawntypes[0]

	var/max_richness=2

	//: How many rooms?
	var/complex_max_size=1

	var/room_size_max=5

	var/flags=0

	var/list/rooms=list()
	var/list/goodies=list()
	var/list/candidates=list()

	var/area/asteroid/artifactroom/complex_area

	proc/spawn_complex(var/atom/start_loc)
		name = "[initial(name)] #[rand(100,999)]"
		complex_area = new
		complex_area.name = name
		var/atom/pos=start_loc
		var/nrooms=complex_max_size
		var/maxtries=50
		var/l_size_x=0
		var/l_size_y=0
		while(nrooms && maxtries)
			var/sx=rand(3,room_size_max)
			var/sy=rand(3,room_size_max)
			var/o_x=l_size_x?rand(0,l_size_x):0
			var/o_y=l_size_y?rand(0,l_size_y):0
			var/atom/npos
			switch(pick(cardinal))
				if(NORTH)
					npos=locate(pos.x+o_x,  pos.y+sy-1, pos.z)
				if(SOUTH)
					npos=locate(pos.x+o_x,  pos.y-sy+1, pos.z)
				if(WEST)
					npos=locate(pos.x-sx-1, pos.y+o_y,  pos.z)
				if(EAST)
					npos=locate(pos.x+sx+1, pos.y+o_y,  pos.z)
			if(spawn_room(npos,sx,sy,1))
				pos=npos
				l_size_x=sx
				l_size_y=sy
			else if(complex_max_size==nrooms)
				// Failed to make first room, abort.
				del(complex_area)
				return 0
			else
				maxtries--
				continue
			nrooms--
		postProcessComplex()
		message_admins("Complex spawned at [formatJumpTo(start_loc)]")
		return 1

	proc/postProcessRoom(var/surprise_room/room)
		for(var/turf/floor in room.floors)
			for(var/turf/T in floor.AdjacentTurfs())
				if(T in room.floors)
					candidates|=T
					break

	proc/postProcessComplex()
		for(var/i=0;i<=rand(0,max_richness);i++)
			var/turf/T = pick(candidates)
			var/thing = pickweight(spawntypes)
			if(thing==null)
				continue
			new thing(T)
			message_admins("Goodie [thing] spawned at [formatJumpTo(T)]")

	proc/spawn_room(var/atom/start_loc, var/x_size, var/y_size, var/clean=0)
		if(!check_complex_placement(start_loc,x_size,y_size))
			return 0

		// If walls/floors are contiguous, pick them out.
		var/wall_type
		if(flags & CONTIGUOUS_WALLS)
			wall_type = pickweight(walltypes)

		var/floor_type
		if(flags & CONTIGUOUS_FLOORS)
			floor_type = pickweight(floortypes)


		var/list/walls[0]
		var/list/floors[0]
		for(var/x = 0,x<x_size,x++)
			for(var/y = 0,y<y_size,y++)
				var/turf/cur_loc = locate(start_loc.x+x,start_loc.y+y,start_loc.z)

				if(clean)
					for(var/O in cur_loc)
						qdel(O)

				if(x == 0 || x==x_size-1 || y==0 || y==y_size-1)
					walls |= cur_loc
				else
					floors |= cur_loc

		var/surprise_room/room = new
		for(var/turf/turf in walls)

			if(!(flags & CONTIGUOUS_WALLS))
				wall_type=pickweight(walltypes)

			var/turf/T
			if(dd_hasprefix("[wall_type]","/obj"))
				if(!(flags & CONTIGUOUS_FLOORS))
					floor_type=pickweight(floortypes)
				T=new floor_type(turf)
				new wall_type(T)
			else
				//testing("Creating wall of type [wall_type].")
				T=new wall_type(turf)

			room.walls += T
			complex_area.contents += T

		for(var/turf/turf in floors)
			if(!(flags & CONTIGUOUS_FLOORS))
				floor_type=pickweight(floortypes)

			var/turf/T = new floor_type(turf)
			room.floors += T
			complex_area.contents += T

		postProcessRoom(room)

		rooms += room

		message_admins("Room spawned at [formatJumpTo(start_loc)]")

		return 1

/mining_surprise/human_vault
	name="Hidden Complex"
	floortypes = list(
		/turf/simulated/floor/airless=95,
		/turf/simulated/floor/plating/airless=5
	)
	walltypes = list(
		/turf/simulated/wall=100
	)
	spawntypes = list(
		/obj/item/weapon/pickaxe/silver					=4,
		/obj/item/weapon/pickaxe/drill					=4,
		/obj/item/weapon/pickaxe/jackhammer				=4,
		/obj/item/weapon/pickaxe/diamond				=3,
		/obj/item/weapon/pickaxe/diamonddrill			=3,
		/obj/item/weapon/pickaxe/gold					=3,
		/obj/item/weapon/pickaxe/plasmacutter			=2,
		/obj/structure/closet/syndicate/resources		=2,
		/obj/item/weapon/melee/energy/sword/pirate		=1,
		/obj/mecha/working/ripley/mining				=1
	)
	complex_max_size=2

	flags = CONTIGUOUS_WALLS | CONTIGUOUS_FLOORS

/mining_surprise/alien_nest
	name="Hidden Nest"
	floortypes = list(
		/turf/unsimulated/floor/asteroid=100
	)

	walltypes = list(
		/obj/effect/alien/resin/wall=90,
		/obj/effect/alien/resin/membrane=10
	)

	spawntypes = list(
		/obj/effect/decal/mecha_wreckage/ripley			=4,
		/obj/item/clothing/mask/facehugger				=4,
		/obj/mecha/working/ripley/mining				=1
	)

	complex_max_size=6
	room_size_max=7

	var/const/eggs_left=10 // Per complex
	var/turf/weeds[0] // Turfs with weeds.
	postProcessComplex()
		..()
		var/list/all_floors=list()
		for(var/surprise_room/room in rooms)
			var/list/w_cand=room.floors
			var/egged=0
			while(w_cand.len)
				var/turf/weed_turf = pick(w_cand)
				if(locate(/obj/effect/alien) in weed_turf)
					continue
				w_cand -= weed_turf
				if(weed_turf && !egged)
					new /obj/effect/alien/weeds/node(weed_turf)
					weeds += weed_turf
					egged=1
				else
					all_floors |= room.floors

		for(var/e=0;e<eggs_left;e++)
			var/turf/egg_turf = pick(all_floors)
			if(egg_turf && !(locate(/obj/effect/alien) in egg_turf))
				new /obj/effect/alien/egg(egg_turf)