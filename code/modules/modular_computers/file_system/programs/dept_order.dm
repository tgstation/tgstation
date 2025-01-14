/datum/computer_file/program/department_order
	filename = "dept_order"
	filedesc = "Departmental Orders"
	can_run_on_flags = PROGRAM_CONSOLE
	downloader_category = PROGRAM_CATEGORY_SUPPLY
	program_open_overlay = "request"
	extended_desc = "Allows for departments to order supplied from Cargo for free, with a cooldown between orders."
	size = 10
	tgui_id = "NtosDeptOrder"
	program_icon = FA_ICON_CART_FLATBED
	alert_able = TRUE

	// Filled via set_linked_department. Also serves as "who can cancel the order".
	download_access = list(ACCESS_COMMAND)
	// Anyone can open, not everyone can use.
	run_access = list()
	/// Filled via set_linked_department. Serves as "who can place orders".
	VAR_PRIVATE/list/use_access = list()

	/// The department we are linked to, typepath.
	VAR_PRIVATE/datum/job_department/linked_department
	/// Stores the time when we can next place an order for each department.
	VAR_PRIVATE/static/list/department_cooldowns = list(
		/datum/job_department/engineering = 0,
		/datum/job_department/medical = 0,
		/datum/job_department/science = 0,
		/datum/job_department/security = 0,
		/datum/job_department/service = 0,
	)
	/// Reference to the order we've made UNTIL it gets sent on the supply shuttle. this is so heads can cancel it
	VAR_PRIVATE/datum/supply_order/department_order
	/// Our radio object we use to talk to our department.
	VAR_PRIVATE/obj/item/radio/radio
	/// The radio channel we will speak into by default.
	VAR_PRIVATE/radio_channel
	/// Maps what department gets what encryption key
	/// I could've put this on the job department datum but it felt unnecessary
	VAR_PRIVATE/static/list/dept_to_radio = list(
		/datum/job_department/engineering = /obj/item/encryptionkey/headset_eng,
		/datum/job_department/medical = /obj/item/encryptionkey/headset_med,
		/datum/job_department/science = /obj/item/encryptionkey/headset_sci,
		/datum/job_department/security = /obj/item/encryptionkey/headset_sec,
		/datum/job_department/service = /obj/item/encryptionkey/headset_service,
	)

/// Sets the passed department type as the active department for this computer file.
/datum/computer_file/program/department_order/proc/set_linked_department(datum/job_department/department)
	linked_department = department
	var/datum/job_department/linked_department_real = SSjob.get_department_type(linked_department)
	// Heads of staff can download
	download_access |= linked_department_real.head_of_staff_access
	// Heads of staff + anyone in the dept can run it
	use_access |= linked_department_real.head_of_staff_access
	use_access |= linked_department_real.department_access
	// Also set up the radio
	if(dept_to_radio[linked_department])
		if(!isnull(radio))
			QDEL_NULL(radio)
		var/picked_key = dept_to_radio[linked_department] || /obj/item/encryptionkey/headset_cargo
		radio = new(computer)
		radio.keyslot = new picked_key()
		radio.subspace_transmission = TRUE
		radio.canhear_range = 0
		radio.recalculateChannels()
		radio_channel = radio.keyslot.channels[1]
	computer.update_static_data_for_all_viewers()

/datum/computer_file/program/department_order/Destroy()
	QDEL_NULL(radio)
	return ..()

/datum/computer_file/program/department_order/ui_interact(mob/user, datum/tgui/ui)
	check_cooldown()

/datum/computer_file/program/department_order/ui_data(mob/user)
	var/list/data = list()
	data["no_link"] = !linked_department
	data["id_inside"] = !!computer.computer_id_slot
	data["time_left"] = department_cooldowns[linked_department] ? DisplayTimeText(max(department_cooldowns[linked_department] - world.time, 0), 1) : null
	data["can_override"] = !!department_order
	return data

