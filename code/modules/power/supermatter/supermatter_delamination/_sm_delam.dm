/// Priority is top to bottom.
GLOBAL_LIST_INIT(sm_delam_strat_list, list(
	/datum/sm_delam_strat/cascade = new /datum/sm_delam_strat/cascade,
	/datum/sm_delam_strat/singularity = new /datum/sm_delam_strat/singularity,
	/datum/sm_delam_strat/tesla = new /datum/sm_delam_strat/tesla,
	/datum/sm_delam_strat/default = new /datum/sm_delam_strat/default,
))

/datum/sm_delam_strat

/// Whether we are eligible for this delamination or not.
/datum/sm_delam_strat/proc/can_apply(obj/machinery/power/supermatter_crystal/sm)
	return FALSE

/// Called when the count down has been finished. 
/// This bad boy is called internally unlike all the rest.
/datum/sm_delam_strat/proc/delaminate(obj/machinery/power/supermatter_crystal/sm)

/// Start counting down, means SM is about to blow. Can still be healed though.
/datum/sm_delam_strat/proc/count_down(obj/machinery/power/supermatter_crystal/sm)

/// Means our integrity is going down.
/datum/sm_delam_strat/proc/delamination_warning(obj/machinery/power/supermatter_crystal/sm)

/// The sound we play to let people know we're delamming.
/datum/sm_delam_strat/proc/play_sound(obj/machinery/power/supermatter_crystal/sm)

