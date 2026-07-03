/datum/singleton
	abstract_type = /datum/singleton

/datum/singleton/proc/Initialize()
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)

/datum/singleton/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	. = QDEL_HINT_LETMELIVE
	CRASH("Prevented attempt to delete a singleton instance: [src]")
