#define PEN_ROTATIONS 2

/**
 * Uplinks
 *
 * All /obj/item(s) have a hidden_uplink var. By default it's null. Give the item one with 'new(src') (it must be in it's contents). Then add 'uses.'
 * Use whatever conditionals you want to check that the user has an uplink, and then call interact() on their uplink.
 * You might also want the uplink menu to open if active. Check if the uplink is 'active' and then interact() with it.
**/
/datum/component/uplink
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/name = "syndicate uplink"
	var/active = FALSE
	var/lockable = TRUE
	var/locked = TRUE
	var/allow_restricted = TRUE
	///initial money to spend, non gimmicky and non murdery
	var/red_telecrystals
	///money earned via completing objectives, most things cost this
	var/black_telecrystals
	var/selected_cat
	var/owner = null
	var/uplink_flag
	var/datum/uplink_purchase_log/purchase_log
	var/list/uplink_items
	var/hidden_crystals = 0
	var/unlock_note
	var/unlock_code
	var/failsafe_code
	var/compact_mode = FALSE
	var/debug = FALSE

	var/list/previous_attempts

	///Instructions on how to access the uplink based on location
	var/unlock_text

/datum/component/uplink/Initialize(owner, lockable = TRUE, active = FALSE, uplink_flag = UPLINK_TRAITORS, red_telecrystals = RED_TELECRYSTALS_DEFAULT, black_telecrystals = BLACK_TELECRYSTALS_DEFAULT, name)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(name)
		src.name = name
	src.lockable = lockable
	src.active = active
	src.uplink_flag = uplink_flag
	src.red_telecrystals = red_telecrystals
	src.black_telecrystals = black_telecrystals

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/OnAttackBy)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/interact)
	if(istype(parent, /obj/item/implant))
		RegisterSignal(parent, COMSIG_IMPLANT_ACTIVATED, .proc/implant_activation)
		RegisterSignal(parent, COMSIG_IMPLANT_IMPLANTING, .proc/implanting)
		RegisterSignal(parent, COMSIG_IMPLANT_OTHER, .proc/old_implant)
		RegisterSignal(parent, COMSIG_IMPLANT_EXISTING_UPLINK, .proc/new_implant)
	else if(istype(parent, /obj/item/pda))
		RegisterSignal(parent, COMSIG_PDA_CHANGE_RINGTONE, .proc/new_ringtone)
		RegisterSignal(parent, COMSIG_PDA_CHECK_DETONATE, .proc/check_detonate)
	else if(istype(parent, /obj/item/radio))
		RegisterSignal(parent, COMSIG_RADIO_NEW_FREQUENCY, .proc/new_frequency)
	else if(istype(parent, /obj/item/pen))
		RegisterSignal(parent, COMSIG_PEN_ROTATED, .proc/pen_rotation)

	if(owner)
		src.owner = owner
		LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
		if(GLOB.uplink_purchase_logs_by_key[owner])
			purchase_log = GLOB.uplink_purchase_logs_by_key[owner]
		else
			purchase_log = new(owner, src)
	update_items()

	if(!lockable)
		active = TRUE
		locked = FALSE

	previous_attempts = list()

/datum/component/uplink/InheritComponent(datum/component/uplink/uplink_item)
	lockable |= uplink_item.lockable
	active |= uplink_item.active
	uplink_flag |= uplink_item.uplink_flag
	red_telecrystals += uplink_item.red_telecrystals
	black_telecrystals += uplink_item.black_telecrystals
	if(purchase_log && uplink_item.purchase_log)
		purchase_log.MergeWithAndDel(uplink_item.purchase_log)

/datum/component/uplink/Destroy()
	purchase_log = null
	return ..()

/datum/component/uplink/proc/update_items()
	var/updated_items
	updated_items = get_uplink_items(uplink_flag, TRUE, allow_restricted)
	update_sales(updated_items)
	uplink_items = updated_items

/datum/component/uplink/proc/update_sales(updated_items)
	var/discount_categories = list("Discounted Gear", "Discounted Team Gear", "Limited Stock Team Gear")
	if (uplink_items == null)
		return
	for (var/category in discount_categories) // Makes sure discounted items aren't renewed or replaced
		if (uplink_items[category] != null && updated_items[category] != null)
			updated_items[category] = uplink_items[category]

/datum/component/uplink/proc/LoadTC(mob/user, obj/item/stack/telecrystals, silent = FALSE)
	if(!silent)
		to_chat(user, span_notice("You slot [telecrystals] into [parent] and charge its internal uplink."))
	var/amt = telecrystals.amount
	if(istype(telecrystals, /obj/item/stack/red_telecrystal))
		red_telecrystals += amt
		log_uplink("[key_name(user)] loaded [amt] red telecrystals into [parent]'s uplink")
	else
		black_telecrystals += amt
		log_uplink("[key_name(user)] loaded [amt] black telecrystals into [parent]'s uplink")
	telecrystals.use(amt)


