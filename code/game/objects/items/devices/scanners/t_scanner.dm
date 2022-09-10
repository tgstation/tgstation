/obj/item/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	custom_price = PAYCHECK_LOWER * 0.7
	icon = 'icons/obj/device.dmi'
	icon_state = "t-ray0"
	var/on = FALSE
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	custom_materials = list(/datum/material/iron=150)

/obj/item/t_scanner/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to emit terahertz-rays into [user.p_their()] brain with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

/obj/item/t_scanner/proc/toggle_on()
	on = !on
	icon_state = copytext_char(icon_state, 1, -1) + "[on]"
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/t_scanner/attack_self(mob/user)
	toggle_on()

/obj/item/t_scanner/cyborg_unequip(mob/user)
	if(!on)
		return
	toggle_on()

/obj/item/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null
	scan()

/obj/item/t_scanner/proc/scan()
	t_ray_scan(loc)

/**
 * Performs a t-ray scan, showing the viewer any nearby undertiles
 *
 * viewer - the mob seeing the tray
 * flick_time - how long the scan lasts
 * distance - the radius around to scan
 * view_source - optional, around what atom do we look for undertiles. If not suppied, uses the viewer
 */
/proc/t_ray_scan(mob/viewer, flick_time = 0.8 SECONDS, distance = 3, atom/view_source)
	if(!ismob(viewer) || !viewer.client)
		return

	var/list/all_t_ray_images = list()
	for(var/obj/potential_undertile in orange(distance, view_source || viewer))
		if(!HAS_TRAIT(potential_undertile, TRAIT_T_RAY_VISIBLE))
			continue
		var/image/t_ray_image = new(loc = get_turf(potential_undertile))
		var/mutable_appearance/t_ray_mutable = new(potential_undertile)
		t_ray_mutable.alpha = 128
		t_ray_mutable.dir = potential_undertile.dir
		t_ray_image.appearance = t_ray_mutable
		all_t_ray_images += t_ray_image

	if(!length(all_t_ray_images))
		return

	flick_overlay(all_t_ray_images, list(viewer.client), flick_time)
