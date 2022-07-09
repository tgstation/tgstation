/datum/action/cooldown/mob_cooldown/transform_weapon
	name = "Transform Weapon"
	icon_icon = 'icons/obj/lavaland/artefacts.dmi'
	button_icon_state = "cleaving_saw"
	desc = "Transform weapon into a different state."
	cooldown_time = 5 SECONDS
	shared_cooldown = MOB_SHARED_COOLDOWN_2
	/// The max possible cooldown, cooldown is random between the default cooldown time and this
	var/max_cooldown_time = 10 SECONDS

/datum/action/cooldown/mob_cooldown/transform_weapon/Activate(atom/target_atom)
	StartCooldown(100)
	do_transform(target_atom)
	StartCooldown(rand(cooldown_time, max_cooldown_time))

/datum/action/cooldown/mob_cooldown/transform_weapon/proc/do_transform(atom/target)
	if(!istype(owner, /mob/living/simple_animal/hostile/megafauna/blood_drunk_miner))
		return
	var/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/BDM = owner
	var/obj/item/melee/cleaving_saw/miner/miner_saw = BDM.miner_saw
	miner_saw.attack_self(owner)
	if(!miner_saw.is_open)
		BDM.rapid_melee = 5 // 4 deci cooldown before changes, npcpool subsystem wait is 20, 20/4 = 5
	else
		BDM.rapid_melee = 3 // same thing but halved (slightly rounded up)
	BDM.icon_state = "miner[miner_saw.is_open ? "_transformed":""]"
	BDM.icon_living = "miner[miner_saw.is_open ? "_transformed":""]"
