/mob/living/basic/mining/bileworm/vileworm
	name = "vileworm"
	desc = "Vileworms, the product of lavaland's corruptive nature on the natural fauna."
	icon_state = "vileworm"
	icon_living = "vileworm"
	icon_dead = "vileworm_dead"
	maxHealth = 150
	health = 150

	attack_action_path = /datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/bileworm/vileworm
	evolve_path = null

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/bileworm/vileworm
	name = "Spew Corrupted Bile"
	desc = "Spews corrupted bile everywhere. Must resurface after use to refresh."
	projectile_type = /obj/projectile/bileworm_acid/vile

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/bileworm/vileworm/Activate(atom/target_atom)
	StartCooldownSelf(INFINITY)
	attack_sequence(owner, target_atom)
	//faster than unevolved
	StartCooldownOthers(1.5 SECONDS)

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/bileworm/vileworm/attack_sequence(mob/living/firer, atom/target)
	fire_in_directions(firer, target, GLOB.cardinals)
	SLEEP_CHECK_DEATH(0.25 SECONDS, firer)
	fire_in_directions(firer, target, GLOB.diagonals)
	SLEEP_CHECK_DEATH(0.25 SECONDS, firer)
	fire_in_directions(firer, target, GLOB.cardinals)
	// surprise!
	if(prob(25))
		SLEEP_CHECK_DEATH(0.25 SECONDS, firer)
		fire_in_directions(firer, target, GLOB.diagonals)

/obj/projectile/bileworm_acid/vile
	name = "corrupted bile"
	icon_state = "vileworm"
