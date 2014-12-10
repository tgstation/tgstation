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

//#define BEAM_TESTING(x) testing(x) // Uncomment to spam console with debug info.
#define BEAM_TESTING(x) // Uncomment to NOT spam console with debug info.

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
		BEAM_TESTING("Child got target_moved!  Feeding to master.")
		master.target_moved(args)
		return

	if(!targetMoveKey)
		BEAM_TESTING("Uh oh, got a target_moved when we weren't listening for one.")
		return

	var/turf/T = args["loc"]
	BEAM_TESTING("Target now at [T.x],[T.y],[T.z]")
	if(T != targetContactLoc)
		BEAM_TESTING("Disconnecting: Target moved.")
		// Disconnect and re-emit.
		disconnect()

// Listener for /atom/on_destroyed
/obj/effect/beam/proc/target_destroyed(var/list/args)
	if(master)
		BEAM_TESTING("Child got target_destroyed!  Feeding to master.")
		master.target_moved(args)
		return

	if(!targetDestroyKey)
		BEAM_TESTING("Uh oh, got a target_destroyed when we weren't listening for one.")
		return

	BEAM_TESTING("Disconnecting: Target destroyed.")
	// Disconnect and re-emit.
	disconnect()

/obj/effect/beam/Bumped(var/atom/movable/AM)
	if(!master || !AM)
		return
	if(istype(AM, /obj/effect/beam) || !AM.density)
		return
	BEAM_TESTING("Bumped by [AM]")
	am_connector=1
	connect_to(AM)
	qdel(src)

/obj/effect/beam/proc/get_master()
	if(master)
		return master
	return src

/obj/effect/beam/proc/get_damage()
	return damage

/obj/effect/beam/proc/connect_to(var/atom/movable/AM)
	if(!AM)
		return
	var/obj/effect/beam/BM=get_master()
	if(BM.target == AM)
		return
	if(BM.target)
		BEAM_TESTING("\ref[BM] - Disconnecting [BM.target]: target changed.")
		BM.disconnect(0)
	AM.beam_connect(BM)
	BM.target=AM
	BM.targetMoveKey    = AM.on_moved.Add(BM,    "target_moved")
	BM.targetDestroyKey = AM.on_destroyed.Add(BM,"target_destroyed")
	BM.targetContactLoc = AM.loc
	BEAM_TESTING("\ref[BM] - Connected to [AM] BM=(TMK=[BM.targetMoveKey], TCL=[BM.targetContactLoc]),src=(TMK=[src.targetMoveKey], TCL=[src.targetContactLoc])")

/obj/effect/beam/proc/killKids()
	for(var/obj/effect/beam/child in children)
		if(child)
			qdel(child)
	children.Cut()

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
		//	qdel(_master.next)
		if(re_emit)
			_master.emit(sources)

/obj/effect/beam/Crossed(atom/movable/AM as mob|obj)
	if(!master || !AM)
		return

	if(istype(AM, /obj/effect/beam) || !AM.density)
		return

	BEAM_TESTING("Crossed by [AM]")
	am_connector=1
	connect_to(AM)
	qdel(src)

/obj/effect/beam/proc/HasSource(var/atom/source)
	return source in sources

/**
 * Create and emit the beam in the desired direction.
 */
/obj/effect/beam/proc/emit(var/spawn_by, var/_range=-1)
	sources=list(spawn_by)

	if(_range==-1)
		BEAM_TESTING("\ref[src] - emit(), source=[source]")
		_range=max_range

	if(next && next.loc)
		next.emit(sources,_range-1)
		return

	if(!loc)
		qdel(src)
		return

	if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
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
			qdel(src)
			return

		stepped=1

		if(_range-- < 1)
			qdel(src)
			return

	update_icon()

	next = spawn_child()
	next.emit(sources,_range)

/obj/effect/beam/proc/spawn_child()
	var/obj/effect/beam/B = new type(src.loc)
	B.dir=dir
	B.master = get_master()
	B.master.children.Add(next)
	return B

/obj/effect/beam/Bump(var/atom/A as mob|obj|turf|area)
	if(!master)
		return
	bumped = 1
	if(A)
		BEAM_TESTING("\ref[get_master()] - Bumped [A]!")
		connect_to(A)
		am_connector=1 // Prevents disconnecting after stepping into target.
	return 1

/obj/effect/beam/Destroy()
	if(!am_connector && !master)
		BEAM_TESTING("\ref[get_master()] - Disconnecting (qdel)")
		disconnect(0)
	if(master)
		master.children.Remove(src)
	if(next)
		qdel(next)
		next=null
	..()

#undef BEAM_TESTING