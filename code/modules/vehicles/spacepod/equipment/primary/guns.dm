/obj/item/pod_equipment/primary/projectile_weapon
	/// the projectile typepath we fire
	var/obj/projectile/projectile_path
	/// alternatively fire a casing
	var/obj/item/ammo_casing/casing_path
	/// sound when firing
	var/fire_sound
	/// force applied backwards to fire this gun, only applicable if only using a projectile path
	var/fire_force = 0.5 NEWTONS
	/// effect when we fire
	var/effect_path = /obj/effect/temp_visual/dir_setting/firing_effect/blue

/obj/item/pod_equipment/primary/projectile_weapon/proc/prefire_checks(mob/living/user)
	. = TRUE
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		if(casing_path && initial(casing_path.harmful))
			pod.balloon_alert(user, "you dont want to harm!")
			return FALSE
		else if(projectile_path && initial(projectile_path.damage) && initial(projectile_path.damage) != STAMINA)
			pod.balloon_alert(user, "you dont want to harm!")
			return FALSE

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

		projectile.fire(dir2angle(pod.dir))
		pod.newtonian_move(dir2angle(REVERSE_DIR(pod.dir)), fire_force, controlled_cap = fire_force*2)
	else
		var/obj/item/ammo_casing/casing = new casing_path
		casing.fire_casing(get_step(pod, pod.dir), user, fired_from = src)
		qdel(casing)
	playsound(pod, fire_sound, 50, TRUE)

	pod.log_message("[key_name(user)] fired [src], with [projectile_path ? projectile_path : casing_path]", LOG_ATTACK)

/obj/item/pod_equipment/primary/projectile_weapon/energy
	interface_id = "Gun"
	/// how much power used to fire
	var/power_used_to_fire = 1

/obj/item/pod_equipment/primary/projectile_weapon/energy/prefire_checks(mob/living/user)
	. = ..()
	if(!.)
		return
	return pod.use_power(power_used_to_fire)

/obj/item/pod_equipment/primary/projectile_weapon/energy/ui_data(mob/user)
	var/obj/item/stock_parts/power_store/battery/cell = pod?.get_cell()
	return list(
		"ammo" = isnull(cell) ? "0" : cell.charge,
		"maxAmmo" = isnull(cell) ? "0" : cell.maxcharge,
		"ammoPerShot" = power_used_to_fire,
		"mode" = "Normal", // maybe soon there will be guns with alternate firing modes
	)

/obj/item/pod_equipment/primary/projectile_weapon/energy/wildlife
	name = "wildlife dissuasion laser gun"
	desc = "A laser gun for pods, tuned to specifically hurt those of not human physiology. Due to that, cannot pass windows."
	icon_state = "wildlifegun"
	projectile_path = /obj/projectile/beam/wildlife_dissuasion
	fire_sound = 'sound/items/weapons/laser.ogg'
	fire_force = 0 //brrrrrrrr
	cooldown_time = 0.75 SECONDS
	power_used_to_fire = STANDARD_BATTERY_CHARGE / 45
