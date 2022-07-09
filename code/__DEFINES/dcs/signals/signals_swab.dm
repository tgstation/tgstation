// /datum/component/swabbing signals
#define COMSIG_SWAB_FOR_SAMPLES "swab_for_samples" ///Called when you try to swab something using the swabable component, includes a mutable list of what has been swabbed so far so it can be modified.
	#define COMPONENT_SWAB_FOUND (1<<0)
