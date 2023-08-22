#define ELECTRICAL_DAMAGE_REPAIR_WELD_BASE_DELAY 3 SECONDS
#define ELECTRICAL_DAMAGE_REPLACE_METALS_BASE_DELAY 4 SECONDS

/datum/wound/electrical_damage/pierce
	wound_type = WOUND_PIERCE
	wound_series = WOUND_SERIES_WIRE_PIERCE_ELECTRICAL_DAMAGE

	limb_unimportant_damage_mult = 0.5
	/// If [get_intensity_mult()] is at or above this, the limb gets disabled.
	var/disable_at_intensity_mult

	/// The bodyheat our victim must be at or above to start getting passive healing.
	var/heat_thresh_to_heal = (BODYTEMP_NORMAL + 20)
	/// The mult that heat differences between normal and current bodytemp is multiplied against. Controls passive heat healing.
	var/heat_differential_healing_mult = 30

	/// Percent chance for a heat repair to give the victim a message.
	var/heat_heal_message_chance = 20

/datum/wound_pregen_data/electrical_damage/pierce
	abstract = TRUE

/datum/wound/electrical_damage/pierce/wound_injury(datum/wound/electrical_damage/old_wound, attack_direction)
	RegisterSignals(limb, list(COMSIG_BODYPART_GAUZED, COMSIG_BODYPART_GAUZE_DESTROYED), PROC_REF(update_inefficiencies))

	return ..()

/datum/wound/electrical_damage/pierce/set_limb(obj/item/bodypart/new_limb)
	if (limb)
		UnregisterSignal(limb, list(COMSIG_BODYPART_GAUZED, COMSIG_BODYPART_GAUZE_DESTROYED))
	if (new_limb)
		RegisterSignals(new_limb, list(COMSIG_BODYPART_GAUZED, COMSIG_BODYPART_GAUZE_DESTROYED), PROC_REF(update_inefficiencies))

	. = ..()

	if (limb)
		update_inefficiencies()

/datum/wound/electrical_damage/pierce/set_victim(new_victim)
	if (victim)
		victim.remove_status_effect(/datum/status_effect/limp)

	return ..()

/datum/wound/electrical_damage/pierce/modify_seconds_for_intensity_after_mult(seconds_for_intensity)
	if (!victim)
		return seconds_for_intensity

	var/healing_amount = max((victim.bodytemperature - heat_thresh_to_heal), 0) * heat_differential_healing_mult
	if (healing_amount != 0 && prob(heat_heal_message_chance))
		to_chat(victim, span_notice("You feel the solder within your [limb.plaintext_zone] reform and repair your [name]..."))

	return seconds_for_intensity - healing_amount

/datum/wound/electrical_damage/pierce/moderate
	name = "Punctured Capacitor"
	desc = "A major capacitor has been broken open, causing slow and intensifying electrical damage, as well as limb dysfunction."
	occur_text = "shoots out a short stream of sparks"
	examine_desc = "is shuddering gently, movements a little weak"
	treat_text = "Replacing of damaged wiring, though repairs via wirecutting instruments or sutures may suffice, albiet at limited efficiency. In case of emergency, \
				subject may be subjected to high temperatures to allow solder to reset."

	sound_effect = 'sound/effects/wounds/robotic_slash_T1.ogg'

	severity = WOUND_SEVERITY_MODERATE

	sound_volume = 30

	threshold_minimum = 40
	threshold_penalty = 30

	intensity = 10 SECONDS
	processing_full_shock_threshold = 8 MINUTES

	processing_shock_power_per_second_max = 1.1
	processing_shock_power_per_second_min = 0.9

	processing_shock_stun_chance = 0.5
	processing_shock_spark_chance = 35

	process_shock_spark_count_max = 1
	process_shock_spark_count_min = 1

	wirecut_repair_percent = 0.015 //15% per wirecut
	wire_repair_percent = 0.06 //6% per suture

	interaction_efficiency_penalty = 2
	limp_slowdown = 2
	limp_chance = 60

	wiring_reset = TRUE

	initial_sparks_amount = 1

	status_effect_type = /datum/status_effect/wound/electrical_damage/pierce/moderate

	a_or_from = "a"

	scar_keyword = "robotic_piercemoderate"

/datum/wound_pregen_data/electrical_damage/pierce/moderate
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/pierce/moderate

