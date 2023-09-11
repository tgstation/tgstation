#define OVERHEAT_ON_STASIS_HEAT_MULT 0.25

/datum/wound_pregen_data/burnt_metal
	abstract = TRUE

	required_limb_biostate = BIO_METAL
	required_wounding_types = list(WOUND_BURN)

	wound_series = WOUND_SERIES_METAL_BURN_OVERHEAT

/datum/wound_pregen_data/burnt_metal/generate_scar_priorities()
	return list("[BIO_METAL]")

/datum/wound/burn/robotic/overheat
	treat_text = "Introduction of a cold environment or lowering of body temperature."

	simple_desc = "Metals are overheated, increasing damage taken significantly and raising body temperature!"
	simple_treat_text = "Ideally <b>cryogenics</b>, but any source of <b>low body temperature</b> can work. <b>Fire exinguishers</b> and <b>showers</b> can quickly reduce \
	the temperature, but <b>will damage the limb</b>. <b>Clothing</b> reduces the water that makes it to the metal, and <b>gauze</b> binds it and <b>reduces</b> the damage taken."
	homemade_treat_text = "<b>Coffee vendors</b>, when hacked, dispense <b>ice water</b>, which can be used to lower your body temperature!"

	default_scar_file = METAL_SCAR_FILE

	wound_flags = (ACCEPTS_GAUZE) // gauze binds the metal and makes it resistant to thermal shock

	processes = TRUE

	/// The virtual temperature of the chassis. Crucial for many things, like our severity, the temp we transfer, our cooling damage, etc.
	var/chassis_temperature

	/// The lower bound of the chassis_temperature we can start with.
	var/starting_temperature_min = (BODYTEMP_NORMAL + 200)
	/// The upper bound of the chassis_temperature we can start with.
	var/starting_temperature_max = (BODYTEMP_NORMAL + 250)

	/// If [chassis_temperature] goes below this, we reduce in severity.
	var/cooling_threshold = (BODYTEMP_NORMAL + 3)
	/// If [chassis_temperature] goes above this, we increase in severity.
	var/heating_threshold = (BODYTEMP_NORMAL + 300)

	/// The buffer in kelvin we will subtract from the chassis_temperature of a wound we demote to.
	var/cooling_demote_buffer = 60
	/// The buffer in kelvin we will add to the chassis_temperature of a wound we promote to.
	var/heating_promote_buffer = 60

	/// The coefficient of heat transfer we will use when shifting our temp to the victim's.
	var/bodytemp_coeff = 0.04
	/// For every degree below normal bodytemp, we will multiply our incoming temperature by 1 + degrees * this. Allows incentivization of freezing yourself instead of just waiting.
	var/bodytemp_difference_expose_bonus_ratio = 0.035
	/// The coefficient of heat transfer we will use when shifting our victim's temp to ours.
	var/outgoing_bodytemp_coeff = 0
	/// The mult applied to heat output when we are on a important limb, e.g. head/torso.
	var/important_outgoing_mult = 1.2
	/// The coefficient of heat transfer we will use when shifting our temp to a turf.
	var/turf_coeff = 0.02

	/// If we are hit with burn damage, the damage will be multiplied against this to determine the effective heat we get.
	var/incoming_damage_heat_coeff = 3

	/// The coefficient of heat transfer we will use when receiving heat from reagent contact.
	var/base_reagent_temp_coefficient = 0.07

	/// The ratio of temp shift -> brute damage. Careful with this value, it can make stuff really really nasty.
	var/heat_shock_delta_to_damage_ratio = 0.2
	/// The minimum heat difference we must have on reagent contact to cause heat shock damage.
	var/heat_shock_minimum_delta = 5

	/// If we are sprayed with a extinguisher/shower with obscuring clothing on (think clothing that prevents surgery), the effect is multiplied against this.
	var/sprayed_with_reagent_clothed_mult = 0.25

	/// The max damage a given thermal shock can do. Used for preventing things like spalshing a beaker to instantly kill someone.
	var/heat_shock_max_damage_per_shock = 80

	/// The wound we demote to when we go below cooling threshold. If null, removes us.
	var/datum/wound/burn/robotic/demotes_to
	/// The wound we promote to when we go above heating threshold.
	var/datum/wound/burn/robotic/promotes_to

	/// The color of the light we will generate.
	var/light_color
	/// The power of the light we will generate.
	var/light_power
	/// The range of the light we will generate.
	var/light_range

	/// The glow we have attached to our victim, to simulate our limb glowing.
	var/obj/effect/dummy/lighting_obj/moblight/mob_glow

