/**
 * Base code for CONSTANT beams.  No more constant addition and removal of shit from the pool.
 *
 * Weapon beams are projectiles.  This is for emitters and IR tripwires.
 *
 * Instead of triggering a bullet_act constantly, beams just send a
 *  beam_connect(var/obj/effect/beam/B) to the "client" and a similar
 *  beam_disconnect(var/obj/effect/beam/B) when disconnected.
 *
 * Note: All /atoms automatically maintain a beams list, so you should
 *  only need to fuck with that.
 */

// Uncomment to spam console with debug info.
//#define BEAM_DEBUG

#define BEAM_DEL(x) del(x)

#ifdef BEAM_DEBUG
# warning SOME ASSHOLE FORGOT TO COMMENT BEAM_DEBUG BEFORE COMMITTING
# define beam_testing(x) testing(x)
#else
# define beam_testing(x)
#endif

/obj/effect/beam
	name = "beam"
	unacidable = 1//Just to be sure.
	anchored = 1
	density = 0

	var/def_zone=""
	var/damage=0
	var/damage_type=BURN

	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

	// The first beam object
	var/obj/effect/beam/master = null

	// Children (for cleanup)
	var/list/children = list()

	// The next beam in the chain
	var/obj/effect/beam/next = null

	// Who we eventually hit
	var/atom/movable/target = null

	var/max_range = INFINITY

	var/bumped=0
	var/stepped=0
	var/am_connector=0
	var/targetMoveKey=null // Key for the on_moved listener.
	var/targetDestroyKey=null // Key for the on_destroyed listener.
	var/targetContactLoc=null // Where we hit the target (used for target_moved)

	var/list/sources = list() // Whoever served in emitting this beam. Used in prisms to prevent infinite loops.

// Listener for /atom/movable/on_moved
/obj/effect/beam/proc/target_moved(var/list/args)
	if(master)
		beam_testing("Child got target_moved!  Feeding to master.")
		master.target_moved(args)
		return

	if(!targetMoveKey)
		beam_testing("Uh oh, got a target_moved when we weren't listening for one.")
		return

	var/turf/T = args["loc"]
	beam_testing("Target now at [T.x],[T.y],[T.z]")
	if(T != targetContactLoc && T != loc)
		beam_testing("Disconnecting: Target moved.")
		// Disconnect and re-emit.
		disconnect()

// Listener for /atom/on_destroyed
/obj/effect/beam/proc/target_destroyed(var/list/args)
	if(master)
		beam_testing("Child got target_destroyed!  Feeding to master.")
		master.target_destroyed(args)
		return

	if(!targetDestroyKey)
		beam_testing("Uh oh, got a target_destroyed when we weren't listening for one.")
		return

	beam_testing("\ref[src] Disconnecting: \ref[target] Target destroyed.")
	// Disconnect and re-emit.
	disconnect()

/obj/effect/beam/Bumped(var/atom/movable/AM)
	if(!master || !AM)
		return
	if(istype(AM, /obj/effect/beam) || !AM.density)
		return
	beam_testing("Bumped by [AM]")
	am_connector=1
	connect_to(AM)
	//BEAM_DEL(src)
	qdel(src)

/obj/effect/beam/proc/get_master()
	var/master_ref = "\ref[master]"
	beam_testing("\ref[src] [master ? "get_master is returning [master_ref]" : "get_master is returning ourselves."]")
	if(master)
		return master
	return src

/obj/effect/beam/proc/get_damage()
	return damage

/obj/effect/beam/proc/get_machine_underlay(var/mdir)
	return image(icon=icon, icon_state="[icon_state] underlay", dir=mdir)

/obj/effect/beam/proc/connect_to(var/atom/movable/AM)
	if(!AM)
		return
	var/obj/effect/beam/BM=get_master()
	if(BM.target == AM)
		return
	if(BM.target)
		beam_testing("\ref[BM] - Disconnecting [BM.target]: target changed.")
		BM.disconnect(0)
	AM.beam_connect(BM)
	BM.target=AM
	BM.targetMoveKey    = AM.on_moved.Add(BM,    "target_moved")
	BM.targetDestroyKey = AM.on_destroyed.Add(BM,"target_destroyed")
	BM.targetContactLoc = AM.loc
	beam_testing("\ref[BM] - Connected to [AM]")

/obj/effect/beam/blob_act()
	// Act like Crossed.
	// To do that, we need the blob.
	// Blob calls blob_act() twice:  Once (or so) on intent to expand, and finally on New().
	// We then use that second one to call Crossed().
	var/obj/effect/blob/B = locate() in loc
	if(B)
		Crossed(B)

/obj/effect/beam/proc/killKids()
	for(var/obj/effect/beam/child in children)
		if(child)
			//BEAM_DEL(child)
			children -= child
			qdel(child)
	children.len = 0

