/datum/action/cooldown/spell/emp
	name = "Emplosion"
	desc = "This spell causes an EMP in an area."
	button_icon_state = "emp"
	sound = 'sound/items/weapons/zapbang.ogg'

	school = SCHOOL_EVOCATION

	/// The heavy radius of the EMP
	var/emp_heavy = 2
	/// The light radius of the EMP
	var/emp_light = 3

/datum/action/cooldown/spell/emp/cast(atom/cast_on)
	. = ..()
	empulse(get_turf(cast_on), emp_heavy, emp_light)

/datum/action/cooldown/spell/emp/disable_tech
	name = "Disable Tech"
	desc = "This spell disables all weapons, cameras and most other technology in range."
	sound = 'sound/effects/magic/disable_tech.ogg'

	cooldown_time = 40 SECONDS
	cooldown_reduction_per_rank = 5 SECONDS

	invocation = "NEC CANTIO!"
	invocation_type = INVOCATION_SHOUT

	emp_heavy = 6
	emp_light = 10
