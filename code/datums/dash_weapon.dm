/datum/action/innate/dash
	name = "Dash"
	desc = "Teleport to the targeted location."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "jetboot"
	var/current_charges = 1
	var/max_charges = 1
	var/charge_rate = 250
	var/obj/item/dashing_item
	var/dash_sound = 'sound/magic/blink.ogg'
	var/recharge_sound = 'sound/magic/charge.ogg'
	var/beam_effect = "blur"
	var/phasein = /obj/effect/temp_visual/dir_setting/ninja/phase
	var/phaseout = /obj/effect/temp_visual/dir_setting/ninja/phase/out

/datum/action/innate/dash/Grant(mob/user, obj/dasher)
	. = ..()
	dashing_item = dasher

/datum/action/innate/dash/Destroy()
	dashing_item = null
	return ..()

/datum/action/innate/dash/IsAvailable()
	if(current_charges > 0)
		return TRUE
	else
		return FALSE

/datum/action/innate/dash/Activate()
	dashing_item.attack_self(owner) //Used to toggle dash behavior in the dashing item

/// Teleports user to target using do_teleport. Returns TRUE if teleport successful, FALSE otherwise.
/datum/action/innate/dash/proc/teleport(mob/user, atom/target)
	if(!IsAvailable())
		return FALSE

	var/turf/target_turf = get_turf(target)
	if(target in view(user.client.view, user))
		if(!do_teleport(user, target_turf, no_effects = TRUE))
			user.balloon_alert(user, "dash blocked by location!")
			return FALSE

		var/obj/spot1 = new phaseout(get_turf(user), user.dir)
		playsound(target_turf, dash_sound, 25, TRUE)
		var/obj/spot2 = new phasein(get_turf(user), user.dir)
		spot1.Beam(spot2,beam_effect,time=2 SECONDS)
		current_charges--
		owner.update_action_buttons_icon()
		addtimer(CALLBACK(src, .proc/charge), charge_rate)
		return TRUE

	return FALSE

/datum/action/innate/dash/proc/charge()
	current_charges = clamp(current_charges + 1, 0, max_charges)
	if(recharge_sound)
		playsound(dashing_item, recharge_sound, 50, TRUE)

	if(!owner)
		return
	owner.update_action_buttons_icon()
	dashing_item.balloon_alert(owner, "[current_charges]/[max_charges] dash charges")
