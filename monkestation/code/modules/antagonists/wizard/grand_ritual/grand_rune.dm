#define GRAND_RUNE_INVOKES_TO_COMPLETE 3 //moved from the upstream file to here as this is where its used now

/obj/effect/grand_rune
	///Weakref to our owning mind
	var/datum/weakref/owning_mind
	///How many times this rune needs to be invoked to complete
	var/invokes_needed = GRAND_RUNE_INVOKES_TO_COMPLETE

#undef GRAND_RUNE_INVOKES_TO_COMPLETE
