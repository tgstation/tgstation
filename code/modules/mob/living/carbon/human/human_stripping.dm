#define INTERNALS_TOGGLE_DELAY (4 SECONDS)
#define POCKET_EQUIP_DELAY (1 SECONDS)

GLOBAL_LIST_INIT(strippable_human_items, create_strippable_list(list(
	/datum/strippable_item/mob_item_slot/head,
	/datum/strippable_item/mob_item_slot/back,
	/datum/strippable_item/mob_item_slot/mask,
	/datum/strippable_item/mob_item_slot/neck,
	/datum/strippable_item/mob_item_slot/eyes,
	/datum/strippable_item/mob_item_slot/ears,
	/datum/strippable_item/mob_item_slot/jumpsuit,
	/datum/strippable_item/mob_item_slot/suit,
	/datum/strippable_item/mob_item_slot/gloves,
	/datum/strippable_item/mob_item_slot/feet,
	/datum/strippable_item/mob_item_slot/suit_storage,
	/datum/strippable_item/mob_item_slot/id,
	/datum/strippable_item/mob_item_slot/belt,
	/datum/strippable_item/mob_item_slot/pocket/left,
	/datum/strippable_item/mob_item_slot/pocket/right,
	/datum/strippable_item/hand/left,
	/datum/strippable_item/hand/right,
	/datum/strippable_item/mob_item_slot/handcuffs,
	/datum/strippable_item/mob_item_slot/legcuffs,
)))

/mob/living/carbon/human/proc/should_strip(mob/user)
	if (user.pulling != src || user.grab_state != GRAB_AGGRESSIVE)
		return TRUE

	if (ishuman(user))
		var/mob/living/carbon/human/human_user = user
		return !human_user.can_be_firemanned(src)

	return TRUE

/datum/strippable_item/mob_item_slot/eyes
	key = STRIPPABLE_ITEM_EYES
	item_slot = ITEM_SLOT_EYES

/datum/strippable_item/mob_item_slot/ears
	key = STRIPPABLE_ITEM_EARS
	item_slot = ITEM_SLOT_EARS

/datum/strippable_item/mob_item_slot/jumpsuit
	key = STRIPPABLE_ITEM_JUMPSUIT
	item_slot = ITEM_SLOT_ICLOTHING

/datum/strippable_item/mob_item_slot/jumpsuit/get_alternate_actions(atom/source, mob/user)
	var/obj/item/clothing/under/jumpsuit = get_item(source)
	if (!istype(jumpsuit))
		return null

	var/list/actions = list()
	if(jumpsuit.has_sensor == HAS_SENSORS)
		actions += "adjust_sensor"
	if(jumpsuit.can_adjust)
		actions += "adjust_jumpsuit"
	if(length(jumpsuit.attached_accessories))
		actions += "strip_accessory"

	return actions

/datum/strippable_item/mob_item_slot/jumpsuit/perform_alternate_action(atom/source, mob/user, action_key)
	if (!..())
		return
	var/obj/item/clothing/under/jumpsuit = get_item(source)
	if (!istype(jumpsuit))
		return null

	switch(action_key)
		if("adjust_jumpsuit")
			do_adjust_jumpsuit(source, user, jumpsuit)
		if("adjust_sensor")
			do_adjust_sensor(source, user, jumpsuit)
		if("strip_accessory")
			do_strip_accessory(source, user, jumpsuit)
		else
			stack_trace("Unknown action key: [action_key] for [type]")

/datum/strippable_item/mob_item_slot/jumpsuit/proc/do_adjust_jumpsuit(atom/source, mob/user, obj/item/clothing/under/jumpsuit)
	to_chat(source, span_notice("[user] is trying to adjust your [jumpsuit]."))
	if (!do_after(user, (jumpsuit.strip_delay * 0.5), source))
		return
	to_chat(source, span_notice("[user] successfully adjusted your [jumpsuit]."))
	jumpsuit.toggle_jumpsuit_adjust()

	if (!ismob(source))
		return

	var/mob/mob_source = source
	mob_source.update_worn_undersuit()
	mob_source.update_body()

