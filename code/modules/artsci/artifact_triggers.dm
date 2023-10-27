/* WOE
	Here are Stimuli for artifacts. They decide what way you need to activate them.
	What applies what stimulus is actually handled by the artifact itself, these datums serve to give them a name, and all those cool variables
	So far, artifacts should need higher tier parts for machines to be able to dish out higher stimuli.
	Stimulus base_amount needed is multiplied by the artifact type, so more potent artifacts need higher stimuli.
*/
/datum/artifact_trigger
	var/name = "Call coderbus!"
	///stimulus like STIMULUS_CARBON_TOUCH
	var/needed_stimulus
	var/check_amount = TRUE
	///base stimulus severity for math magic... base_amount + (max_amount - base_amount) * percentage...
	var/base_amount = 0
	var/max_amount = 0
	///stimulus severity needed to activate, changed after setup()..
	var/amount = 0
	///stimulus severity range, needs to be between amount and range for activation, done on setup()
	var/range = 0
	///Probability for a hint to be shown when the stimulus is hint_range close to the needed stimuli base_amount.
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
	hint_range = 10
	hint_prob = 75
	max_amount = 35

/datum/artifact_trigger/force/New()
		base_amount = rand(2,15)

/datum/artifact_trigger/heat
	name = "Heat"
	needed_stimulus = STIMULUS_HEAT
	hint_range = 20
	max_amount = 15000

/datum/artifact_trigger/heat/New()
		base_amount = rand(320,950)

/datum/artifact_trigger/shock
	name = "Electricity"
	needed_stimulus = STIMULUS_SHOCK
	max_amount = 10000
	hint_range = 500

/datum/artifact_trigger/shock/New()
		base_amount = rand(400,1200)

/datum/artifact_trigger/radiation
	name = "Radiation"
	needed_stimulus = STIMULUS_RADIATION
	max_amount = 10
	hint_range = 2
	base_amount = 1

/datum/artifact_trigger/data
	name = "Data"
	needed_stimulus = STIMULUS_DATA
	check_amount = FALSE
