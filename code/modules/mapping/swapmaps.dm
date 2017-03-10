

/*
	SwapMaps library by Lummox JR
	developed for digitalBYOND
	http://www.digitalbyond.org

	Version 2.1

	The purpose of this library is to make it easy for authors to swap maps
	in and out of their game using savefiles. Swapped-out maps can be
	transferred between worlds for an MMORPG, sent to the client, etc.
	This is facilitated by the use of a special datum and a global list.

	Uses of swapmaps:

	- Temporary battle arenas
	- House interiors
	- Individual custom player houses
	- Virtually unlimited terrain
	- Sharing maps between servers running different instances of the same
	  game
	- Loading and saving pieces of maps for reusable room templates
 */

/*
	User Interface:

	VARS:

	swapmaps_iconcache
		An associative list of icon files with names, like
		'player.dmi' = "player"
	swapmaps_mode
		This must be set at runtime, like in world/New().

		SWAPMAPS_SAV	0	(default)
			Uses .sav files for raw /savefile output.
		SWAPMAPS_TEXT	1
			Uses .txt files via ExportText() and ImportText(). These maps
			are easily editable and appear to take up less space in the
			current version of BYOND.

	PROCS:

	SwapMaps_Find(id)
		Find a map by its id
	SwapMaps_Load(id)
		Load a map by its id
	SwapMaps_Save(id)
		Save a map by its id (calls swapmap.Save())
	SwapMaps_Unload(id)
		Save and unload a map by its id (calls swapmap.Unload())
	SwapMaps_Save_All()
		Save all maps
	SwapMaps_DeleteFile(id)
		Delete a map file
	SwapMaps_CreateFromTemplate(id)
		Create a new map by loading another map to use as a template.
		This map has id==src and will not be saved. To make it savable,
		  change id with swapmap.SetID(newid).
	SwapMaps_LoadChunk(id,turf/locorner)
		Load a swapmap as a "chunk", at a specific place. A new datum is
		created but it's not added to the list of maps to save or unload.
		The new datum can be safely deleted without affecting the turfs
		it loaded. The purpose of this is to load a map file onto part of
		another swapmap or an existing part of the world.
		locorner is the corner turf with the lowest x,y,z values.
	SwapMaps_SaveChunk(id,turf/corner1,turf/corner2)
		Save a piece of the world as a "chunk". A new datum is created
		for the chunk, but it can be deleted without destroying any turfs.
		The chunk file can be reloaded as a swapmap all its own, or loaded
		via SwapMaps_LoadChunk() to become part of another map.
	SwapMaps_GetSize(id)
		Return a list corresponding to the x,y,z sizes of a map file,
		without loading the map.
		Returns null if the map is not found.
	SwapMaps_AddIconToCache(name,icon)
		Cache an icon file by name for space-saving storage

	swapmap.New(id,x,y,z)
		Create a new map; specify id, width (x), height (y), and
		 depth (z)
		Default size is world.maxx,world.maxy,1
	swapmap.New(id,turf1,turf2)
		Create a new map; specify id and 2 corners
		This becomes a /swapmap for one of the compiled-in maps, for
		 easy saving.
	swapmap.New()
		Create a new map datum, but does not allocate space or assign an
		 ID (used for loading).
	swapmap.Del()
		Deletes a map but does not save
	swapmap.Save()
		Saves to map_[id].sav
		Maps with id==src are not saved.
	swapmap.Unload()
		Saves the map and then deletes it
		Maps with id==src are not saved.
	swapmap.SetID(id)
		Change the map's id and make changes to the lookup list
	swapmap.AllTurfs(z)
		Returns a block of turfs encompassing the entire map, or on just
		 one z-level
		z is in world coordinates; it is optional
	swapmap.Contains(turf/T)
		Returns nonzero if T is inside the map's boundaries.
		Also works for objs and mobs, but the proc is not area-safe.
	swapmap.InUse()
		Returns nonzero if a mob with a key is within the map's
		 boundaries.
	swapmap.LoCorner(z=z1)
		Returns locate(x1,y1,z), where z=z1 if none is specified.
	swapmap.HiCorner(z=z2)
		Returns locate(x2,y2,z), where z=z2 if none is specified.
	swapmap.BuildFilledRectangle(turf/corner1,turf/corner2,item)
		Builds a filled rectangle of item from one corner turf to the
		 other, on multiple z-levels if necessary. The corners may be
		 specified in any order.
		item is a type path like /turf/closed/wall or /obj/barrel{full=1}.
	swapmap.BuildRectangle(turf/corner1,turf/corner2,item)
		Builds an unfilled rectangle of item from one corner turf to
		 the other, on multiple z-levels if necessary.
	swapmap.BuildInTurfs(list/turfs,item)
		Builds item on all of the turfs listed. The list need not
		 contain only turfs, or even only atoms.
 */

