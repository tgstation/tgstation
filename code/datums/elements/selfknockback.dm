/datum/element/selfknockback
	element_flags = ELEMENT_DETACH

/datum/element/selfknockback/Attach(datum/target)
	. = ..()
	if(isitem(target))
		RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, .proc/Item_SelfKnockback)
	else if(isprojectile(target))
		RegisterSignal(target, COMSIG_PROJECTILE_FIRE, .proc/Projectile_SelfKnockback)
	else	
		return ELEMENT_INCOMPATIBLE
	
/datum/element/selfknockback/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ITEM_AFTERATTACK, COMSIG_PROJECTILE_FIRE))

/datum/element/selfknockback/proc/Item_SelfKnockback(obj/item/I, atom/attacktarget, mob/usertarget, proximity_flag)
	if(ismovableatom(attacktarget)) //This check prevents us from launching ourselves off floors or walls.
		if(proximity_flag || (get_dist(attacktarget, usertarget) <= I.reach))
			var/target_angle = Get_Angle(attacktarget, usertarget)
			var/knockback_force = CLAMP(CEILING((I.force / 10), 1), 1, 5)
			var/move_target = get_ranged_target_turf(usertarget, angle2dir(target_angle), knockback_force)
			usertarget.throw_at(move_target, knockback_force, knockback_force)
			usertarget.visible_message("<span class='warning'>[usertarget] gets thrown back by the force of \the [I] impacting \the [attacktarget]!</span>", "<span class='warning'>The force of \the [I] impacting \the [attacktarget] sends you flying!</span>")

/datum/element/selfknockback/proc/Projectile_SelfKnockback(obj/projectile/P)
	if(!P.firer)
		return
	var/atom/movable/knockback_target = P.firer
	var/knockback_force = CLAMP(CEILING((P.damage / 10), 1), 1, 5)
	var/move_target = get_edge_target_turf(knockback_target, angle2dir(P.original_angle+180))
	knockback_target.throw_at(move_target, knockback_force, knockback_force)
