/obj/item/pod_equipment/primary/projectile_weapon
	/// the projectile typepath we fire
	var/projectile_path
	/// sound when firing
	var/fire_sound
	/// force applied backwards to fire this gun
	var/fire_force = 0.5 NEWTONS
	/// effect when we fire
	var/effect_path = /obj/effect/temp_visual/dir_setting/firing_effect/blue

/obj/item/pod_equipment/primary/projectile_weapon/action(mob/living/user)
	. = ..()
	new effect_path(get_turf(pod), pod.dir)
	var/obj/projectile/projectile = new projectile_path(get_turf(src))
	projectile.log_override = TRUE
	projectile.firer = pod
	if(istype(user) && user.client) //dont want it to happen from syndie mecha npc mobs, they do direct fire anyways
		projectile.hit_prone_targets = user.combat_mode

	projectile.fire(dir2angle(pod))
	pod.newtonian_move(dir2angle(REVERSE_DIR(pod.dir)), fire_force)
	playsound(pod, fire_sound, 50, TRUE)

	pod.log_message("[key_name(user)] fired [src], with a projectile path of [projectile_path]", LOG_ATTACK)

/obj/item/pod_equipment/primary/projectile_weapon/kinetic_accelerator
	cooldown_time = 1.75 SECONDS
	name = "pod proto-kinetic accelerator"
	projectile_path = /obj/item/ammo_casing/energy/kinetic::projectile_type
	fire_sound = /obj/item/ammo_casing/energy/kinetic::fire_sound