swapmap
	var/id		// a string identifying this map uniquely
	var/x1		// minimum x,y,z coords
	var/y1
	var/z1
	var/x2		// maximum x,y,z coords (also used as width,height,depth until positioned)
	var/y2
	var/z2
	var/tmp/locked	// don't move anyone to this map; it's saving or loading
	var/tmp/mode	// save as text-mode
	var/ischunk		// tells the load routine to load to the specified location

	New(_id,x,y,z)
		if(isnull(_id)) return
		id=_id
		mode=swapmaps_mode
		if(isturf(x) && isturf(y))
			/*
				Special format: Defines a map as an existing set of turfs;
				this is useful for saving a compiled map in swapmap format.
				Because this is a compiled-in map, its turfs are not deleted
				when the datum is deleted.
			 */
			x1=min(x:x,y:x);x2=max(x:x,y:x)
			y1=min(x:y,y:y);y2=max(x:y,y:y)
			z1=min(x:z,y:z);z2=max(x:z,y:z)
			InitializeSwapMaps()
			if(z2>swapmaps_compiled_maxz ||\
			   y2>swapmaps_compiled_maxy ||\
			   x2>swapmaps_compiled_maxx)
				qdel(src)
			return
		x2=x?(x):world.maxx
		y2=y?(y):world.maxy
		z2=z?(z):1
		AllocateSwapMap()

	Destroy()
		// a temporary datum for a chunk can be deleted outright
		// for others, some cleanup is necessary
		if(!ischunk)
			swapmaps_loaded-=src
			swapmaps_byname-=id
			if(z2>swapmaps_compiled_maxz ||\
			   y2>swapmaps_compiled_maxy ||\
			   x2>swapmaps_compiled_maxx)
				var/list/areas=new
				for(var/atom/A in block(locate(x1,y1,z1),locate(x2,y2,z2)))
					for(var/obj/O in A) qdel(O)
					for(var/mob/M in A)
						if(!M.key) qdel(M)
						else M.loc=null
					areas[A.loc]=null
					qdel(A)
				// delete areas that belong only to this map
				for(var/area/a in areas)
					if(a && !a.contents.len) qdel(a)
				if(x2>=world.maxx || y2>=world.maxy || z2>=world.maxz) CutXYZ()
				qdel(areas)
		..()
		return QDEL_HINT_HARDDEL_NOW

	/*
		Savefile format:
		map
		  id
		  x		// size, not coords
		  y
		  z
		  areas	// list of areas, not including default
		  [each z; 1 to depth]
		    [each y; 1 to height]
		      [each x; 1 to width]
		        type	// of turf
		        AREA    // if non-default; saved as a number (index into areas list)
		        vars    // all other changed vars
	 */
	Write(savefile/S)
		var/x
		var/y
		var/z
		var/n
		var/list/areas
		var/area/defarea=locate(world.area)
		if(!defarea) defarea=new world.area
		areas=list()
		for(var/turf/T in block(locate(x1,y1,z1),locate(x2,y2,z2)))
			areas[T.loc]=null
		for(n in areas)	// quickly eliminate associations for smaller storage
			areas-=n
			areas+=n
		areas-=defarea
		InitializeSwapMaps()
		locked=1
		S["id"] << id
		S["z"] << z2-z1+1
		S["y"] << y2-y1+1
		S["x"] << x2-x1+1
		S["areas"] << areas
		for(n in 1 to areas.len) areas[areas[n]]=n
		var/oldcd=S.cd
		for(z in z1 to z2)
			S.cd="[z-z1+1]"
			for(y in y1 to y2)
				S.cd="[y-y1+1]"
				for(x in x1 to x2)
					S.cd="[x-x1+1]"
					var/turf/T=locate(x,y,z)
					S["type"] << T.type
					if(T.loc!=defarea) S["AREA"] << areas[T.loc]
					T.Write(S)
					S.cd=".."
				S.cd=".."
			sleep()
			S.cd=oldcd
		locked=0
		qdel(areas)

	Read(savefile/S,_id,turf/locorner)
		var/x
		var/y
		var/z
		var/n
		var/list/areas
		var/area/defarea=locate(world.area)
		id=_id
		if(locorner)
			ischunk=1
			x1=locorner.x
			y1=locorner.y
			z1=locorner.z
		if(!defarea) defarea=new world.area
		if(!_id)
			S["id"] >> id
		else
			var/dummy
			S["id"] >> dummy
		S["z"] >> z2		// these are depth,
		S["y"] >> y2		//   		 height,
		S["x"] >> x2		//			 width
		S["areas"] >> areas
		locked=1
		AllocateSwapMap()	// adjust x1,y1,z1 - x2,y2,z2 coords
		var/oldcd=S.cd
		for(z in z1 to z2)
			S.cd="[z-z1+1]"
			for(y in y1 to y2)
				S.cd="[y-y1+1]"
				for(x in x1 to x2)
					S.cd="[x-x1+1]"
					var/tp
					S["type"]>>tp
					var/turf/T=locate(x,y,z)
					T.loc.contents-=T
					T=new tp(locate(x,y,z))
					if("AREA" in S.dir)
						S["AREA"]>>n
						var/area/A=areas[n]
						A.contents+=T
					else defarea.contents+=T
					// clear the turf
					for(var/obj/O in T) qdel(O)
					for(var/mob/M in T)
						if(!M.key) qdel(M)
						else M.loc=null
					// finish the read
					T.Read(S)
					S.cd=".."
				S.cd=".."
			sleep()
			S.cd=oldcd
		locked=0
		qdel(areas)

	/*
		Find an empty block on the world map in which to load this map.
		If no space is found, increase world.maxz as necessary. (If the
		map is greater in x,y size than the current world, expand
		world.maxx and world.maxy too.)

		Ignore certain operations if loading a map as a chunk. Use the
		x1,y1,z1 position for it, and *don't* count it as a loaded map.
	 */
	proc/AllocateSwapMap()
		InitializeSwapMaps()
		world.maxx=max(x2,world.maxx)	// stretch x/y if necessary
		world.maxy=max(y2,world.maxy)
		if(!ischunk)
			if(world.maxz<=swapmaps_compiled_maxz)
				z1=swapmaps_compiled_maxz+1
				x1=1;y1=1
			else
				var/list/l=ConsiderRegion(1,1,world.maxx,world.maxy,swapmaps_compiled_maxz+1)
				x1=l[1]
				y1=l[2]
				z1=l[3]
				qdel(l)
		x2+=x1-1
		y2+=y1-1
		z2+=z1-1
		world.maxz=max(z2,world.maxz)	// stretch z if necessary
		if(!ischunk)
			swapmaps_loaded[src]=null
			swapmaps_byname[id]=src

	proc/ConsiderRegion(X1,Y1,X2,Y2,Z1,Z2)
		while(1)
			var/nextz=0
			var/swapmap/M
			for(M in swapmaps_loaded)
				if(M.z2<Z1 || (Z2 && M.z1>Z2) || M.z1>=Z1+z2 ||\
				   M.x1>X2 || M.x2<X1 || M.x1>=X1+x2 ||\
				   M.y1>Y2 || M.y2<Y1 || M.y1>=Y1+y2) continue
				// look for sub-regions with a defined ceiling
				var/nz2=Z2?(Z2):Z1+z2-1+M.z2-M.z1
				if(M.x1>=X1+x2)
					.=ConsiderRegion(X1,Y1,M.x1-1,Y2,Z1,nz2)
					if(.) return
				else if(M.x2<=X2-x2)
					.=ConsiderRegion(M.x2+1,Y1,X2,Y2,Z1,nz2)
					if(.) return
				if(M.y1>=Y1+y2)
					.=ConsiderRegion(X1,Y1,X2,M.y1-1,Z1,nz2)
					if(.) return
				else if(M.y2<=Y2-y2)
					.=ConsiderRegion(X1,M.y2+1,X2,Y2,Z1,nz2)
					if(.) return
				nextz=nextz?min(nextz,M.z2+1):(M.z2+1)
			if(!M)
				/* If nextz is not 0, then at some point there was an overlap that
				   could not be resolved by using an area to the side */
				if(nextz) Z1=nextz
				if(!nextz || (Z2 && Z2-Z1+1<z2))
					return (!Z2 || Z2-Z1+1>=z2)?list(X1,Y1,Z1):null
				X1=1;X2=world.maxx
				Y1=1;Y2=world.maxy

	proc/CutXYZ()
		var/mx=swapmaps_compiled_maxx
		var/my=swapmaps_compiled_maxy
		var/mz=swapmaps_compiled_maxz
		for(var/swapmap/M in swapmaps_loaded)	// may not include src
			mx=max(mx,M.x2)
			my=max(my,M.y2)
			mz=max(mz,M.z2)
		world.maxx=mx
		world.maxy=my
		world.maxz=mz

	// save and delete
	proc/Unload()
		Save()
		qdel(src)

	proc/Save()
		if(id==src) return 0
		var/savefile/S=mode?(new):new("map_[id].sav")
		S << src
		while(locked) sleep(1)
		if(mode)
			fdel("map_[id].txt")
			S.ExportText("/","map_[id].txt")
		return 1

	// this will not delete existing savefiles for this map
	proc/SetID(newid)
		swapmaps_byname-=id
		id=newid
		swapmaps_byname[id]=src

	proc/AllTurfs(z)
		if(isnum(z) && (z<z1 || z>z2)) return null
		return block(LoCorner(z),HiCorner(z))

	// this could be safely called for an obj or mob as well, but
	// probably not an area
	proc/Contains(turf/T)
		return (T && T.x>=x1 && T.x<=x2\
		          && T.y>=y1 && T.y<=y2\
		          && T.z>=z1 && T.z<=z2)

	proc/InUse()
		for(var/turf/T in AllTurfs())
			for(var/mob/M in T) if(M.key) return 1

	proc/LoCorner(z=z1)
		return locate(x1,y1,z)
	proc/HiCorner(z=z2)
		return locate(x2,y2,z)

	/*
		Build procs: Take 2 turfs as corners, plus an item type.
		An item may be like:

		/turf/closed/wall
		/obj/fence{icon_state="iron"}
	 */
	proc/BuildFilledRectangle(turf/T1,turf/T2,item)
		if(!Contains(T1) || !Contains(T2)) return
		var/turf/T=T1
		// pick new corners in a block()-friendly form
		T1=locate(min(T1.x,T2.x),min(T1.y,T2.y),min(T1.z,T2.z))
		T2=locate(max(T.x,T2.x),max(T.y,T2.y),max(T.z,T2.z))
		for(T in block(T1,T2)) new item(T)

	proc/BuildRectangle(turf/T1,turf/T2,item)
		if(!Contains(T1) || !Contains(T2)) return
		var/turf/T=T1
		// pick new corners in a block()-friendly form
		T1=locate(min(T1.x,T2.x),min(T1.y,T2.y),min(T1.z,T2.z))
		T2=locate(max(T.x,T2.x),max(T.y,T2.y),max(T.z,T2.z))
		if(T2.x-T1.x<2 || T2.y-T1.y<2) BuildFilledRectangle(T1,T2,item)
		else
			//for(T in block(T1,T2)-block(locate(T1.x+1,T1.y+1,T1.z),locate(T2.x-1,T2.y-1,T2.z)))
			for(T in block(T1,locate(T2.x,T1.y,T2.z))) new item(T)
			for(T in block(locate(T1.x,T2.y,T1.z),T2)) new item(T)
			for(T in block(locate(T1.x,T1.y+1,T1.z),locate(T1.x,T2.y-1,T2.z))) new item(T)
			for(T in block(locate(T2.x,T1.y+1,T1.z),locate(T2.x,T2.y-1,T2.z))) new item(T)

	/*
		Supplementary build proc: Takes a list of turfs, plus an item
		type. Actually the list doesn't have to be just turfs.
	 */
	proc/BuildInTurfs(list/turfs,item)
		for(var/T in turfs) new item(T)

