/turf/open/water
	///Do we give the player_sink component
	var/sinking = FALSE
	///If we have one then what should our player_sink max_sinkage be set to, leave unset for default sinkage
	var/max_sinkage

/turf/open/water/Initialize(mapload)
	. = ..()
	if(sinking)
		RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(try_add_sinking))

/turf/open/water/proc/try_add_sinking(turf/open/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(arrived.GetComponent(/datum/component/player_sink))
		return
	arrived.AddComponent(/datum/component/player_sink, max_sinkage = src.max_sinkage, type_to_add = src.type)

/turf/open/water/beach/biodome/sinking
	name = "Water"
	desc = "You get the feeling that somebody's bothered to actually make this water partly functional..."
	sinking = TRUE

//the tram beachside bar has 1 tile of this
/turf/open/water/beach/biodome/sinking/deep
	max_sinkage = 28
