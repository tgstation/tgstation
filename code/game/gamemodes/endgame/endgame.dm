/**********************
 * ENDGAME STUFF
 **********************/

 // Universal State
 // Handles stuff like space icon_state, constants, etc.
 // Essentially a policy manager.  Once shit hits the fan, this changes its policies.
 // Called by master controller.

 var/global/datum/universal_state/universe = new

 // Default shit.
/datum/universal_state
	// Just for reference, for now.
	// Might eventually add an observatory job.
 	var/name = "Normal"
 	var/desc = "Nothing seems awry."

 	// Sets world.turf, replaces all turfs of type /turf/space.
 	var/space_type         = /turf/space

 	// Replaces all turfs of type /turf/space/transit
 	var/transit_space_type = /turf/space/transit

 	// Chance of a floor or wall getting damaged [0-100]
 	// Simulates stuff getting broken due to molecular bonds decaying.
 	var/decay_rate = 0

 	var/escape = 0 // NO ESCAPE

// Actually decay the turf.
/datum/universal_state/proc/DecayTurf(var/turf/T)
	if(istype(T,/turf/simulated/wall))
		var/turf/simulated/wall/W=T
		W.melt()
		return
	if(istype(T,/turf/simulated/floor))
		var/turf/simulated/floor/F=T
		// Burnt?
		if(!F.burnt)
			F.burn_tile()
		else
			F.ReplaceWithLattice()
		return

// Apply changes to a turf
/datum/universal_state/proc/FilterTurf(var/turf/T)
 	// Does nothing by default