/datum/corral_upgrade
	var/name = "Generic Corral Upgrade"
	var/desc = "Generic Corral Upgrade Description"
	///the amount of xenobiology points this pen upgrade costs
	var/cost = 0

/datum/corral_upgrade/proc/on_add(datum/corral_data/parent)
	return

/datum/corral_upgrade/proc/on_slime_entered(mob/living/basic/slime/slime)
	return

/datum/corral_upgrade/proc/on_slime_exited(mob/living/basic/slime/slime)
	return
