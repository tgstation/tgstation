/// Fearful component: provides optional handling of fears and phobias for mob's mood
/// Can be applied from multiple sources, and essentially serves as a central controller for fear datums described below

/datum/component/fearful
	dupe_mode = COMPONENT_DUPE_SOURCES

	/// How terrified is the owner?
	var/terror_buildup = 0
	/// List of terror handlers,