/datum/wound/burn/robotic/overheat/New(temperature)
	chassis_temperature = (isnull(temperature) ? get_random_starting_temperature() : temperature)

	return ..()

/datum/wound/burn/robotic/overheat/Destroy()
	QDEL_NULL(mob_glow)
	return ..()

/datum/wound/burn/robotic/overheat/set_victim(mob/living/new_victim)
	if (victim)
		QDEL_NULL(mob_glow)
		UnregisterSignal(victim, COMSIG_MOB_AFTER_APPLY_DAMAGE)
		UnregisterSignal(victim, COMSIG_ATOM_AFTER_EXPOSE_REAGENTS)
	if (new_victim)
		mob_glow = new_victim.mob_light(light_range, light_power, light_color)
		mob_glow.set_light_on(TRUE)
		RegisterSignal(new_victim, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(victim_attacked))
		RegisterSignal(new_victim, COMSIG_ATOM_AFTER_EXPOSE_REAGENTS, PROC_REF(victim_exposed_to_reagents))

	return ..()

/datum/wound/burn/robotic/overheat/proc/get_random_starting_temperature()
	return LERP(starting_temperature_min, starting_temperature_max, rand()) // LERP since we deal with decimals

/datum/wound/burn/robotic/get_limb_examine_description()
	return span_warning("The metal on this limb is glowing radiantly.")

/datum/wound/burn/robotic/overheat/handle_process(seconds_per_tick, times_fired)
	if (isnull(victim))
		var/turf/our_turf = get_turf(limb)
		if (!isnull(our_turf))
			expose_temperature(our_turf.GetTemperature(), (turf_coeff * seconds_per_tick))
		return
	if (outgoing_bodytemp_coeff <= 0)
		return
	var/statis_mult = 1
	if (IS_IN_STASIS(victim)) // stasis heavily reduces the ingoing and outgoing transfer of heat
		statis_mult *= OVERHEAT_ON_STASIS_HEAT_MULT

	var/difference_from_average = max((BODYTEMP_NORMAL - victim.bodytemperature), 0)
	var/difference_mult = 1 + (difference_from_average * bodytemp_difference_expose_bonus_ratio)
	if (expose_temperature(victim.bodytemperature, (bodytemp_coeff * seconds_per_tick * statis_mult * difference_mult)))
		return
	var/mult = outgoing_bodytemp_coeff
	if (limb_essential())
		mult *= important_outgoing_mult
	victim.adjust_bodytemperature(((chassis_temperature - victim.bodytemperature) * mult) * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick * statis_mult)

