/// The basic player-facing types that don't have any super special behaviour.
GLOBAL_LIST_INIT(wiremod_basic_types, list(
	PORT_TYPE_ANY,
	PORT_TYPE_ATOM,
	PORT_TYPE_NUMBER,
	PORT_TYPE_SIGNAL,
	PORT_TYPE_STRING,
	PORT_TYPE_TABLE,
))

/// The fundamental datatypes of the byond game engine.
GLOBAL_LIST_INIT(wiremod_fundamental_types, list(
	PORT_TYPE_ANY,
	PORT_TYPE_ASSOC_LIST(PORT_TYPE_ANY, PORT_TYPE_ANY),
	PORT_TYPE_ATOM,
	PORT_TYPE_DATUM,
	PORT_TYPE_LIST(PORT_TYPE_ANY),
	PORT_TYPE_NUMBER,
	PORT_TYPE_STRING,
))

/// All possible types of list something can be.
GLOBAL_LIST_INIT(wiremod_list_types, list(
	PORT_LIST_NONE,
	PORT_COMPOSITE_TYPE_LIST,
	PORT_COMPOSITE_TYPE_ASSOC_LIST
))