/datum/strippable_item/mob_item_slot/jumpsuit/proc/do_adjust_sensor(atom/source, mob/user, obj/item/clothing/under/jumpsuit)
	if(jumpsuit.has_sensor != HAS_SENSORS)
		return

	var/static/list/sensor_mode_text_to_num = list(
		"Off" = SENSOR_OFF,
		"Living" = SENSOR_LIVING,
		"Vitals" = SENSOR_VITALS,
		"Tracking" = SENSOR_COORDS,
	)
	var/static/list/senor_mode_num_to_text = list( // keep this as the inverse of the above list
		"[SENSOR_OFF]" = "Off",
		"[SENSOR_LIVING]" = "Living",
		"[SENSOR_VITALS]" = "Vitals",
		"[SENSOR_COORDS]" = "Tracking",
	)

	var/new_mode = tgui_input_list(user, "Adjust suit sensors", "Adjust Sensors", sensor_mode_text_to_num, senor_mode_num_to_text["[jumpsuit.sensor_mode]"])
	new_mode = sensor_mode_text_to_num[new_mode]
	if(isnull(new_mode)) // also catches returning null
		return

	if(!user.Adjacent(source))
		source.balloon_alert(user, "can't reach!")
		return

	to_chat(source, span_notice("[user] is trying to adjust your [jumpsuit.name]'s sensor."))
	if(!do_after(user, jumpsuit.strip_delay * 0.5, source) || !jumpsuit.set_sensor_mode(new_mode)) // takes the same amount of time as adjusting it
		source.balloon_alert(user, "failed!")
		return
	source.balloon_alert(user, "changed sensors")
	to_chat(source, span_notice("[user] successfully adjusted your [jumpsuit.name]'s sensor."))

/datum/strippable_item/mob_item_slot/jumpsuit/proc/do_strip_accessory(atom/source, mob/user, obj/item/clothing/under/jumpsuit)
	var/list/accessory_choices = list()
	for(var/obj/item/clothing/accessory/jumpsuit_accessory as anything in jumpsuit.attached_accessories)
		if(!istype(jumpsuit_accessory))
			continue
		accessory_choices[jumpsuit_accessory.name] += jumpsuit_accessory

	var/chosen_accessory_name = tgui_input_list(user, "Select which accessory to strip", "Select Accessory", accessory_choices)
	var/obj/item/clothing/accessory/chosen_accessory = accessory_choices[chosen_accessory_name]
	if(isnull(chosen_accessory))
		return

	if(!user.Adjacent(source))
		source.balloon_alert(user, "can't reach!")
		return

	to_chat(source, span_notice("[user] is trying to take [chosen_accessory] off of [jumpsuit]!"))
	if(!do_after(user, chosen_accessory.strip_delay, source))
		source.balloon_alert(user, "failed!")
		return

	to_chat(source, span_notice("[user] has taken [chosen_accessory] off of [jumpsuit]."))
	jumpsuit.remove_accessory(chosen_accessory)
	jumpsuit.update_appearance()
	chosen_accessory.forceMove(jumpsuit.drop_location())

	if(!ismob(source))
		return

	var/mob/mob_source = source
	mob_source.update_worn_undersuit()

/datum/strippable_item/mob_item_slot/suit
	key = STRIPPABLE_ITEM_SUIT
	item_slot = ITEM_SLOT_OCLOTHING

/datum/strippable_item/mob_item_slot/gloves
	key = STRIPPABLE_ITEM_GLOVES
	item_slot = ITEM_SLOT_GLOVES

/datum/strippable_item/mob_item_slot/feet
	key = STRIPPABLE_ITEM_FEET
	item_slot = ITEM_SLOT_FEET

/datum/strippable_item/mob_item_slot/feet/get_alternate_actions(atom/source, mob/user)
	var/obj/item/clothing/shoes/shoes = get_item(source)
	if (!istype(shoes) || shoes.fastening_type == SHOES_SLIPON)
		return null

	switch (shoes.tied)
		if (SHOES_UNTIED)
			return list("knot")
		if (SHOES_TIED)
			return list("untie")
		if (SHOES_KNOTTED)
			return list("unknot")

/datum/strippable_item/mob_item_slot/feet/perform_alternate_action(atom/source, mob/user, action_key)
	if(!..())
		return

	var/obj/item/clothing/shoes/shoes = get_item(source)
	if (!istype(shoes))
		return
	switch(action_key)
		if("knot", "untie", "unknot")
			shoes.handle_tying(user)
		else
			stack_trace("Unknown action key: [action_key] for [type]")

/datum/strippable_item/mob_item_slot/suit_storage
	key = STRIPPABLE_ITEM_SUIT_STORAGE
	item_slot = ITEM_SLOT_SUITSTORE

/datum/strippable_item/mob_item_slot/suit_storage/get_alternate_actions(atom/source, mob/user)
	return get_strippable_alternate_action_internals(get_item(source), source)

