/datum/experiment/autopsy
	name = "Autopsy Experiment"
	description = "An experiment requiring a autopsy surgery to progress"
	exp_tag = "Autopsy"
	performance_hint = "Perform a autopsy surgery while connected to an operating computer."

/datum/experiment/autopsy/is_complete()
	return completed

/datum/experiment/autopsy/perform_experiment_actions(datum/component/experiment_handler/experiment_handler, mob/target)
	if (is_valid_autopsy(target))
		completed = TRUE
		return TRUE
	else
		return FALSE

/datum/experiment/autopsy/proc/is_valid_autopsy(mob/target)
	return TRUE

/datum/experiment/autopsy/human
	name = "Human Autopsy Experiment"
	description = "We don't want to invest in a station that doesn't know their coccyx from their cochlea. Send us back data dissecting a human to receive more funding."

/datum/experiment/autopsy/human/is_valid_autopsy(mob/target)
	return ishumanbasic(target)

/datum/experiment/autopsy/nonhuman
	name = "Non-human Autopsy Experiment"
	description = "When we asked for a tail bone, we didn't mean...look, just send us back data from something OTHER than a human. It could be a monkey for all we care, just send us research."

/datum/experiment/autopsy/nonhuman/is_valid_autopsy(mob/target)
	return ishuman(target) && !ishumanbasic(target)

/datum/experiment/autopsy/xenomorph
	name = "Xenomorph Autopsy Experiment"
	description = "Our understanding of the xenomorph only scratches the surface. Send us research from dissecting a xenomorph."

/datum/experiment/autopsy/xenomorph/is_valid_autopsy(mob/target)
	return isalien(target)
