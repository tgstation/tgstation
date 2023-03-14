
/area/ruin/space/meateor
	name = "organic asteroid"

/// Give it an exit wound
/obj/effect/mob_spawn/corpse/human/tigercultist/perforated

/obj/effect/mob_spawn/corpse/human/tigercultist/perforated/special(mob/living/carbon/human/spawned_human)
	. = ..()
	var/datum/wound/pierce/critical/exit_hole = new()
	exit_hole.apply_wound(spawned_human.get_bodypart(BODY_ZONE_CHEST))