/datum/strippable_item/mob_item_slot/suit_storage/perform_alternate_action(atom/source, mob/user, action_key)
	if(!..())
		return
	if(action_key in get_strippable_alternate_action_internals(get_item(source), source))
		strippable_alternate_action_internals(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/id
	key = STRIPPABLE_ITEM_ID
	item_slot = ITEM_SLOT_ID

/datum/strippable_item/mob_item_slot/belt
	key = STRIPPABLE_ITEM_BELT
	item_slot = ITEM_SLOT_BELT

/datum/strippable_item/mob_item_slot/belt/get_alternate_actions(atom/source, mob/user)
	return get_strippable_alternate_action_internals(get_item(source), source)

/datum/strippable_item/mob_item_slot/belt/perform_alternate_action(atom/source, mob/user, action_key)
	if (!..())
		return
	if(action_key in get_strippable_alternate_action_internals(get_item(source), source))
		strippable_alternate_action_internals(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/pocket
	/// Which pocket we're referencing. Used for visible text.
	var/pocket_side

/datum/strippable_item/mob_item_slot/pocket/get_obscuring(atom/source)
	return isnull(get_item(source)) \
		? STRIPPABLE_OBSCURING_NONE \
		: STRIPPABLE_OBSCURING_HIDDEN

/datum/strippable_item/mob_item_slot/pocket/get_equip_delay(obj/item/equipping)
	return POCKET_EQUIP_DELAY

/datum/strippable_item/mob_item_slot/pocket/start_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if (!.)
		warn_owner(source)

/datum/strippable_item/mob_item_slot/pocket/start_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if (isnull(item))
		return FALSE

	to_chat(user, span_notice("You try to empty [source]'s [pocket_side] pocket."))

	user.log_message("is pickpocketing [key_name(source)] of [item] ([pocket_side])", LOG_ATTACK, color="red")
	source.log_message("is being pickpocketed of [item] by [key_name(user)] ([pocket_side])", LOG_VICTIM, color="orange", log_globally=FALSE)
	item.add_fingerprint(src)

	var/result = start_unequip_mob(item, source, user, strip_delay = POCKET_STRIP_DELAY, hidden = TRUE)

	if (!result)
		warn_owner(source)

	return result

/datum/strippable_item/mob_item_slot/pocket/proc/warn_owner(atom/owner)
	to_chat(owner, span_warning("You feel your [pocket_side] pocket being fumbled with!"))

/datum/strippable_item/mob_item_slot/pocket/left
	key = STRIPPABLE_ITEM_LPOCKET
	item_slot = ITEM_SLOT_LPOCKET
	pocket_side = "left"

/datum/strippable_item/mob_item_slot/pocket/right
	key = STRIPPABLE_ITEM_RPOCKET
	item_slot = ITEM_SLOT_RPOCKET
	pocket_side = "right"

/proc/get_strippable_alternate_action_internals(obj/item/item, atom/source)
	if (!iscarbon(source))
		return

	var/mob/living/carbon/carbon_source = source
	if (carbon_source.can_breathe_internals() && istype(item, /obj/item/tank))
		if(carbon_source.internal != item)
			return list("enable_internals")
		else
			return list("disable_internals")

/proc/strippable_alternate_action_internals(obj/item/item, atom/source, mob/user)
	var/obj/item/tank/tank = item
	if (!istype(tank))
		return

	var/mob/living/carbon/carbon_source = source
	if (!istype(carbon_source))
		return

	if (!carbon_source.can_breathe_internals())
		return

	carbon_source.visible_message(
		span_danger("[user] tries to [(carbon_source.internal != item) ? "open" : "close"] the valve on [source]'s [item.name]."),
		span_userdanger("[user] tries to [(carbon_source.internal != item) ? "open" : "close"] the valve on your [item.name]."),
		ignored_mobs = user,
	)

	to_chat(user, span_notice("You try to [(carbon_source.internal != item) ? "open" : "close"] the valve on [source]'s [item.name]..."))

	if(!do_after(user, INTERNALS_TOGGLE_DELAY, carbon_source))
		return

	if (carbon_source.internal == item)
		carbon_source.close_internals()
	// This isn't meant to be FALSE, it correlates to the item's name.
	else if (!QDELETED(item))
		if(!carbon_source.try_open_internals(item))
			return

	carbon_source.visible_message(
		span_danger("[user] [isnull(carbon_source.internal) ? "closes": "opens"] the valve on [source]'s [item.name]."),
		span_userdanger("[user] [isnull(carbon_source.internal) ? "closes": "opens"] the valve on your [item.name]."),
		ignored_mobs = user,
	)

	to_chat(user, span_notice("You [isnull(carbon_source.internal) ? "close" : "open"] the valve on [source]'s [item.name]."))

#undef INTERNALS_TOGGLE_DELAY
#undef POCKET_EQUIP_DELAY
