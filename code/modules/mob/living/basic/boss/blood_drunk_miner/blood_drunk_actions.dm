/datum/action/cooldown/mob_cooldown/charge/basic_charge/blood_drunk_miner
	cooldown_time = 1.5 SECONDS
	charge_delay = 0.1 SECONDS
	shake_duration = 0.2 SECONDS // A bit longer so he shakes during the dash too
	charge_distance = 6
	// Don't stun ourselves or the target
	recoil_duration = -1
	knockdown_duration = -1
	destroy_objects = FALSE
	charge_damage = 0
	charge_speed = 0.3

/datum/action/cooldown/mob_cooldown/charge/basic_charge/blood_drunk_miner/hit_target(atom/movable/source, atom/target, damage_dealt)
	. = ..()
	if(!isbasicmob(source) || !isliving(target))
		return
	var/mob/living/basic/basic_source = source
	basic_source.melee_attack(target, ignore_cooldown = TRUE)

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
	do_transform()
	StartCooldown(rand(cooldown_time, max_cooldown_time), 0)
	enable_cooldown_actions()
	return TRUE

/datum/action/cooldown/mob_cooldown/transform_weapon/proc/do_transform()
	if(!istype(owner, /mob/living/basic/boss/blood_drunk_miner))
		return
	var/mob/living/basic/boss/blood_drunk_miner/blood_drunk_miner = owner
	blood_drunk_miner.transform_saw()

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/kinetic_accelerator
	name = "Fire Kinetic Accelerator"
	desc = "Fires a kinetic accelerator projectile at the target."
	button_icon = 'icons/obj/weapons/guns/energy.dmi'
	button_icon_state = "kineticgun"
	cooldown_time = 1.5 SECONDS
	projectile_type = /obj/projectile/kinetic/miner
	projectile_sound = 'sound/items/weapons/kinetic_accel.ogg'
	shot_count = 3
	shot_delay = 0.15 SECONDS
	default_projectile_spread = 10
	can_move = FALSE
	/// Delay for the alert
	var/alert_delay = 0.5 SECONDS
	/// Delay before we start shooting during which we cannot move
	var/prefire_delay = 0.2 SECONDS
	/// Delay before the user can move or act again after firing
	var/reload_delay = 0.1 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/kinetic_accelerator/Activate(atom/target_atom)
	owner.visible_message(span_danger("[owner] fires the proto-kinetic accelerator!"))
	owner.face_atom(target_atom)
	owner.do_alert_animation(alert_delay + (shot_count - 1) * shot_delay)
	disable_cooldown_actions()
	if (alert_delay > prefire_delay) // As to delay movement blocking
		SLEEP_CHECK_DEATH(alert_delay - prefire_delay, owner)
	return ..()

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/kinetic_accelerator/attack_sequence(mob/living/firer, atom/target)
	SLEEP_CHECK_DEATH(prefire_delay, firer)
	. = ..()
	sleep(reload_delay)

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/kinetic_accelerator/shoot_projectile(atom/origin, atom/target, set_angle, mob/firer, projectile_spread, speed_multiplier, override_projectile_type, override_homing)
	. = ..()
	new /obj/effect/temp_visual/dir_setting/firing_effect(get_turf(firer), firer.dir)

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/kinetic_accelerator/long_burst
	shot_count = 5
	shot_delay = 0.1 SECONDS
