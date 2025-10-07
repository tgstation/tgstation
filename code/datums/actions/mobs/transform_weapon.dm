/datum/action/cooldown/mob_cooldown/transform_weapon
	name = "Transform Weapon"
	button_icon = 'icons/obj/mining_zones/artefacts.dmi'
	button_icon_state = "cleaving_saw"
	desc = "Transform weapon into a different state."
	cooldown_time = 5 SECONDS
	shared_cooldown = MOB_SHARED_COOLDOWN_2
	/// The max possible cooldown, cooldown is random between the default cooldown time and this
	var/max_cooldown_time = 10 SECONDS

/datum/action/cooldown/mob_cooldown/transform_weapon/Activate(atom/target_atom)
	disable_cooldown_actions()
	do_transform(target_atom)
	StartCooldown(rand(cooldown_time, max_cooldown_time), 0)
	enable_cooldown_actions()
	return TRUE

/datum/action/cooldown/mob_cooldown/transform_weapon/proc/do_transform(atom/target)
	if(!istype(owner, /mob/living/simple_animal/hostile/megafauna/blood_drunk_miner))
		return
	var/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/blood_drunk_miner = owner
	blood_drunk_miner.miner_saw.attack_self(owner)
	var/saw_open = HAS_TRAIT(blood_drunk_miner.miner_saw, TRAIT_TRANSFORM_ACTIVE)
	blood_drunk_miner.rapid_melee = saw_open ? 3 : 5
	blood_drunk_miner.icon_state = "miner[saw_open ? "_transformed":""]"
	blood_drunk_miner.icon_living = "miner[saw_open ? "_transformed":""]"
