/*
You'll notice this is the atmospherics system,
but with reagents instead gas mixtures.

Quick overview:

Pipes combine to form pipelines
Pipelines and other water objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network

*/

obj/machinery/water
	anchored = 1
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = ENVIRON
	var/nodealert = 0



	var/initialize_directions = 0
	var/color

	process()
		build_network()
		..()

	proc
		network_expand(datum/water/pipe_network/new_network, obj/machinery/water/pipe/reference)
			// Check to see if should be added to network. Add self if so and adjust variables appropriately.
			// Note don't forget to have neighbors look as well!

			return null

		build_network()
			// Called to build a network from this node

			return null

		return_network(obj/machinery/water/reference)
			// Returns pipe_network associated with connection to reference
			// Notes: should create network if necessary
			// Should never return null

			return null

		reassign_network(datum/water/pipe_network/old_network, datum/water/pipe_network/new_network)
			// Used when two pipe_networks are combining

		return_network_reagents(datum/water/pipe_network/reference)
			// Return a list of reagents(s) in the object
			//		associated with reference pipe_network for use in rebuilding the networks gases list
			// Is permitted to return null

		disconnect(obj/machinery/water/reference)

		mingle_dc_with_turf(D, datum/water/pipe_network/net)
			// 250 being a pipe opening volume
			mingle_outflow_with_turf(get_turf(src), \
				net.reagents_transient.total_volume / net.reagents_transient.maximum_volume * 250, \
				D, network = net)

	update_icon()
		return null