/**
 * Called by the machinery disconnect(), custom for each type
 */
/obj/machinery/atmospherics/proc/destroy_network()
	return

/// This should only be called by SSair as part of the rebuild queue.
/// Handles rebuilding pipelines after init or they've been changed.
/obj/machinery/atmospherics/proc/rebuild_pipes()
	var/list/targets = get_rebuild_targets()
	rebuilding = FALSE
	for(var/datum/pipeline/build_off as anything in targets)
		build_off.build_pipeline(src) //This'll add to the expansion queue

/**
 * Returns a list of new pipelines that need to be built up
 */
/obj/machinery/atmospherics/proc/get_rebuild_targets()
	return

/**
 * Called on construction and when expanding the datum_pipeline, returns the nodes of the device
 */
/obj/machinery/atmospherics/proc/pipeline_expansion()
	return nodes

/**
 * Called by addMember() in datum_pipeline.dm, returns the parent network the device is connected to
 */
/obj/machinery/atmospherics/proc/returnPipenet()
	return

/**
 * Called by addMachineryMember() in datum_pipeline.dm, returns a list of gas_mixtures and assigns them into other_airs (by addMachineryMember) to allow pressure redistribution for the machineries.
 */
/obj/machinery/atmospherics/proc/returnPipenetAirs()
	return

/**
 * Called by build_pipeline() and addMember() in datum_pipeline.dm, set the network the device is connected to, to the datum pipeline it has reference
 */
/obj/machinery/atmospherics/proc/setPipenet()
	return

/**
 * Similar to setPipenet() but instead of setting a network to a pipeline, it replaces the old pipeline with a new one, called by Merge() in datum_pipeline.dm
 */
/obj/machinery/atmospherics/proc/replacePipenet()
	return
