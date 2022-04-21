/// A status effect used for specifying confusion on a living mob.
/// Created automatically with /mob/living/set_confusion.
/datum/status_effect/confusion
	id = "confusion"
	alert_type = null
	/// How strong the confusion effect is on us.
	/// The longer duration remaining, the stronger the effect.
	var/strength = 1

/datum/status_effect/confusion/on_creation(mob/living/new_owner, duration = 10 SECONDS, strength = 1)
	set_strength(strength)
	set_duration(duration, adjust_strength = FALSE)
	return ..()

/datum/status_effect/confusion/tick()
	if(duration - world.time >= 40 SECONDS)
		set_strength(3)

/datum/status_effect/confusion/proc/set_strength(new_strength)
	if(!isnum(new_strength))
		CRASH("")

	strength = new_strength

/datum/status_effect/confusion/proc/set_strength(new_duration)
	if(!isnum(new_duration))
		CRASH("")

	duration = new_duration
