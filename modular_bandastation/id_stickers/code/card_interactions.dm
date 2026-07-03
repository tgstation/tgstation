/obj/item/card/id/advanced
	var/obj/item/id_sticker/applied_sticker = null

/obj/item/card/id/advanced/Destroy()
	if(applied_sticker)
		QDEL_NULL(applied_sticker)
	. = ..()

/obj/item/card/id/advanced/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(!istype(tool, /obj/item/id_sticker))
		return NONE

	if(applied_sticker)
		to_chat(user, span_warning("На ID карте уже есть наклейка, сначала снимите её!"))
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("Вы начинаете наносить наклейку на ID карту."))
	if(!do_after(user, 2 SECONDS, src))
		return ITEM_INTERACT_BLOCKING
	apply_sticker(user, tool)

/obj/item/card/id/advanced/examine(mob/user)
	. = ..()
	if(applied_sticker)
		. += "На ней [applied_sticker.declent_ru(NOMINATIVE)]"
		. += span_info("Вы можете снять наклейку, используя <b>Ctrl-Shift-Click</b>.")

/obj/item/card/id/advanced/click_ctrl_shift(mob/living/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("Ваши руки должны быть свободны, чтобы сделать это!"))
		return
	if(!applied_sticker)
		to_chat(user, span_warning("На ID карте нет наклейки!"))
		return
	if(user.combat_mode)
		to_chat(user, span_notice("Вы сдираете наклейку с ID карты!"))
		playsound(src, 'sound/items/poster/poster_ripped.ogg', 100, TRUE)
		qdel(remove_sticker())
		return

	to_chat(user, span_notice("Вы пытаетесь снять наклейку с ID карты..."))
	if(do_after(user, 5 SECONDS, src))
		to_chat(user, span_notice("Вы сняли наклейку с ID карты."))
		user.put_in_hands(remove_sticker())

/obj/item/card/id/advanced/update_overlays()
	. = ..()
	if(applied_sticker)
		var/mutable_appearance/sticker_overlay = mutable_appearance(applied_sticker.icon, applied_sticker.icon_state)
		. += sticker_overlay

/obj/item/card/id/advanced/update_desc(updates)
	. = ..()
	if(applied_sticker?.id_card_desc)
		desc = "[src::desc]<br>[applied_sticker.id_card_desc]"
	else
		desc = src::desc

/obj/item/card/id/advanced/proc/apply_sticker(mob/user, obj/item/id_sticker/sticker)
	sticker.forceMove(src)
	applied_sticker = sticker
	update_appearance(UPDATE_OVERLAYS|UPDATE_DESC)
	to_chat(user, span_notice("Вы наклеили [sticker.declent_ru(ACCUSATIVE)] на ID карту."))
	RegisterSignal(sticker, COMSIG_QDELETING, PROC_REF(on_applied_sticker_qdeleting))

/obj/item/card/id/advanced/proc/on_applied_sticker_qdeleting()
	SIGNAL_HANDLER

	remove_sticker()

/obj/item/card/id/advanced/proc/remove_sticker()
	var/obj/item/id_sticker/removed_sticker = applied_sticker
	applied_sticker = null
	update_appearance(UPDATE_OVERLAYS|UPDATE_DESC)
	UnregisterSignal(removed_sticker, COMSIG_QDELETING)
	return removed_sticker

/obj/machinery/pdapainter/attackby(obj/item/O, mob/living/user, params)
	if(istype(O, /obj/item/card/id/advanced))
		var/obj/item/card/id/advanced/card = O
		if(card.applied_sticker)
			to_chat(user, span_warning("ID карта со стикером не может быть покрашена!"))
			return
	. = ..()
