//Bioware
//Body modifications applied through surgery. They generally affect physiology.

/datum/bioware
	var/name = "Generic Bioware"
	var/mob/living/carbon/human/owner
	var/desc = "If you see this something's wrong, warn a coder."
	var/active = FALSE
	var/can_process = FALSE
	var/mod_type = BIOWARE_GENERIC

/datum/bioware/New(mob/living/carbon/human/_owner)
	owner = _owner
	for(var/datum/bioware/bioware as anything in owner.bioware)
		if(bioware.mod_type == mod_type)
			qdel(src)
			return
	owner.bioware += src
	on_gain()

/datum/bioware/Destroy()
	owner = null
	if(active)
		on_lose()
	return ..()

/datum/bioware/proc/on_gain()
	active = TRUE
	if(can_process)
		START_PROCESSING(SSobj, src)

/datum/bioware/proc/on_lose()
	STOP_PROCESSING(SSobj, src)
	return
