/mob/living/carbon/human/proc/toggle_holster(
	obj/item/clothing/accessory/holster/H,
	typepath
)
	var/obj/item/held_item = get_held_item_of_type(typepath)
	if(held_item)
		if(!H.atom_storage.attempt_insert(held_item, src))
			to_chat(src, span_warning("[capitalize(held_item.declent_ru(NOMINATIVE))] не помещается в кобуру!"))
		return TRUE

	for(var/obj/item/I in H.atom_storage.real_location.contents)
		if(!istype(I, typepath))
			continue
		if(!H.atom_storage.attempt_remove(I, src.loc))
			return TRUE
		put_in_hands(I)
		to_chat(src, span_notice("Вы быстро достаёте [I.declent_ru(ACCUSATIVE)]."))
		return TRUE

	return FALSE

/mob/living/carbon/human/proc/get_held_item_of_type(typepath)
	var/obj/item/I = get_active_held_item()
	if(istype(I, typepath))
		return I
	I = get_inactive_held_item()
	if(istype(I, typepath))
		return I
	return null

/mob/living/carbon/human/proc/toggle_accessory_storage(obj/item/clothing/accessory/A)
	var/obj/item/held_item = get_active_held_item()
	if(held_item)
		if(!A.atom_storage.attempt_insert(held_item, src))
			to_chat(src, span_warning("Не удалось убрать [held_item.declent_ru(NOMINATIVE)]!"))
		return TRUE

	for(var/obj/item/I in A.atom_storage.real_location.contents)
		if(!A.atom_storage.attempt_remove(I, src.loc))
			return TRUE
		put_in_hands(I)
		to_chat(src, span_notice("Вы достаёте [I.declent_ru(ACCUSATIVE)]."))
		return TRUE

	return FALSE

/mob/living/carbon/human/proc/quick_accessory_draw()
	var/obj/item/clothing/under/U = w_uniform
	if(!U)
		to_chat(src, span_warning("На вас нет формы!"))
		return
	if(!LAZYLEN(U.attached_accessories))
		to_chat(src, span_warning("Нет аксессуаров!"))
		return

	var/obj/item/clothing/accessory/target_accessory = null
	for(var/obj/item/clothing/accessory/A in U.attached_accessories)
		if(A.atom_storage)
			target_accessory = A
			break
	if(!target_accessory)
		to_chat(src, span_warning("Нет аксессуара с хранилищем!"))
		return

	// Tacticool holster
	if(istype(target_accessory, /obj/item/clothing/accessory/holster/tacticool))
		var/obj/item/gun/held_gun = get_held_item_of_type(/obj/item/gun)
		var/obj/item/gun/first_gun = null
		var/obj/item/gun/second_gun = null
		for(var/obj/item/I in target_accessory.atom_storage.real_location.contents)
			if(!istype(I, /obj/item/gun))
				continue
			var/obj/item/gun/G = I
			if(!first_gun)
				first_gun = G
				continue
			if(!second_gun)
				second_gun = G
				break
		if(held_gun)
			if(!first_gun)
				if(!target_accessory.atom_storage.attempt_insert(held_gun, src))
					to_chat(src, span_warning("[capitalize(held_gun.declent_ru(NOMINATIVE))] не помещается в кобуру!"))
					return
				return
			if(!second_gun)
				if(!target_accessory.atom_storage.attempt_insert(held_gun, src))
					to_chat(src, span_warning("[capitalize(held_gun.declent_ru(NOMINATIVE))] не помещается в кобуру!"))
					return
				return
			to_chat(src, span_warning("Тактическая кобура заполнена!"))
			return

		var/obj/item/gun/target_gun = null
		for(var/obj/item/I in target_accessory.atom_storage.real_location.contents)
			if(!istype(I, /obj/item/gun))
				continue
			target_gun = I
			break
		if(!target_gun)
			to_chat(src, span_warning("В кобуре нет оружия!"))
			return
		if(!target_accessory.atom_storage.attempt_remove(target_gun, src.loc))
			return
		put_in_hands(target_gun)
		to_chat(src, span_notice("Вы быстро достаёте [target_gun.declent_ru(ACCUSATIVE)]."))
		return

	// Energy holster
	if(istype(target_accessory, /obj/item/clothing/accessory/holster/energy))
		var/obj/item/clothing/accessory/holster/H = target_accessory
		if(!H.can_access_holster(src))
			to_chat(src, span_warning("Кобура скрыта под плотной одеждой!"))
			return
		if(toggle_holster(H, /obj/item/gun/energy))
			return
		to_chat(src, span_warning("Кобура пуста!"))
		return

	// Standart holster
	if(istype(target_accessory, /obj/item/clothing/accessory/holster))
		var/obj/item/clothing/accessory/holster/H = target_accessory
		if(!H.can_access_holster(src))
			to_chat(src, span_warning("Кобура скрыта под плотной одеждой!"))
			return
		if(toggle_holster(H, /obj/item/gun))
			return
		to_chat(src, span_warning("В кобуре нет оружия!"))
		return

	// Standard accessories
	if(toggle_accessory_storage(target_accessory))
		return

	to_chat(src, span_warning("Карман пуст!"))

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_KB_HUMAN_QUICK_ACCESSORY_DRAW_DOWN, PROC_REF(on_quick_accessory_draw))

/mob/living/carbon/human/proc/on_quick_accessory_draw()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(quick_accessory_draw))
