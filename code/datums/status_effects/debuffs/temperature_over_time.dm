/**
 * Affects temperature over time.
 * I don't know how this wasn't a thing already.

 * Incidentally: Thermal insulation is actually really bad for this, since it traps the temperature inside.
 * If you're going to use this in a situation where it'd make sense for insulation to hinder its effects,
 * you should to check for it manually.
 */

/datum/status_effect/temperature_over_time
	id = "temp_ot"
	alert_type = null // no alert. you do the sprite
	remove_on_fullheal = TRUE
	on_remove_on_mob_delete = TRUE
	tick_interval = 1 SECONDS

	duration = 60 SECONDS

	/// How much to change temperature per second.
	var/temperature_value = 10
	/// How much to remove from above variable per second.
	var/temperature_decay = 1
	/// Cap of temperature, won't apply the effect above this.
	var/capped_temperature_hot = BODYTEMP_HEAT_WARNING_2
	/// Cap of temperature, won't apply the effect below this.
	var/capped_temperature_cold = BODYTEMP_COLD_WARNING_2
	/// Effect removed outright at this temperature or above.
	var/removal_temperature_hot = BODYTEMP_HEAT_WARNING_3
	/// Effect removed outright at this temperature or below.
	var/removal_temperature_cold = BODYTEMP_COLD_WARNING_3

/datum/status_effect/temperature_over_time/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/temperature_over_time/on_apply()
	. = ..()
	if((HAS_TRAIT(owner, TRAIT_RESISTHEAT) && temperature_value > 1))
		qdel(src) // git out
	else if((HAS_TRAIT(owner, TRAIT_RESISTCOLD) && temperature_value < 1))
		qdel(src) // git out

/datum/status_effect/temperature_over_time/on_remove()
	return ..()

/datum/status_effect/temperature_over_time/get_examine_text()

	if(temperature_value > 0)
		return "[owner.p_They()] [owner.p_are()] sweating bullets!"

	return "[owner.p_They()] [owner.p_are()] shivering!"

/datum/status_effect/temperature_over_time/tick(seconds_between_ticks)
	if((TRAIT_RESISTHEAT && temperature_value > 1) || (TRAIT_RESISTCOLD && temperature_value < 1))
		qdel(src) // git out
		return
	temperaturetion(seconds_between_ticks)

/datum/status_effect/temperature_over_time/proc/temperaturetion(seconds_per_tick)

	// I feel like there should be an easier way to do this but I am a fool
	if(capped_temperature_hot && owner.bodytemperature > capped_temperature_hot)
		return
	if(capped_temperature_cold && owner.bodytemperature < capped_temperature_cold)
		return

	owner.adjust_bodytemperature(temperature_value * seconds_per_tick) // note that this has no softcap reduction, unlike fire
	temperature_value += temperature_decay
	if(temperature_value == 0)
		qdel(src)

	if(removal_temperature_hot && owner.bodytemperature > removal_temperature_hot)
		qdel(src)
		return
	if(removal_temperature_cold && owner.bodytemperature < removal_temperature_cold)
		qdel(src)
		return

/datum/status_effect/temperature_over_time/chip_overheat
	id = "temp_ot_chip"
	temperature_value = 15
	temperature_decay = -0.5
	duration = 15 SECONDS
	capped_temperature_hot = BODYTEMP_HEAT_WARNING_3
	removal_temperature_cold = BODYTEMP_COLD_WARNING_1 // internal cooling...

	removal_temperature_hot = null
	capped_temperature_cold = null
