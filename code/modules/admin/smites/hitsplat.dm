/datum/smite/hitsplat
	name = "Hitsplat"

/datum/smite/hitsplat/effect(client/user, mob/living/target)
	. = ..()

	target.AddComponent(/datum/component/hitsplat)

// Dragon dagger spec spam.
/datum/smite/hitsplat/stackout
	name = "Stackout (hitsplat)"

/datum/smite/hitsplat/stackout/effect(client/user, mob/living/target)
	. = ..()

	for(var/attack in 1 to 4)
		target.apply_damage(rand(0, 50))
		target.apply_damage(rand(0, 50))
		// dragon dagger has a 2 tick attack
		sleep(1.2 SECONDS)
