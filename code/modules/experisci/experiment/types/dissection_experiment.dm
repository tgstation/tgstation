/datum/experiment/dissection
	name = "Dissection Experiment"
	description = "An experiment requiring a dissection surgery to progress"
	exp_tag = "Dissection"
	performance_hint = "Perform a dissection surgery while connected to an operating computer."

/datum/experiment/dissection/is_complete()
	return completed

/datum/experiment/dissection/perform_experiment_actions(datum/component/experiment_handler/experiment_handler, mob/target)
	if (is_valid_dissection(target))
		completed = TRUE
		return TRUE
	else
		return FALSE

/datum/experiment/dissection/proc/is_valid_dissection(mob/target)
	return TRUE

/datum/experiment/dissection/human
	name = "Human Dissection Experiment"
	description = "We don't want to invest in a station that doesn't know their coccyx from their cochlea. Send us back data dissecting a human to receive more funding."

/datum/experiment/dissection/human/is_valid_dissection(mob/target)
	return ishumanbasic(target)

/datum/experiment/dissection/nonhuman
	name = "Non-human Dissection Experiment"
	description = "When we asked for a tail bone, we didn't mean...look, just send us back data from something OTHER than a human. It could be a monkey for all we care, just send us research."

/datum/experiment/dissection/nonhuman/is_valid_dissection(mob/target)
	return ishuman(target) && !ishumanbasic(target)

/datum/experiment/dissection/xenomorph
	name = "Xenomorph Dissection Experiment"
	description = "Our understanding of the xenomorph only scratches the surface. Send us research from dissecting a xenomorph."

/datum/experiment/dissection/xenomorph/is_valid_dissection(mob/target)
	return isalien(target)