atom
	Write(savefile/S)
		for(var/V in vars-"x"-"y"-"z"-"contents"-"icon"-"overlays"-"underlays")
			if(issaved(vars[V]))
				if(vars[V]!=initial(vars[V])) S[V]<<vars[V]
				else S.dir.Remove(V)
		if(icon!=initial(icon))
			if(swapmaps_iconcache && swapmaps_iconcache[icon])
				S["icon"]<<swapmaps_iconcache[icon]
			else S["icon"]<<icon
		// do not save mobs with keys; do save other mobs
		var/mob/M
		for(M in src) if(M.key) break
		if(overlays.len) S["overlays"]<<overlays
		if(underlays.len) S["underlays"]<<underlays
		if(contents.len && !isarea(src))
			var/list/l=contents
			if(M)
				l=l.Copy()
				for(M in src) if(M.key) l-=M
			if(l.len) S["contents"]<<l
			if(l!=contents) qdel(l)
	Read(savefile/S)
		var/list/l
		if(contents.len) l=contents
		..()
		// if the icon was a text string, it would not have loaded properly
		// replace it from the cache list
		if(!icon && ("icon" in S.dir))
			var/ic
			S["icon"]>>ic
			if(istext(ic)) icon=swapmaps_iconcache[ic]
		if(l && contents!=l)
			contents+=l
			qdel(l)


