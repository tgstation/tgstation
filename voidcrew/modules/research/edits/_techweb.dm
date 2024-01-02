/datum/techweb
	///Amount of people connected to the Techweb's neural network, which it uses to generate points better.
	var/neural_network_count = 0
	///List of everything connected to this techweb via Multitool, used for R&D server deconstruction.
	var/list/connected_machines = list()
