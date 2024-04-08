/obj/machinery/slime_extract_requestor
	name = "extract requestor pad"
	desc = "A tall device with a hole for retrieving slime extracts."
	icon = 'monkestation/code/modules/slimecore/icons/machinery.dmi'
	icon_state = "civilian_pad"
	base_icon_state = "civilian_pad"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000
	circuit = /obj/item/circuitboard/machine/slime_extract_requestor
	var/obj/machinery/computer/slime_market/console
	var/list/current_requests = list()

	var/static/list/extracts = list()
	var/static/list/name_to_path = list()


/obj/machinery/slime_extract_requestor/Initialize(mapload)
	. = ..()
	if(GLOB.default_slime_market)
		console = GLOB.default_slime_market
		console.request_pad = src

	if(!length(extracts))
		for(var/obj/item/slime_extract/extract as anything in subtypesof(/obj/item/slime_extract))
			var/obj/item/slime_extract/new_extract = new extract
			extracts |= list("[new_extract.name]" = image(icon = new_extract.icon, icon_state = new_extract.icon_state))
			name_to_path |= list("[new_extract.name]" = new_extract.type)
			qdel(new_extract)

/obj/machinery/slime_extract_requestor/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!console)
		to_chat(user, span_warning("[src] does not have a console linked to it!"))
		return
	var/obj/item/card/id/card = user.get_idcard(TRUE)
	if(!card)
		to_chat(user, span_warning("Unable to locate an ID card!"))
		return

	if(check_in_requests(card))
		if(check_finished_request(card))
			return
		say("You already have an ongoing request, would you like to cancel it?")
		if(tgui_alert(user, "You already have an ongoing request, would you like to cancel it?", "[name]", list("Yes", "No")) == "Yes")
			cancel_request(card)
		return
	create_request(user, card)

/obj/machinery/slime_extract_requestor/multitool_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return
	if(!multitool_check_buffer(user, tool))
		return
	var/obj/item/multitool/multitool = tool
	multitool.buffer = src
	to_chat(user, span_notice("You save the data in the [multitool.name]'s buffer."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/slime_extract_requestor/proc/check_in_requests(obj/item/card/id/card)
	for(var/datum/extract_request_data/listed_request as anything in current_requests)
		if(!(listed_request.host_card == card))
			continue
		return TRUE
	return FALSE

/obj/machinery/slime_extract_requestor/proc/check_finished_request(obj/item/card/id/card)
	for(var/datum/extract_request_data/listed_request as anything in current_requests)
		if(!(listed_request.host_card == card))
			continue
		if(listed_request.ready_for_pickup)
			var/obj/item/storage/box/box = new(loc)
			for(var/i in 1 to listed_request.extracts_needed)
				new listed_request.extract_path(box)
			current_requests -= listed_request
			listed_request.finish_request(console)
			qdel(listed_request)
			return TRUE
	return FALSE

/obj/machinery/slime_extract_requestor/proc/cancel_request(obj/item/card/id/card)
	for(var/datum/extract_request_data/listed_request as anything in current_requests)
		if(!(listed_request.host_card == card))
			continue
		current_requests -= listed_request
		listed_request.cancel_request_early(console)
		qdel(listed_request)

/obj/machinery/slime_extract_requestor/proc/create_request(mob/user, obj/item/card/id/card)
	var/choice = show_radial_menu(user, src, extracts, require_near = TRUE, tooltips = TRUE)

	if(!(choice in name_to_path))
		return

	var/number_choice = tgui_input_number(user, "How many extracts do you want?", "[name]", default = 1, min_value = 1, round_value = 1, max_value = 15)
	if(!number_choice)
		return

	var/payout = tgui_input_number(user, "How much will the payout be for this request?", "[name]", default = 0, min_value = 0, round_value = 1, max_value = card.registered_account.account_balance)
	if(payout)
		card.registered_account.adjust_money(-payout, "Slime Extract Request")

	var/datum/extract_request_data/request = new

	request.host_card = card
	request.extract_path = name_to_path[choice]
	request.extracts_needed = number_choice
	request.payout = payout
	request.linked_console = console
	request.request_name = "[card.registered_name]'s [choice] request ([number_choice])"
	request.on_creation()

	var/obj/item/slime_extract/request_extract = name_to_path[choice]
	request.radial_data = list("[request.request_name]" = image(icon = initial(request_extract.icon), icon_state = initial(request_extract.icon_state)))

	current_requests += request
	console.say("A new request has been made.")

/datum/extract_request_data
	///the name of our request
	var/request_name
	///our linked_console purely for when something is early deleted
	var/obj/machinery/computer/slime_market/linked_console
	///the card from which the request was made
	var/obj/item/card/id/host_card
	///the extract we spawn
	var/extract_path
	///the amount of extracts we need
	var/extracts_needed = 1
	///the payoff sent to the scientist that finished the bounty
	var/payout = 0
	//radial information
	var/list/radial_data = list()
	///amount of extracts given
	var/extracts_given = 0
	///finished request
	var/ready_for_pickup = FALSE

/datum/extract_request_data/proc/on_creation()
	RegisterSignal(host_card, COMSIG_QDELETING, PROC_REF(end_request_qdeleted))

/datum/extract_request_data/Destroy(force, ...)
	UnregisterSignal(host_card, COMSIG_QDELETING)
	host_card = null
	linked_console = null
	QDEL_LIST(radial_data)
	. = ..()

/datum/extract_request_data/proc/end_request_qdeleted()
	SIGNAL_HANDLER

	linked_console.say("[host_card.registered_name]'s request has been cancelled.")
	linked_console.return_extracts(extract_path, extracts_given)
	linked_console.stored_credits += payout * 0.5
	qdel(src)

/datum/extract_request_data/proc/cancel_request_early(obj/machinery/computer/slime_market/console)
	console.say("[host_card.registered_name]'s request has been cancelled.")
	console.return_extracts(extract_path, extracts_given)
	if(payout)
		host_card.registered_account.adjust_money(payout * 0.5, "Slime Extract Request Cancelled Early")
	console.stored_credits += payout * 0.5
	qdel(src)

/datum/extract_request_data/proc/finish_request(obj/machinery/computer/slime_market/console)
	console.say("[host_card.registered_name]'s request has been collected.")
	console.stored_credits += payout
	SSresearch.xenobio_points += payout * 3
	qdel(src)


/datum/extract_request_data/proc/add_extract()
	extracts_given++
	if(extracts_given >= extracts_needed)
		ready_for_pickup = TRUE
		declare_ready()

/datum/extract_request_data/proc/declare_ready()
	host_card.say("Extract Request has been completed, please come collect your request.")
