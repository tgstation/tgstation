/obj/item/reagent_containers/cup/primitive_centrifuge
	name = "primitive centrifuge"
	desc = "A small cup that allows a person to slowly spin out liquids they do not desire."
	icon = 'modular_doppler/reagent_forging/icons/obj/misc_tools.dmi'
	icon_state = "primitive_centrifuge"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_GREYSCALE | MATERIAL_COLOR

/obj/item/reagent_containers/cup/primitive_centrifuge/examine()
	. = ..()
	. += span_notice("<b>Ctrl + Click</b> to select chemicals to remove.")
	. += span_notice("<b>Ctrl + Shift + Click</b> to select a chemical to keep, the rest removed.")

/obj/item/reagent_containers/cup/primitive_centrifuge/item_ctrl_click(mob/user)
	if(!length(reagents.reagent_list))
		return CLICK_ACTION_BLOCKING

	var/datum/user_input = tgui_input_list(user, "Select which chemical to remove.", "Removal Selection", reagents.reagent_list)

	if(!user_input)
		balloon_alert(user, "no selection!")
		return CLICK_ACTION_BLOCKING

	user.balloon_alert_to_viewers("spinning [src]...")
	if(!do_after(user, 5 SECONDS, target = src))
		user.balloon_alert_to_viewers("stopped spinning [src]")
		return CLICK_ACTION_BLOCKING

	reagents.del_reagent(user_input.type)
	balloon_alert(user, "removed reagent from [src]")
	return CLICK_ACTION_SUCCESS

/obj/item/reagent_containers/cup/primitive_centrifuge/click_ctrl_shift(mob/user)
	if(!length(reagents.reagent_list))
		return

	var/datum/user_input = tgui_input_list(user, "Select which chemical to keep, the rest removed.", "Keep Selection", reagents.reagent_list)

	if(!user_input)
		balloon_alert(user, "no selection!")
		return

	user.balloon_alert_to_viewers("spinning [src]...")
	if(!do_after(user, 5 SECONDS, target = src))
		user.balloon_alert_to_viewers("stopped spinning [src]")
		return

	for(var/datum/reagent/remove_reagent in reagents.reagent_list)
		if(!istype(remove_reagent, user_input.type))
			reagents.del_reagent(remove_reagent.type)

	balloon_alert(user, "removed reagents from [src]")
