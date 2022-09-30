/datum/component/gags_recolorable

/datum/component/gags_recolorable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)

/datum/component/gags_recolorable/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)

/datum/component/gags_recolorable/proc/on_attackby(datum/source, obj/item/attacking_item, mob/user)
	SIGNAL_HANDLER

	if(!isatom(parent))
		return

	if(!istype(attacking_item, /obj/item/toy/crayon/spraycan))
		return
	var/obj/item/toy/crayon/spraycan/can = attacking_item

	if(can.is_capped || can.check_empty())
		return

	INVOKE_ASYNC(src, .proc/open_ui, user, can)
	return COMPONENT_NO_AFTERATTACK

/datum/component/gags_recolorable/proc/open_ui(mob/user, obj/item/toy/crayon/spraycan/can)
	var/atom/atom_parent = parent
	var/list/allowed_configs = list()
	var/config = initial(atom_parent.greyscale_config)
	if(!config)
		return
	allowed_configs += "[config]"
	if(ispath(atom_parent, /obj/item))
		var/obj/item/item = atom_parent
		if(initial(item.greyscale_config_worn))
			allowed_configs += "[initial(item.greyscale_config_worn)]"
		if(initial(item.greyscale_config_inhand_left))
			allowed_configs += "[initial(item.greyscale_config_inhand_left)]"
		if(initial(item.greyscale_config_inhand_right))
			allowed_configs += "[initial(item.greyscale_config_inhand_right)]"

	var/datum/greyscale_modify_menu/spray_paint/menu = new(
		atom_parent, user, allowed_configs, CALLBACK(src, .proc/recolor, user, can),
		starting_icon_state = initial(atom_parent.icon_state),
		starting_config = initial(atom_parent.greyscale_config),
		starting_colors = atom_parent.greyscale_colors,
		used_spraycan = can
	)
	menu.ui_interact(user)

/datum/component/gags_recolorable/proc/recolor(mob/user, obj/item/toy/crayon/spraycan/can, datum/greyscale_modify_menu/menu)
	if(!isatom(parent))
		return
	var/atom/atom_parent = parent

	if(can.is_capped || can.check_empty(user))
		menu.ui_close()
		return

	can.use_charges()
	if(can.pre_noise)
		atom_parent.audible_message(span_hear("You hear spraying."))
		playsound(atom_parent.loc, 'sound/effects/spray.ogg', 5, TRUE, 5)

	atom_parent.set_greyscale(menu.split_colors)

	// If the item is a piece of clothing and is being worn, make sure it updates on the player
	if(!isclothing(atom_parent))
		return
	if(!ishuman(atom_parent.loc))
		return
	var/obj/item/clothing/clothing_parent = atom_parent
	var/mob/living/carbon/human/wearer = atom_parent.loc
	wearer.update_clothing(clothing_parent.slot_flags)
