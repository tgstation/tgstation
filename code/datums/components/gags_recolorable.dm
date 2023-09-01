/datum/element/gags_recolorable

/datum/element/gags_recolorable/Attach(datum/target)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

/datum/element/gags_recolorable/proc/on_attackby(datum/source, obj/item/attacking_item, mob/user)
	SIGNAL_HANDLER

	if(!istype(attacking_item, /obj/item/toy/crayon/spraycan))
		return
	var/obj/item/toy/crayon/spraycan/can = attacking_item

	if(can.is_capped || can.check_empty())
		return

	INVOKE_ASYNC(src, PROC_REF(open_ui), user, can, source)
	return COMPONENT_NO_AFTERATTACK

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
		starting_icon_state = initial(target.icon_state),
		starting_config = initial(target.greyscale_config),
		starting_colors = target.greyscale_colors,
		used_spraycan = can
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

	// If the item is a piece of clothing and is being worn, make sure it updates on the player
	if(!isclothing(target))
		return
	if(!ishuman(target.loc))
		return
	var/obj/item/clothing/clothing_target = target
	var/mob/living/carbon/human/wearer = target.loc
	wearer.update_clothing(clothing_target.slot_flags)
