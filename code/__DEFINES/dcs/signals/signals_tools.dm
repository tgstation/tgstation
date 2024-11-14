// Notifies tools that something is happening.

// Successful actions against an atom.
///Called from /atom/proc/tool_act (atom)
#define COMSIG_TOOL_ATOM_ACTED_PRIMARY(tooltype) "tool_atom_acted_[tooltype]"
///Called from /atom/proc/tool_act (atom)
#define COMSIG_TOOL_ATOM_ACTED_SECONDARY(tooltype) "tool_atom_acted_[tooltype]"
