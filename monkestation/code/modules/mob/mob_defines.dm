/mob
	///If set to true, this mob will have rightclick always act as the context menu
	var/rclick_always_context_menu = null
	/// Path to forced interaction mode, should be used for mobs that have special interaction modes such as cyborgs.
	var/forced_interaction_mode
	/// The interaction state of this mob, istate for short because typing interaction_state is annoying.
	var/istate = NONE
