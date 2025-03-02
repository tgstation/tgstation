/obj/item/gun
	var/kickback_force = 0
	var/kickback_speed = 0
	var/kickback_range = 0

/obj/item/gun/shoot_live_shot(mob/living/user, pointblank = FALSE, atom/pbtarget = null, message = TRUE)
	. = ..()
	if(user.mob_size == MOB_SIZE_TINY)

		to_chat(user, span_warning("Your tiny body is thrown back by the force of the [src]!"))

		var/move_target = get_edge_target_turf(user, REVERSE_DIR(user.dir))
		user.throw_at(move_target, kickback_range, kickback_speed, user, force = kickback_force)
		shake_camera(user, 1, kickback_range/2) //small guys get a lil extra recoil as a treat

//Happens before the actual projectile creation
/obj/item/gun/before_firing(atom/target,mob/user)
	kickback_force = chambered.loaded_projectile.damage
	kickback_speed = kickback_force
	kickback_range = chambered.loaded_projectile.damage/10
	. = ..()
	return

