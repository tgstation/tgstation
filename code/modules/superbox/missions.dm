// Special handling for Superbox's use of custom objectives

/datum/mind/proc/is_any_antag()
    // except for custom, that is, so the shuttle isn't hijacked every round.
    . = FALSE
    for(var/a in antag_datums)
        if (!istype(a, /datum/antagonist/custom))
            return TRUE
