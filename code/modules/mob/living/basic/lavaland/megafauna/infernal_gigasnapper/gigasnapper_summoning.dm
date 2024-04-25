
/datum/action/cooldown/mob_cooldown/jump
	name = "Call of Cancer"
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
