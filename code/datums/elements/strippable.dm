/// An element for atoms that, when dragged and dropped onto a mob, opens a strip panel.
/datum/element/strippable
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2

	/// An assoc list of keys to /datum/strippable_item
	var/list/items

	/// A proc path that returns TRUE/FALSE if we should show the strip panel for this entity.
	/// If it does not exist, the strip menu will always show.
	/// Will be called with (mob/user).
	var/should_strip_proc_path

	/// An existing strip menus
	var/list/strip_menus

/datum/element/strippable/Attach(datum/target, list/items = list(), should_strip_proc_path)
	. = ..()
	if (!isatom(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOUSEDROP_ONTO, PROC_REF(mouse_drop_onto))

	src.items = items
	src.should_strip_proc_path = should_strip_proc_path

/datum/element/strippable/Detach(datum/source)
	. = ..()

	UnregisterSignal(source, COMSIG_MOUSEDROP_ONTO)

	if (!isnull(strip_menus))
		qdel(strip_menus[source])
		strip_menus -= source

/datum/element/strippable/proc/mouse_drop_onto(datum/source, atom/over, mob/user)
	SIGNAL_HANDLER

	if (user == source)
		return
	if (over != user)
		return
	if(!user.can_perform_action(source, FORBID_TELEKINESIS_REACH | ALLOW_RESTING))
		return

	// Snowflake for cyborgs and bots buckling people by dragging them onto them, unless in combat mode.
	if(iscyborg(user) || isbot(user))
		var/mob/living/bot_user = user
		if (!bot_user.combat_mode)
			return
	// Snowflake for xeno consumption code
	if (isalienadult(user))
		var/mob/living/carbon/alien/adult/alien = user
		if (alien.grab_state == GRAB_AGGRESSIVE && alien.pulling == source)
			return

	if (!isnull(should_strip_proc_path) && !call(source, should_strip_proc_path)(user))
		return

	// Snowflake for mob scooping
	if (isliving(source))
		var/mob/living/mob = source
		if (mob.can_be_held && (user.grab_state == GRAB_AGGRESSIVE) && (user.pulling == source))
			return

	var/datum/strip_menu/strip_menu = LAZYACCESS(strip_menus, source)

	if (isnull(strip_menu))
		strip_menu = new(source, src)
		LAZYSET(strip_menus, source, strip_menu)

	INVOKE_ASYNC(strip_menu, TYPE_PROC_REF(/datum/, ui_interact), user)
	return COMPONENT_CANCEL_MOUSEDROP_ONTO

/// A representation of an item that can be stripped down
/datum/strippable_item
	/// The STRIPPABLE_ITEM_* key
	var/key

	/// Should we give feedback messages?
	var/show_visible_message = TRUE

/// Gets the item from the given source.
/datum/strippable_item/proc/get_item(atom/source)

/// Tries to equip the item onto the given source.
/// Returns TRUE/FALSE depending on if it is allowed.
/// This should be used for checking if an item CAN be equipped.
/// It should not perform the equipping itself.
/datum/strippable_item/proc/try_equip(atom/source, obj/item/equipping, mob/user)
	if(SEND_SIGNAL(user, COMSIG_TRY_STRIP, source, equipping) & COMPONENT_CANT_STRIP)
		return FALSE
	if(SEND_SIGNAL(source, COMSIG_BEING_STRIPPED, user, equipping) & COMPONENT_CANT_STRIP)
		return FALSE

	if (HAS_TRAIT(equipping, TRAIT_NODROP))
		to_chat(user, span_warning("You can't put [equipping] on [source], it's stuck to your hand!"))
		return FALSE

	if (equipping.item_flags & ABSTRACT)
		return FALSE //I don't know a sane-sounding feedback message for trying to put a slap into someone's hand

	return TRUE

/// Start the equipping process. This is the proc you should yield in.
/// Returns TRUE/FALSE depending on if it is allowed.
/datum/strippable_item/proc/start_equip(atom/source, obj/item/equipping, mob/user)

	equipping.item_start_equip(source, equipping, user, show_visible_message)
	return TRUE

/// The proc that places the item on the source. This should not yield.
/datum/strippable_item/proc/finish_equip(atom/source, obj/item/equipping, mob/user)
	SHOULD_NOT_SLEEP(TRUE)

/// Tries to unequip the item from the given source.
/// Returns TRUE/FALSE depending on if it is allowed.
/// This should be used for checking if it CAN be unequipped.
/// It should not perform the unequipping itself.
/datum/strippable_item/proc/try_unequip(atom/source, mob/user)
	SHOULD_NOT_SLEEP(TRUE)

	var/obj/item/item = get_item(source)
	if (isnull(item))
		return FALSE

	if (ismob(source))
		if(SEND_SIGNAL(user, COMSIG_TRY_STRIP, source, item) & COMPONENT_CANT_STRIP)
			return FALSE
		if(SEND_SIGNAL(source, COMSIG_BEING_STRIPPED, user, item) & COMPONENT_CANT_STRIP)
			return FALSE
		var/mob/mob_source = source
		if (!item.canStrip(user, mob_source))
			return FALSE

	return TRUE

/// Start the unequipping process. This is the proc you should yield in.
/// Returns TRUE/FALSE depending on if it is allowed.
/datum/strippable_item/proc/start_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if (isnull(item))
		return FALSE

	if (HAS_TRAIT(item, TRAIT_NO_STRIP))
		return FALSE

	source.visible_message(
		span_warning("[user] tries to remove [source]'s [item.name]."),
		span_userdanger("[user] tries to remove your [item.name]."),
		blind_message = span_hear("You hear rustling."),
		ignored_mobs = user,
	)

	to_chat(user, span_danger("You try to remove [source]'s [item.name]..."))
	user.log_message("is stripping [key_name(source)] of [item].", LOG_ATTACK, color="red")
	source.log_message("is being stripped of [item] by [key_name(user)].", LOG_VICTIM, color="orange", log_globally=FALSE)
	item.add_fingerprint(src)

	if(ishuman(source))
		var/mob/living/carbon/human/victim_human = source
		if(victim_human.key && !victim_human.client) // AKA braindead
			if(victim_human.stat <= SOFT_CRIT && LAZYLEN(victim_human.afk_thefts) <= AFK_THEFT_MAX_MESSAGES)
				var/list/new_entry = list(list(user.name, "tried unequipping your [item.name]", world.time))
				LAZYADD(victim_human.afk_thefts, new_entry)

		else if(victim_human.is_blind())
			to_chat(source, span_userdanger("You feel someone fumble with your belongings."))

	return TRUE

/// The proc that unequips the item from the source. This should not yield.
/datum/strippable_item/proc/finish_unequip(atom/source, mob/user)

/// Returns a STRIPPABLE_OBSCURING_* define to report on whether or not this is obscured.
/datum/strippable_item/proc/get_obscuring(atom/source)
	SHOULD_NOT_SLEEP(TRUE)
	return STRIPPABLE_OBSCURING_NONE

/**
 * Returns a list of alternate actions that can be performed on this strippable_item.
 * All string keys in the list must be inside tgui\packages\tgui\interfaces\StripMenu.tsx
 * You can also return null if there are no alternate actions.
 */
/datum/strippable_item/proc/get_alternate_actions(atom/source, mob/user)
	RETURN_TYPE(/list)
	return null

/**
 * Performs an alternate action on this strippable_item.
 * - source: The source of the action.
 * - user: The user performing the action.
 * - action_key: The key of the alternate action to perform.
 * Returns FALSE if unable to perform the action; whether it be due to the signal or some other factor.
 */
/datum/strippable_item/proc/perform_alternate_action(atom/source, mob/user, action_key)
	SHOULD_CALL_PARENT(TRUE)
	if(SEND_SIGNAL(user, COMSIG_TRY_ALT_ACTION, source, action_key) & COMPONENT_CANT_ALT_ACTION)
		return FALSE
	return TRUE

/// Returns whether or not this item should show.
/datum/strippable_item/proc/should_show(atom/source, mob/user)
	return TRUE

/// A preset for equipping items onto mob slots
/datum/strippable_item/mob_item_slot
	/// The ITEM_SLOT_* to equip to.
	var/item_slot

/datum/strippable_item/mob_item_slot/get_item(atom/source)
	if (!ismob(source))
		return null

	var/mob/mob_source = source
	return mob_source.get_item_by_slot(item_slot)

/datum/strippable_item/mob_item_slot/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if (!.)
		return

	if (!ismob(source))
		return FALSE

	if (!equipping.mob_can_equip(source, item_slot, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
		to_chat(user, span_warning("\The [equipping] doesn't fit in that place!"))
		return FALSE

	return TRUE

/datum/strippable_item/mob_item_slot/start_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if (!.)
		return

	if (!ismob(source))
		return FALSE

	if (!do_after(user, get_equip_delay(equipping), source))
		return FALSE

	if (!equipping.mob_can_equip(source, item_slot, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
		return FALSE

	if (!user.temporarilyRemoveItemFromInventory(equipping))
		return FALSE

	return TRUE

/datum/strippable_item/mob_item_slot/finish_equip(atom/source, obj/item/equipping, mob/user)
	if (!ismob(source))
		return FALSE

	var/mob/mob_source = source
	mob_source.equip_to_slot(equipping, item_slot)

	return finish_equip_mob(equipping, source, user)

/datum/strippable_item/mob_item_slot/get_obscuring(atom/source)
	if (!iscarbon(source))
		return STRIPPABLE_OBSCURING_NONE

	var/mob/living/carbon/carbon_source = source
	if (hidden_slots_to_inventory_slots(carbon_source.obscured_slots) & item_slot)
		return STRIPPABLE_OBSCURING_COMPLETELY

	if (hidden_slots_to_inventory_slots(carbon_source.covered_slots) & item_slot)
		return STRIPPABLE_OBSCURING_INACCESSIBLE

	return STRIPPABLE_OBSCURING_NONE

/datum/strippable_item/mob_item_slot/start_unequip(atom/source, mob/user)
	. = ..()
	if (!.)
		return

	return start_unequip_mob(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/finish_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if (isnull(item))
		return FALSE

	if (!ismob(source))
		return FALSE

	return finish_unequip_mob(item, source, user)

/// Returns the delay of equipping this item to a mob
/datum/strippable_item/mob_item_slot/proc/get_equip_delay(obj/item/equipping)
	return equipping.equip_delay_other

/// A utility function for `/datum/strippable_item`s to finish equipping an item to a mob.
/proc/finish_equip_mob(obj/item/item, mob/source, mob/user)
	user.log_message("has put [item] on [key_name(source)].", LOG_ATTACK, color="red")
	source.log_message("had [item] put on them by [key_name(user)].", LOG_VICTIM, color="orange", log_globally=FALSE)

/// A utility function for `/datum/strippable_item`s to start unequipping an item from a mob.
/proc/start_unequip_mob(obj/item/item, mob/source, mob/user, strip_delay, hidden = FALSE)
	if (!do_after(user, strip_delay || item.strip_delay, source, interaction_key = REF(item), hidden = hidden))
		return FALSE

	return TRUE

/// A utility function for `/datum/strippable_item`s to finish unequipping an item from a mob.
/proc/finish_unequip_mob(obj/item/item, mob/source, mob/user)
	if (!item.doStrip(user, source))
		return FALSE

	user.log_message("has stripped [key_name(source)] of [item].", LOG_ATTACK, color="red")
	source.log_message("has been stripped of [item] by [key_name(user)].", LOG_VICTIM, color="orange", log_globally=FALSE)

/// A representation of the stripping UI
/datum/strip_menu
	/// The owner who has the element /datum/element/strippable
	var/atom/movable/owner

	/// The strippable element itself
	var/datum/element/strippable/strippable

	/// A lazy list of user mobs to a list of strip menu keys that they're interacting with
	var/list/interactions

/datum/strip_menu/New(atom/movable/owner, datum/element/strippable/strippable)
	. = ..()
	src.owner = owner
	src.strippable = strippable

/datum/strip_menu/Destroy()
	owner = null
	strippable = null

	return ..()

/datum/strip_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "StripMenu")
		ui.open()

/datum/strip_menu/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/inventory),
	)

/datum/strip_menu/ui_data(mob/user)
	var/list/data = list()

	var/list/items = list()

	for (var/strippable_key in strippable.items)
		var/datum/strippable_item/item_data = strippable.items[strippable_key]

		if (!item_data.should_show(owner, user))
			continue

		var/list/result

		if(strippable_key in LAZYACCESS(interactions, user))
			LAZYSET(result, "interacting", TRUE)

		var/obscuring = item_data.get_obscuring(owner)
		LAZYSET(result, "obscured", obscuring)
		if (obscuring != STRIPPABLE_OBSCURING_NONE && obscuring != STRIPPABLE_OBSCURING_INACCESSIBLE)
			items[strippable_key] = result
			continue

		var/obj/item/item = item_data.get_item(owner)
		if (isnull(item) || (HAS_TRAIT(item, TRAIT_NO_STRIP) || HAS_TRAIT(item, TRAIT_EXAMINE_SKIP)))
			items[strippable_key] = result
			continue

		LAZYINITLIST(result)

		result["icon"] = icon2base64(icon(item.icon, item.icon_state))
		result["name"] = item.name
		result["alternate"] = item_data.get_alternate_actions(owner, user)
		var/static/list/already_cried = list()
		if(length(result["alternate"]) > 2 && !(type in already_cried))
			stack_trace("Too many alternate actions for [type]! Only two are supported at the moment! This will look bad!")
			already_cried += type

		items[strippable_key] = result

	data["items"] = items

	// While most `\the`s are implicit, this one is not.
	// In this case, `\The` would otherwise be used.
	// This doesn't match with what it's used for, which is to say "Stripping the alien drone",
	// as opposed to "Stripping The alien drone".
	// Human names will still show without "the", as they are proper nouns.
	data["name"] = "\the [owner]"

	return data

/datum/strip_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	. = TRUE

	var/mob/user = usr

	switch (action)
		if ("use")
			var/key = params["key"]
			var/datum/strippable_item/strippable_item = strippable.items[key]

			if (isnull(strippable_item))
				return

			if (!strippable_item.should_show(owner, user))
				return

			var/obscured = strippable_item.get_obscuring(owner)
			if (obscured == STRIPPABLE_OBSCURING_COMPLETELY || obscured == STRIPPABLE_OBSCURING_INACCESSIBLE)
				return

			var/item = strippable_item.get_item(owner)
			if (isnull(item))
				var/obj/item/held_item = user.get_active_held_item()
				if (isnull(held_item))
					return

				if (strippable_item.try_equip(owner, held_item, user))
					LAZYORASSOCLIST(interactions, user, key)

					// Yielding call
					var/should_finish = strippable_item.start_equip(owner, held_item, user)

					LAZYREMOVEASSOC(interactions, user, key)

					if (!should_finish)
						return

					if (QDELETED(src) || QDELETED(owner))
						return

					// They equipped an item in the meantime
					if (!isnull(strippable_item.get_item(owner)))
						user.put_in_hands(held_item)
						return

					if (!user.Adjacent(owner))
						user.put_in_hands(held_item)
						return

					strippable_item.finish_equip(owner, held_item, user)
			else if (strippable_item.try_unequip(owner, user))
				LAZYORASSOCLIST(interactions, user, key)

				var/should_unequip = strippable_item.start_unequip(owner, user)

				LAZYREMOVEASSOC(interactions, user, key)

				// Yielding call
				if (!should_unequip)
					return

				if (QDELETED(src) || QDELETED(owner))
					return

				// They changed the item in the meantime
				if (strippable_item.get_item(owner) != item)
					return

				if (!user.Adjacent(owner))
					return

				strippable_item.finish_unequip(owner, user)
		if ("alt")
			var/key = params["key"]
			var/alt_action = params["alternate_action"]
			var/datum/strippable_item/strippable_item = strippable.items[key]

			if (isnull(strippable_item))
				return

			if (!strippable_item.should_show(owner, user))
				return

			var/obscured = strippable_item.get_obscuring(owner)
			if (obscured == STRIPPABLE_OBSCURING_COMPLETELY || obscured == STRIPPABLE_OBSCURING_INACCESSIBLE)
				return

			var/item = strippable_item.get_item(owner)
			if (isnull(item))
				return

			if (!(alt_action in strippable_item.get_alternate_actions(owner, user)))
				return

			LAZYORASSOCLIST(interactions, user, key)

			// Potentially yielding
			strippable_item.perform_alternate_action(owner, user, alt_action)

			LAZYREMOVEASSOC(interactions, user, key)

/datum/strip_menu/ui_host(mob/user)
	return owner

/datum/strip_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/strip_menu/ui_status(mob/user, datum/ui_state/state)
	return min(
		ui_status_only_living(user, owner),
		ui_status_user_has_free_hands(user, owner),
		ui_status_user_is_adjacent(user, owner, allow_tk = FALSE),
		HAS_TRAIT(user, TRAIT_CAN_STRIP) ? UI_INTERACTIVE : UI_UPDATE,
		max(
			ui_status_user_is_conscious_and_lying_down(user),
			ui_status_user_is_abled(user, owner),
		),
	)

/// Creates an assoc list of keys to /datum/strippable_item
/proc/create_strippable_list(types)
	var/list/strippable_items = list()

	for (var/strippable_type in types)
		var/datum/strippable_item/strippable_item = new strippable_type
		strippable_items[strippable_item.key] = strippable_item

	return strippable_items
