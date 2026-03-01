///An element that lets players recolor the item through the greyscale menu with the help of a spraycan.
/datum/element/gags_recolorable

/datum/element/gags_recolorable/Attach(datum/target)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine))

/datum/element/gags_recolorable/proc/on_examine(atom/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice("Now utilising PPP recolouring technology, capable of absorbing paint and pigments for changing its colours!")

/datum/element/gags_recolorable/proc/on_item_interaction(atom/movable/source, mob/living/user, obj/item/toy/crayon/spraycan/item, modifiers)
	SIGNAL_HANDLER

	if(!istype(item))
		return NONE

	if(item.is_capped)
		user.balloon_alert(user, "take the cap off first!")
		return ITEM_INTERACT_BLOCKING
	if(item.check_empty())
		user.balloon_alert(user, "empty!")
		return ITEM_INTERACT_BLOCKING

	INVOKE_ASYNC(src, PROC_REF(open_ui), user, item, source)
	return ITEM_INTERACT_SUCCESS

/datum/element/gags_recolorable/proc/open_ui(mob/user, obj/item/toy/crayon/spraycan/can, atom/target)
	var/list/allowed_configs = list()
	var/config = initial(target.greyscale_config)
	if(!config)
		return
	allowed_configs += "[config]"
	if(isitem(target))
		var/obj/item/item = target
		if(initial(item.greyscale_config_worn))
			allowed_configs += "[initial(item.greyscale_config_worn)]"
		if(initial(item.greyscale_config_inhand_left))
			allowed_configs += "[initial(item.greyscale_config_inhand_left)]"
		if(initial(item.greyscale_config_inhand_right))
			allowed_configs += "[initial(item.greyscale_config_inhand_right)]"

	var/datum/greyscale_modify_menu/spray_paint/menu = new(
		target, user, allowed_configs, CALLBACK(src, PROC_REF(recolor), user, can, target),
		starting_icon_state = target::post_init_icon_state || target::icon_state,
		starting_config = initial(target.greyscale_config),
		starting_colors = target.greyscale_colors,
		used_spraycan = can,
	)
	menu.ui_interact(user)

/datum/element/gags_recolorable/proc/recolor(mob/user, obj/item/toy/crayon/spraycan/can, atom/target, datum/greyscale_modify_menu/menu)
	if(can.is_capped || can.check_empty(user))
		menu.ui_close()
		return

	can.use_charges()
	if(can.pre_noise)
		target.audible_message(span_hear("You hear spraying."))
		playsound(target.loc, 'sound/effects/spray.ogg', 5, TRUE, 5)

	target.set_greyscale(menu.split_colors)
