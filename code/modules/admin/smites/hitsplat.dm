/datum/smite/hitsplat
	name = "Hitsplat"

/datum/smite/hitsplat/effect(client/user, mob/living/target)
	. = ..()
	target.AddComponent(/datum/component/hitsplat, /obj/effect/overlay/vis/hitsplat/lore_accurate)


// Dragon dagger spec spam.
/datum/smite/hitsplat/stackout
	name = "Stackout (Hitsplat)"

/datum/smite/hitsplat/stackout/effect(client/user, mob/living/target)
	. = ..()
	for(var/attack in 1 to 4)
		playsound(target, SFX_SWING_HIT, 50, TRUE)
		target.apply_damage(rand(0, 50))
		target.apply_damage(rand(0, 50))
		// dragon dagger has a 4 tick attack
		sleep(2.4 SECONDS)
