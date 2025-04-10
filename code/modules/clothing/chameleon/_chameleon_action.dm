/// Default duration of an EMP randomisation on a chameleon item
#define EMP_RANDOMISE_TIME 30 SECONDS

/datum/action/item_action/chameleon

/datum/action/item_action/chameleon/change
	name = "Chameleon Change"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED
	/// Typecache of all item types we explicitly cannot pick
	/// Note that abstract items are already excluded
	VAR_FINAL/list/chameleon_blacklist = list()
	/// Typecache of typepaths we can turn into
	VAR_FINAL/list/chameleon_typecache
	/// Assoc list of item name + icon state to item typepath
	/// This is passed to the list input
	VAR_FINAL/list/chameleon_list
	/// The prime typepath of what class of item we're allowed to pick from
	var/chameleon_type
	/// Used in the action button to describe what we're changing into
	var/chameleon_name = "Item"
	/// What chameleon is active right now?
	/// Can be set in the declaration to update in init
	var/active_type
	/// Cooldown from when we started being EMP'd
	COOLDOWN_DECLARE(emp_timer)

/datum/action/item_action/chameleon/change/New(Target)
	. = ..()
	if(!isitem(target))
		stack_trace("Adding chameleon action to non-item ([target])")
		qdel(src)
		return

	initialize_blacklist()
	initialize_disguises()
	if(active_type)
		if(chameleon_blacklist[active_type])
			stack_trace("[type] has an active type defined in init which is blacklisted ([active_type])")
			active_type = null
		else
			update_look(active_type)

	RegisterSignal(target, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))

/datum/action/item_action/chameleon/change/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/action/item_action/chameleon/change/proc/on_emp(datum/source, severity, protection)
	SIGNAL_HANDLER
	if(protection & EMP_PROTECT_SELF)
		return
	emp_randomise()

/datum/action/item_action/chameleon/change/Grant(mob/grant_to)
	. = ..()
	if(isnull(owner))
		return

	// Whenever a mob gains their first cham change action, they need to also gain the outfit action
	if(locate(/datum/action/chameleon_outfit) in grant_to.actions)
		return

	var/datum/action/chameleon_outfit/outfit_action = new(owner)
	outfit_action.Grant(owner)

/datum/action/item_action/chameleon/change/Remove(mob/remove_from)
	. = ..()
	// Likewise when the mob loses the cham change action, if they have no others, they need to lose the outfit action
	if(locate(/datum/action/item_action/chameleon/change) in remove_from.actions)
		return

	var/datum/action/chameleon_outfit/outfit_action = locate() in remove_from.actions
	QDEL_NULL(outfit_action)

/datum/action/item_action/chameleon/change/proc/initialize_blacklist()
	chameleon_blacklist |= typecacheof(target.type)

/datum/action/item_action/chameleon/change/proc/initialize_disguises()
	name = "Change [chameleon_name] Appearance"
	build_all_button_icons()

	LAZYINITLIST(chameleon_typecache)
	LAZYINITLIST(chameleon_list)

	if(!ispath(chameleon_type, /obj/item))
		stack_trace("Non-item chameleon type defined on [type] ([chameleon_type])")
		return

	add_chameleon_items(chameleon_type)

/datum/action/item_action/chameleon/change/proc/add_chameleon_items(type_to_add)

	chameleon_typecache |= typecacheof(type_to_add)
	for(var/obj/item/item_type as anything in chameleon_typecache)
		if(chameleon_blacklist[item_type] || (initial(item_type.item_flags) & ABSTRACT) || !initial(item_type.icon_state))
			continue
		var/chameleon_item_name = "[initial(item_type.name)] ([initial(item_type.icon_state)])"
		chameleon_list[chameleon_item_name] = item_type


/datum/action/item_action/chameleon/change/proc/select_look(mob/user)
	var/picked_name = tgui_input_list(user, "Select [chameleon_name] to change into", "Chameleon Settings", sort_list(chameleon_list, GLOBAL_PROC_REF(cmp_typepaths_asc)))
	if(isnull(picked_name) || isnull(chameleon_list[picked_name]) || QDELETED(src) || QDELETED(user) || QDELETED(owner) || !IsAvailable(feedback = TRUE))
		return
	var/obj/item/picked_item = chameleon_list[picked_name]
	update_look(picked_item)

/datum/action/item_action/chameleon/change/proc/random_look()
	var/picked_name = pick(chameleon_list)
	update_look(chameleon_list[picked_name])

