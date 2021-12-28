//~*~*~*~*SPARKLER*~*~*~*~*~*~

/obj/item/sparkler
	name = "sparkler"
	desc = "A little stick coated with metal powder and barium nitrate, burns with a pleasing sparkle."
	icon = 'icons/obj/holiday_misc.dmi'
	icon_state = "sparkler"
	atom_size = WEIGHT_CLASS_TINY
	heat = 1000
	/// Burn time in seconds
	var/burntime = 120
	var/lit = FALSE

/obj/item/sparkler/fire_act(exposed_temperature, exposed_volume)
	light()

/obj/item/sparkler/attackby(obj/item/item, mob/user, params)
	var/ignition_msg = item.ignition_effect(src, user)
	if(ignition_msg)
		light(user, ignition_msg)
	else
		return ..()

/obj/item/sparkler/proc/light(mob/user, message)
	if(lit)
		return
	if(user && message)
		user.visible_message(message)
	lit = TRUE
	icon_state = "sparkler_on"
	force = 6
	hitsound = 'sound/items/welder.ogg'
	name = "lit [initial(name)]"
	attack_verb_continuous = list("burns")
	attack_verb_simple = list("burn")
	set_light(l_range = 2, l_power = 2)
	damtype = BURN
	START_PROCESSING(SSobj, src)
	playsound(src, 'sound/effects/fuse.ogg', 20, TRUE)
	update_appearance()

/obj/item/sparkler/process(delta_time)
	burntime -= delta_time
	if(burntime <= 0)
		new /obj/item/stack/rods(drop_location())
		qdel(src)
	else
		open_flame(heat)

/obj/item/sparkler/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/sparkler/ignition_effect(atom/atom, mob/user)
	. = span_notice("[user] gracefully lights [atom] with [src].")

/obj/item/sparkler/get_temperature()
	return lit * heat

//~*~*~*~*FIRECRACKER*~*~*~*~*~*~

/obj/item/grenade/firecracker
	name = "large firecracker"
	desc = "Outlawed in most of the sector. Doubles as an excellent finger remover."
	icon = 'icons/obj/holiday_misc.dmi'
	icon_state = "firecracker"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	atom_size = WEIGHT_CLASS_SMALL
	inhand_icon_state = "flare"
	throw_speed = 3
	throw_range = 7
	det_time = 30

/obj/item/grenade/firecracker/attack_self(mob/user) // You need to light it manually.
	return

/obj/item/grenade/firecracker/attackby(obj/item/item, mob/user, params)
	var/ignition_msg = item.ignition_effect(src, user)
	if(ignition_msg && !active)
		visible_message(ignition_msg)
		arm_grenade(user)
	else
		return ..()

/obj/item/grenade/firecracker/fire_act(exposed_temperature, exposed_volume)
	detonate()

/obj/item/grenade/firecracker/wirecutter_act(mob/living/user, obj/item/item)
	if(active)
		return
	if(det_time)
		det_time -= 10
		to_chat(user, span_notice("You shorten the fuse of [src] with [item]."))
		playsound(src, 'sound/items/wirecutter.ogg', 20, TRUE)
		icon_state = initial(icon_state) + "_[det_time]"
		update_appearance()
	else
		to_chat(user, span_danger("You've already removed all of the fuse!"))

/obj/item/grenade/firecracker/arm_grenade(mob/user, delayoverride, msg = TRUE, volume = 80)
	log_grenade(user)
	if(user)
		add_fingerprint(user)
		if(msg)
			to_chat(user, span_warning("You prime [src]! [capitalize(DisplayTimeText(det_time))]!"))
	playsound(src, 'sound/effects/fuse.ogg', volume, TRUE)
	active = TRUE
	icon_state = initial(icon_state) + "_active"
	addtimer(CALLBACK(src, .proc/detonate), isnull(delayoverride)? det_time : delayoverride)

/obj/item/grenade/firecracker/detonate(mob/living/lanced_by)
	. = ..()
	update_mob()
	explosion(src, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 2)
	qdel(src)


