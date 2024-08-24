//touch artifacts are just if something comes into contact without a range IE if someone touches an artifact

/datum/artifact_activator/touch
	name = "Generic Contact Trigger"
	required_stimuli = STIMULUS_DATA | STIMULUS_CARBON_TOUCH | STIMULUS_SILICON_TOUCH

/datum/artifact_activator/touch/data
	name = "Data"
	required_stimuli = STIMULUS_DATA
	hint_texts = list("It yearns for information")
	discovered_text = "Activated by Information"

/datum/artifact_activator/touch/carbon
	name = "Carbon Touch"
	required_stimuli = STIMULUS_CARBON_TOUCH
	hint_texts = list("You swear you hear the artifact saying it yearns for flesh.", "One touch couldn't hurt could it?")
	discovered_text = "Activated by Organic Contact"

/datum/artifact_activator/touch/silicon
	name = "Silicon Touch"
	required_stimuli = STIMULUS_SILICON_TOUCH
	hint_texts  = list("It feels like it's malfunctioning")
	discovered_text = "Activated by Silicon Contact"
