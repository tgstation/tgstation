/datum/artifact_trigger
	var/name = "Call coderbus!"
	///stimulus like STIMULUS_CARBON_TOUCH
	var/needed_stimulus
	var/check_amount = TRUE
	///stimulus severity to trigger
	var/stimulus_amount = 0
	///Either "<=" or ">=", what operator to use for stimulus amount
	var/stimulus_operator = ">="
	///Probability for a hint to be shown when the stimulus is hint_range close to the needed stimuli amount.
	var/hint_range = 0
	var/hint_prob = 35

/datum/artifact_trigger/carbon_touch
	name = "Carbon Touch"
	needed_stimulus = STIMULUS_CARBON_TOUCH
	check_amount = FALSE

/datum/artifact_trigger/silicon_touch
	name = "Silicon Touch"
	needed_stimulus = STIMULUS_SILICON_TOUCH
	check_amount = FALSE

/datum/artifact_trigger/force
	type_name = "Physical Force"
	stimulus_required = STIMULUS_FORCE
	hint_range = 20
	hint_prob = 75

	New()
		..()
		stimulus_amount = rand(2,30)

/datum/artifact_trigger/heat
	type_name = "Heat"
	stimulus_required = STIMULUS_HEAT
	hint_range = 20

	New()
		..()
		stimulus_amount = rand(320,400)