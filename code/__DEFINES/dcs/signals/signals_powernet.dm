// Powernet signals

/// Sent when a wirenet circuit component sends a signal (list/data)
#define COMSIG_POWERNET_CIRCUIT_TRANSMISSION "powernet_circuit_transmision"

/// Sent when a powernet is merged into us
#define COMSIG_POWERNET_MERGED "powernet_merged"

/// Sent when a cable is added to the powernet, i.e. the powernet is expanded
#define COMSIG_POWERNET_ADDED_CABLE "powernet_added_cable"

/// Sent when a cable is removed from the powernet, i.e. the powernet is shrunk
#define COMSIG_POWERNET_REMOVED_CABLE "powernet_removed_cable"

/// From /obj/machinery/proc/powered()
#define COMSIG_MACHINERY_POWERED "machinery_powered"
	/// Return to force the machinery to not be powered even if it otherwise would be
	#define FLAG_MACHINERY_POWERED_FORCE_OFF (1<<0)