// set this up (at runtime) as follows:
// list(\
//     'player.dmi'="player",\
//     'monster.dmi'="monster",\
//     ...
//     'item.dmi'="item")
var/list/swapmaps_iconcache

// preferred mode; sav or text
var/const/SWAPMAPS_SAV=0
var/const/SWAPMAPS_TEXT=1
var/swapmaps_mode=SWAPMAPS_SAV

var/swapmaps_compiled_maxx
var/swapmaps_compiled_maxy
var/swapmaps_compiled_maxz
var/swapmaps_initialized
var/swapmaps_loaded
var/swapmaps_byname

/proc/InitializeSwapMaps()
	if(swapmaps_initialized) return
	swapmaps_initialized=1
	swapmaps_compiled_maxx=world.maxx
	swapmaps_compiled_maxy=world.maxy
	swapmaps_compiled_maxz=world.maxz
	swapmaps_loaded=list()
	swapmaps_byname=list()
	if(swapmaps_iconcache)
		for(var/V in swapmaps_iconcache)
			// reverse-associate everything
			// so you can look up an icon file by name or vice-versa
			swapmaps_iconcache[swapmaps_iconcache[V]]=V

/proc/SwapMaps_AddIconToCache(name,icon)
	if(!swapmaps_iconcache) swapmaps_iconcache=list()
	swapmaps_iconcache[name]=icon
	swapmaps_iconcache[icon]=name

