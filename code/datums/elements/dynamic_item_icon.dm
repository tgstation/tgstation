/datum/element/dynamic_item_icon

/datum/element/dynamic_item_icon/Attach(datum/target)
	. = ..()

	if (!isitem(target))
		return ELEMENT_INCOMPATIBLE
	var/obj/item/item_target = target
	if (!item_target.onflooricon)
		return ELEMENT_INCOMPATIBLE

	if (isturf(item_target.loc))
		apply_onfloor_icon(item_target)

	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(handle_item_equipped))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(handle_item_dropped))

/datum/element/dynamic_item_icon/Detach(datum/source, ...)
	. = ..()

	// Reset to normal icon
	apply_equipped_icon(source)
	UnregisterSignal(source, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(source, COMSIG_ITEM_DROPPED)

/datum/element/dynamic_item_icon/proc/handle_item_equipped(obj/item/source, mob/equipper, slot)
	SIGNAL_HANDLER

	apply_equipped_icon(source)

/datum/element/dynamic_item_icon/proc/handle_item_dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER

	if (!isturf(source.loc))
		return

	apply_onfloor_icon(source)

/datum/element/dynamic_item_icon/proc/apply_equipped_icon(obj/item/item)
	item.icon = initial(item.icon)
	item.pixel_w = initial(item.pixel_w)

	if(item.item_flags & ACTIVE_ONFLOOR_ICON)
		item.item_flags &= ~ACTIVE_ONFLOOR_ICON

	item.update_icon()
	item.update_greyscale()

/datum/element/dynamic_item_icon/proc/apply_onfloor_icon(obj/item/item)
	item.icon = item.onflooricon
	item.pixel_w = 0
	item.cut_overlays()
	if (item.onflooricon_state)
		item.icon_state = item.onflooricon_state

	if(!(item.item_flags & ACTIVE_ONFLOOR_ICON))
		item.item_flags |= ACTIVE_ONFLOOR_ICON

	item.update_icon()
	//item.update_greyscale()

#warn proof of concept. Likely does not belong in this pr.
/obj/item/toy/plush/argemia
	name = "strange plushie"
	desc = "Voiding..."
	icon_state = "argemia"
	ONFLOOR_ICON_HELPER('icons/obj/toys/plushes_onfloor.dmi')
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/plush/argemia/microwave_act(obj/machinery/microwave/microwave_source, mob/microwaver, randomize_pixel_offset)
	. = ..()
	playsound(microwave_source.loc, 'modular_darkpack/modules/toys/sounds/aeaeae.ogg', 100, FALSE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/toy/plush/argemia, microwave_explode), microwave_source), 5 SECONDS)

/obj/item/toy/plush/argemia/proc/microwave_explode(obj/machinery/microwave/microwave_source)
	explosion(microwave_source.loc, 0, 1, 2)
