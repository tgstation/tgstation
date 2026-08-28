/// Adds the cult halo effect vfx to the mob (instantly/after a delay)
/datum/status_effect/cult_halo
	id = "cult_halo"
	alert_type = null
	tick_interval = STATUS_EFFECT_NO_TICK
	/// Cooldown for when the halo is actually visible
	COOLDOWN_DECLARE(halo_start)
	/// The actual halo applied to the mob
	VAR_PRIVATE/mutable_appearance/halo_overlay

/datum/status_effect/cult_halo/on_creation(mob/living/new_owner, initial_delay = 20 SECONDS)
	COOLDOWN_START(src, halo_start, initial_delay)
	return ..()

/datum/status_effect/cult_halo/on_apply()
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(add_halo))
	if(COOLDOWN_FINISHED(src, halo_start))
		refresh_halo()
	else
		addtimer(CALLBACK(src, PROC_REF(refresh_halo)), COOLDOWN_TIMELEFT(src, halo_start), TIMER_DELETE_ME)
	return TRUE

/datum/status_effect/cult_halo/on_remove()
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	owner.update_appearance(UPDATE_OVERLAYS)
	REMOVE_TRAIT(owner, TRAIT_CULT_HALO, TRAIT_STATUS_EFFECT(id))
	halo_overlay = null
	return TRUE

/datum/status_effect/cult_halo/proc/refresh_halo()
	COOLDOWN_RESET(src, halo_start)
	ADD_TRAIT(owner, TRAIT_CULT_HALO, TRAIT_STATUS_EFFECT(id))
	owner.update_appearance(UPDATE_OVERLAYS)
	new /obj/effect/temp_visual/cult/sparks(get_turf(owner), owner.dir)

/datum/status_effect/cult_halo/proc/add_halo(datum/source, list/overlay_list)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, halo_start))
		return

	halo_overlay ||= mutable_appearance('icons/mob/effects/halo.dmi', "halo[rand(1, 6)]", -HALO_LAYER)
	halo_overlay.pixel_z = 0
	halo_overlay.pixel_w = 0
	if (ishuman(owner))
		var/mob/living/carbon/human/human_parent = owner
		human_parent.apply_height(halo_overlay, UPPER_BODY)

		var/obj/item/bodypart/head/human_head = human_parent.get_bodypart(BODY_ZONE_HEAD)
		human_head?.worn_head_offset?.apply_offset(halo_overlay)

	overlay_list += halo_overlay