/datum/action/item_action/chameleon/change/proc/update_look(obj/item/picked_item)
	var/obj/item/chameleon_item = target

	update_item(picked_item)
	build_all_button_icons()
	active_type = picked_item

	if(ismob(chameleon_item.loc))
		var/mob/wearer = chameleon_item.loc
		wearer.update_clothing(chameleon_item.slot_flags | ITEM_SLOT_HANDS)

/datum/action/item_action/chameleon/change/proc/update_item(obj/item/picked_item)
	PROTECTED_PROC(TRUE) // Call update_look, not this!

	var/atom/atom_target = target
	atom_target.name = initial(picked_item.name)
	atom_target.desc = initial(picked_item.desc)
	atom_target.icon_state = initial(picked_item.icon_state)

	if(isitem(atom_target))
		var/obj/item/item_target = target
		item_target.worn_icon = initial(picked_item.worn_icon)
		item_target.lefthand_file = initial(picked_item.lefthand_file)
		item_target.righthand_file = initial(picked_item.righthand_file)

		item_target.worn_icon_state = initial(picked_item.worn_icon_state)
		item_target.inhand_icon_state = initial(picked_item.inhand_icon_state)

		if(initial(picked_item.greyscale_colors))
			if(initial(picked_item.greyscale_config_worn))
				item_target.worn_icon = SSgreyscale.GetColoredIconByType(
					initial(picked_item.greyscale_config_worn),
					initial(picked_item.greyscale_colors),
				)
			if(initial(picked_item.greyscale_config_inhand_left))
				item_target.lefthand_file = SSgreyscale.GetColoredIconByType(
					initial(picked_item.greyscale_config_inhand_left),
					initial(picked_item.greyscale_colors),
				)
			if(initial(picked_item.greyscale_config_inhand_right))
				item_target.righthand_file = SSgreyscale.GetColoredIconByType(
					initial(picked_item.greyscale_config_inhand_right),
					initial(picked_item.greyscale_colors),
				)

		item_target.flags_inv = initial(picked_item.flags_inv)
		item_target.hair_mask = initial(picked_item.hair_mask)
		item_target.transparent_protection = initial(picked_item.transparent_protection)
		if(isclothing(item_target) && ispath(picked_item, /obj/item/clothing))
			var/obj/item/clothing/clothing_target = item_target
			var/obj/item/clothing/picked_clothing = picked_item
			clothing_target.flags_cover = initial(picked_clothing.flags_cover)


	if(initial(picked_item.greyscale_config) && initial(picked_item.greyscale_colors))
		atom_target.icon = SSgreyscale.GetColoredIconByType(
			initial(picked_item.greyscale_config),
			initial(picked_item.greyscale_colors),
		)

	else
		atom_target.icon = initial(picked_item.icon)

/datum/action/item_action/chameleon/change/do_effect(trigger_flags)
	select_look(owner)
	return TRUE

/datum/action/item_action/chameleon/change/proc/emp_randomise(amount = EMP_RANDOMISE_TIME)
	START_PROCESSING(SSprocessing, src)
	random_look()

	COOLDOWN_START(src, emp_timer, amount)

/datum/action/item_action/chameleon/change/process()
	if(COOLDOWN_FINISHED(src, emp_timer))
		STOP_PROCESSING(SSprocessing, src)
		return
	random_look()

/datum/action/item_action/chameleon/change/proc/apply_outfit(datum/outfit/applying_from, list/all_items_to_apply)
	SHOULD_CALL_PARENT(TRUE)

	var/using_item_type
	for(var/item_type in all_items_to_apply)
		if(!ispath(item_type, /obj/item))
			stack_trace("Invalid item type passed to apply_outfit ([item_type])")
			continue
		if(chameleon_typecache[item_type])
			using_item_type = item_type
			break

	if(isnull(using_item_type))
		return FALSE

	if(istype(applying_from, /datum/outfit/job))
		var/datum/outfit/job/job_outfit = applying_from
		var/datum/job/job_datum = SSjob.get_job_type(job_outfit.jobtype)
		apply_job_data(job_datum)

	update_look(using_item_type)
	all_items_to_apply -= using_item_type
	return TRUE

/// Used when applying this cham item via a job datum (from an outfit selection)
/datum/action/item_action/chameleon/change/proc/apply_job_data(datum/job/job_datum)
	return

#undef EMP_RANDOMISE_TIME
