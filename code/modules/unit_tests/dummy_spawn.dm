///This set of tests is focused on ensuring the stability of preference dummies
///And by extension the hacks built to make them fast
///Organ consistency, object pooling via the wardrobe ss, etc

//Test spawning one of every species
/datum/unit_test/dummy_spawn_species

/datum/unit_test/dummy_spawn_species/Run()
	var/mob/living/carbon/human/dummy/lad = allocate(/mob/living/carbon/human/dummy)
	for(var/datum/species/testing_testing as anything in subtypesof(/datum/species))
		lad.set_species(testing_testing, icon_update = FALSE, pref_load = TRUE) //I wonder if I should somehow hook into the species pref here

///Equips and devests our dummy of one of every job outfit
/datum/unit_test/dummy_spawn_outfit

/datum/unit_test/dummy_spawn_outfit/Run()
	var/mob/living/carbon/human/dummy/lad = allocate(/mob/living/carbon/human/dummy)
	for(var/datum/job/one_two_three as anything in subtypesof(/datum/job))
		var/datum/job/can_you_hear_this = SSjob.GetJobType(one_two_three)
		if(!can_you_hear_this)
			log_world("Job type [one_two_three] could not be retrieved from SSjob")
			continue
		lad.job = can_you_hear_this
		lad.dress_up_as_job(can_you_hear_this, TRUE)
		lad.wipe_state() //Nuke it all
