/datum
	var/var_edited = FALSE //datumvars.dm

	var/fingerprintslast

    var/gc_destroyed    //garbage.dm
#ifdef TESTING
    var/running_find_references 
    var/last_find_references = 0
#endif

    var/list/active_timers  //timer.dm

    var/list/processors //processing.dm