/datum/component/uplink/proc/OnAttackBy(datum/source, obj/item/attacked_with, mob/user)
	SIGNAL_HANDLER

	if(!active)
		return //no hitting everyone/everything just to try to slot tcs in!
	if(istype(attacked_with, /obj/item/stack/red_telecrystal) || istype(attacked_with, /obj/item/stack/black_telecrystal))
		LoadTC(user, attacked_with)
	for(var/category in uplink_items)
		for(var/item in uplink_items[category])
			var/datum/uplink_item/uplink_item = uplink_items[category][item]
			var/path = uplink_item.refund_path || uplink_item.item
			var/red_cost = uplink_item.refund_amount || uplink_item.red_cost
			var/black_cost = uplink_item.refund_amount || uplink_item.black_cost
			var/amt_refunded = 0
			if(attacked_with.type == path && uplink_item.refundable && attacked_with.check_uplink_validity())
				if(uplink_item.red_cost) //prevents payouts where refund_amount != 0 but red_cost does
					red_telecrystals += red_cost
					amt_refunded += red_cost
				if(uplink_item.black_cost) //see above but for the other one
					black_telecrystals += black_cost
					amt_refunded += black_cost
				log_uplink("[key_name(user)] refunded [uplink_item] for [amt_refunded] telecrystals using [parent]'s uplink")
				if(purchase_log)
					purchase_log.total_spent -= red_cost
				to_chat(user, span_notice("[attacked_with] refunded."))
				qdel(attacked_with)
				return

/datum/component/uplink/proc/interact(datum/source, mob/user)
	SIGNAL_HANDLER

	if(locked)
		return
	active = TRUE
	update_items()
	if(user)
		INVOKE_ASYNC(src, .proc/ui_interact, user)
	// an unlocked uplink blocks also opening the PDA or headset menu
	return COMPONENT_CANCEL_ATTACK_CHAIN


/datum/component/uplink/ui_state(mob/user)
	return GLOB.inventory_state

/datum/component/uplink/ui_interact(mob/user, datum/tgui/ui)
	active = TRUE
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SyndicateUplink", name)
		// This UI is only ever opened by one person,
		// and never is updated outside of user input.
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/component/uplink/ui_data(mob/user)
	if(!user.mind)
		return
	var/list/data = list()
	data["buy_with_black"] = !(uplink_flag & UPLINK_TRAITORS)
	data["black_telecrystals"] = black_telecrystals
	data["red_telecrystals"] = red_telecrystals
	data["lockable"] = lockable
	data["compactMode"] = compact_mode
	return data

/datum/component/uplink/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()
	for(var/category in uplink_items)
		var/list/cat = list(
			"name" = category,
			"items" = (category == selected_cat ? list() : null))
		for(var/item in uplink_items[category])
			var/datum/uplink_item/uplink_item = uplink_items[category][item]
			if(uplink_item.limited_stock == 0)
				continue
			if(uplink_item.restricted_roles.len)
				var/is_inaccessible = TRUE
				for(var/R in uplink_item.restricted_roles)
					if(R == user.mind.assigned_role || debug)
						is_inaccessible = FALSE
				if(is_inaccessible)
					continue
			if(uplink_item.restricted_species)
				if(ishuman(user))
					var/is_inaccessible = TRUE
					var/mob/living/carbon/human/H = user
					for(var/F in uplink_item.restricted_species)
						if(F == H.dna.species.id || debug)
							is_inaccessible = FALSE
							break
					if(is_inaccessible)
						continue
			cat["items"] += list(list(
				"name" = uplink_item.name,
				"red_cost" = uplink_item.red_cost,
				"black_cost" = uplink_item.black_cost,
				"desc" = uplink_item.desc,
			))
		data["categories"] += list(cat)
	return data

/datum/component/uplink/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!active)
		return
	switch(action)
		if("buy")
			var/item_name = params["name"]
			var/list/buyable_items = list()
			for(var/category in uplink_items)
				buyable_items += uplink_items[category]
			if(item_name in buyable_items)
				var/datum/uplink_item/uplink_item = buyable_items[item_name]
				MakePurchase(usr, uplink_item, params["tc"])
				return TRUE
		if("lock")
			active = FALSE
			locked = TRUE
			red_telecrystals += hidden_crystals
			hidden_crystals = 0
			SStgui.close_uis(src)
		if("select")
			selected_cat = params["category"]
			return TRUE
		if("compact_toggle")
			compact_mode = !compact_mode
			return TRUE

/datum/component/uplink/proc/MakePurchase(mob/user, datum/uplink_item/uplink_item, currency)
	if(!istype(uplink_item))
		return
	if(!user || user.incapacitated())
		return
	if(uplink_item.limited_stock == 0)
		return

	var/currency_spent = 0

	if(currency == RED_TELECRYSTALS)
		if(red_telecrystals < uplink_item.red_cost)
			return
		red_telecrystals -= uplink_item.red_cost
		currency_spent += uplink_item.red_cost
	else
		if(black_telecrystals < uplink_item.black_cost)
			return
		black_telecrystals -= uplink_item.black_cost
		currency_spent += uplink_item.black_cost

	uplink_item.purchase(user, src)

	if(uplink_item.limited_stock > 0)
		uplink_item.limited_stock -= 1

	SSblackbox.record_feedback("nested tally", "traitor_uplink_items_bought", 1, list("[initial(uplink_item.name)]", "[currency_spent]"))
	return TRUE

