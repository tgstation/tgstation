///Bullet shield element, spawns an anti-toolbox shield when hit by a bullet.
/datum/element/projectile_shield/Attach(datum/target)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_BULLET_ACT, .proc/on_bullet_act)

/datum/element/projectile_shield/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_BULLET_ACT)

/datum/element/projectile_shield/proc/on_bullet_act(datum/source, obj/projectile/proj)
	SIGNAL_HANDLER

	var/mob/movable_mob = source
	var/turf/current_turf = movable_mob.loc
	if(!isturf(current_turf))
		return
	if(movable_mob.stat == DEAD)
		return

	var/obj/effect/temp_visual/at_shield/new_atshield = new /obj/effect/temp_visual/at_shield(current_turf, movable_mob)

	var/random_x = rand(-32, 32)
	new_atshield.pixel_x += random_x

	var/random_y = rand(0, 72)
	new_atshield.pixel_y += random_y
