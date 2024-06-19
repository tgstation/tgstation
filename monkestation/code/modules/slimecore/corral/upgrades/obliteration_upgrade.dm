/datum/corral_upgrade/obliteration
	name = "Slime Obliteration Upgrade"
	desc = "Just obliterates slimes that enter the cage."
	cost = 5000


/datum/corral_upgrade/obliteration/on_add(datum/corral_data/parent)
	for(var/mob/living/basic/slime/slime as anything in parent.managed_slimes)
		parent.managed_slimes -= slime
		qdel(slime)

/datum/corral_upgrade/obliteration/on_slime_entered(mob/living/basic/slime/slime, datum/corral_data/parent)
	parent.managed_slimes -= slime
	qdel(slime)
