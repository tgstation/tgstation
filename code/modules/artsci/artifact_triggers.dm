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
	name = "Physical Force"
	needed_stimulus = STIMULUS_FORCE
	hint_range = 20
	hint_prob = 75

/datum/artifact_trigger/force/New()
		..()
		stimulus_amount = rand(2,30)

/datum/artifact_trigger/heat
	name = "Heat"
	needed_stimulus = STIMULUS_HEAT
	hint_range = 20

/datum/artifact_trigger/heat/New()
		..()
		stimulus_amount = rand(320,950)

/datum/artifact_trigger/cold
	name = "Cold"
	needed_stimulus = STIMULUS_HEAT
	hint_range = 20
	stimulus_operator = "<="

/datum/artifact_trigger/cold/New()
		..()
		stimulus_amount = rand(170,300)

/datum/artifact_trigger/shock
	name = "Electricity"
	needed_stimulus = STIMULUS_SHOCK

/datum/artifact_trigger/shock/New()
		..()
		stimulus_amount = rand(400,1200)

/datum/artifact_trigger/radiation
	name = "Radiation"
	needed_stimulus = STIMULUS_RADIATION

/datum/artifact_trigger/radiation/New()
		..()
		stimulus_amount = rand(1,10)

/datum/artifact_trigger/data
	name = "Data"
	needed_stimulus = STIMULUS_DATA
	check_amount = FALSE