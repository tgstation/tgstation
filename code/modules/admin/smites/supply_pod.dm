#define SUPPLY_POD_FIRE_RANGE

/// Throws a supply pod at the target, with no item inside
/datum/smite/supply_pod
	name = "Supply Pod"

	// punish_log() is handled by the centcom_podlauncher datum
	should_log = FALSE

/datum/smite/supply_pod/effect(client/user, mob/living/target)
	. = ..()
	var/datum/centcom_podlauncher/plaunch = new(user)
	plaunch.specificTarget = target
	plaunch.launchChoice = 0
	plaunch.damageChoice = 1
	plaunch.explosionChoice = 1
	plaunch.temp_pod.damage = 40 // bring the mother fuckin ruckus
	plaunch.temp_pod.explosionSize = list(0, 0, 0, SUPPLY_POD_FIRE_RANGE)
	plaunch.temp_pod.effectStun = TRUE

#undef SUPPLY_POD_FIRE_RANGE
