//range artifacts require stimuli to fall within a range between amount and upper range
// hint range and hint chance are added onto range to see if something we should pull a hint for the user

/datum/artifact_activator/range
	name = "Generic Range Trigger"
	//the upper range of the weapon basically between amount, and upper_range
	var/upper_range = 0
	///Hint range goes like amount - hint_range to upper_range + hint_range
	var/hint_range = 0
	///if we are in the hint range the odds of pulling a hint out.
	var/hint_prob = 15

/datum/artifact_activator/range/setup(potency)
	. = ..()
	upper_range = amount + (hint_range * 2)

/datum/artifact_activator/range/force
	name = "Physical Trauma"
	required_stimuli = STIMULUS_FORCE
	highest_trigger_amount = 30 //any higher than this and its gonna be practically impossible to trigger
	hint_prob = 50
	hint_range = 10
	hint_texts = list("you almost want to start hitting things.", "a good whack might fix this.")
	discovered_text = "Activated by Kinetic Energy"

/datum/artifact_activator/range/heat
	name = "Heat Sensisty"
	required_stimuli = STIMULUS_HEAT
	hint_range = 20
	highest_trigger_amount = 15000
	hint_texts = list("it feels like someone messed with the thermostat.", "it feels unpleasent being near")
	discovered_text = "Activated by Thermal Energy"

/datum/artifact_activator/range/heat/New()
	base_trigger_amount = rand(350, 1000)

/datum/artifact_activator/range/shock
	name = "Electrical Charged"
	required_stimuli = STIMULUS_SHOCK
	highest_trigger_amount = 10000 // requires atleast t2 parts to trigger a max roll one
	hint_range = 500
	hint_texts = list("you can feel the static in the air", "your hairs stand on their ends")
	discovered_text = "Activated by Electrical Energy"

/datum/artifact_activator/range/shock/New()
	base_trigger_amount = rand(400, 1200)

/datum/artifact_activator/range/radiation
	name = "Radioactivity"
	required_stimuli = STIMULUS_RADIATION
	highest_trigger_amount = 10
	hint_range = 2
	base_trigger_amount = 1 //x-ray machine goes from 1-10
	hint_texts = list("emits a hum that resembles the Super Matter", "you could swear you saw your bones for a second")
	discovered_text = "Activated by Radiation"
