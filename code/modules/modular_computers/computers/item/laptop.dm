/obj/item/modular_computer/laptop
	name = "laptop"
	desc = "A portable laptop computer."

	icon = 'icons/obj/devices/modular_laptop.dmi'
	icon_state = "laptop-closed"
	icon_state_powered = "laptop"
	icon_state_unpowered = "laptop-off"
	icon_state_menu = "menu"

	hardware_flag = PROGRAM_LAPTOP
	max_idle_programs = 3
	w_class = WEIGHT_CLASS_NORMAL
	interaction_flags_mouse_drop = NEED_HANDS


	// No running around with open laptops in hands.
	item_flags = SLOWS_WHILE_IN_HAND

	drag_slowdown = 0
	screen_on = FALSE // Starts closed
	var/start_open = TRUE // unless this var is set to 1
	var/icon_state_closed = "laptop-closed"
	var/w_class_open = WEIGHT_CLASS_BULKY
	var/slowdown_open = 1

/obj/item/modular_computer/laptop/examine(mob/user)
	. = ..()
	if(screen_on)
		. += span_notice("Alt-click to close it.")

/obj/item/modular_computer/laptop/Initialize(mapload)
	. = ..()

	if(start_open && !screen_on)
		toggle_open()

/obj/item/modular_computer/laptop/update_icon_state()
	if(!screen_on)
		icon_state = icon_state_closed
		return
	return ..()

/obj/item/modular_computer/laptop/update_overlays()
	if(!screen_on)
		cut_overlays()
		return
	return ..()

/obj/item/modular_computer/laptop/attack_self(mob/user)
	if(!screen_on)
		try_toggle_open(user)
	else
		return ..()

/obj/item/modular_computer/laptop/verb/open_computer()
	set name = "Toggle Open"
	set category = "Object"
	set src in view(1)

	try_toggle_open(usr)

/obj/item/modular_computer/laptop/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(over_object == user || over_object == src)
		try_toggle_open(user)
		return
	if(istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/H = over_object
		if(!isturf(loc))
			return
		user.put_in_hand(src, H.held_index)

/obj/item/modular_computer/laptop/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(screen_on && isturf(loc))
		return attack_self(user)

/obj/item/modular_computer/laptop/proc/try_toggle_open(mob/living/user)
	if(issilicon(user))
		return
	if(!isturf(loc) && !ismob(loc)) // No opening it in backpack.
		return
	if(!user.can_perform_action(src))
		return

	toggle_open(user)


/obj/item/modular_computer/laptop/click_alt(mob/user)
	if(!screen_on)
		return CLICK_ACTION_BLOCKING
	try_toggle_open(user) // Close it.
	return CLICK_ACTION_SUCCESS

/obj/item/modular_computer/laptop/proc/toggle_open(mob/living/user=null)
	if(screen_on)
		to_chat(user, span_notice("You close \the [src]."))
		slowdown = initial(slowdown)
		update_weight_class(initial(w_class))
		drag_slowdown = initial(drag_slowdown)
	else
		to_chat(user, span_notice("You open \the [src]."))
		slowdown = slowdown_open
		update_weight_class(w_class_open)
		drag_slowdown = slowdown_open
	if(isliving(loc))
		var/mob/living/localmob = loc
		localmob.update_equipment_speed_mods()
		localmob.update_pull_movespeed()

	screen_on = !screen_on
	update_appearance()

/obj/item/modular_computer/laptop/get_messenger_ending()
	return "Sent from my UNIX Laptop"

// Laptop frame, starts empty and closed.
/obj/item/modular_computer/laptop/buildable
	start_open = FALSE