/datum/computer_file/program/department_order/ui_static_data(mob/user)
	var/datum/job_department/linked_department_real = SSjob.get_department_type(linked_department)
	if(isnull(linked_department_real))
		return list("supplies" = list())

	var/list/data = list()

	var/list/supply_data = list()
	for(var/group in linked_department_real.associated_cargo_groups)
		supply_data[group] = list()

	for(var/pack_key in SSshuttle.supply_packs)
		var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_key]
		if(!islist(supply_data[pack.group]) || !can_see_pack(pack))
			continue

		UNTYPED_LIST_ADD(supply_data[pack.group], list(
			"name" = pack.name,
			"cost" = pack.get_cost(),
			"id" = pack.id,
			"desc" = pack.desc || pack.name, // If there is a description, use it. Otherwise use the pack's name.
		))

	var/list/supply_data_flattened = list()
	for(var/group in supply_data)
		UNTYPED_LIST_ADD(supply_data_flattened, list(
			"name" = group,
			"packs" = supply_data[group],
		))

	data["supplies"] = supply_data_flattened
	return data

/// Checks if we can "see" the passed supply pack
/datum/computer_file/program/department_order/proc/can_see_pack(datum/supply_pack/to_check)
	PROTECTED_PROC(TRUE)
	if(to_check.hidden && !(computer.obj_flags & EMAGGED))
		return FALSE
	if(to_check.special && !to_check.special_enabled)
		return FALSE
	if(to_check.drop_pod_only)
		return FALSE
	if(to_check.goody)
		return FALSE
	return TRUE

/// Looks through all possible departments and finds one this ID card "corresponds" to.
/datum/computer_file/program/department_order/proc/find_department_to_link(obj/item/card/id/id_card)
	PROTECTED_PROC(TRUE)
	if(id_card.type != /obj/item/card/id/advanced/silver)
		// I don't want to introduce weird "access order" behavior with Captain's ID / Chameleon ids / etc, so only silver IDs work
		return null
	var/list/access_to_depts = list()
	for(var/datum/job_department/department as anything in department_cooldowns)
		access_to_depts[initial(department.head_of_staff_access)] = department
	for(var/access_key in id_card.GetAccess())
		if(access_to_depts[access_key])
			return access_to_depts[access_key]
	return null

