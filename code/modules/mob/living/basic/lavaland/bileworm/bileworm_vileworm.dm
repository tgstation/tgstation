/mob/living/basic/mining/bileworm/vileworm
	name = "vileworm"
	desc = "Vileworms, the product of lavaland's corruptive nature on the natural fauna."
	icon_state = "vileworm"
	icon_living = "vileworm"
	icon_dead = "vileworm_dead"
	maxHealth = 175
	health = 175

	attack_action_path = /datum/action/cooldown/mob_cooldown/bileworm_spew/corrupt
	evolve_path = null

/datum/action/cooldown/mob_cooldown/bileworm_spew/corrupt
	name = "Spew Corrupted Bile"
	desc = "Spew a barrage of corrupted bile globs."
	cooldown_time = 2.5 SECONDS
	acid_type = /obj/effect/bileworm_acid/corrupt
	additional_shots = 6
	shot_delay = 0.1 SECONDS

/obj/effect/bileworm_acid/corrupt
	icon_state = "corrupt_bile_glob"
	damage = 27
