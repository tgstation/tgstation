//OTHER IDEAS
// force pull a single target into the fissure? to prevent players from trying to stay out of it
// past 50% health, can activate hazards inside the fissure to make fight more difficult
// charging bubble blast that deals heavy damage and blows player back into magma if caught, hitbox is wide as crab sprite above and below

/datum/action/cooldown/mob_cooldown/jump
	name = "Crustacean Reposition"
	desc = "Jump to a new location without creating a fissure. Much shorter cooldown than the full version."
	shared_cooldown = MOB_SHARED_COOLDOWN_1

/datum/action/cooldown/mob_cooldown/jump/Activate(atom/target_atom)
	StartCooldownSelf(INFINITY)
	jump(owner, target_atom)
	StartCooldownOthers(1.5 SECONDS)

/datum/action/cooldown/mob_cooldown/jump/proc/jump(mob/living/crab, atom/target)
	///TODO
	//player chooses a location with a point and click before activate
	//	if no player, auto decision somewhere on a nearby target or random if none
	//chargeup sequence, cant do anything
	//leap
	return