/proc/SwapMaps_Find(id)
	InitializeSwapMaps()
	return swapmaps_byname[id]

/proc/SwapMaps_Load(id)
	InitializeSwapMaps()
	var/swapmap/M=swapmaps_byname[id]
	if(!M)
		var/savefile/S
		var/text=0
		if(swapmaps_mode==SWAPMAPS_TEXT && fexists("map_[id].txt"))
			text=1
		else if(fexists("map_[id].sav"))
			S=new("map_[id].sav")
		else if(swapmaps_mode!=SWAPMAPS_TEXT && fexists("map_[id].txt"))
			text=1
		else return	// no file found
		if(text)
			S=new
			S.ImportText("/",file("map_[id].txt"))
		S >> M
		while(M.locked) sleep(1)
		M.mode=text
	return M

/proc/SwapMaps_Save(id)
	InitializeSwapMaps()
	var/swapmap/M=swapmaps_byname[id]
	if(M) M.Save()
	return M

/proc/SwapMaps_Save_All()
	InitializeSwapMaps()
	for(var/swapmap/M in swapmaps_loaded)
		if(M) M.Save()

/proc/SwapMaps_Unload(id)
	InitializeSwapMaps()
	var/swapmap/M=swapmaps_byname[id]
	if(!M) return	// return silently from an error
	M.Unload()
	return 1

