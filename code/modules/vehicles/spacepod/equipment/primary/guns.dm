/obj/item/pod_equipment/primary/projectile_weapon
	/// the projectile typepath we fire
	var/projectile_path
	/// alternatively fire a casing
	var/casing_path
	/// sound when firing
	var/fire_sound
	/// force applied backwards to fire this gun, only applicable if only using a projectile path
	var/fire_force = 0.5 NEWTONS
	/// effect when we fire
	var/effect_path = /obj/effect/temp_visual/dir_setting/firing_effect/blue

/obj/item/pod_equipment/primary/projectile_weapon/proc/prefire_checks(mob/living/user)
	return TRUE

/obj/item/pod_equipment/primary/projectile_weapon/action(mob/living/user)
	. = ..()
	if(!prefire_checks(user))
		return
	new effect_path(get_turf(pod), pod.dir)
	if(!isnull(projectile_path))
		var/obj/projectile/projectile = new projectile_path(get_turf(src))
		projectile.log_override = TRUE
		projectile.firer = pod
		if(istype(user) && user.client)
			projectile.hit_prone_targets = user.combat_mode

		projectile.fire(dir2angle(pod))
		pod.newtonian_move(dir2angle(REVERSE_DIR(pod.dir)), fire_force)
	else
		var/obj/item/ammo_casing/casing = new casing_path
		casing.fire_casing(get_step(pod, pod.dir), user, fired_from = src)
		qdel(casing)
	playsound(pod, fire_sound, 50, TRUE)

	pod.log_message("[key_name(user)] fired [src], with [projectile_path ? projectile_path : casing_path]", LOG_ATTACK)

/obj/item/pod_equipment/primary/projectile_weapon/energy
	/// how much power used to fire
	var/power_used_to_fire = 1

/obj/item/pod_equipment/primary/projectile_weapon/energy/prefire_checks(mob/living/user)
	return pod.use_power(power_used_to_fire)

/obj/item/pod_equipment/primary/projectile_weapon/energy/kinetic_accelerator
	cooldown_time = 1.75 SECONDS
	name = "pod proto-kinetic accelerator"
	projectile_path = /obj/item/ammo_casing/energy/kinetic::projectile_type
	fire_sound = /obj/item/ammo_casing/energy/kinetic::fire_sound