/obj/effect/beam/proc/disconnect(var/re_emit=1)
	var/obj/effect/beam/_master=get_master()
	if(_master.target)
		_master.target.on_moved.Remove(_master.targetMoveKey)
		_master.target.on_destroyed.Remove(_master.targetDestroyKey)
		_master.target.beam_disconnect(_master)
		_master.target=null
		_master.targetMoveKey=null
		_master.targetDestroyKey=null
		//if(_master.next)
		//	BEAM_DEL(_master.next)
		if(re_emit)
			_master.emit(sources)

/obj/effect/beam/Crossed(atom/movable/AM as mob|obj)
	beam_testing("Crossed by [AM]")
	if(!master || !AM)
		beam_testing(" returning (!AM || !master)")
		return

	if(istype(AM, /obj/effect/beam) || (!AM.density && !istype(AM, /obj/effect/blob)))
		beam_testing(" returning (is beam or not dense)")
		return

	if(master.target)
		disconnect(0)

	beam_testing(" Connecting!")
	am_connector=1
	connect_to(AM)
	//BEAM_DEL(src)
	qdel(src)

/obj/effect/beam/proc/HasSource(var/atom/source)
	return source in sources

/**
 * Create and emit the beam in the desired direction.
 */
/obj/effect/beam/proc/emit(var/spawn_by, var/_range=-1)
	if(istype(spawn_by,/list))
		sources=spawn_by
	else
		sources.Add(spawn_by)

	if(_range==-1)
#ifdef BEAM_DEBUG
		var/str_sources=text2list(sources,", ") // This will not work as an embedded statement.
		beam_testing("\ref[src] - emit(), sources=[str_sources]")
#endif
		_range=max_range

	if(next && next.loc)
		next.emit(sources,_range-1)
		return

	if(!loc)
		//BEAM_DEL(src)
		qdel(src)
		return

	if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
		//BEAM_DEL(src)
		qdel(src)
		return

	// If we're master, we're actually invisible, and we're on the same tile as the machine.
	// TODO: underlay firing machine.
	invisibility=0
	if(!master && !stepped)
		stepped=1
		invisibility=101

	if(!stepped)
		// Reset bumped
		bumped=0

		step(src, dir) // Move.

		if(bumped)
			//BEAM_DEL(src)
			qdel(src)
			return

		stepped=1

		if(_range-- < 1)
			//BEAM_DEL(src)
			qdel(src)
			return

	update_icon()

	next = spawn_child()
	next.emit(sources,_range)

/obj/effect/beam/proc/spawn_child()
	var/obj/effect/beam/B = new type(src.loc)
	B.dir=dir
	B.master = get_master()
	if(B.master != B)
		B.master.children.Add(B)
	return B

/obj/effect/beam/Bump(var/atom/A as mob|obj|turf|area)
	if(!master)
		return
	bumped = 1
	if(A)
		beam_testing("\ref[get_master()] - Bumped [A]!")
		connect_to(A)
		am_connector=1 // Prevents disconnecting after stepping into target.
	return 1

/obj/effect/beam/emitter/Destroy()
	if(sources && sources.len)
		for(var/obj/machinery/power/emitter/E in sources)
			if(E.beam == src)
				E.beam = null
		for(var/obj/machinery/prism/P in sources)
			if(P.beam == src)
				P.beam = null
		for(var/obj/machinery/mirror/M in sources)
			for(var/thing in M.emitted_beams)
				if(thing == src)
					M.emitted_beams -= thing
	..()

/obj/effect/beam/Destroy()
	if(target)
		if(target.beams)
			target.beams -= src
	for(var/obj/machinery/mirror/M in mirror_list)
		if(!M)
			continue
		if(src in M.beams)
			M.beams -= src
	for(var/obj/machinery/field_generator/F in field_gen_list)
		if(!F)
			continue
		if(src in F.beams)
			F.beams -= src
	for(var/obj/machinery/prism/P in prism_list)
		if(src == P.beam)
			P.beam = null
		if(src in P.beams)
			P.beams -= src
	for(var/obj/machinery/power/photocollector/PC in photocollector_list)
		if(src in PC.beams)
			PC.beams -= src
	if(!am_connector && !master)
		beam_testing("\ref[get_master()] - Disconnecting (deleted)")
		disconnect(0)
	if(master)
		if(master.target && master.target.beams)
			master.target.beams -= src
		for(var/obj/effect/beam/B in master.children)
			if(B.next == src)
				B.next = null
		if(master.next == src)
			master.next = null
		master.children.Remove(src)
		master = null
	else if(children && children.len)
		killKids()
	if(next)
		//BEAM_DEL(next)
		qdel(next)
		next=null
	..()

/obj/effect/beam/singularity_pull()
	return