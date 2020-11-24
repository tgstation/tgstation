#define BAD_INIT_QDEL_BEFORE 1
#define BAD_INIT_DIDNT_INIT 2
#define BAD_INIT_SLEPT 4
#define BAD_INIT_NO_HINT 8

/datum/unit_test/initialize_sanity/Run()
	if(length(SSatoms.BadInitializeCalls))
		Fail("Bad Initialize() calls detected. Please read logs.")
		var/list/init_failures_to_text = list(
			"[BAD_INIT_QDEL_BEFORE]" = "Qdeleted Before Initialized",
			"[BAD_INIT_DIDNT_INIT]" = "Did Not Initialize",
			"[BAD_INIT_SLEPT]" = "Initialize() Slept",
			"[BAD_INIT_NO_HINT]" = "No Initialize() Hint Returned",
		)
		for(var/failure in SSatoms.BadInitializeCalls)
			log_world("[failure]: [init_failures_to_text["[SSatoms.BadInitializeCalls[failure]]"]]") // You like stacked brackets?
