/obj/item/clothing/gloves
	var/max_number_of_accessories = 1
	var/list/obj/item/clothing/accessory/gloves_accessory/attached_accessories
	var/mutable_appearance/accessory_overlay

/obj/item/clothing/gloves/Initialize(mapload)
	. = ..()
	register_context()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/clothing/gloves/used_in_craft(atom/result, datum/crafting_recipe/current_recipe)
	. = ..()
	dump_attachments()

/obj/item/clothing/gloves/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()

	var/changed = FALSE

	if(istype(held_item, /obj/item/clothing/accessory/gloves_accessory) && length(attached_accessories) < max_number_of_accessories)
		context[SCREENTIP_CONTEXT_LMB] = "Прикрепить аксессуар"
		changed = TRUE

	if(LAZYLEN(attached_accessories))
		context[SCREENTIP_CONTEXT_ALT_RMB] = "Убрать аксессуар"
		changed = TRUE

	return changed ? CONTEXTUAL_SCREENTIP_SET : .

/obj/item/clothing/gloves/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/clothing/accessory/gloves_accessory))
		return attach_accessory(tool, user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

	return ..()

/obj/item/clothing/gloves/click_alt_secondary(mob/user)
	if(!LAZYLEN(attached_accessories))
		balloon_alert(user, "нет аксессуара чтобы снять!")
		return

	pop_accessory(user)

/obj/item/clothing/gloves/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return
	if(accessory_overlay)
		. += accessory_overlay

/obj/item/clothing/gloves/proc/attach_accessory(obj/item/clothing/accessory/gloves_accessory/accessory, mob/living/user, attach_message = TRUE)
	if(!istype(accessory))
		return
	if(!accessory.can_attach_accessory(src, user))
		return
	if(user && !user.temporarilyRemoveItemFromInventory(accessory))
		return
	if(!accessory.attach(src, user))
		return

	LAZYADD(attached_accessories, accessory)
	accessory.forceMove(src)

	accessory.attach(src)

	if(user && attach_message)
		balloon_alert(user, "аксессуар прикреплён")

	update_appearance()
	return TRUE

/obj/item/clothing/gloves/proc/pop_accessory(mob/living/user, attach_message = TRUE)
	var/obj/item/clothing/accessory/gloves_accessory/popped_accessory = attached_accessories[1]
	remove_accessory(popped_accessory)

	if(!user)
		return

	user.put_in_hands(popped_accessory)
	if(attach_message)
		popped_accessory.balloon_alert(user, "аксессуар снят")

/obj/item/clothing/gloves/proc/remove_accessory(obj/item/clothing/accessory/gloves_accessory/removed, update = TRUE)


	LAZYREMOVE(attached_accessories, removed)

	removed.detach(src)

	if(update)
		update_accessory_overlay()

/obj/item/clothing/gloves/proc/update_accessory_overlay()
	if(!length(attached_accessories))
		accessory_overlay = null
	else
		accessory_overlay = mutable_appearance()
		for(var/obj/item/clothing/accessory/gloves_accessory/accessory as anything in attached_accessories)
			accessory_overlay.overlays += accessory.generate_accessory_overlay(src)
	update_appearance()

/obj/item/clothing/gloves/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone in attached_accessories)
		remove_accessory(gone)

/obj/item/clothing/gloves/proc/dump_attachments(atom/drop_to = drop_location())
	for(var/obj/item/clothing/accessory/gloves_accessory/worn_accessory as anything in attached_accessories)
		remove_accessory(worn_accessory, update = FALSE)
		worn_accessory.forceMove(drop_to)
	update_accessory_overlay()

/obj/item/clothing/gloves/atom_destruction(damage_flag)
	dump_attachments()
	return ..()

/obj/item/clothing/gloves/Destroy()
	QDEL_LAZYLIST(attached_accessories)
	return ..()

/obj/item/clothing/gloves/examine(mob/user)
	. = ..()
	if(LAZYLEN(attached_accessories))
		var/list/accessories = list_accessories_with_icon(user)
		. += "Имеет прикрепленное: [english_list(accessories)]."

/obj/item/clothing/gloves/proc/list_accessories_with_icon(mob/user)
	var/list/all_accessories = list()
	for(var/obj/item/clothing/accessory/gloves_accessory/attached as anything in attached_accessories)
		all_accessories += attached.examine_title(user)

	return all_accessories

// MARK: CentCom
/obj/item/clothing/gloves/combat/centcom
	name = "fleet officer's gloves"
	desc = "Солидные перчатки офицеров Центрального Командования Нанотрейзен."
	icon = 'modular_bandastation/aesthetics/clothing/centcom/icons/obj/clothing/gloves/gloves.dmi'
	worn_icon = 'modular_bandastation/aesthetics/clothing/centcom/icons/mob/clothing/gloves/gloves.dmi'
	lefthand_file = 'modular_bandastation/aesthetics/clothing/centcom/icons/inhands/clothing/gloves_lefthand.dmi'
	righthand_file = 'modular_bandastation/aesthetics/clothing/centcom/icons/inhands/clothing/gloves_righthand.dmi'
	icon_state = "centcom"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | FREEZE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/clothing/gloves/combat/centcom/diplomat
	desc = "Изящные и солидные перчатки офицеров Центрального Командования Нанотрейзен."
	icon_state = "centcom_diplomat"

// MARK: Detective (forensics) gloves
/obj/item/clothing/gloves/color/black/forensics
	name = "forensics gloves"
	desc = "Эти высокотехнологичные перчатки не оставляют никаких следов на предметах, к которым прикасаются. Идеально подходят для того, чтобы оставить место преступления нетронутым... как до, так и после преступления."
	icon = 'modular_bandastation/objects/icons/obj/clothing/gloves.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/gloves.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/gloves_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/gloves_righthand.dmi'
	icon_state = "forensics"
	clothing_flags = FIBERLESS_GLOVES

/obj/item/clothing/gloves/examine_tags(mob/user)
	. = ..()
	if(clothing_flags & FIBERLESS_GLOVES)
		.["безволоконная"] = "Не оставляет волокна."

/obj/item/clothing/gloves/fingerless/biker_gloves
	name = "biker gloves"
	desc = "Обычные черные перчатки с черепом."
	icon = 'modular_bandastation/objects/icons/obj/clothing/gloves.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/gloves.dmi'
	icon_state = "bike_gloves"

// MARK: Etamin ind.
/obj/item/clothing/gloves/etamin_gloves
	name = "Gold On Black gloves"
	desc = "Качественные перчатки с золотой вставкой 999 пробы."
	icon = 'modular_bandastation/objects/icons/obj/clothing/gloves.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/gloves.dmi'
	icon_state = "ei_gloves"