/proc/SwapMaps_DeleteFile(id)
	fdel("map_[id].sav")
	fdel("map_[id].txt")

/proc/SwapMaps_CreateFromTemplate(template_id)
	var/swapmap/M=new
	var/savefile/S
	var/text=0
	if(swapmaps_mode==SWAPMAPS_TEXT && fexists("map_[template_id].txt"))
		text=1
	else if(fexists("map_[template_id].sav"))
		S=new("map_[template_id].sav")
	else if(swapmaps_mode!=SWAPMAPS_TEXT && fexists("map_[template_id].txt"))
		text=1
	else
		log_world("SwapMaps error in SwapMaps_CreateFromTemplate(): map_[template_id] file not found.")
		return
	if(text)
		S=new
		S.ImportText("/",file("map_[template_id].txt"))
	/*
		This hacky workaround is needed because S >> M will create a brand new
		M to fill with data. There's no way to control the Read() process
		properly otherwise. The //.0 path should always match the map, however.
	 */
	S.cd="//.0"
	M.Read(S,M)
	M.mode=text
	while(M.locked) sleep(1)
	return M

/proc/SwapMaps_LoadChunk(chunk_id,turf/locorner)
	var/swapmap/M=new
	var/savefile/S
	var/text=0
	if(swapmaps_mode==SWAPMAPS_TEXT && fexists("map_[chunk_id].txt"))
		text=1
	else if(fexists("map_[chunk_id].sav"))
		S=new("map_[chunk_id].sav")
	else if(swapmaps_mode!=SWAPMAPS_TEXT && fexists("map_[chunk_id].txt"))
		text=1
	else
		log_world("SwapMaps error in SwapMaps_LoadChunk(): map_[chunk_id] file not found.")
		return
	if(text)
		S=new
		S.ImportText("/",file("map_[chunk_id].txt"))
	/*
		This hacky workaround is needed because S >> M will create a brand new
		M to fill with data. There's no way to control the Read() process
		properly otherwise. The //.0 path should always match the map, however.
	 */
	S.cd="//.0"
	M.Read(S,M,locorner)
	while(M.locked) sleep(1)
	qdel(M)
	return 1

/proc/SwapMaps_SaveChunk(chunk_id,turf/corner1,turf/corner2)
	if(!corner1 || !corner2)
		log_world("SwapMaps error in SwapMaps_SaveChunk():")
		if(!corner1)
			log_world("  corner1 turf is null")
		if(!corner2)
			log_world("  corner2 turf is null")
		return
	var/swapmap/M=new
	M.id=chunk_id
	M.ischunk=1		// this is a chunk
	M.x1=min(corner1.x,corner2.x)
	M.y1=min(corner1.y,corner2.y)
	M.z1=min(corner1.z,corner2.z)
	M.x2=max(corner1.x,corner2.x)
	M.y2=max(corner1.y,corner2.y)
	M.z2=max(corner1.z,corner2.z)
	M.mode=swapmaps_mode
	M.Save()
	while(M.locked) sleep(1)
	qdel(M)
	return 1

/proc/SwapMaps_GetSize(id)
	var/savefile/S
	var/text=0
	if(swapmaps_mode==SWAPMAPS_TEXT && fexists("map_[id].txt"))
		text=1
	else if(fexists("map_[id].sav"))
		S=new("map_[id].sav")
	else if(swapmaps_mode!=SWAPMAPS_TEXT && fexists("map_[id].txt"))
		text=1
	else
		log_world("SwapMaps error in SwapMaps_GetSize(): map_[id] file not found.")
		return
	if(text)
		S=new
		S.ImportText("/",file("map_[id].txt"))
	/*
		The //.0 path should always be the map. There's no other way to
		read this data.
	 */
	S.cd="//.0"
	var/x
	var/y
	var/z
	S["x"] >> x
	S["y"] >> y
	S["z"] >> z
	return list(x,y,z)