// Implant signal responses

/datum/component/uplink/proc/implant_activation()
	SIGNAL_HANDLER

	var/obj/item/implant/implant = parent
	locked = FALSE
	interact(null, implant.imp_in)

/datum/component/uplink/proc/implanting(datum/source, list/arguments)
	SIGNAL_HANDLER

	var/mob/user = arguments[2]
	owner = "[user.key]"

/datum/component/uplink/proc/old_implant(datum/source, list/arguments, obj/item/implant/new_implant)
	SIGNAL_HANDLER

	// It kinda has to be weird like this until implants are components
	return SEND_SIGNAL(new_implant, COMSIG_IMPLANT_EXISTING_UPLINK, src)

/datum/component/uplink/proc/new_implant(datum/source, datum/component/uplink/uplink)
	SIGNAL_HANDLER

	uplink.red_telecrystals += red_telecrystals
	return COMPONENT_DELETE_NEW_IMPLANT

// PDA signal responses

/datum/component/uplink/proc/new_ringtone(datum/source, mob/living/user, new_ring_text)
	SIGNAL_HANDLER

	var/obj/item/pda/master = parent
	if(trim(lowertext(new_ring_text)) != trim(lowertext(unlock_code)))
		if(trim(lowertext(new_ring_text)) == trim(lowertext(failsafe_code)))
			failsafe(user)
			return COMPONENT_STOP_RINGTONE_CHANGE
		return
	locked = FALSE
	interact(null, user)
	to_chat(user, span_hear("The PDA softly beeps."))
	user << browse(null, "window=pda")
	master.mode = 0
	return COMPONENT_STOP_RINGTONE_CHANGE

/datum/component/uplink/proc/check_detonate()
	SIGNAL_HANDLER

	return COMPONENT_PDA_NO_DETONATE

// Radio signal responses

/datum/component/uplink/proc/new_frequency(datum/source, list/arguments)
	SIGNAL_HANDLER

	var/obj/item/radio/master = parent
	var/frequency = arguments[1]
	if(frequency != unlock_code)
		if(frequency == failsafe_code)
			failsafe(master.loc)
		return
	locked = FALSE
	if(ismob(master.loc))
		interact(null, master.loc)

// Pen signal responses

/datum/component/uplink/proc/pen_rotation(datum/source, degrees, mob/living/carbon/user)
	SIGNAL_HANDLER

	var/obj/item/pen/master = parent
	previous_attempts += degrees
	if(length(previous_attempts) > PEN_ROTATIONS)
		popleft(previous_attempts)

	if(compare_list(previous_attempts, unlock_code))
		locked = FALSE
		previous_attempts.Cut()
		master.degrees = 0
		interact(null, user)
		to_chat(user, span_warning("Your pen makes a clicking noise, before quickly rotating back to 0 degrees!"))

	else if(compare_list(previous_attempts, failsafe_code))
		failsafe(user)

/datum/component/uplink/proc/setup_unlock_code()
	unlock_code = generate_code()
	var/obj/item/P = parent
	if(istype(parent,/obj/item/pda))
		unlock_note = "<B>Uplink Passcode:</B> [unlock_code] ([P.name])."
	else if(istype(parent,/obj/item/radio))
		unlock_note = "<B>Radio Frequency:</B> [format_frequency(unlock_code)] ([P.name])."
	else if(istype(parent,/obj/item/pen))
		unlock_note = "<B>Uplink Degrees:</B> [english_list(unlock_code)] ([P.name])."

/datum/component/uplink/proc/generate_code()
	if(istype(parent,/obj/item/pda))
		return "[rand(100,999)] [pick(GLOB.phonetic_alphabet)]"
	else if(istype(parent,/obj/item/radio))
		return return_unused_frequency()
	else if(istype(parent,/obj/item/pen))
		var/list/L = list()
		for(var/i in 1 to PEN_ROTATIONS)
			L += rand(1, 360)
		return L

/datum/component/uplink/proc/failsafe(mob/living/carbon/user)
	if(!parent)
		return
	var/turf/T = get_turf(parent)
	if(!T)
		return
	message_admins("[ADMIN_LOOKUPFLW(user)] has triggered an uplink failsafe explosion at [AREACOORD(T)] The owner of the uplink was [ADMIN_LOOKUPFLW(owner)].")
	log_game("[key_name(user)] triggered an uplink failsafe explosion. The owner of the uplink was [key_name(owner)].")
	explosion(parent, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3)
	qdel(parent) //Alternatively could brick the uplink.
