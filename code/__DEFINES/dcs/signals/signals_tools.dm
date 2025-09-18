// Notifies tools that something is happening.

// Successful actions against an atom.
///Called from /atom/proc/tool_act (atom)
#define COMSIG_TOOL_ATOM_ACTED_PRIMARY(tooltype) "tool_atom_acted_[tooltype]"
///Called from /atom/proc/tool_act (atom)
#define COMSIG_TOOL_ATOM_ACTED_SECONDARY(tooltype) "tool_atom_acted_[tooltype]"

//Called when a tool attempts to pry open an airlock. Called from /obj/machinery/door/airlock/try_to_crowbar
#define COMSIG_TOOL_FORCE_OPEN_AIRLOCK "tool_force_open_airlock"
	//If this value is returned, prevents the airlock from being forced open.
	#define COMPONENT_TOOL_DO_NOT_ALLOW_FORCE_OPEN (1<<0)
	//If this value is returned, it means the tool successfully opened the airlock without interruption
	#define COMPONENT_TOOL_ALLOW_FORCE_OPEN (1<<1)
