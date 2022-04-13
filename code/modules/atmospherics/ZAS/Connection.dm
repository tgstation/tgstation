#define CONNECTION_DIRECT 2
#define CONNECTION_SPACE 4
#define CONNECTION_INVALID 8

/*

Overview:
	Connections are made between turfs by SSair.connect(). They represent a single point where two zones converge.

Class Vars:
	A - Always a simulated turf.
	B - A simulated or unsimulated turf.

	zoneA - The archived zone of A. Used to check that the zone hasn't changed.
	zoneB - The archived zone of B. May be null in case of unsimulated connections.

	edge - Stores the edge this connection is in. Can reference an edge that is no longer processed
		   after this connection is removed, so make sure to check edge.coefficient > 0 before re-adding it.

Class Procs:

	mark_direct()
		Marks this connection as direct. Does not update the edge.
		Called when the connection is made and there are no doors between A and B.
		Also called by update() as a correction.

	mark_indirect()
		Unmarks this connection as direct. Does not update the edge.
		Called by update() as a correction.

	mark_space()
		Marks this connection as unsimulated. Updating the connection will check the validity of this.
		Called when the connection is made.
		This will not be called as a correction, any connections failing a check against this mark are erased and rebuilt.

	direct()
		Returns 1 if no doors are in between A and B.

	valid()
		Returns 1 if the connection has not been erased.

	erase()
		Called by update() and connection_manager/erase_all().
		Marks the connection as erased and removes it from its edge.

	update()
		Called by connection_manager/update_all().
		Makes numerous checks to decide whether the connection is still valid. Erases it automatically if not.

*/

/connection/var/turf/simulated/A
/connection/var/turf/simulated/B
/connection/var/zone/zoneA
/connection/var/zone/zoneB

/connection/var/connection_edge/edge

/connection/var/state = 0

/connection/New(turf/simulated/A, turf/simulated/B)
	#ifdef ZASDBG
	ASSERT(SSair.has_valid_zone(A))
	//ASSERT(SSair.has_valid_zone(B))
	#endif
	src.A = A
	src.B = B
	zoneA = A.zone
	if(!istype(B))
		mark_space()
		edge = SSair.get_edge(A.zone,B)
		edge.add_connection(src)
	else
		zoneB = B.zone
		edge = SSair.get_edge(A.zone,B.zone)
		edge.add_connection(src)

/connection/proc/mark_direct()
	if(!direct())
		state |= CONNECTION_DIRECT
		edge.direct++
//	log_debug("Marked direct.")

/connection/proc/mark_indirect()
	if(direct())
		state &= ~CONNECTION_DIRECT
		edge.direct--
//	log_debug("Marked indirect.")

/connection/proc/mark_space()
	state |= CONNECTION_SPACE

/connection/proc/direct()
	return (state & CONNECTION_DIRECT)

/connection/proc/valid()
	return !(state & CONNECTION_INVALID)

/connection/proc/erase()
	edge.remove_connection(src)
	state |= CONNECTION_INVALID
//	log_debug("Connection Erased: [state]")

/connection/proc/update()
//	log_debug("Updated, \...")
	if(!istype(A,/turf/simulated))
//		log_debug("Invalid A.")
		erase()
		return

	var/block_status = SSair.air_blocked(A,B)
	if(block_status & AIR_BLOCKED)
//		log_debug("Blocked connection.")
		erase()
		return
	else if(block_status & ZONE_BLOCKED)
		mark_indirect()
	else
		mark_direct()

	var/b_is_space = !istype(B,/turf/simulated)

	if(state & CONNECTION_SPACE)
		if(!b_is_space)
//			log_debug("Invalid B.")
			erase()
			return
		if(A.zone != zoneA)
//			log_debug("Zone changed, \...")
			if(!A.zone)
				erase()
//				log_debug("erased.")
				return
			else
				edge.remove_connection(src)
				edge = SSair.get_edge(A.zone, B)
				edge.add_connection(src)
				zoneA = A.zone

//		log_debug("valid.")
		return

	else if(b_is_space)
//		log_debug("Invalid B.")
		erase()
		return

	if(A.zone == B.zone)
//		log_debug("A == B")
		erase()
		return

	if(A.zone != zoneA || (zoneB && (B.zone != zoneB)))

//		log_debug("Zones changed, \...")
		if(A.zone && B.zone)
			edge.remove_connection(src)
			edge = SSair.get_edge(A.zone, B.zone)
			edge.add_connection(src)
			zoneA = A.zone
			zoneB = B.zone
		else
//			log_debug("erased.")
			erase()
			return


//	log_debug("valid.")