/turf/open/ballpit
	gender = PLURAL

	name = "ballpit"
	desc = "How deep does it go"
	icon = 'goon/icons/turf/ballpit.dmi'
	icon_state = "ballpitfloor"

	slowdown = 1
	turf_flags = NO_RUST

	footstep = FOOTSTEP_BALL
	barefootstep = FOOTSTEP_BALL
	clawfootstep = FOOTSTEP_BALL
	heavyfootstep = FOOTSTEP_BALL

	var/sink_time = 5 SECONDS


/turf/open/ballpit/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(try_attach))


/turf/open/proc/try_attach(turf/open/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(!istype(src, /turf/open/ballpit))
		return
	if(arrived.GetComponent(/datum/component/player_sink))
		return
	arrived.AddComponent(/datum/component/player_sink, type_to_add = src.type)
