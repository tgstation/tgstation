// Notifies tools that something is happening.

// Successful actions against an atom.
///Called from /atom/proc/tool_act (atom)
#define COMSIG_TOOL_ATOM_ACTED_PRIMARY(tooltype) "tool_atom_acted_[tooltype]"
///Called from /atom/proc/tool_act (atom)
#define COMSIG_TOOL_ATOM_ACTED_SECONDARY(tooltype) "tool_atom_acted_[tooltype]"

//Called when a set of jaws of life attempts to pry open an airlock. Called from /obj/machinery/door/airlock/try_to_crowbar
#define COMSIG_JAWS_OF_LIFE_FORCE_OPEN_AIRLOCK "jaws_of_life_force_open_airlock"
	//If this value is returned, prevents the airlock from being forcedo open.
	#define COMPONENT_JAWS_DO_NOT_ALLOW (1<<0)
	//If this value is returned, it means the jaws successfully opened the airlock without interruption
	#define COMPONENT_JAWS_ALLOW (1<<1)
