//This file controls whether or not a job complies with dresscodes.
//If a job complies with dresscodes, loadout items will not be equipped instead of the job's outfit, instead placing the items into the player's backpack.

/datum/job
	var/dresscodecompliant = TRUE

/datum/job/assistant
	dresscodecompliant = FALSE