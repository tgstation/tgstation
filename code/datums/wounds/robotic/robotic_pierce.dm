#define ELECTRICAL_DAMAGE_REPAIR_WELD_BASE_DELAY 3 SECONDS
#define ELECTRICAL_DAMAGE_REPLACE_METALS_BASE_DELAY 4 SECONDS

// Pierce
// Slow to rise but high damage overall
// Hard-ish to fix
/datum/wound/electrical_damage/pierce
	heat_differential_healing_mult = 0.01

	simple_desc = "Electrical conduits have been pierced open, resulting in a fault that <b>slowly</b> intensifies, but with <b>extreme</b> maximum voltage!"

/datum/wound_pregen_data/electrical_damage/pierce
	abstract = TRUE

	wound_series = WOUND_SERIES_WIRE_PIERCE_ELECTRICAL_DAMAGE
	required_wounding_types = list(WOUND_PIERCE)

/datum/wound/burn/electrical_damage/pierce/get_limb_examine_description()
	return span_warning("The metal on this limb is pierced open.")

/datum/wound/electrical_damage/pierce/moderate
	name = "Punctured Capacitor"
	desc = "A major capacitor has been broken open, causing slow but noticable electrical damage."
	occur_text = "shoots out a short stream of sparks"
	examine_desc = "is shuddering gently, movements a little weak"
	treat_text = "Replacing of damaged wiring, though repairs via wirecutting instruments or sutures may suffice, albiet at limited efficiency. In case of emergency, \
				subject may be subjected to high temperatures to allow solder to reset."

	sound_effect = 'sound/effects/wounds/robotic_slash_T1.ogg'

	severity = WOUND_SEVERITY_MODERATE

	sound_volume = 30

	threshold_penalty = 30

	intensity = 10 SECONDS
	processing_full_shock_threshold = 8 MINUTES

	processing_shock_power_per_second_max = 1.3
	processing_shock_power_per_second_min = 1.2

	processing_shock_stun_chance = 0.5
	processing_shock_spark_chance = 35

	process_shock_spark_count_max = 1
	process_shock_spark_count_min = 1

	wirecut_repair_percent = 0.07 // not even faster at this point
	wire_repair_percent = 0.065

	interaction_efficiency_penalty = 2
	limp_slowdown = 2
	limp_chance = 60

	wiring_reset = TRUE

	initial_sparks_amount = 1

	status_effect_type = /datum/status_effect/wound/electrical_damage/pierce/moderate

	a_or_from = "a"

	scar_keyword = "piercemoderate"

/datum/wound_pregen_data/electrical_damage/pierce/moderate
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/pierce/moderate

	threshold_minimum = 40

/datum/wound/electrical_damage/pierce/severe
	name = "Penetrated Transformer"
	desc = "A major transformer has been pierced, causing slow-to-progess but eventually intense electrical damage."
	occur_text = "sputters and goes limp for a moment as it ejects a stream of sparks"
	examine_desc = "is shuddering significantly, servos briefly giving way in a rythmic pattern"
	treat_text = "Containment of damaged wiring via gauze, securing of wires via a wirecutter/hemostat, then application of fresh wiring or sutures."

	sound_effect = 'sound/effects/wounds/robotic_slash_T2.ogg'

	severity = WOUND_SEVERITY_SEVERE

	sound_volume = 15

	threshold_penalty = 40

	intensity = 20 SECONDS
	processing_full_shock_threshold = 7 MINUTES

	processing_shock_power_per_second_max = 1.6
	processing_shock_power_per_second_min = 1.5

	processing_shock_stun_chance = 2.5
	processing_shock_spark_chance = 60

	process_shock_spark_count_max = 2
	process_shock_spark_count_min = 1

	wirecut_repair_percent = 0.06
	wire_repair_percent = 0.05

	interaction_efficiency_penalty = 2.5
	limp_slowdown = 4
	limp_chance = 90

	initial_sparks_amount = 3

	disable_at_intensity_mult = 1

	status_effect_type = /datum/status_effect/wound/electrical_damage/pierce/moderate

	a_or_from = "a"

	scar_keyword = "piercemoderate"

/datum/wound_pregen_data/electrical_damage/pierce/severe
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/pierce/severe

	threshold_minimum = 60

/datum/wound/electrical_damage/pierce/critical
	name = "Ruptured PSU"
	desc = "The local PSU of this limb has suffered a core rupture, causing a progressive power failure that will slowly intensify into massive electrical damage."
	occur_text = "flashes with radiant blue, emitting a noise not unlike a jacobs ladder"
	examine_desc = "'s PSU is visible, with a sizable hole in the center"
	treat_text = "Immediate securing via gauze, followed by emergency cable replacement and securing via wirecutters or hemostat. \
		If the fault has become uncontrollable, extreme heat therapy is reccomended."

	severity = WOUND_SEVERITY_CRITICAL
	wound_flags = (ACCEPTS_GAUZE|MANGLES_EXTERIOR|CAN_BE_GRASPED)

	sound_effect = 'sound/effects/wounds/robotic_slash_T3.ogg'

	sound_volume = 30

	threshold_penalty = 60

	intensity = 40 SECONDS
	processing_full_shock_threshold = 6 MINUTES

	processing_shock_power_per_second_max = 2.3
	processing_shock_power_per_second_min = 2.2

	processing_shock_stun_chance = 1
	processing_shock_spark_chance = 90

	process_shock_spark_count_max = 3
	process_shock_spark_count_min = 2

	wirecut_repair_percent = 0.06
	wire_repair_percent = 0.04

	interaction_efficiency_penalty = 3
	limp_slowdown = 6
	limp_chance = 100

	initial_sparks_amount = 8

	status_effect_type = /datum/status_effect/wound/electrical_damage/pierce/moderate

	a_or_from = "a"

	scar_keyword = "piercecritical"

/datum/wound_pregen_data/electrical_damage/pierce/critical
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/pierce/critical

	threshold_minimum = 110

#undef ELECTRICAL_DAMAGE_REPAIR_WELD_BASE_DELAY
#undef ELECTRICAL_DAMAGE_REPLACE_METALS_BASE_DELAY