// Increase our temp based on burn damage it receives
/datum/wound/burn/robotic/overheat/proc/victim_attacked(datum/source, damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER

	if (def_zone != limb.body_zone) // use this proc since receive damage can also be called for like, chems and shit
		return

	if (!victim)
		return

	if (damagetype != BURN)
		return

	if (wound_bonus == CANT_WOUND)
		return

	var/effective_damage = (damage - blocked)
	if (effective_damage <= 0)
		return

	expose_temperature((chassis_temperature + effective_damage), incoming_damage_heat_coeff)

// Alternate method of cooling
// Can do it quickly, can do it anywhere, just have a fire extinguisher/shower
// The caveat is that this does a ton of brute damage if you're not gauzed up
// Clothes block a lot of the reagents so its not a really effective weapon against most people
/datum/wound/burn/robotic/overheat/proc/victim_exposed_to_reagents(datum/signal_source, list/reagents, datum/reagents/source, methods, volume_modifier, show_message)
	SIGNAL_HANDLER

	var/reagent_coeff = base_reagent_temp_coefficient
	if (!get_location_accessible(victim, limb.body_zone))
		reagent_coeff *= sprayed_with_reagent_clothed_mult

	if (istype(source.my_atom, /obj/effect/particle_effect/water/extinguisher)) // this used to be a lot, lot more modular, but sadly reagent temps/volumes and shit are horribly inconsistant
		expose_temperature(source.chem_temp, 1.7 * reagent_coeff, TRUE)
		return

	if (istype(source.my_atom, /obj/machinery/shower))
		expose_temperature(source.chem_temp, (10 * volume_modifier * reagent_coeff), TRUE)
		return

/// Adjusts chassis_temperature by the delta between temperature and itself, multiplied by coeff.
/// If heat_shock is TRUE, limb will receive brute damage based on the delta.
/datum/wound/burn/robotic/overheat/proc/expose_temperature(temperature, coeff = 0.02, heat_shock = FALSE)
	var/temp_delta = (temperature - chassis_temperature) * coeff
	var/heating_temp_delta_mult = 1
	if (heat_shock && abs(temp_delta) > heat_shock_minimum_delta)

		var/gauze_mult = 1
		var/obj/item/stack/gauze = limb.current_gauze
		if (gauze)
			gauze_mult *= (gauze.splint_factor) * 0.4 // very very effective

		if (victim)
			var/gauze_or_not = (!isnull(gauze) ? ", but [gauze] helps to keep it together" : "")
			var/clothing_text = (!get_location_accessible(victim, limb.body_zone) ? ", its clothing absorbing some of the heat" : "")
			victim.visible_message(span_warning("[victim]'s [limb.plaintext_zone] strains from the thermal shock[clothing_text][gauze_or_not]!"))
			playsound(victim, 'sound/items/welder.ogg', 25)

		var/unclamped_damage = (temp_delta * heat_shock_delta_to_damage_ratio) * gauze_mult
		var/damage = min(abs(unclamped_damage), heat_shock_max_damage_per_shock)
		var/percent_remaining = (damage / abs(unclamped_damage))

		heating_temp_delta_mult *= percent_remaining

		limb.receive_damage(brute = damage, wound_bonus = CANT_WOUND)

	var/heating_temp_delta = temp_delta * heating_temp_delta_mult

	if(temp_delta > 0)
		chassis_temperature = min(chassis_temperature + max(heating_temp_delta, 1), temperature)
	else
		chassis_temperature = max(chassis_temperature + min(heating_temp_delta, -1), temperature)

	return check_temperature()

// Removes, demotes, or promotes ourself to a new wound type if our temperature is past a heating/cooling threshold.
/datum/wound/burn/robotic/overheat/proc/check_temperature()
	if (chassis_temperature < cooling_threshold)
		if (demotes_to)
			victim.visible_message(span_green("[victim]'s [limb.plaintext_zone] turns a more pleasant thermal color as it cools down a little..."), span_green("Your [limb.plaintext_zone] seems to cool down a little!"))
			replace_wound(new demotes_to(cooling_threshold - cooling_demote_buffer))
			return TRUE
		else
			victim.visible_message(span_green("[victim]'s [limb.plaintext_zone] simmers gently as it returns to its usual colors!"), span_green("Your [limb.plaintext_zone] simmers gently as it returns to its usual colors!"))
			remove_wound()
			return TRUE
	else if (promotes_to && chassis_temperature >= heating_threshold)
		victim.visible_message(span_warning("[victim]'s [limb.plaintext_zone] brightens as it overheats further!"), span_userdanger("Your [limb.plaintext_zone] sizzles and brightens as it overheats further!"))
		replace_wound(new promotes_to(heating_threshold + heating_promote_buffer))
		return TRUE

/datum/wound/burn/robotic/overheat/get_wound_status_info()
	var/current_temp_celcius = round(chassis_temperature - T0C, 0.1)
	var/current_temp_fahrenheit = round(chassis_temperature * 1.8-459.67, 0.1)

	var/cool_celcius = round(cooling_threshold - T0C, 0.1)
	var/cool_fahrenheit = round(cooling_threshold * 1.8-459.67, 0.1)

	var/heat_celcius = round(heating_threshold - T0C, 0.1)
	var/heat_fahrenheit = round(heating_threshold * 1.8-459.67, 0.1)

	return "Its current temperature is [span_blue("[current_temp_celcius ] &deg;C ([current_temp_fahrenheit] &deg;F)")], \
	and needs to cool to [span_nicegreen("[cool_celcius] &deg;C ([cool_fahrenheit] &deg;F)")], but \
	will worsen if heated to [span_purple("[heat_celcius] &deg;C ([heat_fahrenheit] &deg;F)")]."

/datum/wound/burn/robotic/overheat/get_xadone_progress_to_qdel()
	return INFINITY

/datum/wound/burn/robotic/overheat/moderate
	name = "Transient Overheating"
	desc = "External metals have exceeded lower-bound thermal limits and have lost some structural integrity, increasing damage taken as well as the chance to \
		sustain additional wounds."
	occur_text = "lets out a slight groan as it turns a dull shade of thermal red"
	examine_desc = "is glowing a dull thermal red and giving off heat"
	treat_text = "Reduction of body temperature to expedite the passive heat dissipation - or, if thermal shock is to be risked, application of a fire extinguisher/shower."
	severity = WOUND_SEVERITY_MODERATE

	damage_multiplier_penalty = 1.1 //1.1x damage taken

	starting_temperature_min = (BODYTEMP_NORMAL + 350)
	starting_temperature_max = (BODYTEMP_NORMAL + 400)

	cooling_threshold = (BODYTEMP_NORMAL + 100)
	heating_threshold = (BODYTEMP_NORMAL + 500)

	cooling_demote_buffer = 60
	heating_promote_buffer = 100

	a_or_from = "from"

	// easy to get
	threshold_penalty = 30

	status_effect_type = /datum/status_effect/wound/burn/robotic/moderate

	sound_volume = 20

	outgoing_bodytemp_coeff = 0.007
	bodytemp_coeff = 0.006

	base_reagent_temp_coefficient = 0.05
	heat_shock_delta_to_damage_ratio = 0.2

	promotes_to = /datum/wound/burn/robotic/overheat/severe

	light_color = COLOR_RED
	light_power = 0.1
	light_range = 0.5

	can_scar = FALSE

/datum/wound_pregen_data/burnt_metal/transient_overheat
	abstract = FALSE

	wound_path_to_generate = /datum/wound/burn/robotic/overheat/moderate

	threshold_minimum = 30

/datum/wound/burn/robotic/overheat/severe
	name = "Thermal Overload"
	desc = "Exterior plating has surpassed critical thermal levels, causing significant failure in structural integrity and overheating of internal systems."
	occur_text = "sizzles, the externals turning a dull shade of orange"
	examine_desc = "appears discolored and polychromatic, parts of it glowing a dull orange"
	treat_text = "Isolation from physical hazards, and accommodation of passive heat dissipation - active cooling may be used, but temperature differentials significantly \
		raise the risk of thermal shock."
	severity = WOUND_SEVERITY_SEVERE

	a_or_from = "from"

	threshold_penalty = 65

	status_effect_type = /datum/status_effect/wound/burn/robotic/severe
	damage_multiplier_penalty = 1.25 // 1.25x damage taken

	starting_temperature_min = (BODYTEMP_NORMAL + 550)
	starting_temperature_max = (BODYTEMP_NORMAL + 600)

	heating_promote_buffer = 150

	cooling_threshold = (BODYTEMP_NORMAL + 375)
	heating_threshold = (BODYTEMP_NORMAL + 800)

	outgoing_bodytemp_coeff = 0.008
	bodytemp_coeff = 0.004

	base_reagent_temp_coefficient = 0.03
	heat_shock_delta_to_damage_ratio = 0.2

	demotes_to = /datum/wound/burn/robotic/overheat/moderate
	promotes_to = /datum/wound/burn/robotic/overheat/critical

	light_color = COLOR_BRIGHT_ORANGE
	light_power = 0.8
	light_range = 0.5

	scar_keyword = "burnsevere"

/datum/wound_pregen_data/burnt_metal/severe
	abstract = FALSE

	wound_path_to_generate = /datum/wound/burn/robotic/overheat/severe

	threshold_minimum = 80

/datum/wound/burn/robotic/overheat/critical
	name = "Runaway Exothermy"
	desc = "Carapace is beyond melting point, causing catastrophic structural integrity failure as well as massively heating up the subject."
	occur_text = "turns a bright shade of radiant white as it sizzles and melts"
	examine_desc = "is a blinding shade of white, almost melting from the heat"
	treat_text = "Immediate confinement to cryogenics, as rapid overheating and physical vulnerability may occur. Active cooling is not advised, \
		since the thermal shock may be lethal with such a temperature differential."
	severity = WOUND_SEVERITY_CRITICAL

	a_or_from = "from"

	sound_effect = 'sound/effects/wounds/sizzle2.ogg'

	threshold_penalty = 100

	status_effect_type = /datum/status_effect/wound/burn/robotic/critical

	damage_multiplier_penalty = 1.4 //1.4x damage taken

	starting_temperature_min = (BODYTEMP_NORMAL + 1050)
	starting_temperature_max = (BODYTEMP_NORMAL + 1100)

	cooling_demote_buffer = 100

	cooling_threshold = (BODYTEMP_NORMAL + 775)
	heating_threshold = INFINITY

	outgoing_bodytemp_coeff = 0.0076 // burn... BURN...
	bodytemp_coeff = 0.002

	base_reagent_temp_coefficient = 0.02
	heat_shock_delta_to_damage_ratio = 0.25

	demotes_to = /datum/wound/burn/robotic/overheat/severe

	wound_flags = (MANGLES_EXTERIOR|ACCEPTS_GAUZE)

	light_color = COLOR_VERY_SOFT_YELLOW
	light_power = 1.3
	light_range = 1.5

	scar_keyword = "burncritical"

/datum/wound_pregen_data/burnt_metal/critical
	abstract = FALSE

	wound_path_to_generate = /datum/wound/burn/robotic/overheat/critical
	threshold_minimum = 140

#undef OVERHEAT_ON_STASIS_HEAT_MULT
