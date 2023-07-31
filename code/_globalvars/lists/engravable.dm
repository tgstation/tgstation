/// Whitelist of things that can be engraved
GLOBAL_LIST_INIT(engravable_whitelist, typecacheof(list(
	/obj/structure/statue/custom, // only custom statues can be engraved for persistence
	/turf/closed,
)))