/datum/wound/electrical_damage/pierce/severe
	name = "Penetrated Transformer"
	desc = "A major transformer has been pierced, causing slow-to-progess but eventually intense electrical damage and limb dysfunction from power loss."
	occur_text = "sputters and goes limp for a moment as it ejects a stream of sparks"
	examine_desc = "is shuddering significantly, servos briefly giving way in a rythmic pattern"
	treat_text = "Containment of damaged wiring via gauze, securing of wires via a wirecutter/hemostat, then application of fresh wiring or sutures."

	sound_effect = 'sound/effects/wounds/robotic_slash_T2.ogg'

	severity = WOUND_SEVERITY_SEVERE

	sound_volume = 15

	threshold_minimum = 60
	threshold_penalty = 40

	intensity = 20 SECONDS
	processing_full_shock_threshold = 7 MINUTES

	processing_shock_power_per_second_max = 1.4
	processing_shock_power_per_second_min = 1.2

	processing_shock_stun_chance = 2.5
	processing_shock_spark_chance = 60

	process_shock_spark_count_max = 2
	process_shock_spark_count_min = 1

	wirecut_repair_percent = 0.012 //12% per wirecut
	wire_repair_percent = 0.04 //4% per suture

	interaction_efficiency_penalty = 2.5
	limp_slowdown = 4
	limp_chance = 90

	initial_sparks_amount = 3

	disable_at_intensity_mult = 1

	status_effect_type = /datum/status_effect/wound/electrical_damage/pierce/moderate

	a_or_from = "a"

	scar_keyword = "robotic_piercemoderate"

/datum/wound_pregen_data/electrical_damage/pierce/severe
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/pierce/severe

/datum/wound/electrical_damage/pierce/critical
	name = "Ruptured PSU"
	desc = "The local PSU of this limb has suffered a core rupture, causing a progressive power failure that will slowly intensify into extreme electrical damage and massive limb dysfunction."
	occur_text = "flashes with radiant blue, emitting a noise not unlike a jacobs ladder"
	examine_desc = "'s PSU is visible, with a sizable hole in the center"
	treat_text = "Immediate securing via gauze, followed by emergency cable replacement and securing via wirecutters or hemostat. \
				If the fault has become uncontrollable, extreme heat therapy is reccomended."

	severity = WOUND_SEVERITY_CRITICAL
	wound_flags = (ACCEPTS_GAUZE|MANGLES_FLESH)

	sound_effect = 'sound/effects/wounds/robotic_slash_T3.ogg'

	sound_volume = 30

	threshold_minimum = 110
	threshold_penalty = 60

	intensity = 40 SECONDS
	processing_full_shock_threshold = 6.5 MINUTES

	processing_shock_power_per_second_max = 2.1
	processing_shock_power_per_second_min = 1.9

	processing_shock_stun_chance = 1
	processing_shock_spark_chance = 90

	process_shock_spark_count_max = 3
	process_shock_spark_count_min = 2

	wirecut_repair_percent = 0.08 //8% per wirecut
	wire_repair_percent = 0.03 //3% per suture

	interaction_efficiency_penalty = 3
	limp_slowdown = 6
	limp_chance = 100

	initial_sparks_amount = 8

	status_effect_type = /datum/status_effect/wound/electrical_damage/pierce/moderate

	a_or_from = "a"

	scar_keyword = "robotic_piercecritical"

/datum/wound_pregen_data/electrical_damage/pierce/critical
	abstract = FALSE

	wound_path_to_generate = /datum/wound/electrical_damage/pierce/critical

/datum/wound/electrical_damage/pierce/proc/update_inefficiencies()
	SIGNAL_HANDLER

	var/intensity_mult = get_intensity_mult()

	var/obj/item/stack/gauze = limb.current_gauze
	if(limb.body_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(gauze?.splint_factor)
			limp_slowdown = (initial(limp_slowdown) * gauze.splint_factor) * intensity_mult
			limp_chance = (initial(limp_chance) * gauze.splint_factor) * intensity_mult
		else
			limp_slowdown = initial(limp_slowdown) * intensity_mult
			limp_chance = initial(limp_chance) * intensity_mult
		if (!victim.has_status_effect(/datum/status_effect/limp))
			victim.apply_status_effect(/datum/status_effect/limp)
		for (var/datum/status_effect/limp/limper in victim.status_effects)
			limper.update_limp()
			break

	else if(limb.body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		if(gauze?.splint_factor)
			interaction_efficiency_penalty = (1 + ((interaction_efficiency_penalty - 1) * gauze.splint_factor) * intensity_mult)
		else
			interaction_efficiency_penalty = (initial(interaction_efficiency_penalty) * intensity_mult)

	if(disable_at_intensity_mult && intensity_mult >= disable_at_intensity_mult)
		set_disabling(gauze)

	limb.update_wounds()

/datum/wound/electrical_damage/pierce/adjust_intensity()
	. = ..()
	update_inefficiencies()

#undef ELECTRICAL_DAMAGE_REPAIR_WELD_BASE_DELAY
#undef ELECTRICAL_DAMAGE_REPLACE_METALS_BASE_DELAY
