/obj/item/jammer/nt
	name = "Nanotrasen radio jammer"
	desc = "Корпоративный генератор помех Нанотрейзен. Компактное устройство, способное эффективно блокировать широкий спектр радиочастот."
	icon = 'modular_bandastation/objects/icons/obj/items/nt_radio_jammer.dmi'
	icon_state = "jammer_nt"
	range = 18
	whitelisted_frequencies = list(
		FREQ_CENTCOM
	)

/obj/item/jammer/nt/examine_more(mob/user)
	. = ..()
	. += span_notice(
		"На обратной стороне выгравировано: «Собственность корпорации Нанотрейзен. \
		Корпорация не несёт ответственности за использование устройства третьими лицами, \
		а также за любые действия, совершённые с его применением в случае кражи».")

/obj/item/jammer/nt/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	context[SCREENTIP_CONTEXT_RMB] = "Переключить"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/jammer/nt/attack_self(mob/user, modifiers)
	return

/obj/item/jammer/nt/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return
