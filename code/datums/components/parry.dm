/// Add to a living mob to allow them to "parry" projectiles by clicking on their tile, sending them back at the firer.
/datum/component/projectile_parry
	/// typecache of valid projectiles to be able to parry
	var/list/parryable_projectiles


/datum/component/projectile_parry/Initialize(list/projectiles_to_parry)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	parryable_projectiles = typecacheof(projectiles_to_parry)


/datum/component/projectile_parry/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_PROJECTILE_PARRYING, PROC_REF(parrying_projectile))
	RegisterSignal(parent, COMSIG_LIVING_PROJECTILE_PARRIED, PROC_REF(parried_projectile))


/datum/component/projectile_parry/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_PROJECTILE_PARRYING, COMSIG_LIVING_PROJECTILE_PARRIED))


/datum/component/projectile_parry/proc/parrying_projectile(datum/source, obj/projectile/parried_projectile)
	SIGNAL_HANDLER

	if(is_type_in_typecache(parried_projectile, parryable_projectiles))
		return ALLOW_PARRY


/datum/component/projectile_parry/proc/parried_projectile(datum/source, obj/projectile/parried_projectile)
	SIGNAL_HANDLER

	var/mob/living/living_parent = parent

	living_parent.playsound_local(get_turf(parried_projectile), 'sound/effects/parry.ogg', 50, TRUE)
	living_parent.overlay_fullscreen("projectile_parry", /atom/movable/screen/fullscreen/crit/projectile_parry, 2)
	addtimer(CALLBACK(living_parent, TYPE_PROC_REF(/mob, clear_fullscreen), "projectile_parry"), 0.25 SECONDS)
	living_parent.visible_message(span_warning("[living_parent] expertly parries [parried_projectile] with [living_parent.p_their()] bare hand!"), span_warning("You parry [parried_projectile] with your hand!"))
