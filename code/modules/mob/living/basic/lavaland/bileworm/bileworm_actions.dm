/datum/action/cooldown/mob_cooldown/resurface
	name = "Resurface"
	desc = "Burrow underground, and then move to a new location near your target. Must spew bile to refresh."
	shared_cooldown = MOB_SHARED_COOLDOWN_1

/datum/action/cooldown/mob_cooldown/resurface/Activate(atom/target_atom)
	StartCooldownSelf(INFINITY)
	burrow(owner, target_atom)
	//spew now off cooldown shortly
	StartCooldownOthers(1.5 SECONDS)

/datum/action/cooldown/mob_cooldown/resurface/proc/burrow(mob/living/burrower, atom/target)
	var/turf/unburrow_turf = get_unburrow_turf(burrower, target)
	if(!unburrow_turf) // means all the turfs nearby are station turfs or something, not lavaland
		to_chat(burrower, span_warning("Couldn't burrow anywhere near the target!"))
		return //just put it on cooldown and let the other ability reactivate, you couldn't burrow and that's okay.
	playsound(burrower, 'sound/effects/break_stone.ogg', 50, TRUE)
	burrower.status_flags |= GODMODE
	burrower.invisibility = INVISIBILITY_MAXIMUM
	burrower.forceMove(unburrow_turf)
	//not that it's gonna die with godmode but still
	SLEEP_CHECK_DEATH(rand(0.75 SECONDS, 1.25 SECONDS), burrower)
	playsound(burrower, 'sound/effects/break_stone.ogg', 50, TRUE)
	burrower.status_flags &= ~GODMODE
	burrower.invisibility = 0

/datum/action/cooldown/mob_cooldown/resurface/proc/get_unburrow_turf(mob/living/burrower, atom/target)
	var/list/potential_turfs = shuffle(oview(5, target))//get in view, shuffle
	for(var/turf/open/misc/chosen_one in potential_turfs)//first turf that counts as ground
		return chosen_one

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/bileworm
	name = "Spew Bile"
	desc = "Spews bile everywhere. Must resurface after use to refresh."
	projectile_type = /obj/projectile/bileworm_acid
	projectile_sound = 'sound/creatures/bileworm/bileworm_spit.ogg'
	shared_cooldown = MOB_SHARED_COOLDOWN_1

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/bileworm/Activate(atom/target_atom)
	StartCooldownSelf(INFINITY)
	attack_sequence(owner, target_atom)
	//resurface now off cooldown shortly
	StartCooldownOthers(1.5 SECONDS)

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/bileworm/attack_sequence(mob/living/firer, atom/target)
	//pre-attack opening
	SLEEP_CHECK_DEATH(0.5 SECONDS, firer)
	fire_in_directions(firer, target, GLOB.cardinals)
	SLEEP_CHECK_DEATH(0.25 SECONDS, firer)
	fire_in_directions(firer, target, GLOB.diagonals)
	SLEEP_CHECK_DEATH(0.25 SECONDS, firer)
	fire_in_directions(firer, target, GLOB.cardinals)
	//post-attack opening
	SLEEP_CHECK_DEATH(0.5 SECONDS, firer)

/obj/projectile/bileworm_acid
	name = "acidic bile"
	icon_state = "neurotoxin"
	hitsound = 'sound/weapons/sear.ogg'
	damage = 20
	armour_penetration = 100
	speed = 2
	jitter = 3 SECONDS
	stutter = 3 SECONDS
	damage_type = BURN
	pass_flags = PASSTABLE
