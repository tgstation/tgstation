/datum/status_effect/freon
	id = "frozen"
	duration = 100
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/freon
	var/icon/cube
	var/can_melt = TRUE

/atom/movable/screen/alert/status_effect/freon
	name = "Frozen Solid"
	desc = "You're frozen inside an ice cube, and cannot move! You can still do stuff, like shooting. Resist out of the cube!"
	icon_state = "frozen"

/datum/status_effect/freon/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	RegisterSignal(owner, COMSIG_LIVING_RESIST, .proc/owner_resist)
	if(!owner.stat)
		to_chat(owner, span_userdanger("You become frozen in a cube!"))
	cube = icon('icons/effects/freeze.dmi', "ice_cube")
	owner.add_overlay(cube)


/datum/status_effect/freon/tick()
	if(can_melt && owner.bodytemperature >= owner.get_body_temp_normal())
		qdel(src)

/datum/status_effect/freon/proc/owner_resist()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/do_resist)

/datum/status_effect/freon/proc/do_resist()
	to_chat(owner, span_notice("You start breaking out of the ice cube..."))
	if(do_mob(owner, owner, 40))
		if(!QDELETED(src))
			to_chat(owner, span_notice("You break out of the ice cube!"))
			owner.remove_status_effect(/datum/status_effect/freon)


/datum/status_effect/freon/on_remove()
	if(!owner.stat)
		to_chat(owner, span_notice("The cube melts!"))
	owner.cut_overlay(cube)
	owner.adjust_bodytemperature(100)
	UnregisterSignal(owner, COMSIG_LIVING_RESIST)
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/freon/watcher
	duration = 8
	can_melt = FALSE

/datum/status_effect/gas_fog
	id = "gas_fog"
	status_type = STATUS_EFFECT_REFRESH
	duration = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/gas_fog
	var/datum/gas/gas_to_check
	var/warned = FALSE
	var/current_timer

/atom/movable/screen/alert/status_effect/gas_fog
	name = "Foggy"
	desc = "You can't see anything in front of you!"

/datum/status_effect/gas_fog/on_remove()
	owner.cure_blind(EYES_COVERED)
	owner.clear_fullscreen("tint", 0)
	gas_to_check = null

/datum/status_effect/gas_fog/on_creation(mob/living/new_owner, gas_id)
	. = ..()
	gas_to_check = gas_id

/datum/status_effect/gas_fog/tick()
	var/datum/gas_mixture/environment = owner.loc?.return_air()
	var/gas_amount = environment?.gases[gas_to_check][MOLES]
	if(gas_amount >= 0)
		check_impaired_type(gas_amount)
	if(warned && (world.time - current_timer > 10 SECONDS))
		current_timer = world.time
		warned = FALSE

/datum/status_effect/gas_fog/proc/check_impaired_type(gas_amount)
	switch(gas_amount)
		if(5 to 14)
			owner.cure_blind(EYES_COVERED)
			if(!warned)
				warned = TRUE
				to_chat(owner, span_notice("You can't see beyond a few meters from you due to the fog."))
			owner.overlay_fullscreen("tint", /atom/movable/screen/fullscreen/impaired, 1)
		if(15 to 29)
			owner.cure_blind(EYES_COVERED)
			if(!warned)
				warned = TRUE
				to_chat(owner, span_warning("You can't see almost right next to you due to the fog."))
			owner.overlay_fullscreen("tint", /atom/movable/screen/fullscreen/impaired, 2)
		if(30 to INFINITY)
			if(!warned)
				warned = TRUE
				to_chat(owner, span_warning("The fog stops you from seeing around you!"))
			owner.become_blind(EYES_COVERED)
		else
			owner.cure_blind(EYES_COVERED)
			owner.clear_fullscreen("tint", 0)
