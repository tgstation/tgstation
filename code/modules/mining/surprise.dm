#define CONTIGUOUS_WALLS  1
#define CONTIGUOUS_FLOORS 2

#define TURF_FLOOR 0
#define TURF_WALL 1
var/global/list/mining_surprises = typesof(/mining_surprise)-/mining_surprise

/surprise_turf_info
	var/list/types[0]
	var/list/adjacents
	var/turf_type=TURF_FLOOR

	New()
		adjacents=list(
			"[NORTH]"=list(),
			"[SOUTH]"=list(),
			"[EAST]"=list(),
			"[WEST]"=list()
		)

	proc/GetAdjacentTypes(var/dir)
		return adjacents["[dir]"]

/surprise_room
	var/list/turfs[0]

	// Used for layout system.
	var/list/turf_info[0]

	var/size_x=0
	var/size_y=0

	proc/UpdateTurfs()
		for(var/turf/T in turfs)
			UpdateTurf(T)

	proc/GetTurfs(var/ttype)
		var/list/selected[0]
		for(var/turf/T in turfs)
			var/surprise_turf_info/Ti = GetTurfInfo(T)
			if(Ti.turf_type==ttype)
				selected |= T
		return selected

	proc/GetTurfInfo(var/turf/T)
		var/surprise_turf_info/sti
		if(!(T in turf_info))
			sti = new
			turf_info[T]=sti
		else
			sti = turf_info[T]
		return sti

	proc/UpdateTurf(var/turf/T, var/no_adjacent=0)
		// List types in this turf.
		var/surprise_turf_info/sti = GetTurfInfo(T)
		if(!istype(sti.types) || isnull(sti.types))
			sti.types = new/list()
		else
			sti.types.len = 0
		for(var/atom/A in T.contents)
			sti.types |= A.type

		if(no_adjacent) return
		UpdateAdjacentsOfTurf(T)

	proc/AddTypeToTurf(var/turf/T, var/newtype)
		var/surprise_turf_info/sti = GetTurfInfo(T)
		sti.types |= newtype

		//UpdateAdjacentsOfTurf(T)

	proc/UpdateAdjacentsOfTurf(var/turf/T)
		var/surprise_turf_info/Ti = turf_info[T]
		for(var/dir in cardinal)
			var/turf/AT = get_step(T,dir)
			if(!(AT in turfs))
				return
			if(!(AT in turf_info))
				UpdateTurf(AT, no_adjacent=1)
			var/surprise_turf_info/ATi = turf_info[AT]
			// By-Ref so shit gets updated.
			ATi.adjacents["[reverse_direction(dir)]"]=Ti.types


	// Common stuff


	proc/IsWall(var/turf/T)
		var/surprise_turf_info/sti = GetTurfInfo(T)
		return sti.turf_type == TURF_WALL

	proc/IsFloor(var/turf/T)
		var/surprise_turf_info/sti = GetTurfInfo(T)
		return sti.turf_type == TURF_FLOOR

	// Are we adjacent to an object of this type?
	proc/AdjacentToType(var/turf/T,var/adjacent_type)
		var/surprise_turf_info/sti = GetTurfInfo(T)
		return locate(adjacent_type) in sti.GetAdjacentTypes()

	// Same, but for walls/floors
	proc/AdjacentToTurfType(var/turf/T,var/turfType)
		for(var/dir in cardinal)
			var/turf/AT = get_step(T,dir)
			var/surprise_turf_info/info = GetTurfInfo(AT)
			if(!info)
				continue
			if(info.turf_type == turfType)
				return 1
		return 0


