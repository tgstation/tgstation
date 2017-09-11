
/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH
	var/in_use = FALSE

INITIALIZE_IMMEDIATE(/mob/living/carbon/human/dummy)

/mob/living/carbon/human/dummy/Life()
	return

/mob/living/carbon/human/dummy/proc/wipe_state()
	QDEL_LIST(contents)
