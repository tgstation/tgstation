/obj/item/organ/cyberimp/arm/toolkit/centcom
	name = "centcom combat implant"
	desc = "Мощный кибернетический имплантат военного класса, предназначенный для обеспечения пользователя полезными для боя устройствами из его руки."
	items_to_create = list(
		/obj/item/melee/energy/blade/hardlight,
		/obj/item/gun/medbeam,
		/obj/item/borg/stun,
		/obj/item/gun/energy/pulse/pistol/m1911
	)

/obj/item/organ/cyberimp/arm/toolkit/centcom/Extend(obj/item/augment)
	. = ..()
	UnregisterSignal(active_item, COMSIG_ITEM_ATTACK_SELF)
	UnregisterSignal(active_item, COMSIG_ITEM_ATTACK_SELF_SECONDARY)

/obj/item/organ/cyberimp/arm/toolkit/custom
	name = "custom arm implant"
	desc = "Настраиваемый имплант руки, спроектированный чтобы хранить предмет по желанию пользователя."
	aug_overlay = "toolkit"
	items_to_create = list()
	var/max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/organ/cyberimp/arm/toolkit/custom/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(LAZYLEN(items_list) == 1)
		var/datum/weakref/ref = items_list[1]
		active_item = ref.resolve()
	if(active_item)
		items_list -= WEAKREF(active_item)
		user.put_in_hands(active_item)
		REMOVE_TRAIT(active_item, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
		user.balloon_alert(user, "Извлечено: [src].")
		playsound(get_turf(src), 'sound/items/tools/screwdriver.ogg', 50, TRUE)
		active_item = null
		return

/obj/item/organ/cyberimp/arm/toolkit/custom/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(LAZYLEN(items_list) == 1)
		var/datum/weakref/ref = items_list[1]
		active_item = ref.resolve()
	if(active_item)
		user.balloon_alert(user, "Уже хранит предмет: [active_item].")
		return
	if(tool.w_class > max_w_class)
		user.balloon_alert(user, "Не помещается!")
		return
	if(!user.transferItemToLoc(tool, src))
		return
	items_list += WEAKREF(tool)
	active_item = tool
	user.balloon_alert(user, "Установлено: [tool].")
	playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)

/obj/item/organ/cyberimp/arm/toolkit/custom/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	return NONE // to prevent screwdriver insertion after item removal

/obj/item/organ/cyberimp/arm/toolkit/custom/on_mob_remove(mob/living/carbon/arm_owner)
	if(active_item)
		Retract()
	return ..()

/obj/item/organ/cyberimp/arm/toolkit/custom/Destroy()
	if(active_item)
		QDEL_NULL(active_item)
	return ..()
