/**
 * Accepts a [voucher_type] and a [set_type] and allows the user to redeem the voucher for items from a set.
 */
/datum/element/voucher_redeemer
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Typepath to what voucher sets are available to us
	var/set_type
	/// Typepath to what item must be redeemed
	var/voucher_type
	/// Cached set of radial options for redeeming a voucher
	var/list/cached_options
	/// Cached set of voucher sets
	var/list/set_instances

/datum/element/voucher_redeemer/Attach(datum/target, voucher_type = /obj/item/coin, set_type = /datum/voucher_set)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	if(!ispath(voucher_type, /obj/item))
		stack_trace("Invalid voucher type for voucher_redeemer [voucher_type || "null"]")
		return ELEMENT_INCOMPATIBLE
	if(!ispath(set_type, /datum/voucher_set))
		stack_trace("Invalid set type for voucher_redeemer [set_type || "null"]")
		return ELEMENT_INCOMPATIBLE

	src.voucher_type = voucher_type
	src.set_type = set_type
	RegisterSignal(target, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(redeem_voucher))

/datum/element/voucher_redeemer/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_ITEM_INTERACTION)

/datum/element/voucher_redeemer/proc/redeem_voucher(atom/source, mob/living/redeemer, obj/item/voucher, list/modifiers)
	SIGNAL_HANDLER

	if(!istype(voucher, voucher_type))
		return NONE
	INVOKE_ASYNC(src, PROC_REF(redeem_voucher_async), source, redeemer, voucher)
	return ITEM_INTERACT_SUCCESS

/datum/element/voucher_redeemer/proc/generate_sets()
	set_instances = list()
	for(var/datum/voucher_set/static_set as anything in subtypesof(set_type))
		set_instances[static_set::name] = new static_set

/datum/element/voucher_redeemer/proc/generate_options()
	cached_options = list()
	for(var/set_name in set_instances)
		var/datum/voucher_set/current_set = set_instances[set_name]
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = current_set.icon, icon_state = current_set.icon_state)
		if(current_set.description)
			option.info = span_boldnotice(current_set.description)
		cached_options[set_name] = option

/datum/element/voucher_redeemer/proc/redeem_voucher_async(atom/source, mob/living/redeemer, obj/item/voucher)
	if(!set_instances)
		generate_sets()
		generate_options()

	var/selection = show_radial_menu(redeemer, source, cached_options, custom_check = CALLBACK(src, PROC_REF(check_menu), voucher, redeemer), radius = 38, require_near = TRUE, tooltips = TRUE)
	if(!selection)
		return

	var/datum/voucher_set/chosen_set = set_instances[selection]
	chosen_set.spawn_set(source.drop_location())
	if(chosen_set.blackbox_key)
		SSblackbox.record_feedback("tally", chosen_set.blackbox_key, 1, selection)
	source.balloon_alert(redeemer, "redeemed [LOWER_TEXT(selection)]")
	qdel(voucher)

/datum/element/voucher_redeemer/proc/check_menu(obj/item/voucher, mob/living/redeemer)
	if(!istype(redeemer))
		return FALSE
	if(redeemer.incapacitated)
		return FALSE
	if(QDELETED(voucher))
		return FALSE
	if(!redeemer.is_holding(voucher))
		return FALSE
	return TRUE
