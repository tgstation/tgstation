#define ROBOTIC_BURN_T1_STARTING_TEMP_MIN (BODYTEMP_NORMAL + 200)  // kelvin
#define ROBOTIC_BURN_T1_STARTING_TEMP_MAX (ROBOTIC_BURN_T1_STARTING_TEMP_MIN + 50)

/datum/wound/burn/robotic
	required_limb_biostate = BIO_ROBOTIC

	/// The percent of the inherent resistances we will remove from this limb.
	/// Separate from a straight damage increase, since this depends on inherent armor values.
	var/burn_resistance_mult = 0.7
	var/brute_resistance_mult = 0.7

	damage_mulitplier_penalty = 1.1

/datum/wound/burn/robotic/wound_injury(datum/wound/old_wound = null, attack_direction = null)
	limb.burn_modifier *= burn_resistance_mult
	limb.brute_modifier *= brute_resistance_mult

	return ..()

/datum/wound/burn/robotic/remove_wound(ignore_limb, replaced)
	if (limb && !ignore_limb)
		limb.burn_modifier /= burn_resistance_mult
		limb.brute_modifier /= brute_resistance_mult
	return ..()
/datum/wound/burn/robotic/moderate
	name = "Overheating"
	desc = "External metals have exceeded lower-bound thermal limits, and as such, have lost some structural integrity. \
			Temperatures have still not exceeded critical levels, so the damage is temporary, assuming the limb is isolated from high temperatures."
	occur_text = "lets out a slight groan as it turns a dull shade of thermal red"
	examine_desc = "is glowing a dull thermal red and giving off heat"
	treat_text = "Introduction of a cold environment or lowering of body temperature."
	severity = WOUND_SEVERITY_MODERATE

	a_or_from = "from"

	// easy to get
	threshold_minimum = 35
	threshold_penalty = 60

	status_effect_type = /datum/status_effect/wound/burn/robotic/moderate

	sound_volume = 30

	var/chassis_temperature
	var/cooling_threshold = (BODYTEMP_NORMAL + 5)

	var/bodytemp_coeff = 0.08
	var/turf_coeff = 0.02

	var/incoming_damage_to_temperature_ratio = 3

	processes = TRUE

/datum/wound/burn/robotic/moderate/wound_injury(datum/wound/old_wound = null, attack_direction = null)
	chassis_temperature = get_random_starting_temperature()

	return ..()

/datum/wound/blunt/robotic/moderate/set_victim(new_victim)
	if (victim)
		UnregisterSignal(victim, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	if (new_victim)
		RegisterSignal(new_victim, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(victim_attacked))

	return ..()

/datum/wound/burn/robotic/moderate/proc/get_random_starting_temperature()
	return rand(ROBOTIC_BURN_T1_STARTING_TEMP_MIN, ROBOTIC_BURN_T1_STARTING_TEMP_MAX)

/datum/wound/burn/robotic/moderate/handle_process(seconds_per_tick, times_fired)
	if (victim)
		expose_temperature(victim.bodytemperature, (bodytemp_coeff * seconds_per_tick))
	else
		var/turf/our_turf = get_turf(limb)
		if (our_turf)
			expose_temperature(our_turf.GetTemperature(), (turf_coeff * seconds_per_tick))

	if (chassis_temperature < cooling_threshold)
		remove_wound()

/datum/wound/burn/robotic/moderate/proc/victim_attacked(datum/source, damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER

	if (def_zone != limb.body_zone) // use this proc since receive damage can also be called for like, chems and shit
		return

	if(!victim)
		return

	if (damagetype != BURN)
		return

	if (wound_bonus == CANT_WOUND)
		return

	var/effective_damage = (damage - blocked)
	if (effective_damage <= 0)
		return

	var/temp_to_expose = (effective_damage * incoming_damage_to_temperature_ratio)

	expose_temperature(temp_to_expose)

/datum/wound/burn/robotic/moderate/proc/expose_temperature(temperature, coeff=0.02)
	var/temp_delta = (temperature - chassis_temperature) * coeff
	if(temp_delta > 0)
		chassis_temperature = min(chassis_temperature + max(temp_delta, 1), temperature)
	else
		chassis_temperature = max(chassis_temperature + min(temp_delta, -1), temperature)

/datum/wound/burn/robotic/moderate/get_scanner_description(mob/user)
	var/desc = ..()

	desc += "It's current temperature is [span_blue("[chassis_temperature]")]K, and needs to cool to [span_green("[cooling_threshold]")]K."

	return desc

/datum/wound/burn/robotic/severe
	name = "Warped Metal"
	desc = "Carapace has suffered significant heating strain and has lost molecular integrity, resulting in significantly worsened resistance factors."
	occur_text = "sizzles, the externals briefly glowing a radiant orange"
	examine_desc = "appears discolored and polychromatic, a few plates of metal curled into the air"
	treat_text = "Removal and replacement of the damaged metal with a welder."
	severity = WOUND_SEVERITY_SEVERE

	a_or_from = "from"

	threshold_minimum = 140
	threshold_penalty = 70

	status_effect_type = /datum/status_effect/wound/burn/robotic/severe

	burn_resistance_mult = 0.3
	brute_resistance_mult = 0.3

	damage_mulitplier_penalty = 1.3

/datum/wound/burn/robotic/critical // placeholder
	name = "Demagnetized Alloys"
	desc = "Internal and external metals have been heated past the Curie point, reducing integrity massively."
	occur_text = "turns a smoldering white as it melts rapidly"
	examine_desc = "is unrecognizably burnt, the surface giving off a beautiful sheen characteristic of heated metal"
	treat_text = "Removal and replacement of the damaged metal with a welder."
	severity = WOUND_SEVERITY_CRITICAL


	a_or_from = "from"

	sound_effect = 'sound/effects/wounds/sizzle2.ogg'

	threshold_minimum = 190
	threshold_penalty = 70

	status_effect_type = /datum/status_effect/wound/burn/robotic/critical

	burn_resistance_mult = 0.05
	brute_resistance_mult = 0.05

	damage_mulitplier_penalty = 1.8

