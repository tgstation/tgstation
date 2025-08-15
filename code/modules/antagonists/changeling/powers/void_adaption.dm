/datum/action/changeling/void_adaption
	name = "Void Adaption"
	desc = "We prepare our cells to resist the hostile environment outside of the station. We may freely travel wherever we wish."
	helptext = "This ability is passive, and will automatically protect us in situations of extreme cold or vacuum, \
		as well as removing our need to breathe oxygen, although we will still be affected by hazardous gases. \
		While it is actively protecting us from temperature or pressure it reduces our chemical regeneration rate."
	owner_has_control = FALSE
	dna_cost = 2

	/// Traits we apply to become immune to the environment
	var/static/list/gain_traits = list(TRAIT_NO_BREATHLESS_DAMAGE, TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE, TRAIT_SNOWSTORM_IMMUNE)
	/// How much we slow chemical regeneration while active, in chems per second
	var/recharge_slowdown = 0.25
	/// Are we currently protecting our user?
	var/currently_active = FALSE

/datum/action/changeling/void_adaption/on_purchase(mob/user, is_respec)
	. = ..()
	user.add_traits(gain_traits, REF(src))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(check_environment))

/datum/action/changeling/void_adaption/Remove(mob/remove_from)
	remove_from.remove_traits(gain_traits, REF(src))
	UnregisterSignal(remove_from, COMSIG_LIVING_LIFE)
	if (currently_active)
		on_removed_adaption(remove_from, "Our cells relax, despite the danger!")
	return ..()

/// Checks if we would be providing any useful benefit at present
/datum/action/changeling/void_adaption/proc/check_environment(mob/living/void_adapted)
	SIGNAL_HANDLER

	var/list/active_reasons = list()

	var/datum/gas_mixture/environment = void_adapted.loc.return_air()
	if (!isnull(environment))
		var/vulnerable_temperature = void_adapted.get_body_temp_cold_damage_limit()
		var/affected_temperature = environment.return_temperature()
		if (ishuman(void_adapted))
			var/mob/living/carbon/human/special_boy = void_adapted
			var/cold_protection = special_boy.get_cold_protection(affected_temperature)
			vulnerable_temperature *= (1 - cold_protection)

			var/affected_pressure = special_boy.calculate_affecting_pressure(environment.return_pressure())
			if (affected_pressure < HAZARD_LOW_PRESSURE)
				active_reasons += "vacuum"

		if (affected_temperature < vulnerable_temperature)
			active_reasons += "cold"

	var/should_be_active = !!length(active_reasons)
	if (currently_active == should_be_active)
		return

	if (!should_be_active)
		on_removed_adaption(void_adapted, "Our cells relax in safer air.")
		return
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(void_adapted)
	to_chat(void_adapted, span_changeling("Our cells harden themselves against the [pick(active_reasons)]."))
	changeling_data?.chem_recharge_slowdown -= recharge_slowdown
	currently_active = TRUE

/// Called when we stop being adapted
/datum/action/changeling/void_adaption/proc/on_removed_adaption(mob/living/former, message)
	var/datum/antagonist/changeling/changeling_data = IS_CHANGELING(former)
	to_chat(former, span_changeling(message))
	changeling_data?.chem_recharge_slowdown += recharge_slowdown
	currently_active = FALSE
