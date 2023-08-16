#define ROBOTIC_BURN_T1_STARTING_TEMP_MIN 500 // kelvin
#define ROBOTIC_BURN_T1_STARTING_TEMP_MAX 700

/*/datum/wound/burn/robotic
	required_limb_biostate = BIO_ROBOTIC

	/// The percent of the inherent resistances we will remove from this limb.
	/// Separate from a straight damage increase, since this depends on inherent armor values.
	var/resistance_removal_percent = 50
	var/

/datum/wound/burn/robotic/moderate
	name = "Overheating"
	desc = ""
	occur_text = "lets out a slight groan as it turns a dull shade of thermal red"
	examine_desc = "is glowing a dull red and giving off a uncomfortable heat"

	a_or_from = "from"

	// extremely easy to get
	threshold_minimum = 10
	threshold_penalty = 30

	var/chassis_temperature

	processes = TRUE

/datum/wound/burn/robotic/moderate/wound_injury(datum/wound/old_wound = null, attack_direction = null)

	chassis_temperature =

	// hook into gaining/losing gauze so crit bone wounds can re-enable/disable depending if they're slung or not
	RegisterSignals(limb, list(COMSIG_BODYPART_GAUZED, COMSIG_BODYPART_GAUZE_DESTROYED), PROC_REF(update_inefficiencies))
	update_inefficiencies()

/datum/wound/burn/robotic/moderate/handle_process(seconds_per_tick, times_fired)
*/
