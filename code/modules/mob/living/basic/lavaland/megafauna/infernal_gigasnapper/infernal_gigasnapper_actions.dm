//OTHER IDEAS
// force pull a single target into the fissure? to prevent players from trying to stay out of it
// past 50% health, can activate hazards inside the fissure to make fight more difficult
// charging bubble blast that deals heavy damage and blows player back into magma if caught, hitbox is wide as crab sprite above and below

/datum/action/cooldown/mob_cooldown/side_charge
	name = "Pyroclastic Plow"
	desc = "Charge left or right at a foe without warning, dealing massive damage. Only usable when a foe is located to your left or right."
	shared_cooldown = MOB_SHARED_COOLDOWN_1

/datum/action/cooldown/mob_cooldown/side_charge/Activate(atom/target_atom)
	StartCooldownSelf(INFINITY)
	charge(owner, target_atom)
	//spew now off cooldown shortly
	StartCooldownOthers(1.5 SECONDS)

/datum/action/cooldown/mob_cooldown/side_charge/proc/charge(mob/living/crab, atom/target)
	///TODO
	//find enemy to the left or right
	//	if not found, return (no cooldown based of returning false)
	//charge to the enemy's side, moving very fast and disabling abilities and player movement
	//	if charge hits, signal sends enemy flying up or down and crab stops
	//	if charge hits a wall or rock, break wall/rock and just stop
	return

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

/datum/action/cooldown/mob_cooldown/jump/molten_wall
	name = "Molten Fissure Leap"
	desc = "After charging up, jump to a new spot. After landing, channel again to create a long lasting invulnerable wall above and below you that damages targets when they touch it."

/datum/action/cooldown/mob_cooldown/jump/molten_wall/Activate(atom/target_atom)
	StartCooldownSelf(INFINITY)
	jump(owner, target_atom)
	//wall after jump is done
	StartCooldownOthers(1.5 SECONDS)

/datum/action/cooldown/mob_cooldown/jump/molten_wall/jump(mob/living/crab, atom/target)
	..()
	wall()

/datum/action/cooldown/mob_cooldown/jump/molten_wall/proc/wall(mob/living/crab, atom/target)
	///TODO
	//raise a molten wall above and below
	return

/datum/action/cooldown/mob_cooldown/toggle_pinching
	name = "Toggle Pinching"
	desc = "While pinching is active, you will randomly pinch above and below you when enemies are nearby. If for some reason you don't want to, you can disable it."
	shared_cooldown = MOB_SHARED_COOLDOWN_1

/datum/action/cooldown/mob_cooldown/toggle_pinching/Activate(atom/target_atom)
	//TODO: disable passive behavior to pinch nearby enemies, this should just be a var toggle
	StartCooldownSelf(1 SECONDS)