/datum/computer_file/program/department_order/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return .

	var/mob/living/orderer = ui.user
	if(!istype(orderer))
		return .

	if(action == "link")
		if(!isnull(linked_department))
			return TRUE

		var/new_dept_type = find_department_to_link(computer.computer_id_slot)
		if(isnull(new_dept_type))
			computer.physical.balloon_alert(orderer, "no department found!")
			playsound(computer, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
		else
			computer.physical.balloon_alert(orderer, "linked")
			playsound(computer, 'sound/machines/ping.ogg', 30, TRUE)
			set_linked_department(new_dept_type)
		return TRUE

	if(isnull(linked_department))
		return TRUE

	var/obj/item/card/id/id_card = computer.computer_id_slot || orderer.get_idcard(hand_first = TRUE)
	var/list/id_card_access = id_card?.GetAccess() || list()

	if(length(use_access & id_card_access) <= 0)
		computer.physical.balloon_alert(orderer, "access denied!")
		playsound(computer, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
		return TRUE

	if(action == "override_order")
		if(isnull(department_order) || !(department_order in SSshuttle.shopping_list))
			return TRUE
		if(length(download_access & id_card_access) <= 0)
			computer.physical.balloon_alert(orderer, "requires head of staff access!")
			playsound(computer, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
			return TRUE

		department_cooldowns[linked_department] = 0
		SSshuttle.shopping_list -= department_order
		department_order = null
		UnregisterSignal(SSshuttle, COMSIG_SUPPLY_SHUTTLE_BUY)
		return TRUE

	if(department_cooldowns[linked_department] > world.time)
		return TRUE

	submit_order(orderer, params["id"])
	return TRUE

/// Submits the order with the specified supply pack id as the specified orderer
/datum/computer_file/program/department_order/proc/submit_order(mob/living/orderer, id)
	id = text2path(id) || id

	var/datum/job_department/linked_department_real = SSjob.get_department_type(linked_department)
	var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
	if(isnull(pack))
		computer.physical.say("Something went wrong!")
		CRASH("requested supply pack id \"[id]\" not found!")
	if(!can_see_pack(pack) || !(pack.group in linked_department_real.associated_cargo_groups))
		return
	var/name = "*None Provided*"
	var/rank = "*None Provided*"
	var/ckey = orderer.ckey
	if(ishuman(orderer))
		var/mob/living/carbon/human/human_orderer = orderer
		name = human_orderer.get_authentification_name()
		rank = human_orderer.get_assignment(hand_first = TRUE)
	else if(HAS_SILICON_ACCESS(orderer))
		name = orderer.real_name
		rank = "Silicon"
	var/already_signalled = !!department_order
	var/chosen_delivery_area
	for(var/delivery_area_type in linked_department_real.department_delivery_areas)
		if(GLOB.areas_by_type[delivery_area_type])
			chosen_delivery_area = delivery_area_type
			break

	if(SSshuttle.supply.get_order_count(pack) == OVER_ORDER_LIMIT)
		playsound(computer, 'sound/machines/buzz/buzz-sigh.ogg', 50, FALSE)
		computer.physical.say("ERROR: No more then [CARGO_MAX_ORDER] of any pack may be ordered at once!")
		return

	department_order = new(
		pack = pack,
		orderer = name,
		orderer_rank = rank,
		orderer_ckey = ckey,
		reason = "Departmental Order",
		paying_account = null,
		department_destination = chosen_delivery_area,
		coupon = null,
		manifest_can_fail = FALSE,
	)
	SSshuttle.shopping_list += department_order
	if(!already_signalled)
		RegisterSignal(SSshuttle, COMSIG_SUPPLY_SHUTTLE_BUY, PROC_REF(finalize_department_order))
	computer.physical.say("Order processed. Cargo will deliver the crate when it comes in on their shuttle. NOTICE: Heads of staff may override the order.")
	calculate_cooldown(pack.cost)

/// Signal when the supply shuttle begins to spawn orders. We forget the current order preventing it from being overridden (since it's already past the point of no return on undoing the order)
/datum/computer_file/program/department_order/proc/finalize_department_order(datum/subsystem)
	SIGNAL_HANDLER
	if(!isnull(department_order) && (department_order in SSshuttle.shopping_list))
		department_order = null
	UnregisterSignal(subsystem, COMSIG_SUPPLY_SHUTTLE_BUY)

/// Calculates the cooldown it will take for this department's free order, based on its credit cost
/datum/computer_file/program/department_order/proc/calculate_cooldown(credits)
	var/time_y = DEPARTMENTAL_ORDER_COOLDOWN_COEFFICIENT * (log(10, credits) ** DEPARTMENTAL_ORDER_COOLDOWN_EXPONENT) * (1 SECONDS)
	department_cooldowns[linked_department] = world.time + time_y

/datum/computer_file/program/department_order/process_tick(seconds_per_tick)
	if(!check_cooldown() || alert_silenced || !alert_able)
		return
	radio?.talk_into(computer, "Order cooldown has expired! A new order may now be placed!", radio_channel)
	computer.alert_call(src, "Order cooldown expired!", 'sound/machines/ping.ogg')

/// Checks if the cooldown is up and resets it if so.
/datum/computer_file/program/department_order/proc/check_cooldown()
	if(department_cooldowns[linked_department] > 0 && department_cooldowns[linked_department] <= world.time)
		department_cooldowns[linked_department] = 0
		return TRUE
	return FALSE
