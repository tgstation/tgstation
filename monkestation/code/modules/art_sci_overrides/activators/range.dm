/datum/artifact_activator/range
	name = "Generic Range Trigger"
	//the range we use math will be explained later
	var/range = 0
	///low end range for hints
	var/hint_range = 0
	///if we are in the hint range the odds of pulling a hint out
	var/hint_prob = 15

/datum/artifact_activator/range/setup(potency)
	. = ..()
	range = amount + (hint_range * 2)

/datum/artifact_activator/range/force
	name = "Physical Trauma"
	required_stimuli = STIMULUS_FORCE
	highest_trigger_amount = 30 //any higher than this and its gonna be practically impossible to trigger
	hint_prob = 50
	hint_range = 10

/datum/artifact_activator/range/heat
	name = "Heat Sensisty"
	required_stimuli = STIMULUS_HEAT
	hint_range = 20
	highest_trigger_amount = 15000

/datum/artifact_activator/range/heat/New()
	base_trigger_amount = rand(350, 1000)

/datum/artifact_activator/range/shock
	name = "Electrical Charged"
	required_stimuli = STIMULUS_SHOCK
	highest_trigger_amount = 10000 // requires atleast t2 parts to trigger a max roll one
	hint_range = 500

/datum/artifact_activator/range/shock/New()
	base_trigger_amount = rand(400, 1200)

/datum/artifact_activator/range/radiation
	name = "Radioactivity"
	required_stimuli = STIMULUS_RADIATION
	highest_trigger_amount = 10
	hint_range = 2
	base_trigger_amount = 1 //x-ray machine goes from 1-10