// For room layouts.
/layout_rule
	var/mining_surprise/root
	var/surprise_room/room

	// What to place if true
	var/placetype=null

	var/min_to_place=0 // Force placement at ALL candidates.
	var/max_to_place=0 // 0 = max amount of ALL candidates.

	var/placed_times=0

	var/list/decorations=list() // types, empty for no decorations

	var/flags = 0

	New(var/mining_surprise/_root,var/surprise_room/_room)
		root=_root
		room=_room

	// Called in Evaluate
	proc/Plop(var/turf/T)
		new placetype(T)
		placed_times++
		room.AddTypeToTurf(T,placetype)
		if(decorations.len)
			var/decoration = pickweight(decorations)
			new decoration(T)
			room.AddTypeToTurf(T,decoration)

	// Return 1 if we Plop()'d something.
	// Return 0 if we didn't or something went wrong.
	proc/Evaluate()
		var/list/candidates=GetCandidates()
		if(candidates.len==0)
			return 0
		if(max_to_place<=0)
			max_to_place=candidates.len
		var/n=candidates.len
		if(min_to_place>0)
			n = min(candidates.len,rand(min_to_place,max_to_place))
		if(n==0)
			return 0
		for(var/i=0;i<n;i++)
			var/turf/T = candidates[1]
			candidates-=T
			Plop(T)

	// Return list of turfs.
	proc/GetCandidates()
		return list()

/layout_rule/place_adjacent
	// MUST be next to any of these.  Anywhere if not set.
	var/list/next_to=list(
		// type = list(NORTH,SOUTH,etc)
	)
	// MUST NOT be next to these.
	var/list/not_next_to=list(
		// type = list(NORTH,SOUTH,etc)
	)
	GetCandidates()
		// Organize next_to/not_next_to so it's easier to use.
		var/list/opt_nt[0]
		var/list/opt_nnt[0]
		var/list/candidates[0]
		for(var/dir in cardinal)
			var/di = "[dir]"
			if(!di in opt_nt)
				opt_nt[di]=list()
				opt_nnt[di]=list()
			for(var/t in next_to)
				if(dir in next_to[t])
					var/list/tl = opt_nt[di]
					tl |= t
			for(var/t in not_next_to)
				if(dir in not_next_to[t])
					var/list/tl = opt_nnt[di]
					tl |= t
		// Check each turf.
		for(var/turf/T in room.turfs)
			if(IsTurfCandidate(T,opt_nt,opt_nnt))
				candidates += T
		return candidates

	proc/IsTurfCandidate(var/turf/T,var/list/opt_nt,var/list/opt_nnt)
		var/surprise_turf_info/sti = room.GetTurfInfo(T)
		for(var/dir in cardinal)
			var/di = "[dir]"
			for(var/_type in sti.adjacents[di])
				if(_type in opt_nnt[di])
					return 0
				if(_type in opt_nt[di])
					return 1
		return 1

/mining_surprise
	var/name = "Hidden Complex"

	//: Types of floor to use
	var/list/floortypes[0]
	var/list/walltypes[0]
	var/list/spawntypes[0]
	var/list/fluffitems[0]

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
		for(var/turf/floor in room.turfs)
			if(floor.density) continue
			for(var/turf/T in floor.AdjacentTurfs())
				if(T in room.turfs)
					if(T.density) continue
					candidates|=T
					break

	proc/postProcessComplex()
		for(var/i=0;i<=rand(1,max_richness);i++)
			if(!candidates.len)
				return
			var/turf/T = pick(candidates)
			var/thing = pickweight(spawntypes)
			if(thing==null)
				continue
			new thing(T)
			candidates -= T
			message_admins("Goodie [thing] spawned at [formatJumpTo(T)]")

		for(var/i=0;i<=rand(5,10);i++)
			if(!candidates.len)
				return
			var/turf/T = pick(candidates)
			var/thing = pickweight(fluffitems)
			if(thing==null)
				continue
			new thing(T)

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
			room.turfs += T
			complex_area.contents += T
			var/surprise_turf_info/Ti = room.GetTurfInfo(T)
			Ti.turf_type=TURF_WALL

		for(var/turf/turf in floors)
			if(!(flags & CONTIGUOUS_FLOORS))
				floor_type=pickweight(floortypes)

			var/turf/T = new floor_type(turf)
			room.turfs += T
			complex_area.contents += T
			var/surprise_turf_info/Ti = room.GetTurfInfo(T)
			Ti.turf_type=TURF_FLOOR

		room.UpdateTurfs()

		postProcessRoom(room)

		rooms += room

		message_admins("Room spawned at [formatJumpTo(start_loc)]")

		return 1