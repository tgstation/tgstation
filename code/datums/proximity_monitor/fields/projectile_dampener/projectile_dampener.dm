//Projectile dampening field that slows projectiles and lowers their damage for an energy cost deducted every 1/5 second.
/datum/proximity_monitor/advanced/bubble/projectile_dampener
	///overlay we apply to caught bullets
	var/static/image/new_bullet_overlay= image('icons/effects/fields.dmi', "projectile_dampen_effect")
	/// datum that holds the effects we apply on caught bullets
	var/datum/dampener_projectile_effects/bullet_effects

/datum/proximity_monitor/advanced/bubble/projectile_dampener/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, atom/projector, datum/dampener_projectile_effects/effects_typepath)
	. = ..()
	bullet_effects = effects_typepath ? new effects_typepath() : new

/datum/proximity_monitor/advanced/bubble/projectile_dampener/Destroy()
	bullet_effects = null
	return ..()

/datum/proximity_monitor/advanced/bubble/projectile_dampener/field_edge_crossed(atom/movable/movable, turf/location, turf/old_location)
	. = ..()
	if(!isprojectile(movable))
		return
	determine_wobble(location)

/datum/proximity_monitor/advanced/bubble/projectile_dampener/field_edge_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	. = ..()
	if(!isprojectile(movable))
		return
	determine_wobble(old_location)

/datum/proximity_monitor/advanced/bubble/projectile_dampener/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(!isprojectile(movable) || HAS_TRAIT_FROM(movable, TRAIT_GOT_DAMPENED, REF(src)))
		return
	catch_bullet_effect(movable)

/datum/proximity_monitor/advanced/bubble/projectile_dampener/field_turf_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(!isprojectile(movable) || get_dist(new_location, host) <= (edge_is_a_field ? current_range : current_range - 1))
		return
	release_bullet_effect(movable)

/datum/proximity_monitor/advanced/bubble/projectile_dampener/setup_field_turf(turf/target)
	for(var/atom/possible_projectile in target)
		if(isprojectile(possible_projectile))
			catch_bullet_effect(possible_projectile)

/datum/proximity_monitor/advanced/bubble/projectile_dampener/cleanup_field_turf(turf/target)
	for(var/atom/possible_projectile in target)
		if(isprojectile(possible_projectile) && HAS_TRAIT_FROM(possible_projectile, TRAIT_GOT_DAMPENED, REF(src)))
			release_bullet_effect(possible_projectile)

///proc that applies the wobbly effect on point of bullet entry
/datum/proximity_monitor/advanced/bubble/projectile_dampener/proc/determine_wobble(turf/location)
	var/coord_x = location.x - host.x
	var/coord_y = location.y - host.y
	var/obj/effect/overlay/vis/field/my_field = edgeturf_effects["[coord_x],[coord_y]"]
	my_field?.set_wobbly(0.15 SECONDS)

/datum/proximity_monitor/advanced/bubble/projectile_dampener/proc/projectile_overlay_updated(atom/source, list/overlays)
	SIGNAL_HANDLER

	if(!isnull(new_bullet_overlay) && HAS_TRAIT_FROM(source, TRAIT_GOT_DAMPENED, REF(src)))
		overlays += new_bullet_overlay

///a bullet has entered our field, apply the dampening effects to it
/datum/proximity_monitor/advanced/bubble/projectile_dampener/proc/catch_bullet_effect(obj/projectile/bullet)
	ADD_TRAIT(bullet,TRAIT_GOT_DAMPENED, REF(src))
	RegisterSignal(bullet, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(projectile_overlay_updated))
	SEND_SIGNAL(src, COMSIG_DAMPENER_CAPTURE, bullet)
	bullet_effects.apply_effects(bullet)
	bullet.update_appearance()

///removing the effects after it has exited our field
/datum/proximity_monitor/advanced/bubble/projectile_dampener/proc/release_bullet_effect(obj/projectile/bullet)
	REMOVE_TRAIT(bullet, TRAIT_GOT_DAMPENED, REF(src))
	SEND_SIGNAL(src, COMSIG_DAMPENER_RELEASE, bullet)
	bullet_effects.remove_effects(bullet)
	bullet.update_appearance()
	UnregisterSignal(bullet, COMSIG_ATOM_UPDATE_OVERLAYS)

/datum/proximity_monitor/advanced/bubble/projectile_dampener/peaceborg

/datum/proximity_monitor/advanced/bubble/projectile_dampener/peaceborg/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	. = ..()
	if(!iscyborg(movable) || !HAS_TRAIT_FROM(movable, TRAIT_GOT_DAMPENED, REF(src)))
		ADD_TRAIT(movable, TRAIT_GOT_DAMPENED, REF(src))

/datum/proximity_monitor/advanced/bubble/projectile_dampener/peaceborg/field_turf_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(!iscyborg(movable) || get_dist(new_location, host) <= (edge_is_a_field ? current_range : current_range - 1))
		return
	REMOVE_TRAIT(movable, TRAIT_GOT_DAMPENED, REF(src))

/datum/proximity_monitor/advanced/bubble/projectile_dampener/peaceborg/setup_field_turf(turf/target)
	for(var/atom/interesting_atom as anything in target)
		if(iscyborg(interesting_atom))
			ADD_TRAIT(interesting_atom, TRAIT_GOT_DAMPENED, REF(src))
		if(isprojectile(interesting_atom))
			catch_bullet_effect(interesting_atom)

/datum/proximity_monitor/advanced/bubble/projectile_dampener/peaceborg/cleanup_field_turf(turf/target)
	for(var/atom/interesting_atom as anything in target)
		if(iscyborg(interesting_atom))
			REMOVE_TRAIT(interesting_atom, TRAIT_GOT_DAMPENED, REF(src))
		if(isprojectile(interesting_atom))
			release_bullet_effect(interesting_atom)
