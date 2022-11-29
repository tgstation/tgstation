/obj/structure/closet/cardboard
	name = "large cardboard box"
	desc = "Just a box..."
	icon_state = "cardboard"
	mob_storage_capacity = 1
	resistance_flags = FLAMMABLE
	max_integrity = 70
	integrity_failure = 0
	can_weld_shut = 0
	cutting_tool = /obj/item/wirecutters
	material_drop = /obj/item/stack/sheet/cardboard
	delivery_icon = "deliverybox"
	anchorable = FALSE
	open_sound = 'sound/machines/cardboard_box.ogg'
	close_sound = 'sound/machines/cardboard_box.ogg'
	open_sound_volume = 35
	close_sound_volume = 35
	has_closed_overlay = FALSE
	door_anim_time = 0 // no animation
	var/move_speed_multiplier = 1
	var/move_delay = FALSE
	can_install_electronics = FALSE

	/// Cooldown controlling when the box can trigger the Metal Gear Solid-style '!' alert.
	COOLDOWN_DECLARE(alert_cooldown)

	/// How much time must pass before the box can trigger the next Metal Gear Solid-style '!' alert.
	var/time_between_alerts = 60 SECONDS

/obj/structure/closet/cardboard/relaymove(mob/living/user, direction)
	if(opened || move_delay || user.incapacitated() || !isturf(loc) || !has_gravity(loc))
		return
	move_delay = TRUE
	var/oldloc = loc
	try_step_multiz(direction);
	if(oldloc != loc)
		addtimer(CALLBACK(src, PROC_REF(ResetMoveDelay)), CONFIG_GET(number/movedelay/walk_delay) * move_speed_multiplier)
	else
		move_delay = FALSE

/obj/structure/closet/cardboard/proc/ResetMoveDelay()
	move_delay = FALSE

/obj/structure/closet/cardboard/open(mob/living/user, force = FALSE)
	var/do_alert = (COOLDOWN_FINISHED(src, alert_cooldown) && (locate(/mob/living) in contents))

	if(!do_alert)
		return ..()

	// Cache the list before we open the box.
	var/list/alerted = viewers(7, src)

	// There are no mobs to alert?
	if(!(locate(/mob/living) in alerted))
		return ..()

	. = ..()

	// Box didn't open?
	if(!.)
		return

	COOLDOWN_START(src, alert_cooldown, time_between_alerts)

	for(var/mob/living/alerted_mob in alerted)
		if(alerted_mob.stat == CONSCIOUS)
			if(!alerted_mob.incapacitated(IGNORE_RESTRAINTS))
				alerted_mob.face_atom(src)
			alerted_mob.do_alert_animation()

	playsound(loc, 'sound/machines/chime.ogg', 50, FALSE, -5)

/// Does the MGS ! animation
/atom/proc/do_alert_animation()
	var/image/alert_image = image('icons/obj/storage/closet.dmi', src, "cardboard_special", layer+1)
	SET_PLANE_EXPLICIT(alert_image, ABOVE_LIGHTING_PLANE, src)
	flick_overlay_view(alert_image, 0.8 SECONDS)
	alert_image.alpha = 0
	animate(alert_image, pixel_z = 32, alpha = 255, time = 0.5 SECONDS, easing = ELASTIC_EASING)
	// We use this list to update plane values on parent z change, which is why we need the timer too
	// I'm sorry :(
	LAZYADD(update_on_z, alert_image)
	addtimer(CALLBACK(src, PROC_REF(forget_alert_image), alert_image), 0.8 SECONDS)

/atom/proc/forget_alert_image(image/alert_image)
	LAZYREMOVE(update_on_z, alert_image)

/obj/structure/closet/cardboard/metal
	name = "large metal box"
	desc = "THE COWARDS! THE FOOLS!"
	icon_state = "metalbox"
	max_integrity = 500
	mob_storage_capacity = 5
	resistance_flags = NONE
	move_speed_multiplier = 2
	cutting_tool = /obj/item/weldingtool
	open_sound = 'sound/machines/crate_open.ogg'
	close_sound = 'sound/machines/crate_close.ogg'
	open_sound_volume = 35
	close_sound_volume = 50
	material_drop = /obj/item/stack/sheet/plasteel
